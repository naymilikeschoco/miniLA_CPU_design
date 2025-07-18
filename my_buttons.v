`timescale 1ns / 1ps

module my_buttons(
    input wire          clk,        // ϵͳʱ��
    input wire          rst,        // ϵͳ��λ
    input wire  [4:0]   btn_raw,    // 5��ԭʼ��������
    output reg  [4:0]   btn_out    // 5��������İ������
);

// ��������
parameter DEBOUNCE_TIME = 15_000_000;  // 15ms����ʱ��
parameter CNT_WIDTH = 24;              // ������λ��

// �ڲ��ź�
reg [4:0] btn_reg;                    // ����ͬ���Ĵ���
reg [4:0] btn_last;                   // ��һ�ΰ���״̬
reg [CNT_WIDTH-1:0] debounce_cnt [4:0]; // 5������������������
reg [4:0] debouncing;                 // ���������б�־

integer i;

// ͬ���ⲿ�������룬��ֹ����̬
always @(posedge clk or posedge rst) begin
    if (rst) begin
        btn_reg <= 5'b0;
        btn_last <= 5'b0;
    end else begin
        btn_reg <= btn_raw;
        btn_last <= btn_reg;
    end
end

// ��������
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 5; i = i + 1) begin
            debounce_cnt[i] <= 0;
            debouncing[i] <= 0;
            btn_out[i] <= 0;
        end
    end else begin
        for (i = 0; i < 5; i = i + 1) begin
            // ��ⰴ���仯
            if (btn_reg[i] != btn_last[i]) begin
                debouncing[i] <= 1'b1;      // ��ʼ����
                debounce_cnt[i] <= DEBOUNCE_TIME; // ���ü�����
            end
            // �����������ݼ�
            else if (debouncing[i] && (debounce_cnt[i] > 0)) begin
                debounce_cnt[i] <= debounce_cnt[i] - 1;
            end
            // �������
            else if (debouncing[i] && (debounce_cnt[i] == 0)) begin
                debouncing[i] <= 1'b0;
                btn_out[i] <= btn_reg[i];   // ����������İ���״̬
            end
        end
    end
end

endmodule