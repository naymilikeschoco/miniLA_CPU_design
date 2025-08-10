`timescale 1ns / 1ps

`include "defines_pipeline.vh"

module my_SEXT(
    input  wire [25:0]  din1_ex,
    input  wire [31:0]  din2_wb,
    input  wire [2:0]   sext1_op,
    input  wire [1:0]   sext2_op,
    input  wire [1:0]   addr,
    output reg [31:0]   ext1,
    output reg [31:0]   ext2 
    );
    
    always @ (*) begin
        case (sext1_op)
            `SEXT_I5: begin
                //imm [14:10]
                ext1 = {{27{din1_ex[14]}}, din1_ex[14:10]};
            end
            `SEXT_I12: begin
                //imm[21:10]
                ext1 = {{20{din1_ex[21]}}, din1_ex[21:10]};
            end
            `SEXT_Z: begin
                //zero extension
                ext1 = {20'h0000, din1_ex[21:10]};
            end
            `SEXT_BJ: begin
                //{IROM.inst[25:10],2'b0}
                ext1 = {{14{din1_ex[25]}}, din1_ex[25:10], 2'b0};
            end
            `SEXT_B: begin
                //{IROM[9:0],IROM.inst[25:10],2'b0}
                ext1 = {{4{din1_ex[9]}}, din1_ex[9:0],din1_ex[25:10], 2'b0};
            end
            default: begin
                ext1 = 32'b0;
            end
        endcase
    end
    
    always @ (*) begin
        case (sext2_op)
            `SEXT_b: begin
                //DRAM.rdo[7:0]
                case(addr)
                    2'b00:  ext2 = {{24{din2_wb[7]}}, din2_wb[7:0]};
                    2'b01:  ext2 = {{24{din2_wb[15]}}, din2_wb[15:8]};
                    2'b10:  ext2 = {{24{din2_wb[23]}}, din2_wb[23:16]};
                    2'b11:  ext2 = {{24{din2_wb[31]}}, din2_wb[31:24]}; 
                endcase
            end
            `SEXT_h: begin
                //DRAM.rdo[15:0]
                case(addr[1])
                    1'b0:   ext2 = {{16{din2_wb[15]}}, din2_wb[15:0]};
                    1'b1:   ext2 = {{16{din2_wb[31]}}, din2_wb[31:16]};
                endcase
            end
            default: begin
                ext2 = din2_wb;
            end
        endcase
    end
    
endmodule
