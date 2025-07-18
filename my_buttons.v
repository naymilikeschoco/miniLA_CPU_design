`timescale 1ns / 1ps

module my_buttons(
    input wire          clk,        // 系统时钟
    input wire          rst,        // 系统复位
    input wire  [4:0]   btn_raw,    // 5个原始按键输入
    output reg  [4:0]   btn_out    // 5个消抖后的按键输出
);

// 参数定义
parameter DEBOUNCE_TIME = 15_000_000;  // 15ms消抖时间
parameter CNT_WIDTH = 24;              // 计数器位宽

// 内部信号
reg [4:0] btn_reg;                    // 按键同步寄存器
reg [4:0] btn_last;                   // 上一次按键状态
reg [CNT_WIDTH-1:0] debounce_cnt [4:0]; // 5个按键的消抖计数器
reg [4:0] debouncing;                 // 消抖进行中标志

integer i;

// 同步外部按键输入，防止亚稳态
always @(posedge clk or posedge rst) begin
    if (rst) begin
        btn_reg <= 5'b0;
        btn_last <= 5'b0;
    end else begin
        btn_reg <= btn_raw;
        btn_last <= btn_reg;
    end
end

// 消抖处理
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 5; i = i + 1) begin
            debounce_cnt[i] <= 0;
            debouncing[i] <= 0;
            btn_out[i] <= 0;
        end
    end else begin
        for (i = 0; i < 5; i = i + 1) begin
            // 检测按键变化
            if (btn_reg[i] != btn_last[i]) begin
                debouncing[i] <= 1'b1;      // 开始消抖
                debounce_cnt[i] <= DEBOUNCE_TIME; // 重置计数器
            end
            // 消抖计数器递减
            else if (debouncing[i] && (debounce_cnt[i] > 0)) begin
                debounce_cnt[i] <= debounce_cnt[i] - 1;
            end
            // 消抖完成
            else if (debouncing[i] && (debounce_cnt[i] == 0)) begin
                debouncing[i] <= 1'b0;
                btn_out[i] <= btn_reg[i];   // 更新消抖后的按键状态
            end
        end
    end
end

endmodule