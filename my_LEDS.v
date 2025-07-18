`timescale 1ns / 1ps

module my_LEDS(
    input wire         rst,
    input wire         clk,
    //input wire [31:0]  addr,
    input wire         we,
    input wire [15:0]  wdata,
    output reg [15:0]  led_data
    );
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            led_data <= 16'h0;
        end
        else begin
            if(we)begin
                led_data <= wdata;
            end
        end
    end
    
endmodule
