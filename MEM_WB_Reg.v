`timescale 1ns / 1ps

module MEM_WB_Reg(
    input wire        cpu_clk,
    input wire        cpu_rst,
    // Control signals from EX_MEM stage
    input wire        EX_MEM_rf_we,
    input wire [1:0]  EX_MEM_sext2_op,
//    input wire        EX_MEM_have_inst,
    // Data from EX_MEM stage
    input wire [31:0] EX_MEM_pc,
    input wire [31:0] EX_MEM_alu_c,
    input wire        EX_MEM_alu_f,
    input wire [4:0]  EX_MEM_wR,
    input wire [2:0]  EX_MEM_rf_wd_sel,
    input wire [31:0] Bus_rdata,
    input wire [31:0] Bus_addr,
    // Data from memory/writeback stage
//    input wire [31:0] WB_RD,
    // Output registers
    output reg        MEM_WB_rf_we,
    output reg [4:0]  MEM_WB_wR,
    output reg [31:0] MEM_WB_pc,
    output reg [31:0] MEM_WB_alu_c,
    output reg        MEM_WB_alu_f,
//    output reg [31:0] WB_RF_wD,
    output reg [1:0]  MEM_WB_sext2_op,
//    output reg        MEM_WB_have_inst,
    output reg [31:0] MEM_WB_rdata,
    output reg [31:0] MEM_WB_raddr,
    output reg [2:0]  MEM_WB_rf_wd_sel
);

    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst) begin
            MEM_WB_rf_we       <= 0;
            MEM_WB_wR          <= 0;
            MEM_WB_pc          <= 0;
            MEM_WB_alu_c       <= 0;
            MEM_WB_alu_f       <= 0;
//            WB_RF_wD           <= 0;
            MEM_WB_sext2_op    <= 0;
            MEM_WB_rdata       <= 0;
            MEM_WB_raddr       <= 0;
            MEM_WB_rf_wd_sel   <= 0;
        end            
        else begin
            MEM_WB_rf_we       <= EX_MEM_rf_we;
            MEM_WB_wR          <= EX_MEM_wR;
            MEM_WB_pc          <= EX_MEM_pc;
            MEM_WB_alu_c       <= EX_MEM_alu_c;
            MEM_WB_alu_f       <= EX_MEM_alu_f;
//            WB_RF_wD           <= WB_RD;
            MEM_WB_sext2_op    <= EX_MEM_sext2_op;
            MEM_WB_rdata       <= Bus_rdata;
            MEM_WB_raddr       <= Bus_addr; 
            MEM_WB_rf_wd_sel   <= EX_MEM_rf_wd_sel;
        end
    end

//    always @(posedge cpu_clk or posedge cpu_rst) begin
//        if (cpu_rst) begin
//            MEM_WB_have_inst   <= 0;
//        end
//        else begin
//            MEM_WB_have_inst   <= EX_MEM_have_inst;
//        end
//    end

endmodule