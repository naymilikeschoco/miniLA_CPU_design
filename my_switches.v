`timescale 1ns / 1ps

module my_switches(
    input  wire           rst,
    input  wire           clk,
    input  wire [15:0]    sw_input,   // 实际连接物理拨码开关的输入
    output reg [31:0]     rdata
    );
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            rdata <= 32'h00000000;
        end
        else begin
            //只读
            rdata <= {16'h0000, sw_input};
        end
    end
    
endmodule
