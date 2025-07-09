`timescale 1ns / 1ps

module my_Ctrl(
    input wire [16:0]    inst,  //[31:15]
    output wire          pc_sel,
    output wire [1:0]    npc_op,
    output wire          rd1_op,
    output wire          rf_we,
    output wire [2:0]    rf_wd_sel,
    output wire [2:0]    sext_op,
    output wire [3:0]    alu_op,
    output wire [1:0]    A_sel,
    output wire          off_sel,
    output wire          ram_we,
    output wire [1:0]    ram_op
    );
    
    wire OPCODE = inst[16:11];
    wire SIG = inst[10];
    wire FUNC3 = inst[9:7];
    wire FUNC7 = inst[6:0];
    
    //3RÐÍ
    wire ADD_W = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 000) & (FUNC7 == 0100000);
    wire SUB_W = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 000) & (FUNC7 == 0100010);
    wire AND   = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 000) & (FUNC7 == 0101001);
    wire OR    = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 000) & (FUNC7 == 0101010);
    wire XOR   = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 000) & (FUNC7 == 0101011);
    wire SLL_W = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 000) & (FUNC7 == 0101110);
    wire SRL_W = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 000) & (FUNC7 == 0101111);
    wire SRA_W = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 000) & (FUNC7 == 0110000);
    wire SLT   = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 000) & (FUNC7 == 0100100);
    wire SLTU  = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 000) & (FUNC7 == 0100101);
    
    //2RI5ÐÍ
    wire SLLI_W = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 001) & (FUNC7 == 0000001);
    wire SRLI_W = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 001) & (FUNC7 == 0001001);
    wire SRAI_W = (OPCODE == 000000) & (SIG == 0) & (FUNC3 == 001) & (FUNC7 == 0010001); 
    
    //2RI12ÐÍ
    wire ADDI_W = (OPCODE == 000000) & (SIG == 1) & (FUNC3 == 010);
    wire ANDI   = (OPCODE == 000000) & (SIG == 1) & (FUNC3 == 101);
    wire ORI    = (OPCODE == 000000) & (SIG == 1) & (FUNC3 == 110);
    wire XORI   = (OPCODE == 000000) & (SIG == 1) & (FUNC3 == 111);
    wire SLTI   = (OPCODE == 000000) & (SIG == 1) & (FUNC3 == 000);
    wire SLTUI  = (OPCODE == 000000) & (SIG == 1) & (FUNC3 == 001);
    wire LD_B   = (OPCODE == 001010) & (SIG == 0) & (FUNC3 == 000);
    wire LD_BU  = (OPCODE == 001010) & (SIG == 1) & (FUNC3 == 000);
    wire LD_H   = (OPCODE == 001010) & (SIG == 0) & (FUNC3 == 001);
    wire LD_HU  = (OPCODE == 001010) & (SIG == 1) & (FUNC3 == 001);
    wire LD_W   = (OPCODE == 001010) & (SIG == 0) & (FUNC3 == 010);
    wire ST_B   = (OPCODE == 001010) & (SIG == 0) & (FUNC3 == 100);
    wire ST_H   = (OPCODE == 001010) & (SIG == 0) & (FUNC3 == 101);
    wire ST_W   = (OPCODE == 001010) & (SIG == 0) & (FUNC3 == 110);
    
    //1RI20ÐÍ
    wire LU12I  = (OPCODE == 000101) & (SIG == 0);
    wire PCADDU = (OPCODE == 000111) & (SIG == 0);
    
    //2RI16ÐÍ
    wire BEQ  = (OPCODE == 010110);
    wire BNE  = (OPCODE == 010111);
    wire BLT  = (OPCODE == 011000);
    wire BLTU = (OPCODE == 011010);
    wire BGE  = (OPCODE == 011011);
    wire BGEU = (OPCODE == 011011);
    wire JIRL = (OPCODE == 010011);
    
    //I26ÐÍ
    wire B  = (OPCODE == 010100);
    wire BL = (OPCODE == 010101);
    
    assign pc_sel = JIRL ? 1 : 0;

    wire npc_op_brc = BEQ | BNE | BLT | BLTU | BGE | BGEU;
    wire npc_op_jmp = JIRL | B | BL;
    wire npc_op_pc4_add = PCADDU;
    wire npc_op_pc4 = !(npc_op_brc & npc_op_jmp & npc_op_pc4_add);
    parameter NPC_PC4 = 0;
    parameter NPC_BRC = 1;
    parameter NPC_JMP = 2;
    parameter NPC_PC4_ADD = 3;
    assign npc_op = {2{npc_op_pc4}} & NPC_PC4
                    | {2{npc_op_brc}} & NPC_BRC
                    | {2{npc_op_jmp}} & NPC_JMP
                    | {2{npc_op_pc4_add}} & NPC_PC4_ADD;
                
    wire rd1_op_2r = BEQ | BNE | BLT | BLTU | BGE | BGEU | ST_B | ST_H | ST_W;
    assign rd1_op = rd1_op_2r ? 1 : 0;
          
    wire rf_we_not = BEQ | BNE | BLT | BLTU | BGE | BGEU | ST_B | ST_H | ST_W | B;
    assign rd1_op = rf_we_not ? 0 : 1;
    
    wire wd_f = SLT | SLTU | SLTI | SLTUI;
    wire wd_sext2 = LD_B | LD_H;
    wire wd_rdob  = LD_BU;
    wire wd_rdoh  = LD_HU;
    wire wd_rdo   = LD_W;
    wire wd_pcb   = PCADDU | JIRL | BL;
    wire wd_c = !(wd_f & wd_sext2 & wd_rdob & wd_rdoh & wd_rdo & wd_pcb);
    parameter WD_C = 0;
    parameter WD_f = 1;
    parameter WD_SEXT = 2;
    parameter WD_RDOB = 3;
    parameter WD_RDOH = 4;
    parameter WD_RDO  = 5;
    parameter WD_PCB = 6;
    assign rf_wd_sel = {3{wd_c}} & WD_C
                    | {3{wd_f}} & WD_f
                    | {3{wd_sext2}} & WD_SEXT
                    | {3{wd_rdob}} & WD_RDOB
                    | {3{wd_rdoh}} & WD_RDOH
                    | {3{wd_rdo}} & WD_RDO
                    | {3{wd_pcb}} & WD_PCB;
         
    wire sext_op_i5 = SLLI_W | SRLI_W | SRAI_W;   
    wire sext_op_i12 = ADDI_W | SLTI | SLTUI | LD_BU | LD_HU | LD_W | ST_B | ST_H | ST_W;
    wire sext_op_z = ANDI | ORI | XORI;
    wire sext_op_i12_b = LD_B;
    wire sext_op_i12_h = LD_H;
    wire sext_op_bj = BEQ | BNE | BLT | BLTU | BGE | BGEU | JIRL | B | BL;
    parameter SEXT_I5    = 0;
    parameter SEXT_I12   = 1;
    parameter SEXT_Z     = 2;
    parameter SEXT_I12_b = 3;
    parameter SEXT_I12_h = 4;
    parameter SEXT_BJ    = 5;                
    assign sext_op = {3{sext_op_i5}} & SEXT_I5
                    | {3{sext_op_i12}} & SEXT_I12
                    | {3{sext_op_z}} & SEXT_Z
                    | {3{sext_op_i12_b}} & SEXT_I12_b
                    | {3{sext_op_i12_h}} & SEXT_I12_h
                    | {3{sext_op_bj}} & SEXT_BJ;
                    
    wire alu_op_sub = SUB_W;
    wire alu_op_and = AND;
    wire alu_op_or  = OR | ORI;
    wire alu_op_xor = XOR | XORI;
    wire alu_op_sll = SLL_W | SLLI_W;
    wire alu_op_srl = SRL_W | SRLI_W;
    wire alu_op_sra = SRA_W | SRAI_W;
    wire alu_op_sll12 = LU12I | PCADDU;
    wire alu_op_beq = BEQ;
    wire alu_op_bne= BNE;
    wire alu_op_blt = SLT | SLTI | BLT;
    wire alu_op_bltu = SLTU | SLTUI | BLTU;
    wire alu_op_bge = BGE;
    wire alu_op_bgeu = BGEU;
    wire alu_op_add = ADD_W | ADDI_W | LD_B | LD_BU | LD_H | LD_HU | LD_W 
                        | ST_B | ST_H | ST_W | JIRL;
    parameter OP_ADD = 0;
    parameter OP_SUB = 1;
    parameter OP_AND = 2;
    parameter OP_OR  = 3;
    parameter OP_XOR = 4;
    parameter OP_SLL = 5;
    parameter OP_SRL = 6;
    parameter OP_SRA = 7;
    parameter OP_SLL_12 = 8;
    parameter OP_BEQ = 9;
    parameter OP_BNE = 10;
    parameter OP_BLT = 11;
    parameter OP_BLTU = 12;
    parameter OP_BGE = 13;
    parameter OP_BGEU = 14;
    assign alu_op = {4{alu_op_add}} & SEXT_I5
                    | {4{alu_op_sub}} & OP_SUB
                    | {4{alu_op_and}} & OP_AND
                    | {4{alu_op_or}} & OP_OR
                    | {4{alu_op_xor}} & OP_XOR
                    | {4{alu_op_sll}} & OP_SLL
                    | {4{alu_op_srl}} & OP_SRL
                    | {4{alu_op_sra}} & OP_SRA
                    | {4{alu_op_sll12}} & OP_SLL_12
                    | {4{alu_op_beq}} & OP_BEQ
                    | {4{alu_op_bne}} & OP_BNE
                    | {4{alu_op_blt}} & OP_BLT
                    | {4{alu_op_bltu}} & OP_BLTU
                    | {4{alu_op_bge}} & OP_BGE
                    | {4{alu_op_bgeu}} & OP_BGEU;
    
    wire a_rd1 = ADD_W | SUB_W | AND | OR | XOR | SLL_W | SRL_W | SRA_W | SLT | SLTU 
                | BEQ | BNE | BLT | BLTU | BGE | BGEU;
    wire a_1r = LU12I | PCADDU;
    wire a_sext = !(a_rd1 & a_1r);
    parameter A_RD1 = 0;
    parameter A_SEXT1 = 1;
    parameter A_1R = 2;
    assign A_sel = {2{a_rd1}} & A_RD1
                    | {2{a_1r}} & A_SEXT1
                    | {2{a_sext}} & A_1R;
    
    //wire off_sel_ext1 = BEQ | BNE | BLT | BLTU | BGE | BGEU | B | BL;
    wire off_sel_c = PCADDU;
    assign off_sel = off_sel_c? 1 : 0; 
    
    wire ram_en = ST_B | ST_H | ST_W;
    assign ram_we = ram_en? 1 : 0;
    
    parameter RAM_B = 0;
    parameter RAM_H = 1;
    parameter RAM_W = 2;
    assign ram_op = ({2{ST_B}} & RAM_B) | ({2{ST_H}} & RAM_H) | ({2{ST_W}} & RAM_W);
    
    
endmodule
