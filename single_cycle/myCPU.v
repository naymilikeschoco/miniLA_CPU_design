`timescale 1ns / 1ps

`include "defines.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // Interface to IROM
`ifdef RUN_TRACE
    output wire [15:0]  inst_addr,
`else
    output wire [13:0]  inst_addr,
`endif
    input  wire [31:0]  inst,
    
    // Interface to Bridge
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire         Bus_we,
    output reg  [31:0]  Bus_wdata

//`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output wire         debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
//`endif
);

    // TODO: 完成你自己的单周期CPU设计
    
    wire [31:0] PC_pc;
    wire [31:0] NPC_npc;
    wire [31:0] NPC_pcb;
//    wire [31:0] IROM_inst;
    wire [31:0] RF_rD1;
    wire [31:0] RF_rD2;
    wire [31:0] SEXT_ext1;
    wire [31:0] SEXT_ext2;
    wire [31:0] ALU_C;
    wire        ALU_f;
//    wire [31:0] DRAM_rdo;

    wire       Ctrl_pc_sel;
    wire [1:0] Ctrl_npc_op;
    wire       Ctrl_rd1_op;
    wire       Ctrl_rf_we;
    wire [2:0] Ctrl_rf_wd_sel;
    wire [2:0] Ctrl_sext_op;
    wire [3:0] Ctrl_alu_op;
    wire [1:0] Ctrl_A_sel;
    wire       Ctrl_off_sel;
    wire [1:0] Ctrl_ram_op;

    my_Ctrl cpu_Ctrl (
        .inst       (inst[31:15]), //input wire [16:0]
        .pc_sel     (Ctrl_pc_sel),
        .npc_op     (Ctrl_npc_op),
        .rd1_op     (Ctrl_rd1_op),
        .rf_we      (Ctrl_rf_we),
        .rf_wd_sel  (Ctrl_rf_wd_sel),
        .sext_op    (Ctrl_sext_op),
        .alu_op     (Ctrl_alu_op),
        .A_sel      (Ctrl_A_sel),
        .off_sel    (Ctrl_off_sel),
        .ram_we     (Bus_we),
        .ram_op     (Ctrl_ram_op)
    );

    assign inst_addr = PC_pc[15:2];

    wire [31:0] PC_din;
    assign PC_din = (Ctrl_pc_sel)? ALU_C : NPC_npc;
    
    wire [31:0] NPC_offset;
    assign NPC_offset = (Ctrl_off_sel)? ALU_C : SEXT_ext1;
    
    reg [31:0] RF_wD;
    my_wd_mux cpu_wd_mux(
        .rf_wd_sel       (Ctrl_rf_wd_sel),
        .addr            (Bus_addr[1:0]),       //用于半字和字节载入
        .ALU_C           (ALU_C),
        .ALU_f           (ALU_f),
        .SEXT_ext2       (SEXT_ext2),
        .Bus_rdata       (Bus_rdata),
        .NPC_pcb         (NPC_pcb),
        .RF_wD           (RF_wD)
    );

    reg [31:0] ALU_A;
    a_sel_mux  cpu_A_mux(
        .A_sel       (Ctrl_A_sel),
        .RF_rD1      (RF_rD1),
        .SEXT_ext1   (SEXT_ext1),
        .inst_20     (inst[24:5]),
        .ALU_A       (ALU_A)
    );
    
    my_PC cpu_PC (
        .rst        (cpu_rst),              // input  wire
        .clk        (cpu_clk),              // input  wire
        .din        (PC_din),               // input  wire [31:0]
        .pc         (PC_pc)                 // output reg  [31:0]
    );

    my_NPC cpu_NPC (
        .offset     (NPC_offset),
        .br         (ALU_f),
        .npc_op     (Ctrl_npc_op),
        .pc         (PC_pc),
        .pcb        (NPC_pcb), //用于写回
        .npc        (NPC_npc)
    );

    my_RF cpu_RF (
        .clk        (cpu_clk),              // input  wire
        .rR1        (inst[14:10]),     // input  wire [ 4:0]
        .rR2        (inst[9:5]),       // input  wire [ 4:0]
        .wR         (inst[4:0]),       // input  wire [ 4:0]
        .rd1_op     (Ctrl_rd1_op),
        .we         (Ctrl_rf_we),           // input  wire
        .wD         (RF_wD),                // input  wire [31:0]
        .rD1        (RF_rD1),               // output reg  [31:0]
        .rD2        (RF_rD2)                // output reg  [31:0]
    );

    my_SEXT cpu_SEXT (
        .din1_ex    (inst[25:0]),
        .din2_wb    (Bus_rdata),
        .sext_op    (Ctrl_sext_op),
        .addr       (Bus_addr[1:0]),       //用于半字和字节载入
        .ext1       (SEXT_ext1),    
        .ext2       (SEXT_ext2)              // output wire [31:0]
    );

    my_ALU cpu_ALU (
        .A          (ALU_A),                // input  wire [31:0]
        .B          (RF_rD2),               // input  wire [31:0]
        .alu_op     (Ctrl_alu_op),          
        .C          (ALU_C),                // output wire [31:0]
        .f          (ALU_f)
    );

    assign Bus_addr = ALU_C;
    always @ (*) begin
        case (Ctrl_ram_op)
            `RAM_B: begin
                //wdin[7:0]
                case(Bus_addr[1:0])
                    2'b00:  Bus_wdata = {Bus_rdata[31:8], RF_rD1[7:0]};
                    2'b01:  Bus_wdata = {Bus_rdata[31:16], RF_rD1[7:0], Bus_rdata[7:0]};
                    2'b10:  Bus_wdata = {Bus_rdata[31:24], RF_rD1[7:0], Bus_rdata[15:0]};
                    2'b11:  Bus_wdata = {RF_rD1[7:0], Bus_rdata[23:0]};
                endcase
            end
            `RAM_H: begin
                //wdin[15:0]
                case(Bus_addr[1])
                    1'b0:   Bus_wdata = {Bus_rdata[31:16], RF_rD1[15:0]};
                    1'b1:   Bus_wdata = {RF_rD1[15:0], Bus_rdata[15:0]};
                endcase
            end
            `RAM_W: begin
                //wdin[31:0]
                Bus_wdata = RF_rD1;
            end
        endcase
    end
    //

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = 1;
    assign debug_wb_pc        = PC_pc;
    assign debug_wb_ena       = Ctrl_rf_we;
    assign debug_wb_reg       = inst[4:0];
    assign debug_wb_value     = RF_wD;
`endif

endmodule
