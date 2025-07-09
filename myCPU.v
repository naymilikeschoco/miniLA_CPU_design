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
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

    // TODO: 完成你自己的单周期CPU设计
    
    wire [31:0] PC_pc;
    wire [31:0] NPC_npc;
    wire [31:0] NPC_pcb;
    wire [31:0] IROM_inst;
    wire [31:0] RF_rD1;
    wire [31:0] RF_rD2;
    wire [31:0] SEXT_ext1;
    wire [31:0] SEXT_ext2;
    wire [31:0] ALU_C;
    wire        ALU_f;
    wire [31:0] DRAM_rdo;

    wire       Ctrl_pc_sel;
    wire [1:0] Ctrl_npc_op;
    wire       Ctrl_rd1_op;
    wire       Ctrl_rf_we;
    wire [2:0] Ctrl_rf_wd_sel;
    wire [2:0] Ctrl_sext_op;
    wire [3:0] Ctrl_alu_op;
    wire [1:0] Ctrl_A_sel;
    wire       Ctrl_off_sel;
    wire       Ctrl_ram_we;
    wire [1:0] Ctrl_ram_op;

    my_Ctrl cpu_Ctrl (
        .inst       (IROM_inst[31:15]), //input wire [16:0]
        .pc_sel     (Ctrl_pc_sel),
        .npc_op     (Ctrl_npc_op),
        .rd1_op     (Ctrl_rd1_op),
        .rf_we      (Ctrl_rf_we),
        .rf_wd_sel  (Ctrl_rf_wd_sel),
        .sext_op    (Ctrl_sext_op),
        .alu_op     (Ctrl_alu_op),
        .A_sel      (Ctrl_A_sel),
        .off_sel    (Ctrl_off_sel),
        .ram_we     (Ctrl_ram_we),
        .ram_op     (Ctrl_ram_op)
    );

    wire [31:0] PC_din;
    assign PC_din = (Ctrl_pc_sel)? ALU_C : NPC_npc;
    my_PC cpu_PC (
        .rst        (cpu_rst),              // input  wire
        .clk        (cpu_clk),              // input  wire
        .din        (PC_din),               // input  wire [31:0]
        .pc         (PC_pc)                 // output reg  [31:0]
    );

    wire [31:0] NPC_offset;
    assign NPC_offset = (Ctrl_off_sel)? ALU_C : SEXT_ext1;
    my_NPC cpu_NPC (
        .offset     (NPC_offset),
        .br         (ALU_f),
        .npc_op     (Ctrl_npc_op),
        .pc         (PC_pc),
        .pcb        (NPC_pcb), //用于写回
        .npc        (NPC_npc)
    );

    my_IROM cpu_IROM (
        .adr        (PC_pc),                // input  wire [31:0]
        .inst       (IROM_inst)             // output wire [31:0]
    );

    reg [31:0] RF_wD;
    parameter WD_C = 0;
    parameter WD_f = 1;
    parameter WD_SEXT = 2;
    parameter WD_RDOB = 3;
    parameter WD_RDOH = 4;
    parameter WD_RDO  = 5;
    parameter WD_PCB = 6;
    always @ (*) begin
        case(Ctrl_rf_wd_sel)
            WD_C: RF_wD <= ALU_C;
            WD_f: RF_wD <= ALU_f;
            WD_SEXT: RF_wD <= SEXT_ext2;
            WD_RDOB: RF_wD <= DRAM_rdo[7:0];
            WD_RDOH: RF_wD <= DRAM_rdo[15:0];
            WD_RDO: RF_wD <= DRAM_rdo;
            WD_PCB: RF_wD <= NPC_pcb;
        endcase
    end
    my_RF cpu_RF (
        .clk        (cpu_clk),              // input  wire
        .rR1        (IROM_inst[14:10]),     // input  wire [ 4:0]
        .rR2        (IROM_inst[9:5]),       // input  wire [ 4:0]
        .wR         (IROM_inst[4:0]),       // input  wire [ 4:0]
        .rd1_op     (Ctrl_rd1_op),
        .we         (Ctrl_rf_we),           // input  wire
        .wD         (RF_wD),                 // input  wire [31:0]
        .rD1        (RF_rD1),               // output reg  [31:0]
        .rD2        (RF_rD2)               // output reg  [31:0]
    );

    my_SEXT cpu_SEXT (
        .din1_ex    (IROM_inst[25:10]),
        .din2_wb    (DRAM_rdo[15:0]),
        .sext_op    (Ctrl_sext_op),
        .ext1       (SEXT_ext1),    
        .ext2       (SEXT_ext2)              // output wire [31:0]
    );

    reg [31:0] ALU_A;
    parameter A_RD1 = 0;
    parameter A_SEXT1 = 1;
    parameter A_1R = 2;
    always @ (*) begin
        case(Ctrl_A_sel)
            A_RD1: ALU_A <= RF_rD1;
            A_SEXT1: ALU_A <= SEXT_ext1;
            A_1R: ALU_A <= IROM_inst[24:5];
        endcase
    end
    my_ALU cpu_ALU (
        .A          (ALU_A),                // input  wire [31:0]
        .B          (RF_rD2),               // input  wire [31:0]
        .alu_op     (Ctrl_alu_op),          
        .C          (ALU_C),                // output wire [31:0]
        .f          (ALU_f)
    );

    my_DRAM cpu_DRAM (
        .clk        (cpu_clk),              // input  wire
        .dram_op    (Ctrl_ram_op),
        .addr       (ALU_C),                // input  wire [31:0]
        .we         (Ctrl_ram_we),          // input  wire
        .wdin       (RF_rD1),               // input  wire [31:0]
        .rdo        (DRAM_rdo)
    );

    //

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = /* TODO */;
    assign debug_wb_pc        = /* TODO */;
    assign debug_wb_ena       = /* TODO */;
    assign debug_wb_reg       = /* TODO */;
    assign debug_wb_value     = /* TODO */;
`endif

endmodule
