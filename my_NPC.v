`timescale 1ns / 1ps

`include "defines_pipeline.vh"

module my_PC_cal(
    input  wire [31:0]  offset,
    input  wire         br,
    input  wire [1:0]   npc_op,
    input  wire [31:0]  pc,
    input  wire [31:0]  rj,
//    input  wire         stop,
    output reg [31:0]   npc
    );
    
    always @ (*) begin
//        if(~stop)begin
            if(npc_op == `NPC_PC4)begin
                npc = pc + 32'h4;
            end
            else if(npc_op == `NPC_BRC)begin
                if(br) npc = pc + offset;
                else npc = pc + 32'h4;
            end
            else if(npc_op == `NPC_OFF)begin
                npc = pc + offset;
            end
            else begin //for JIRL)
                npc = rj + offset;
            end
//        end
    end

endmodule
