`timescale 1ns / 1ps

module EX_MEM_Reg(
    input wire        cpu_clk,
    input wire        cpu_rst,
    // Control signals from ID_EX stage
    input wire        ID_EX_rf_we,
    input wire [2:0]  ID_EX_rf_wd_sel,
    input wire        ID_EX_ram_we,
    input wire [1:0]  ID_EX_ram_op,
    input wire [1:0]  ID_EX_sext2_op,
//    input wire        ID_EX_ctrl,
//    input wire        ID_EX_have_inst,
    // Data from ID_EX stage
    input wire [31:0] ID_EX_pc,
    input wire [31:0] ID_EX_rd1,
    input wire [4:0]  ID_EX_wR,
    // ALU results
    input wire [31:0] ALU_C,
    input wire [31:0] ALU_f,
    // Output registers
    output reg        EX_MEM_rf_we,
    output reg [2:0]  EX_MEM_rf_wd_sel,
    output reg        EX_MEM_ram_we,
    output reg [1:0]  EX_MEM_ram_op,
    output reg [31:0] EX_MEM_pc,
    output reg [31:0] EX_MEM_alu_c,
    output reg [31:0] EX_MEM_alu_f,
    output reg [31:0] EX_MEM_rd1,
    output reg [4:0]  EX_MEM_wR,
    output reg [1:0]  EX_MEM_sext2_op//,
//    output reg        EX_MEM_ctrl,
//    output reg        EX_MEM_have_inst
);

    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst) begin
            EX_MEM_rf_we       <= 0;
            EX_MEM_rf_wd_sel   <= 0;
            EX_MEM_ram_we      <= 0;
            EX_MEM_ram_op      <= 0;
            EX_MEM_pc          <= 0;
            EX_MEM_alu_c       <= 0;
            EX_MEM_alu_f       <= 0;
            EX_MEM_rd1         <= 0;
            EX_MEM_wR          <= 0;
            EX_MEM_sext2_op    <= 0;
//            EX_MEM_ctrl        <= 0;
        end            
        else begin
            EX_MEM_rf_we       <= ID_EX_rf_we;
            EX_MEM_rf_wd_sel   <= ID_EX_rf_wd_sel;
            EX_MEM_ram_we      <= ID_EX_ram_we;
            EX_MEM_ram_op      <= ID_EX_ram_op;
            EX_MEM_pc          <= ID_EX_pc;
            EX_MEM_alu_c       <= ALU_C;
            EX_MEM_alu_f       <= ALU_f;
            EX_MEM_rd1         <= ID_EX_rd1;
            EX_MEM_wR          <= ID_EX_wR;
            EX_MEM_sext2_op    <= ID_EX_sext2_op;
//            EX_MEM_ctrl        <= ID_EX_ctrl;
        end
    end
    
//    always @(posedge cpu_clk or posedge cpu_rst) begin
//        if (cpu_rst) begin
//            EX_MEM_have_inst <= 0;
//        end
//        else begin
//            EX_MEM_have_inst   <= ID_EX_have_inst;
//        end
//    end

endmodule