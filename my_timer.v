`timescale 1ns / 1ps

`include "defines_pipeline.vh"

module my_timer(
    input wire          rst,
    input wire          clk,
    input wire          wen,
    input wire [31:0]   wdata,
    input wire [31:0]   addr,
    output reg [31:0]   rdata
    );
    
    reg [31:0] freq_reg; // ���õķ�Ƶϵ��Ҳ����ֵ�Ĵ���
    reg [31:0] counter0;
    reg [31:0] counter1;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter0 <= 32'h0;
            counter1 <= 32'h0;
            freq_reg <= 32'h0;
            rdata <= 32'h0;
        end
        else begin
            // �������߼�
            if (counter1 == freq_reg) begin
                counter1 <= 32'h0;
                counter0 <= counter0 + 32'h1;
            end
            else begin
                counter1 <= counter1 + 1;
            end
            
            // д����
            if (wen) begin
                if (addr == `PERI_ADDR_TIM) begin
                    // д32λ��ʱ��������
                    counter0 <= wdata;
                end
                else if (addr == `PERI_ADDR_FRE) begin
                    // д��Ƶϵ��
                    freq_reg <= wdata;
                end
            end
            
            // ������
            rdata <= counter0;
        end
    end
    
endmodule