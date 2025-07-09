`timescale 1ns / 1ps

module my_DRAM(
    input  wire         clk,
    input  wire [1:0]   dram_op,
    input  wire [31:0]  addr,
    input  wire         we,
    input  wire [31:0]  wdin,
    output reg [31:0]   rdo
    );
    
    parameter RAM_B = 0;
    parameter RAM_H = 1;
    parameter RAM_W = 2;
    
    reg [31:0] wdata; //data actually written in dram
    
    //Ð´Ê±ÐòÂß¼­
    always @ (posedge clk) begin
        case (dram_op)
            RAM_B: begin
                //wdin[7:0]
                wdata <= {rdo[31:8], wdin[7:0]};
            end
            RAM_H: begin
                //wdin[15:0]
                wdata <= {rdo[31:16], wdin[15:0]};
            end
            RAM_W: begin
                //wdin[31:0]
                wdata <= wdin;
            end
        endcase
    end
    
    // 64KB DRAM
    DRAM my_DRAM (
        .clk    (clk),
        .a      (addr[15:2]),
        .spo    (rdo),
        .we     (we),
        .d      (wdata)
    );

endmodule
