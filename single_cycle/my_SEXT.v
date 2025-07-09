`timescale 1ns / 1ps

module my_SEXT(
    input  wire [15:0]  din1_ex,
    input  wire [15:0]  din2_wb,
    input  wire         sext_op,
    output reg [31:0]   ext1,
    output reg [31:0]   ext2 
    );
    
    parameter SEXT_I5    = 0;
    parameter SEXT_I12   = 1;
    parameter SEXT_Z     = 2;
    parameter SEXT_I12_b = 3;
    parameter SEXT_I12_h = 4;
    parameter SEXT_BJ    = 5;
    
    always @ (*) begin
        case (sext_op)
            SEXT_I5: begin
                //imm [14:10]
                if(din1_ex[4])
                    ext1 <= {27'h7ffffff, din1_ex[4:0]};
                else ext1 <= din1_ex[4:0];
            end
            SEXT_I12: begin
                //imm[21:10]
                if(din1_ex[11])
                    ext1 <= {21'h1fffff, din1_ex[11:0]};
                else ext1 <= din1_ex[11:0];
            end
            SEXT_Z: begin
                //zero extension
                ext1 <= din1_ex;
            end
            SEXT_I12_b: begin
                //imm[21:10]
                if(din1_ex[11])
                    ext1 <= {21'h1fffff, din1_ex[11:0]};
                else ext1 <= din1_ex[11:0];
                //DRAM.rdo[7:0]
                if(din2_wb[7])
                    ext2 <= {24'hffffff, din2_wb[7:0]};
                else ext2 <= din2_wb[7:0];
            end
            SEXT_I12_h: begin
                //imm[21:10]
                if(din1_ex[11])
                    ext1 <= {21'h1fffff, din1_ex[11:0]};
                else ext1 <= din1_ex[11:0];
                //DRAM.rdo[15:0]
                if(din2_wb[15])
                    ext2 <= {16'hffff, din2_wb[15:0]};
                else ext2 <= din2_wb[15:0];
            end
            SEXT_BJ: begin
                //{IROM.inst[25:10],2'b0}
                if(din1_ex[15])
                    ext1 <= {14'h3fff, din1_ex[15:0], 2'b0};
                else ext1 <= {din1_ex[15:0], 2'b0};
            end
        endcase
    end
    
endmodule
