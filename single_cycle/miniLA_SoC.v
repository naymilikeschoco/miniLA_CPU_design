`timescale 1ns / 1ps

//`include "defines.vh"

module miniLA_SoC (
    input  wire         fpga_rstn,   // Low active
    input  wire         fpga_clk,

    input  wire [15:0]  sw,
    input  wire [ 4:0]  button,
    output wire [ 7:0]  dig_en,
    output wire         DN_A0, DN_A1,
    output wire         DN_B0, DN_B1,
    output wire         DN_C0, DN_C1,
    output wire         DN_D0, DN_D1,
    output wire         DN_E0, DN_E1,
    output wire         DN_F0, DN_F1,
    output wire         DN_G0, DN_G1,
    output wire         DN_DP0, DN_DP1,
    output wire [15:0]  led
    
    `ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst, // 褰撳墠鏃堕挓鍛ㄦ湡鏄惁鏈夋寚浠ゅ啓鍥? (瀵瑰崟鍛ㄦ湡CPU锛屽彲鍦ㄥ浣嶅悗鎭掔疆1)
    output wire [31:0]  debug_wb_pc,        // 褰撳墠鍐欏洖鐨勬寚浠ょ殑PC (鑻b_have_inst=0锛屾椤瑰彲涓轰换鎰忓??)
    output              debug_wb_ena,       // 鎸囦护鍐欏洖鏃讹紝瀵勫瓨鍣ㄥ爢鐨勫啓浣胯兘 (鑻b_have_inst=0锛屾椤瑰彲涓轰换鎰忓??)
    output wire [ 4:0]  debug_wb_reg,       // 鎸囦护鍐欏洖鏃讹紝鍐欏叆鐨勫瘎瀛樺櫒鍙? (鑻b_ena鎴杦b_have_inst=0锛屾椤瑰彲涓轰换鎰忓??)
    output wire [31:0]  debug_wb_value      // 鎸囦护鍐欏洖鏃讹紝鍐欏叆瀵勫瓨鍣ㄧ殑鍊? (鑻b_ena鎴杦b_have_inst=0锛屾椤瑰彲涓轰换鎰忓??)
    `endif
);

    wire        pll_lock;
    wire        pll_clk;
    wire        cpu_clk;

    // Interface between CPU and IROM
    wire [13:0] inst_addr;
    wire [31:0] inst;

    // Interface between CPU and Bridge
    wire [31:0] Bus_rdata;
    wire [31:0] Bus_addr;
    wire        Bus_we;
    wire [31:0] Bus_wdata;
    
    // Interface between bridge and DRAM

    wire         clk_bridge2dram;
    wire [31:0]  addr_bridge2dram;
    wire [31:0]  rdata_dram2bridge;
    wire         we_bridge2dram;
    wire [31:0]  wdata_bridge2dram;
  
    
    // Interface between bridge and peripherals
    // TODO: 鍦ㄦ瀹氫箟鎬荤嚎妗ヤ笌澶栬I/O鎺ュ彛鐢佃矾妯″潡鐨勮繛鎺ヤ俊鍙?
    // Interface to 7-seg digital LEDs?
    wire         rst_2_dig;
    wire         clk_2_dig;
    wire         we_2_dig;
    wire [31:0]  wdata_2_dig;

    // Interface to LEDs
    wire         rst_2_led;
    wire         clk_2_led;
    wire         we_2_led;
    wire [15:0]  wdata_2_led;

    // Interface to switches
