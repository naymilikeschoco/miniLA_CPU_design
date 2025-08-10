`timescale 1ns / 1ps

`include "defines_pipeline.vh"

module ID_EX_Reg(
    input wire        cpu_clk,
    input wire        cpu_rst,
    input wire        Ctrl_rf_we,
    input wire [2:0]  Ctrl_rf_wd_sel,
    input wire [3:0]  Ctrl_alu_op,
    input wire [1:0]  Ctrl_A_sel,
    input wire        Ctrl_off_sel,
    input wire [2:0]  Ctrl_rd_sel,
    input wire        Ctrl_ram_we,
    input wire [1:0]  Ctrl_ram_op,
    input wire [1:0]  Ctrl_sext2_op,
    input wire        Ctrl_load,
    //input wire        IF_ID_have_inst,
//    input wire        Ctrl_hazard,
    input wire [31:0] SEXT_ext1,
    input wire [31:0] IF_ID_pc,      //PC+4
    input wire [31:0] IF_ID_inst,
    input wire [1:0]  Ctrl_npc_op,
    input wire        flush_id_ex,
    input wire        pipeline_stop,
    output reg        ID_EX_rf_we,
    output reg [2:0]  ID_EX_rf_wd_sel,
    output reg [3:0]  ID_EX_alu_op,
    output reg [1:0]  ID_EX_A_sel,
    output reg        ID_EX_off_sel,
    output reg        ID_EX_ram_we,
    output reg [1:0]  ID_EX_ram_op,
    output reg        ID_EX_load,
//    output reg        ID_EX_ctrl,
    output reg [31:0] ID_EX_ext1,
    output reg [31:0] ID_EX_pc,
    output reg [4:0]  ID_EX_wR,
    output reg [19:0] ID_EX_inst,
    output reg [1:0]  ID_EX_sext2_op,
    output reg [1:0]  ID_EX_npc_op//,
    //output reg        have_inst
    );
    
    always @(posedge cpu_clk or posedge cpu_rst) begin
       if (cpu_rst) begin
            ID_EX_rf_we     <= 0;
            ID_EX_rf_wd_sel <= 0;
            ID_EX_alu_op    <= 0;
            ID_EX_A_sel     <= 0;
            ID_EX_off_sel   <= 0;
            ID_EX_ram_we    <= 0;
            ID_EX_ram_op    <= 0;
            ID_EX_load      <= 0;
//            ID_EX_ctrl      <= 0;
            ID_EX_ext1      <= 0; 
            ID_EX_pc        <= 0;
            ID_EX_wR        <= 0;
            ID_EX_inst      <= 0;
            ID_EX_sext2_op  <= 0;
            ID_EX_npc_op    <= 0;
        end 
        else if(flush_id_ex || pipeline_stop)begin
            ID_EX_rf_we     <= 0;
            ID_EX_rf_wd_sel <= 0;
            ID_EX_alu_op    <= 0;
            ID_EX_A_sel     <= 0;
            ID_EX_off_sel   <= 0;
            ID_EX_ram_we    <= 0;
            ID_EX_ram_op    <= 0;
            ID_EX_load      <= 0;
            ID_EX_ext1      <= 0; 
            ID_EX_pc        <= 0;
            ID_EX_wR        <= 0;
            ID_EX_inst      <= 0;
            ID_EX_sext2_op  <= 0;
            ID_EX_npc_op    <= 0;
        end        
        else begin
            ID_EX_rf_we     <= Ctrl_rf_we;
            ID_EX_rf_wd_sel <= Ctrl_rf_wd_sel;
            ID_EX_alu_op    <= Ctrl_alu_op;
            ID_EX_A_sel     <= Ctrl_A_sel;
            ID_EX_off_sel   <= Ctrl_off_sel;
            ID_EX_ram_we    <= Ctrl_ram_we;
            ID_EX_ram_op    <= Ctrl_ram_op;
            ID_EX_load      <= Ctrl_load;
//            ID_EX_ctrl      <= Ctrl_hazard;
            ID_EX_ext1      <= SEXT_ext1;
            ID_EX_pc        <= IF_ID_pc;
            ID_EX_wR        <= (Ctrl_rd_sel == `rD_1)? 5'b00001 : IF_ID_inst[4:0];
            ID_EX_inst      <= IF_ID_inst[24:5];
            ID_EX_sext2_op  <= Ctrl_sext2_op;
            ID_EX_npc_op    <= Ctrl_npc_op;
        end
    end
    
//    always @(posedge cpu_clk or posedge cpu_rst) begin
//        if (cpu_rst) begin
//            have_inst <= 0;
//        end
//        else if(flush_id_ex || pipeline_stop)begin
//            have_inst <= 0;
//        end 
//        else begin
//            have_inst <= IF_ID_have_inst;
//        end
//    end
    
endmodule
