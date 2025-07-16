`timescale 1ns / 1ps
module my_PC(
    input  wire         rst,
    input  wire         clk,
    input  wire [31:0]  din,
    output reg [31:0]   pc
    );
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
           pc <= 32'hfffffffC;     //-4
//            pc <= 0;
        end else begin
            pc <= din;
        end
    end
   
endmodule
