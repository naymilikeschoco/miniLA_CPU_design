`timescale 1ns / 1ps

module my_7_LEDS(
    input wire         clk,        // 系统时钟(建议50MHz或更高)
    input wire         rst,        // 复位信号(高电平有效)
    input wire         we,         // 写使能
    input wire [31:0]  wdata,      // 写入数据(8位数码管数据)
    output reg [7:0]   dig_en,
    output reg [7:0]   seg_data         
);

    // 7段译码表(共阴极数码管)
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
    
    // 显示数据寄存器
    reg [31:0] seg_reg;
    
    // 写入数据到显示寄存器
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_reg <= 32'h0;
        end
        else if (we) begin
            seg_reg <= wdata;
        end
    end
    
    reg [17:0] cnt;
    parameter CNT_MAX = 50000;
    always @(posedge clk or posedge rst) begin
        if(rst== 1) begin
            cnt <= 0;
        end else begin
            if(cnt == CNT_MAX) begin
                cnt <= 0;
            end else begin
                cnt <= cnt+1;
            end
        end
    end
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin 
            dig_en <= 8'b00000001;
        end
        else if (cnt == CNT_MAX) begin
            dig_en <= {dig_en[6:0], dig_en[7]}; 
        end
    end
    
    reg [3:0] hex_code;
    always @ (*) begin
        case (dig_en)
            8'b1000_0000: hex_code = seg_reg[31:28];
            8'b0100_0000: hex_code = seg_reg[27:24];
            8'b0010_0000: hex_code = seg_reg[23:20];
            8'b0001_0000: hex_code = seg_reg[19:16];
            8'b0000_1000: hex_code = seg_reg[15:12];
            8'b0000_0100: hex_code = seg_reg[11:8];
            8'b0000_0010: hex_code = seg_reg[7:4];
            8'b0000_0001: hex_code = seg_reg[3:0];
            default     : hex_code = 4'h0;
        endcase
    end
    
    always @ (*) begin
        case (hex_code)
            4'h0: seg_data = seg_table[0];
            4'h1: seg_data = seg_table[1];
            4'h2: seg_data = seg_table[2];
            4'h3: seg_data = seg_table[3];
            4'h4: seg_data = seg_table[4];
            4'h5: seg_data = seg_table[5];
            4'h6: seg_data = seg_table[6];
            4'h7: seg_data = seg_table[7];
            4'h8: seg_data = seg_table[8];
            4'h9: seg_data = seg_table[9];
            4'ha: seg_data = seg_table[10];
            4'hb: seg_data = seg_table[11];
            4'hc: seg_data = seg_table[12];
            4'hd: seg_data = seg_table[13];
            4'he: seg_data = seg_table[14];
            4'hf: seg_data = seg_table[15];
            default: seg_data = seg_table[0];
        endcase
    end
    
endmodule