//    wire         rst_2_sw;
//    wire         clk_2_sw;
    wire [31:0]  rdata_4_sw;

    // Interface to Timer
    wire         rst_2_tim;
    wire         clk_2_tim;
    wire         wen_2_tim;
    wire [31:0]  wdata_2_tim;
    wire [31:0]  addr_2_tim;
    wire [31:0]  rdata_4_tim;
    
    // Interface to buttons
    wire         rst_2_btn;
    wire         clk_2_btn;
    wire [4:0]   rdata_4_btn;
    //

    assign DN_A1 = DN_A0;
    assign DN_B1 = DN_B0;
    assign DN_C1 = DN_C0;
    assign DN_D1 = DN_D0;
    assign DN_E1 = DN_E0;
    assign DN_F1 = DN_F0;
    assign DN_G1 = DN_G0;
    assign DN_DP1 = DN_DP0;
    
    // 下板时，使用PLL分频后的时钟
    assign cpu_clk = pll_clk & pll_lock;
    cpuclk Clkgen (
        // .resetn     (!fpga_rst),
        .clk_in1    (fpga_clk),
        .clk_out1   (pll_clk),
        .locked     (pll_lock)
    );

    
    myCPU Core_cpu (
        .cpu_rst            (!fpga_rstn),
        .cpu_clk            (cpu_clk),

        // Interface to IROM
        .inst_addr          (inst_addr),
        .inst               (inst),

        // Interface to Bridge
        .Bus_addr           (Bus_addr),
        .Bus_rdata          (Bus_rdata),
        .Bus_we             (Bus_we),
        .Bus_wdata          (Bus_wdata)//,
        
        // Debug Interface
//        .debug_wb_have_inst (debug_wb_have_inst),
//        .debug_wb_pc        (debug_wb_pc),
//        .debug_wb_ena       (debug_wb_ena),
//        .debug_wb_reg       (debug_wb_reg),
//        .debug_wb_value     (debug_wb_value)

    );
    
    // 64KB IROM
    IROM my_IROM (
        .a      (inst_addr),
        .spo    (inst)
    );
    
    Bridge Bridge (       
        // Interface to CPU
        .rst_from_cpu       (!fpga_rstn),
        .clk_from_cpu       (cpu_clk),
        .addr_from_cpu      (Bus_addr),
        .we_from_cpu        (Bus_we),
        .wdata_from_cpu     (Bus_wdata),
        .rdata_to_cpu       (Bus_rdata),
        
        // Interface to DRAM
        .clk_to_dram        (clk_bridge2dram),
        .addr_to_dram       (addr_bridge2dram),
        .rdata_from_dram    (rdata_dram2bridge),
        .we_to_dram         (we_bridge2dram),
        .wdata_to_dram      (wdata_bridge2dram),
        
        // Interface to 7-seg digital LEDs
        .rst_to_dig         (rst_2_dig),
        .clk_to_dig         (clk_2_dig),

        .we_to_dig          (we_2_dig),
        .wdata_to_dig       (wdata_2_dig),

        // Interface to LEDs
        .rst_to_led         (rst_2_led),
        .clk_to_led         (clk_2_led),
        .we_to_led          (we_2_led),
        .wdata_to_led       (wdata_2_led),

        // Interface to switches
//        .rst_to_sw          (rst_2_sw),
//        .clk_to_sw          (clk_2_sw),
        .rdata_from_sw      (rdata_4_sw),

        // Interface to timer
        .rst_to_tim         (rst_2_tim),
        .clk_to_tim         (clk_2_tim),
        .wen_to_tim         (wen_2_tim),
        .wdata_to_tim       (wdata_2_tim),
        .addr_to_tim        (addr_2_tim),
        .rdata_from_tim     (rdata_4_tim),
        
        // Interface to buttons
        .rst_to_btn         (rst_2_btn),
        .clk_to_btn         (clk_2_btn),
        .rdata_from_btn     (rdata_4_btn)
    );

    // DRAM
    DRAM my_DRAM (
        .clk    (clk_bridge2dram),
        .a      (addr_bridge2dram[15:2]),
        .spo    (rdata_dram2bridge),
        .we     (we_bridge2dram),
        .d      (wdata_bridge2dram)
    );
    
    // TODO: 鍦ㄦ瀹炰緥鍖栦綘鐨勫璁綢/O鎺ュ彛鐢佃矾妯″潡
    my_7_LEDS cpu_7seg_led(
        .rst        (rst_2_dig),
        .clk        (clk_2_dig),
        .we         (we_2_dig),
        .wdata      (wdata_2_dig),
        .dig_en     (dig_en), 
        .seg_data   ({DN_DP0,DN_G0,DN_F0,DN_E0,DN_D0,DN_C0,DN_B0,DN_A0})
);
    
    my_LEDS cpu_led(
        .rst        (rst_2_led),
        .clk        (clk_2_led),
        .we         (we_2_led),
        .wdata      (wdata_2_led),
        .led_data   (led)
    );
    
    my_switches cpu_sw(
//        .rst        (rst_2_sw),
//        .clk        (clk_2_sw),
        .sw_input   (sw),
        .rdata      (rdata_4_sw)
    );
    
    my_timer cpu_timer(
        .rst        (rst_2_tim),
        .clk        (clk_2_tim),
        .wen        (wen_2_tim),
        .wdata      (wdata_2_tim),
        .addr       (addr_2_tim),
        .rdata      (rdata_4_tim)
    );
    
    my_buttons cpu_buttons(
        .clk        (clk_2_btn),
        .rst        (rst_2_btn),
        .btn_raw    (button),
        .btn_out    (rdata_4_btn)
    );
    
    //


endmodule
