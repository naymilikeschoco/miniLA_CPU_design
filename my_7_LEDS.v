`timescale 1ns / 1ps
//七段数码管

module my_7_LEDS(
    input wire         rst,
    input wire         clk,
    //input wire [31:0]  addr,
    input wire         we,
    input wire [31:0]  wdata,
    //output reg [31:0]  seg_reg,     // 存储要显示的数据
    output reg [7:0]   seg_en,      // 数码管位选（共8个）
    output reg [7:0]   seg_data     // 7段码输出（a到g + 小数点dp）
);

    // 数码管扫描计数器（用于动态刷新）
    reg [19:0] scan_cnt;
    reg [2:0]  sel;                // 当前选择的数码管（0到7）

    // 7段译码表（共阴极数码管，0到F的显示编码）
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

    reg [31:0]  seg_reg;     // 存储要显示的数据
    // 写入wdata 到 seg_reg
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_reg <= 32'h0;
        end
        else if (we) begin
            seg_reg <= wdata;  // 存储要显示的数据（32位 = 8位数码管 × 4位数据）
        end
    end

    // 动态扫描逻辑，每隔一段时间切换一个数码管
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_cnt <= 20'h0;
            sel <= 3'h0;
        end
        else begin
            scan_cnt <= scan_cnt + 1;
            if (scan_cnt == 20'hfffff) begin  // 调整扫描频率（防止闪烁）
                sel <= sel + 1;
                if (sel == 3'h7) sel <= 3'h0;
            end
        end
    end

    // 数码管位选信号（共阴极数码管，低电平有效）
    always @(*) begin
        seg_en = 8'b1111_1111;      // 默认全关闭
        seg_en[sel] = 1'b0;         // 选中当前数码管
    end

    // 7段译码输出（从 seg_reg 提取当前数码管的数据）
    always @(*) begin
        case (sel)
            3'h0: seg_data = seg_table[seg_reg[3:0]];    // 第0位数码管
            3'h1: seg_data = seg_table[seg_reg[7:4]];    // 第1位数码管
            3'h2: seg_data = seg_table[seg_reg[11:8]];   // 第2位数码管
            3'h3: seg_data = seg_table[seg_reg[15:12]];  // 第3位数码管
            3'h4: seg_data = seg_table[seg_reg[19:16]];  // 第4位数码管
            3'h5: seg_data = seg_table[seg_reg[23:20]];  // 第5位数码管
            3'h6: seg_data = seg_table[seg_reg[27:24]];  // 第6位数码管
            3'h7: seg_data = seg_table[seg_reg[31:28]];  // 第7位数码管
            default: seg_data = 8'h00;
        endcase
    end

endmodule
