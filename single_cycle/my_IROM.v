`timescale 1ns / 1ps

module my_IROM(
    input  wire [31:0] adr,     // 实际有效的位宽与IROM的容量有关
    output wire [31:0] inst
);

    wire [13:0] inst_addr = adr[15:2];    // PC是字节地址
    
    // 64KB IROM
    IROM my_IROM (
        .a      (inst_addr),
        .spo    (inst)
    );

endmodule
