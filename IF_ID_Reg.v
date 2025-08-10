`timescale 1ns / 1ps

module IF_ID_Reg(
    input wire cpu_clk,
    input wire cpu_rst,
    input wire pipeline_stop,
    input wire flush_if_id,
    input wire [31:0] PC_pc,
    input wire [31:0] inst,
    output reg [31:0] IF_ID_pc,
    output reg [31:0] IF_ID_inst//,
//    output reg        IF_ID_have_inst
    );
    
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst) begin
            IF_ID_pc   <= 32'h0;
            IF_ID_inst <= 32'h0;
        end else if(flush_if_id)begin
            IF_ID_pc   <= 32'h0;
            IF_ID_inst <= 32'h0;
        end else if (pipeline_stop) begin
            IF_ID_pc   <= IF_ID_pc;
            IF_ID_inst <= IF_ID_inst;
        end else begin
            IF_ID_pc   <= PC_pc;
            IF_ID_inst <= inst;
        end
    end

    
//    always @(posedge cpu_clk or posedge cpu_rst) begin
//        if (cpu_rst)                    IF_ID_have_inst <= 0;
//        else if (flush_if_id)                IF_ID_have_inst <= 0;
//        else if (pipeline_stop)         IF_ID_have_inst <= IF_ID_have_inst;
//        else                            IF_ID_have_inst <= (inst != 32'h00000000);
//    end
    
endmodule
