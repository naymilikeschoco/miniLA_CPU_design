`timescale 1ns / 1ps

`include "defines_pipeline.vh"

module a_sel_mux(
    input wire [1:0]   A_sel,
    input wire [31:0]  RF_rD1,
    input wire [31:0]  SEXT_ext1,
    input wire [19:0]  inst_20,   // inst[24:5]
    output reg [31:0]  ALU_A
    );
    
    always @ (*) begin
        case(A_sel)
            `A_RD1: ALU_A = RF_rD1;
            `A_SEXT1: ALU_A = SEXT_ext1;
            `A_1R: ALU_A = {12'b0, inst_20};
            default:  ALU_A = 32'b0;
        endcase
    end
    
endmodule
