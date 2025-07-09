`timescale 1ns / 1ps

module my_IROM(
    input  wire [31:0] adr,     // ʵ����Ч��λ����IROM�������й�
    output wire [31:0] inst
);

    wire [13:0] inst_addr = adr[15:2];    // PC���ֽڵ�ַ
    
    // 64KB IROM
    IROM my_IROM (
        .a      (inst_addr),
        .spo    (inst)
    );

endmodule