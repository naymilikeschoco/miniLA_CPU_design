`timescale 1ns / 1ps

module hazard_det(
    input wire       cpu_clk,
    input wire       cpu_rst,           
    input wire [4:0] ID_EX_wR,
    input wire       ID_EX_rf_we,
    input wire [4:0] EX_MEM_wR,
    input wire       EX_MEM_rf_we,
    input wire [4:0] MEM_WB_wR,
    input wire       MEM_WB_rf_we,
    input wire [4:0] ID_rs1,
    input wire [4:0] ID_rs2,
    input wire       Ctrl_id_rf1,
    input wire       Ctrl_id_rf2,
    input wire       ID_EX_load,
    input wire [1:0] ID_EX_npc_op,
    output wire      rs1_id_ex_hazard,
    output wire      rs2_id_ex_hazard,
    output wire      rs1_id_mem_hazard,
    output wire      rs2_id_mem_hazard,
    output wire      rs1_id_wb_hazard,
    output wire      rs2_id_wb_hazard,
    output wire      pipeline_stop,
    output wire      flush_if_id,
    output wire      flush_id_ex
    );
    
        //RAW冒险情形A：
    assign rs1_id_ex_hazard = (ID_EX_wR != 5'b0) & (ID_EX_wR == ID_rs1) & ID_EX_rf_we & Ctrl_id_rf1;
    assign rs2_id_ex_hazard = (ID_EX_wR != 5'b0) & (ID_EX_wR == ID_rs2) & ID_EX_rf_we & Ctrl_id_rf2;
//    wire stop_3 = (rs1_id_ex_hazard | rs2_id_ex_hazard); //暂停3个周期
    
    //RAW冒险情形B：
    assign rs1_id_mem_hazard = (EX_MEM_wR != 5'b0) & (EX_MEM_wR == ID_rs1) & EX_MEM_rf_we & Ctrl_id_rf1;
    assign rs2_id_mem_hazard = (EX_MEM_wR != 5'b0) & (EX_MEM_wR == ID_rs2) & EX_MEM_rf_we & Ctrl_id_rf2;
//    wire stop_2 = (rs1_id_mem_hazard | rs2_id_mem_hazard); //暂停2个周期
    
    //RAW冒险情形C：
    assign rs1_id_wb_hazard = (MEM_WB_wR != 0) & (MEM_WB_wR == ID_rs1) & MEM_WB_rf_we & Ctrl_id_rf1;
    assign rs2_id_wb_hazard = (MEM_WB_wR != 0) & (MEM_WB_wR == ID_rs2) & MEM_WB_rf_we & Ctrl_id_rf2;
//    wire stop_1 = (rs1_id_wb_hazard | rs2_id_wb_hazard); //暂停1个周期
    
    // 必须暂停的Load-Use冒险
    wire rs1_load_use;
    wire rs2_load_use;
    assign rs1_load_use = rs1_id_ex_hazard & ID_EX_load;
    assign rs2_load_use = rs2_id_ex_hazard & ID_EX_load;
    assign pipeline_stop = (rs1_load_use | rs2_load_use);
    
    assign flush_if_id = (ID_EX_npc_op != `NPC_PC4);
    assign flush_id_ex = flush_if_id;

endmodule
