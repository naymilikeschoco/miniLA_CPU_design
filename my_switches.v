`timescale 1ns / 1ps

module my_switches(
//    input  wire           rst,
//    input  wire           clk,
    input  wire [15:0]    sw_input,   // ʵ�����������뿪�ص�����
    output wire [31:0]    rdata
    );
    
    assign rdata = {16'h0, sw_input};
    
//    always @(posedge clk or posedge rst) begin
//        if(rst) begin
//            rdata <= 32'h00000000;
//        end
//        else begin
//            //ֻ��
//            rdata <= {16'h0000, sw_input};
//        end
//    end
    
endmodule
