`timescale 1ns / 1ps

module my_ALU(
    input  wire [31:0]  A,
    input  wire [31:0]  B,
    input  wire [3:0]   alu_op,
    output reg [31:0]   C,
    output wire         f 
    );
    
    parameter OP_ADD = 0;
    parameter OP_SUB = 1;
    parameter OP_AND = 2;
    parameter OP_OR  = 3;
    parameter OP_XOR = 4;
    parameter OP_SLL = 5;
    parameter OP_SRL = 6;
    parameter OP_SRA = 7;
    parameter OP_SLL_12 = 8;
    parameter OP_BEQ = 9;
    parameter OP_BNE = 10;
    parameter OP_BLT = 11;
    parameter OP_BLTU = 12;
    parameter OP_BGE = 13;
    parameter OP_BGEU = 14;
    
    // 计算标志位f
    assign f = (alu_op == OP_BEQ) ? (A == B) :
               (alu_op == OP_BNE) ? (A != B) :
               (alu_op == OP_BLT) ? ($signed(A) < $signed(B)) :
               (alu_op == OP_BLTU) ? (A < B) :
               (alu_op == OP_BGE) ? ($signed(A) >= $signed(B)) :
               (alu_op == OP_BGEU) ? (A >= B) : 1'b0;
    
    always @(*) begin
        case (alu_op)
            OP_ADD:    C <= A + B;
            OP_AND:    C <= A & B;
            OP_OR:     C <= A | B;
            OP_XOR:    C <= A ^ B;
            OP_SLL:    C <= A << B;
            OP_SRL:    C <= A >> B;
            OP_SRA:    C <= A >>> B;  // 算术右移
            OP_SLL_12: C <= A << 12;  // 固定移位12位
            default:   C <= A - B;
        endcase
    end

endmodule
