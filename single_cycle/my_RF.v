`timescale 1ns / 1ps

module my_RF(
    input  wire         clk,
    input  wire [4:0]   rR1, //[14:10]
    input  wire [4:0]   rR2, //[9:5]
    input  wire [4:0]   wR,  //[4:0]
    input  wire         rd1_op,
    input  wire         we,
    input  wire [31:0]  wD,
    output wire [31:0]  rD1,
    output wire [31:0]  rD2
    );
    
    parameter RD1_3R = 0;
    parameter RD1_2R = 1; 
    
    reg [31:0] Regs[4:0];
    //写时序逻辑
    always @ (posedge clk) begin
        Regs[0] <= 0; //$zero always == 0
        if(we) begin //写使能
            Regs[wR] <= wD;
        end
    end
    
    //读组合逻辑
    assign rD1 = (rd1_op == RD1_3R)? Regs[rR1]: Regs[wR];
    assign rD2 = Regs[rR2];
    
endmodule
