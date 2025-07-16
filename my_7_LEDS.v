`timescale 1ns / 1ps
//�߶������

module my_7_LEDS(
    input wire         rst,
    input wire         clk,
    //input wire [31:0]  addr,
    input wire         we,
    input wire [31:0]  wdata,
    //output reg [31:0]  seg_reg,     // �洢Ҫ��ʾ������
    output reg [7:0]   seg_en,      // �����λѡ����8����
    output reg [7:0]   seg_data     // 7���������a��g + С����dp��
);

    // �����ɨ������������ڶ�̬ˢ�£�
    reg [19:0] scan_cnt;
    reg [2:0]  sel;                // ��ǰѡ�������ܣ�0��7��

    // 7�����������������ܣ�0��F����ʾ���룩
    reg [7:0] seg_table [0:15];
    initial begin
        seg_table[0]  = 8'h3f; // 0
        seg_table[1]  = 8'h06; // 1
        seg_table[2]  = 8'h5b; // 2
        seg_table[3]  = 8'h4f; // 3
        seg_table[4]  = 8'h66; // 4
        seg_table[5]  = 8'h6d; // 5
        seg_table[6]  = 8'h7d; // 6
        seg_table[7]  = 8'h07; // 7
        seg_table[8]  = 8'h7f; // 8
        seg_table[9]  = 8'h6f; // 9
        seg_table[10] = 8'h77; // A
        seg_table[11] = 8'h7c; // b
        seg_table[12] = 8'h39; // C
        seg_table[13] = 8'h5e; // d
        seg_table[14] = 8'h79; // E
        seg_table[15] = 8'h71; // F
    end

    reg [31:0]  seg_reg;     // �洢Ҫ��ʾ������
    // д��wdata �� seg_reg
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_reg <= 32'h0;
        end
        else if (we) begin
            seg_reg <= wdata;  // �洢Ҫ��ʾ�����ݣ�32λ = 8λ����� �� 4λ���ݣ�
        end
    end

    // ��̬ɨ���߼���ÿ��һ��ʱ���л�һ�������
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_cnt <= 20'h0;
            sel <= 3'h0;
        end
        else begin
            scan_cnt <= scan_cnt + 1;
            if (scan_cnt == 20'hfffff) begin  // ����ɨ��Ƶ�ʣ���ֹ��˸��
                sel <= sel + 1;
                if (sel == 3'h7) sel <= 3'h0;
            end
        end
    end

    // �����λѡ�źţ�����������ܣ��͵�ƽ��Ч��
    always @(*) begin
        seg_en = 8'b1111_1111;      // Ĭ��ȫ�ر�
        seg_en[sel] = 1'b0;         // ѡ�е�ǰ�����
    end

    // 7������������� seg_reg ��ȡ��ǰ����ܵ����ݣ�
    always @(*) begin
        case (sel)
            3'h0: seg_data = seg_table[seg_reg[3:0]];    // ��0λ�����
            3'h1: seg_data = seg_table[seg_reg[7:4]];    // ��1λ�����
            3'h2: seg_data = seg_table[seg_reg[11:8]];   // ��2λ�����
            3'h3: seg_data = seg_table[seg_reg[15:12]];  // ��3λ�����
            3'h4: seg_data = seg_table[seg_reg[19:16]];  // ��4λ�����
            3'h5: seg_data = seg_table[seg_reg[23:20]];  // ��5λ�����
            3'h6: seg_data = seg_table[seg_reg[27:24]];  // ��6λ�����
            3'h7: seg_data = seg_table[seg_reg[31:28]];  // ��7λ�����
            default: seg_data = 8'h00;
        endcase
    end

endmodule
