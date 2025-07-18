`timescale 1ns / 1ps

`include "defines.vh"

module my_RF(
    input  wire          clk,
    input  wire [4:0]    rR1,  // [14:10]
    input  wire [4:0]    rR2,  // [9:5]
    input  wire [4:0]    wR,   // [4:0]
    input  wire [1:0]    rf_op,
    input  wire          we,
    input  wire [31:0]   wD,
    output wire  [31:0]  rD1,
    output wire  [31:0]  rD2
);
     
    reg [31:0] Regs[31:0];

    always @(posedge clk) begin
        if (we) begin
            if(rf_op == `WR_1)  Regs[1] <= wD;
            else if(wR != 5'b00000)  Regs[wR] <= wD;
        end
    end
    
    assign rD1 = ((rR1 | wR) == 5'b0) ? 32'b0 : ((rf_op == `RD1_3R)? Regs[rR1] : Regs[wR]);
    assign rD2 = (rR2 == 5'b0) ? 32'b0 : Regs[rR2];

    
endmodule
