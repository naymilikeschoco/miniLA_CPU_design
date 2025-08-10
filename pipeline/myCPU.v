`timescale 1ns / 1ps

`include "defines_pipeline.vh"

module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,
    
    // Interface to IROM
`ifdef RUN_TRACE
    output wire [15:0]  inst_addr,
`else
    output wire [13:0]  inst_addr,
`endif
    input  wire [31:0]  inst,
    
    // Interface to Bridge
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire         Bus_we,
    output reg  [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

    // TODO:
    //IF_ID Reg
    wire [31:0] IF_ID_pc;      //PC+4
    wire [31:0] IF_ID_inst;
        
    //ID_EX Reg
    wire        ID_EX_rf_we;
    wire [2:0]  ID_EX_rf_wd_sel;
    wire [3:0]  ID_EX_alu_op;
    wire [1:0]  ID_EX_A_sel;
    wire        ID_EX_off_sel;
    wire        ID_EX_ram_we;
    wire [1:0]  ID_EX_ram_op;
    wire        ID_EX_load;
    wire        ID_EX_ctrl;
    wire [31:0] ID_EX_ext1;
    wire [31:0] ID_EX_pc;
    reg [31:0]  ID_EX_rd1;
    reg [31:0]  ID_EX_rd2;
    wire [4:0]  ID_EX_wR;
    wire [19:0] ID_EX_inst;
    wire [1:0]  ID_EX_sext2_op;
    wire [1:0]  ID_EX_npc_op;
    
    //EX_MEM Reg
    wire        EX_MEM_rf_we;
    wire [2:0]  EX_MEM_rf_wd_sel;
    wire        EX_MEM_ram_we;
    wire [1:0]  EX_MEM_ram_op;
    wire [31:0] EX_MEM_pc;
    wire [31:0] EX_MEM_alu_c;
    wire        EX_MEM_alu_f;
    wire [31:0] EX_MEM_rd1;
    wire [4:0]  EX_MEM_wR;
    wire [1:0]  EX_MEM_sext2_op;
    wire        EX_MEM_ctrl;
    
    //MEM_WB Reg:
    wire        MEM_WB_rf_we;
    wire [4:0]  MEM_WB_wR;
    wire [31:0] MEM_WB_pc;
    wire [31:0] MEM_WB_alu_c;
    wire        MEM_WB_alu_f;
//    wire [31:0] WB_RF_wD;
    wire [1:0]  MEM_WB_sext2_op;
    wire [2:0]  MEM_WB_rf_wd_sel;
    wire [31:0] MEM_WB_rdata;
    wire [31:0] MEM_WB_raddr;
    wire MEM_WB_have_inst;
    
    wire [31:0] PC_pc;
    wire [31:0] PC_offset;
    
    wire [31:0] RF_rD1;
    wire [31:0] RF_rD2;
    wire [31:0] WB_RD;
    wire [31:0] SEXT_ext1;
    wire [31:0] SEXT_ext2;
    wire [31:0] ALU_C;
    wire        ALU_f;

    wire [1:0] Ctrl_npc_op;
    wire       Ctrl_rd1_op;
    wire       Ctrl_rd_sel;
    wire       Ctrl_id_rf1;
    wire       Ctrl_id_rf2;
    wire       Ctrl_rf_we;
    wire [2:0] Ctrl_rf_wd_sel;
    wire [2:0] Ctrl_sext1_op;
    wire [1:0] Ctrl_sext2_op;
    wire [3:0] Ctrl_alu_op;
    wire [1:0] Ctrl_A_sel;
    wire       Ctrl_off_sel;
    wire       Ctrl_ram_we;
    wire [1:0] Ctrl_ram_op;
    wire       Ctrl_load;
    wire       Ctrl_hazard;
    
    wire [4:0] ID_rs1 = (Ctrl_rd1_op == `RD1_3R)? IF_ID_inst[14:10] : IF_ID_inst[4:0];
    wire [4:0] ID_rs2 = IF_ID_inst[9:5];

    wire      rs1_id_ex_hazard;
    wire      rs2_id_ex_hazard;
    wire      rs1_id_mem_hazard;
    wire      rs2_id_mem_hazard;
    wire      rs1_id_wb_hazard;
    wire      rs2_id_wb_hazard;
    wire      pipeline_stop;
    wire      flush_if_id;
    wire      flush_id_ex;
    hazard_det  cpu_DET(
        .cpu_clk            (cpu_clk),
        .cpu_rst            (cpu_rst),           
        .ID_EX_wR           (ID_EX_wR),
        .ID_EX_rf_we        (ID_EX_rf_we),
        .EX_MEM_wR          (EX_MEM_wR),
        .EX_MEM_rf_we       (EX_MEM_rf_we),
        .MEM_WB_wR          (MEM_WB_wR),
        .MEM_WB_rf_we       (MEM_WB_rf_we),
        .ID_rs1             (ID_rs1),
        .ID_rs2             (ID_rs2),
        .Ctrl_id_rf1        (Ctrl_id_rf1),
        .Ctrl_id_rf2        (Ctrl_id_rf2),
        .ID_EX_load         (ID_EX_load),
        .ID_EX_npc_op       (ID_EX_npc_op),
        .rs1_id_ex_hazard   (rs1_id_ex_hazard),
        .rs2_id_ex_hazard   (rs2_id_ex_hazard),
        .rs1_id_mem_hazard  (rs1_id_mem_hazard),
        .rs2_id_mem_hazard  (rs2_id_mem_hazard),
        .rs1_id_wb_hazard   (rs1_id_wb_hazard),
        .rs2_id_wb_hazard   (rs2_id_wb_hazard),
        .pipeline_stop      (pipeline_stop),
        .flush_if_id        (flush_if_id),
        .flush_id_ex        (flush_id_ex)
    );

    //IF stage
    wire [31:0] NPC_cal;
    my_PC cpu_PC (
        .rst        (cpu_rst),              // input  wire
        .clk        (cpu_clk),              // input  wire
        .stop       (pipeline_stop),
        .flush      (flush_if_id),
        .din        (NPC_cal),              // input  wire [31:0]
        .pc         (PC_pc)                 // output reg  [31:0]
    );
    
    `ifdef RUN_TRACE
        assign inst_addr = PC_pc[17:2];
    `else
        assign inst_addr = PC_pc[15:2];
    `endif
    
    //IF_ID
    wire IF_ID_have_inst;
    IF_ID_Reg cpu_IF_ID(
        .cpu_clk        (cpu_clk),
        .cpu_rst        (cpu_rst),
        .pipeline_stop  (pipeline_stop),
        .flush_if_id    (flush_if_id),
        .PC_pc          (PC_pc),
        .inst           (inst),
        .IF_ID_pc       (IF_ID_pc),
        .IF_ID_inst     (IF_ID_inst)//,
        //.IF_ID_have_inst (IF_ID_have_inst)
    );
    
    //ID stage:
    my_Ctrl cpu_Ctrl (
        .inst       (IF_ID_inst[31:15]), //input wire [16:0]
        .npc_op     (Ctrl_npc_op),
        .rd1_op     (Ctrl_rd1_op),
        .rd_sel     (Ctrl_rd_sel),
        .id_rf1     (Ctrl_id_rf1),
        .id_rf2     (Ctrl_id_rf2),
        .rf_we      (Ctrl_rf_we),
        .rf_wd_sel  (Ctrl_rf_wd_sel),
        .sext1_op   (Ctrl_sext1_op),
        .sext2_op   (Ctrl_sext2_op),
        .alu_op     (Ctrl_alu_op),
        .A_sel      (Ctrl_A_sel),
        .off_sel    (Ctrl_off_sel),
        .ram_we     (Ctrl_ram_we),
        .ram_op     (Ctrl_ram_op),
        .load_inst  (Ctrl_load)//,
//        .ctrl_hazard (Ctrl_hazard)
    );
     
    my_SEXT cpu_SEXT (
        .din1_ex    (IF_ID_inst[25:0]),
//        .din2_wb    (WB_RF_wD),
        .din2_wb    (WB_RD),
        .sext1_op   (Ctrl_sext1_op),
        .sext2_op   (MEM_WB_sext2_op),
        .addr       (MEM_WB_alu_c[1:0]), 
        .ext1       (SEXT_ext1),    
        .ext2       (SEXT_ext2)              // output wire [31:0]
    );
    
    my_RF cpu_RF (
        .clk        (cpu_clk),              // input  wire
        .rR1        (ID_rs1),               // input  wire [ 4:0]
        .rR2        (ID_rs2),               // input  wire [ 4:0]
        .wR         (MEM_WB_wR),                    // input  wire [ 4:0]
        .rd1_op     (Ctrl_rd1_op),
        .we         (MEM_WB_rf_we),           // input  wire
        .wD         (SEXT_ext2),                // input  wire [31:0]
        .rD1        (RF_rD1),               // output reg  [31:0]
        .rD2        (RF_rD2)                // output reg  [31:0]
    );

    //ID_EX
    //wire ID_EX_have_inst;
    ID_EX_Reg cpu_ID_EX(
        .cpu_clk        (cpu_clk),
        .cpu_rst        (cpu_rst),
        .Ctrl_rf_we     (Ctrl_rf_we),
        .Ctrl_rf_wd_sel (Ctrl_rf_wd_sel),
        .Ctrl_alu_op    (Ctrl_alu_op),
        .Ctrl_A_sel     (Ctrl_A_sel),
        .Ctrl_off_sel   (Ctrl_off_sel),
        .Ctrl_rd_sel    (Ctrl_rd_sel),
        .Ctrl_ram_we    (Ctrl_ram_we),
        .Ctrl_ram_op    (Ctrl_ram_op),
        .Ctrl_sext2_op  (Ctrl_sext2_op),
        .Ctrl_load      (Ctrl_load),
       // .IF_ID_have_inst (IF_ID_have_inst),
//        .Ctrl_hazard    (Ctrl_hazard),
        .SEXT_ext1      (SEXT_ext1),
        .IF_ID_pc       (IF_ID_pc),
        .IF_ID_inst     (IF_ID_inst),
        .Ctrl_npc_op    (Ctrl_npc_op),
        .flush_id_ex    (flush_id_ex),
        .pipeline_stop  (pipeline_stop),
        .ID_EX_rf_we    (ID_EX_rf_we),
        .ID_EX_rf_wd_sel(ID_EX_rf_wd_sel),
        .ID_EX_alu_op   (ID_EX_alu_op),
        .ID_EX_A_sel    (ID_EX_A_sel),
        .ID_EX_off_sel  (ID_EX_off_sel),
        .ID_EX_ram_we   (ID_EX_ram_we),
        .ID_EX_ram_op   (ID_EX_ram_op),
        .ID_EX_load     (ID_EX_load),
//        .ID_EX_ctrl     (ID_EX_ctrl),
        .ID_EX_ext1     (ID_EX_ext1),
        .ID_EX_pc       (ID_EX_pc),
        .ID_EX_wR       (ID_EX_wR),
        .ID_EX_inst     (ID_EX_inst),
        .ID_EX_sext2_op (ID_EX_sext2_op),
        .ID_EX_npc_op   (ID_EX_npc_op)//,
       // .have_inst      (ID_EX_have_inst)
    );
    
    //Ç°µÝ
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if(cpu_rst)begin
            ID_EX_rd1       <= 0;
        end
        else if(rs1_id_ex_hazard)begin
            if(ID_EX_rf_wd_sel == `WD_C)       ID_EX_rd1 <= ALU_C;
            else if(ID_EX_rf_wd_sel == `WD_f)  ID_EX_rd1 <= {31'h00000000, ALU_f};
            else if(ID_EX_rf_wd_sel == `WD_PCB) ID_EX_rd1 <= ID_EX_pc + 4;
        end
        else if(rs1_id_mem_hazard)begin
            if(EX_MEM_rf_wd_sel == `WD_C)       ID_EX_rd1 <= EX_MEM_alu_c;
            else if(EX_MEM_rf_wd_sel == `WD_f)  ID_EX_rd1 <= {31'h00000000, EX_MEM_alu_f};
            else if(EX_MEM_rf_wd_sel == `WD_PCB) ID_EX_rd1 <= EX_MEM_pc + 4;
            else if(EX_MEM_rf_wd_sel == `WD_RDO) ID_EX_rd1 <= Bus_rdata;
            else if(EX_MEM_rf_wd_sel == `WD_RDOB)begin
                case(Bus_addr[1:0])
                    2'b00:  ID_EX_rd1 <= {24'b0, Bus_rdata[7:0]};
                    2'b01:  ID_EX_rd1 <= {24'b0, Bus_rdata[15:8]};
                    2'b10:  ID_EX_rd1 <= {24'b0, Bus_rdata[23:16]};
                    2'b11:  ID_EX_rd1 <= {24'b0, Bus_rdata[31:24]};
                endcase
            end
            else if(EX_MEM_rf_wd_sel == `WD_RDOH)begin 
                case(Bus_addr[1])
                    1'b0:   ID_EX_rd1 <= {16'b0, Bus_rdata[15:0]};
                    1'b1:   ID_EX_rd1 <= {16'b0, Bus_rdata[31:16]};
                endcase
            end
            else if(EX_MEM_rf_wd_sel == `WD_SEXT)begin
                case (EX_MEM_sext2_op)
                    `SEXT_b: begin
                        //DRAM.rdo[7:0]
                        case(Bus_addr[1:0])
                            2'b00:  ID_EX_rd1 <= {{24{Bus_rdata[7]}}, Bus_rdata[7:0]};
                            2'b01:  ID_EX_rd1 <= {{24{Bus_rdata[15]}}, Bus_rdata[15:8]};
                            2'b10:  ID_EX_rd1 <= {{24{Bus_rdata[23]}}, Bus_rdata[23:16]};
                            2'b11:  ID_EX_rd1 <= {{24{Bus_rdata[31]}}, Bus_rdata[31:24]}; 
                        endcase
                    end
                    `SEXT_h: begin
                        //DRAM.rdo[15:0]
                        case(Bus_addr[1])
                            1'b0:   ID_EX_rd1 <= {{16{Bus_rdata[15]}}, Bus_rdata[15:0]};
                            1'b1:   ID_EX_rd1 <= {{16{Bus_rdata[31]}}, Bus_rdata[31:16]};
                        endcase
                    end
                endcase
            end
        end
        else if(rs1_id_wb_hazard)begin
            if(MEM_WB_rf_wd_sel == `WD_C)       ID_EX_rd1 <= MEM_WB_alu_c;
            else if(MEM_WB_rf_wd_sel == `WD_f)  ID_EX_rd1 <= {31'h00000000, MEM_WB_alu_f};
            else if(MEM_WB_rf_wd_sel == `WD_PCB) ID_EX_rd1 <= MEM_WB_pc + 4;
            else if(MEM_WB_rf_wd_sel == `WD_RDO) ID_EX_rd1 <= MEM_WB_rdata;
            else if(MEM_WB_rf_wd_sel == `WD_RDOB)begin
                case(MEM_WB_raddr[1:0])
                    2'b00:  ID_EX_rd1 <= {24'b0, MEM_WB_rdata[7:0]};
                    2'b01:  ID_EX_rd1 <= {24'b0, MEM_WB_rdata[15:8]};
                    2'b10:  ID_EX_rd1 <= {24'b0, MEM_WB_rdata[23:16]};
                    2'b11:  ID_EX_rd1 <= {24'b0, MEM_WB_rdata[31:24]};
                endcase
            end
            else if(MEM_WB_rf_wd_sel == `WD_RDOH)begin 
                case(MEM_WB_raddr[1])
                    1'b0:   ID_EX_rd1 <= {16'b0, MEM_WB_rdata[15:0]};
                    1'b1:   ID_EX_rd1 <= {16'b0, MEM_WB_rdata[31:16]};
                endcase
            end
            else if(MEM_WB_rf_wd_sel == `WD_SEXT)begin
                case (MEM_WB_sext2_op)
                    `SEXT_b: begin
                        //DRAM.rdo[7:0]
                        case(MEM_WB_raddr[1:0])
                            2'b00:  ID_EX_rd1 <= {{24{MEM_WB_rdata[7]}}, MEM_WB_rdata[7:0]};
                            2'b01:  ID_EX_rd1 <= {{24{MEM_WB_rdata[15]}}, MEM_WB_rdata[15:8]};
                            2'b10:  ID_EX_rd1 <= {{24{MEM_WB_rdata[23]}}, MEM_WB_rdata[23:16]};
                            2'b11:  ID_EX_rd1 <= {{24{MEM_WB_rdata[31]}}, MEM_WB_rdata[31:24]}; 
                        endcase
                    end
                    `SEXT_h: begin
                        //DRAM.rdo[15:0]
                        case(MEM_WB_raddr[1])
                            1'b0:   ID_EX_rd1 <= {{16{MEM_WB_rdata[15]}}, MEM_WB_rdata[15:0]};
                            1'b1:   ID_EX_rd1 <= {{16{MEM_WB_rdata[31]}}, MEM_WB_rdata[31:16]};
                        endcase
                    end
                endcase
            end
        end
        else ID_EX_rd1      <= RF_rD1;
    end
    
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if(cpu_rst)begin
            ID_EX_rd2       <= 0;
        end
        else if(rs2_id_ex_hazard)begin
            if(ID_EX_rf_wd_sel == `WD_C)       ID_EX_rd2 <= ALU_C;
            else if(ID_EX_rf_wd_sel == `WD_f)  ID_EX_rd2 <= {31'h00000000, ALU_f};
            else if(ID_EX_rf_wd_sel == `WD_PCB) ID_EX_rd2 <= ID_EX_pc + 4;
        end
        else if(rs2_id_mem_hazard)begin
            if(EX_MEM_rf_wd_sel == `WD_C)       ID_EX_rd2 <= EX_MEM_alu_c;
            else if(EX_MEM_rf_wd_sel == `WD_f)  ID_EX_rd2 <= {31'h00000000, EX_MEM_alu_f};
            else if(EX_MEM_rf_wd_sel == `WD_PCB) ID_EX_rd2 <= EX_MEM_pc + 4;
            else if(EX_MEM_rf_wd_sel == `WD_RDO) ID_EX_rd2 <= Bus_rdata;
            else if(EX_MEM_rf_wd_sel == `WD_RDOB)begin
                case(Bus_addr[1:0])
                    2'b00:  ID_EX_rd2 <= {24'b0, Bus_rdata[7:0]};
                    2'b01:  ID_EX_rd2 <= {24'b0, Bus_rdata[15:8]};
                    2'b10:  ID_EX_rd2 <= {24'b0, Bus_rdata[23:16]};
                    2'b11:  ID_EX_rd2 <= {24'b0, Bus_rdata[31:24]};
                endcase
            end
            else if(EX_MEM_rf_wd_sel == `WD_RDOH)begin 
                case(Bus_addr[1])
                    1'b0:   ID_EX_rd2 <= {16'b0, Bus_rdata[15:0]};
                    1'b1:   ID_EX_rd2 <= {16'b0, Bus_rdata[31:16]};
                endcase
            end
            else if(EX_MEM_rf_wd_sel == `WD_SEXT)begin
                case (EX_MEM_sext2_op)
                    `SEXT_b: begin
                        //DRAM.rdo[7:0]
                        case(Bus_addr[1:0])
                            2'b00:  ID_EX_rd2 <= {{24{Bus_rdata[7]}}, Bus_rdata[7:0]};
                            2'b01:  ID_EX_rd2 <= {{24{Bus_rdata[15]}}, Bus_rdata[15:8]};
                            2'b10:  ID_EX_rd2 <= {{24{Bus_rdata[23]}}, Bus_rdata[23:16]};
                            2'b11:  ID_EX_rd2 <= {{24{Bus_rdata[31]}}, Bus_rdata[31:24]}; 
                        endcase
                    end
                    `SEXT_h: begin
                        //DRAM.rdo[15:0]
                        case(Bus_addr[1])
                            1'b0:   ID_EX_rd2 <= {{16{Bus_rdata[15]}}, Bus_rdata[15:0]};
                            1'b1:   ID_EX_rd2 <= {{16{Bus_rdata[31]}}, Bus_rdata[31:16]};
                        endcase
                    end
                endcase
            end
        end
        else if(rs2_id_wb_hazard)begin
            if(MEM_WB_rf_wd_sel == `WD_C)       ID_EX_rd2 <= MEM_WB_alu_c;
            else if(MEM_WB_rf_wd_sel == `WD_f)  ID_EX_rd2 <= {31'h00000000, MEM_WB_alu_f};
            else if(MEM_WB_rf_wd_sel == `WD_PCB) ID_EX_rd2 <= MEM_WB_pc + 4;
            else if(MEM_WB_rf_wd_sel == `WD_RDO) ID_EX_rd2 <= MEM_WB_rdata;
            else if(MEM_WB_rf_wd_sel == `WD_RDOB)begin
                case(MEM_WB_raddr[1:0])
                    2'b00:  ID_EX_rd2 <= {24'b0, MEM_WB_rdata[7:0]};
                    2'b01:  ID_EX_rd2 <= {24'b0, MEM_WB_rdata[15:8]};
                    2'b10:  ID_EX_rd2 <= {24'b0, MEM_WB_rdata[23:16]};
                    2'b11:  ID_EX_rd2 <= {24'b0, MEM_WB_rdata[31:24]};
                endcase
            end
            else if(MEM_WB_rf_wd_sel == `WD_RDOH)begin 
                case(MEM_WB_raddr[1])
                    1'b0:   ID_EX_rd2 <= {16'b0, MEM_WB_rdata[15:0]};
                    1'b1:   ID_EX_rd2 <= {16'b0, MEM_WB_rdata[31:16]};
                endcase
            end
            else if(MEM_WB_rf_wd_sel == `WD_SEXT)begin
                case (MEM_WB_sext2_op)
                    `SEXT_b: begin
                        //DRAM.rdo[7:0]
                        case(MEM_WB_raddr[1:0])
                            2'b00:  ID_EX_rd2 <= {{24{MEM_WB_rdata[7]}}, MEM_WB_rdata[7:0]};
                            2'b01:  ID_EX_rd2 <= {{24{MEM_WB_rdata[15]}}, MEM_WB_rdata[15:8]};
                            2'b10:  ID_EX_rd2 <= {{24{MEM_WB_rdata[23]}}, MEM_WB_rdata[23:16]};
                            2'b11:  ID_EX_rd2 <= {{24{MEM_WB_rdata[31]}}, MEM_WB_rdata[31:24]}; 
                        endcase
                    end
                    `SEXT_h: begin
                        //DRAM.rdo[15:0]
                        case(MEM_WB_raddr[1])
                            1'b0:   ID_EX_rd2 <= {{16{MEM_WB_rdata[15]}}, MEM_WB_rdata[15:0]};
                            1'b1:   ID_EX_rd2 <= {{16{MEM_WB_rdata[31]}}, MEM_WB_rdata[31:16]};
                        endcase
                    end
                endcase
            end
        end
        else ID_EX_rd2      <= RF_rD2;
    end

    //EX stage:
    wire [31:0] ALU_A;
    a_sel_mux  cpu_A_mux(
        .A_sel       (ID_EX_A_sel),
        .RF_rD1      (ID_EX_rd1),
        .SEXT_ext1   (ID_EX_ext1),
        .inst_20     (ID_EX_inst),
        .ALU_A       (ALU_A)
    );
    
    //
    wire [31:0] ALU_B;
    assign ALU_B = (ID_EX_alu_op == `OP_PCADDU)? ID_EX_pc : ID_EX_rd2;
    
    my_ALU cpu_ALU (
        .A          (ALU_A),                // input  wire [31:0]
        .B          (ALU_B),               // input  wire [31:0]
        .alu_op     (ID_EX_alu_op),          
        .C          (ALU_C),                // output wire [31:0]
        .f          (ALU_f)
    );
    
    assign PC_offset = (ID_EX_off_sel)? ALU_C : ID_EX_ext1;
    my_PC_cal cpu_PC_cal(
        .offset     (PC_offset), 
        .br         (ALU_f), 
        .npc_op     (ID_EX_npc_op), 
        .pc         (ID_EX_pc),
        .rj         (ID_EX_rd2),
//        .stop       (pipeline_stop),
        .npc        (NPC_cal)
    );
    
    //EX_MEM
    //wire EX_MEM_have_inst;
    EX_MEM_Reg cpu_EX_MEM(
        .cpu_clk           (cpu_clk),
        .cpu_rst           (cpu_rst),
        // Control signals
        .ID_EX_rf_we       (ID_EX_rf_we),
        .ID_EX_rf_wd_sel   (ID_EX_rf_wd_sel),
        .ID_EX_ram_we      (ID_EX_ram_we),
        .ID_EX_ram_op      (ID_EX_ram_op),
        .ID_EX_sext2_op    (ID_EX_sext2_op),
       // .ID_EX_ctrl        (ID_EX_ctrl),
        //.ID_EX_have_inst   (ID_EX_have_inst),
        // Data signals
        .ID_EX_pc          (ID_EX_pc),
        .ID_EX_rd1         (ID_EX_rd1),
        .ID_EX_wR          (ID_EX_wR),
        // ALU results
        .ALU_C             (ALU_C),
        .ALU_f             (ALU_f),
        // Outputs
        .EX_MEM_rf_we       (EX_MEM_rf_we),
        .EX_MEM_rf_wd_sel   (EX_MEM_rf_wd_sel),
        .EX_MEM_ram_we      (EX_MEM_ram_we),
        .EX_MEM_ram_op      (EX_MEM_ram_op),
        .EX_MEM_pc          (EX_MEM_pc),
        .EX_MEM_alu_c       (EX_MEM_alu_c),
        .EX_MEM_alu_f       (EX_MEM_alu_f),
        .EX_MEM_rd1         (EX_MEM_rd1),
        .EX_MEM_wR          (EX_MEM_wR),
        .EX_MEM_sext2_op    (EX_MEM_sext2_op)//,
//        .EX_MEM_ctrl        (EX_MEM_ctrl),
       // .EX_MEM_have_inst   (EX_MEM_have_inst)
    );
        
    //MEM stage:
    assign Bus_addr = EX_MEM_alu_c;
    assign Bus_we   = EX_MEM_ram_we;
    always @ (*) begin
        case (EX_MEM_ram_op)
            `RAM_B: begin
                //wdin[7:0]
                case(Bus_addr[1:0])
                    2'b00:  Bus_wdata = {Bus_rdata[31:8], EX_MEM_rd1[7:0]};
                    2'b01:  Bus_wdata = {Bus_rdata[31:16], EX_MEM_rd1[7:0], Bus_rdata[7:0]};
                    2'b10:  Bus_wdata = {Bus_rdata[31:24], EX_MEM_rd1[7:0], Bus_rdata[15:0]};
                    2'b11:  Bus_wdata = {EX_MEM_rd1[7:0], Bus_rdata[23:0]};
                endcase
            end
            `RAM_H: begin
                //wdin[15:0]
                case(Bus_addr[1])
                    1'b0:   Bus_wdata = {Bus_rdata[31:16], EX_MEM_rd1[15:0]};
                    1'b1:   Bus_wdata = {EX_MEM_rd1[15:0], Bus_rdata[15:0]};
                endcase
            end
            `RAM_W: begin
                //wdin[31:0]
                Bus_wdata = EX_MEM_rd1;
            end
        endcase
    end
    
   //MEM_WB
    MEM_WB_Reg cpu_MEM_WB(
        .cpu_clk          (cpu_clk),
        .cpu_rst          (cpu_rst),
        // Control signals
        .EX_MEM_rf_we     (EX_MEM_rf_we),
        .EX_MEM_sext2_op  (EX_MEM_sext2_op),
        //.EX_MEM_have_inst (EX_MEM_have_inst),
        .Bus_rdata        (Bus_rdata),
        .Bus_addr         (Bus_addr),
        // Data signals
        .EX_MEM_pc        (EX_MEM_pc),
        .EX_MEM_alu_c     (EX_MEM_alu_c),
        .EX_MEM_alu_f     (EX_MEM_alu_f),
        .EX_MEM_wR        (EX_MEM_wR),
        .EX_MEM_rf_wd_sel (EX_MEM_rf_wd_sel),
        // Writeback data
//        .WB_RD            (WB_RD),
        // Outputs
        .MEM_WB_rf_we     (MEM_WB_rf_we),
        .MEM_WB_wR        (MEM_WB_wR),
        .MEM_WB_pc        (MEM_WB_pc),
        .MEM_WB_alu_c     (MEM_WB_alu_c),
        .MEM_WB_alu_f     (MEM_WB_alu_f),
//        .WB_RF_wD         (WB_RF_wD),
        .MEM_WB_sext2_op  (MEM_WB_sext2_op),
        //.MEM_WB_have_inst (MEM_WB_have_inst),
        .MEM_WB_rdata     (MEM_WB_rdata),
        .MEM_WB_raddr     (MEM_WB_raddr),
        .MEM_WB_rf_wd_sel (MEM_WB_rf_wd_sel)
    );
    
    //WB stage:
    my_wd_mux cpu_wd_mux(
        .rf_wd_sel       (MEM_WB_rf_wd_sel),
//        .addr            (Bus_addr[1:0]),
        .addr            (MEM_WB_alu_c[1:0]),
        .ALU_C           (MEM_WB_alu_c),
        .ALU_f           (MEM_WB_alu_f),
//        .SEXT_ext2       (SEXT_ext2),
        .Bus_rdata       (MEM_WB_rdata),
        .pc4             ((MEM_WB_pc + 4)),
        .RF_wD           (WB_RD)
    );
    
    //

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = MEM_WB_have_inst;
    assign debug_wb_pc        = MEM_WB_pc;
    assign debug_wb_ena       = MEM_WB_rf_we;
    assign debug_wb_reg       = MEM_WB_wR;
    assign debug_wb_value     = SEXT_ext2;
`endif

endmodule
