// Annotate this macro before synthesis
// `define RUN_TRACE

// TODO: 在此处定义你的宏
//PC
`define NPC_PC4  2'b00
`define NPC_BRC  2'b01
`define NPC_OFF  2'b10
`define NPC_JIRL 2'b11

//RF
`define RD1_3R 1'b0
`define RD1_2R 1'b1

`define rD_i   1'b0
`define rD_1   1'b1

//SEXT
`define SEXT_I5     3'b000
`define SEXT_I12    3'b001
`define SEXT_Z      3'b010
`define SEXT_BJ     3'b011
`define SEXT_B      3'b100

`define SEXT_b  2'b01
`define SEXT_h  2'b10

//ALU
`define OP_ADD   4'h0
`define OP_SUB   4'h1
`define OP_AND   4'h2
`define OP_OR    4'h3
`define OP_XOR   4'h4
`define OP_SLL   4'h5
`define OP_SRL   4'h6
`define OP_SRA   4'h7 
`define OP_SLL_12  4'h8
`define OP_BEQ   4'h9
`define OP_BNE   4'ha
`define OP_BLT   4'hb
`define OP_BLTU  4'hc
`define OP_BGE   4'hd
`define OP_BGEU  4'he
`define OP_PCADDU  4'hf

//ALU_A_sel
`define A_RD1    2'b00
`define A_SEXT1  2'b01
`define A_1R     2'b10

//RF_WD
`define WD_C  3'b000
`define WD_f  3'b001
`define WD_SEXT  3'b010
`define WD_RDOB  3'b011
`define WD_RDOH  3'b100
`define WD_RDO   3'b101
`define WD_PCB   3'b110

//DRAM
`define RAM_B  2'b00
`define RAM_H  2'b01
`define RAM_W  2'b10

// 外设I/O接口电路的端口地址?
`define PERI_ADDR_DIG   32'hFFFF_F000
`define PERI_ADDR_TIM   32'hFFFF_F020
`define PERI_ADDR_FRE   32'hFFFF_F024
`define PERI_ADDR_LED   32'hFFFF_F060
`define PERI_ADDR_SW    32'hFFFF_F070
`define PERI_ADDR_BTN   32'hFFFF_F078
