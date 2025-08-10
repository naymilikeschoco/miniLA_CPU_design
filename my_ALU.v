`timescale 1ns / 1ps

`include "defines_pipeline.vh"

module my_ALU(
    input  wire [31:0]  A,
    input  wire [31:0]  B,
    input  wire [3:0]   alu_op,
    output reg  [31:0]  C,
    output reg          f 
    );
    
    // 计算标志位f
    always @(*) begin
        case (alu_op)
            `OP_BEQ:    f = (B == A);
            `OP_BNE:    f = (B != A);
            `OP_BLT:    f = ($signed(B) < $signed(A));
            `OP_BLTU:   f = (B < A);
            `OP_BGE:    f = ($signed(B) >= $signed(A));
            `OP_BGEU:   f = (B >= A);
            default:   f = 1'b0;
        endcase
    end
    
    always @(*) begin
        case (alu_op)
            `OP_ADD:    C = A + B;
            `OP_SUB:    C = B + (~A) + 1;
            `OP_AND:    C = A & B;
            `OP_OR:     C = A | B;
            `OP_XOR:    C = A ^ B;
            `OP_SLL:    C = B << A[4:0];
            `OP_SRL:    C = B >> A[4:0];
            `OP_SRA:    C = $signed(B) >>> A[4:0];  // 算术右移
            `OP_SLL_12: C = A << 4'hc;  // 固定移位12位
            `OP_PCADDU: C = (A << 4'hc) + B;  // 固定移位12位
            default:   C = 32'b00000000;
        endcase
    end

endmodule
