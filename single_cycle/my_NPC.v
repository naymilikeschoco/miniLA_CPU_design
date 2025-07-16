`timescale 1ns / 1ps

`include "defines.vh"

module my_NPC(
    input  wire [31:0]  offset,
    input  wire         br,
    input  wire [1:0]   npc_op,
    input  wire [31:0]  pc,
    output reg [31:0]   pcb, //ÓÃÓÚÐ´»Ø
    output reg [31:0]   npc
    );
    
    always @ (*) begin
        if(npc_op == `NPC_PC4)begin
            npc = pc + 32'h4;
            pcb = pc + 32'h4; //not used
        end
        else if(npc_op == `NPC_BRC)begin
            if(br) npc = pc + offset;
            else npc = pc + 32'h4;
            pcb = pc + 32'h4; //not used
        end
        else if(npc_op == `NPC_JMP)begin
            npc = pc + offset;
            pcb = pc + 32'h4;
        end
        else begin //npc_op == NPC_PC4_ADD (for pcaddu12i)
            npc = pc + 32'h4;
            pcb = pc + offset;
        end
    end

endmodule
