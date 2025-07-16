`timescale 1ns / 1ps

`include "defines.vh"

module my_wd_mux(
    input wire [2:0]       rf_wd_sel,
    input wire [1:0]       addr,
    input wire [31:0]      ALU_C,
    input wire             ALU_f,
    input wire [31:0]      SEXT_ext2,
    input wire [31:0]      Bus_rdata,
    input wire [31:0]      NPC_pcb,
    output reg [31:0]      RF_wD
    );

    always @ (*) begin
        case(rf_wd_sel)
            `WD_C: RF_wD = ALU_C;
            `WD_f: RF_wD = {31'b0, ALU_f};
            `WD_SEXT: RF_wD = SEXT_ext2;
            `WD_RDOB: begin
                case(addr)
                    2'b00:  RF_wD = {24'b0, Bus_rdata[7:0]};
                    2'b01:  RF_wD = {24'b0, Bus_rdata[15:8]};
                    2'b10:  RF_wD = {24'b0, Bus_rdata[23:16]};
                    2'b11:  RF_wD = {24'b0, Bus_rdata[31:24]};
                endcase
            end
            `WD_RDOH: 
                case(addr[1])
                    1'b0:   RF_wD = {16'b0, Bus_rdata[15:0]};
                    1'b1:   RF_wD = {16'b0, Bus_rdata[31:16]};
                endcase
            `WD_RDO: RF_wD = Bus_rdata;
            `WD_PCB: RF_wD = NPC_pcb;
            default: RF_wD = 32'b0;  // 添加默认情况
        endcase
    end
    
endmodule
