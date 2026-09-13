// Reduced Instruction Set Computer - V

import pkg::*;

module risc_v#(
    parameter BUS_WIDTH         = 32,
    parameter I_MEM_ADDR_WIDTH  = 8,
    parameter D_MEM_ADDR_WIDTH  = 8,
    parameter REG_FILE_DEPTH    = 32
) (
    input  logic            clk,
    input  logic            ares,
    input  logic            sres
);

    //--------------------//
    //  Local Parameters  //
    //--------------------//

    localparam REG_FILE_A_WIDTH = $clog2(REG_FILE_DEPTH);

    //----------------------//
    //  Intermediate Wires  //
    //----------------------//

    // Program Counter
    logic [BUS_WIDTH-1:0]           pc;
    pc_mux_ctrl_t                   pc_mux_ctrl;

    // Instruction Memory
    logic [BUS_WIDTH-1:0]           instr;

    // Register File
    logic [REG_FILE_A_WIDTH-1:0]    instr_rs1;
    logic [REG_FILE_A_WIDTH-1:0]    instr_rs2;
    logic [REG_FILE_A_WIDTH-1:0]    instr_rd;
    logic [BUS_WIDTH-1:0]           rd1;
    logic [BUS_WIDTH-1:0]           rd2;
    logic [BUS_WIDTH-1:0]           reg_file_wd3;
    logic                           rf_wren;

    // Immediate Extend
    logic [BUS_WIDTH-1:0]           imm_ext;
    instr_type_t                    imm_dec_ctrl;

    // ALU
    logic                           alu_taken_br;
    logic [BUS_WIDTH-1:0]           alu_result;
    alu_op_t                        alu_op;
    alu_HEHE_ctrl_t                 alu_mux_a_ctrl;
    alu_HAHA_ctrl_t                 alu_mux_b_ctrl;

    // Data Memory
    logic [BUS_WIDTH-1:0]           write_data;
    logic [BUS_WIDTH-1:0]           d_mem_addr;
    logic [BUS_WIDTH-1:0]           read_data;
    logic                           mem_write;

    rf_mux_ctrl_t                   rf_mux_ctrl;
    
    //----------------------------//
    //  Intermediate Assignments  //
    //----------------------------//

    always_comb begin
        // Register File
        instr_rs2   = instr[24:20];
        instr_rs1   = instr[19:15];
        instr_rd    = instr[11:7];
    end


    //------------------------//
    //  Module Instantiation  //
    //------------------------//

    // Control Unit
    cpu_ctrl u_cpu_ctrl (
        .i_instr(instr),
        .i_taken_br(alu_taken_br),

        .o_pc_mux_ctrl(pc_mux_ctrl),
        .o_imm_dec_ctrl(imm_dec_ctrl),
        .o_rf_wren(rf_wren),
        .o_alu_op(alu_op),
        .o_alu_mux_a_ctrl(alu_mux_a_ctrl),
        .o_alu_mux_b_ctrl(alu_mux_b_ctrl),
        .o_rf_mux_ctrl(rf_mux_ctrl),
        .o_dmem_wren(mem_write)
    );
    
    // Program Counter
    pc # (
        .BUS_WIDTH(BUS_WIDTH)
    ) u_pc (
        .clk(clk),
        .ares(ares),
        .sres(sres),

        .i_src1(rd1),
        .i_imm(imm_ext),

        .i_en(1'b1),        // Always Enabled for single cycle processor
        .i_pc_mux_ctrl(pc_mux_ctrl),

        .o_pc(pc)
    );

    // Instruction Memory
    instr_mem #(
        .D_WIDTH(BUS_WIDTH),
        .A_WIDTH(I_MEM_ADDR_WIDTH)
    ) u_instr_mem (
        .clk(clk),

        .i_addr(pc[I_MEM_ADDR_WIDTH-1:0]),
        .o_data(instr)
    );

        // Register File
    reg_file # (
        .D_WIDTH(BUS_WIDTH),
        .A_WIDTH(REG_FILE_A_WIDTH),
        .N_REG(REG_FILE_DEPTH)
    ) u_reg_file (
        .clk(clk),
        .ares(ares),
        .sres(sres),

        // Read Ports
        .i_addr_rs1(instr_rs1),
        .i_addr_rs2(instr_rs2),

        .o_data_rs1(rd1),
        .o_data_rs2(rd2),

        // Write Port
        .i_data_rd(reg_file_wd3),
        .i_addr_rd(instr_rd),
        .i_wr_en_rd(rf_wren)
    );

    // Sign Extend
    sign_ext #(
        .BUS_WIDTH(BUS_WIDTH)
    ) u_sign_ext (
        .i_instr(instr[BUS_WIDTH-1:7]), // Lower 7b are op codes
        .i_imm_dec_ctrl(imm_dec_ctrl),

        .o_imm_ext(imm_ext)
    );

    alu_wrap #(
        .D_WIDTH(BUS_WIDTH)
    ) u_alu_wrap (
        
        .i_alu_op(alu_op),
        .i_alu_mux_a_ctrl(alu_mux_a_ctrl),
        .i_alu_mux_b_ctrl(alu_mux_b_ctrl),

        .i_src1(rd1),
        .i_src2(rd2),
        .i_pc(pc),
        .i_imm(imm_ext),

        .o_taken_br(alu_taken_br),
        .o_alu_result(alu_result)
    );

    always_comb begin
        write_data  = rd2;
        d_mem_addr  = alu_result;

        reg_file_wd3 = rf_mux_ctrl ? read_data : alu_result;
    end

    // Data Memory
    data_mem #(
        .D_WIDTH(BUS_WIDTH),
        .A_WIDTH(D_MEM_ADDR_WIDTH)
    ) u_data_mem (
        .clk(clk),

        .i_data(write_data),
        .i_addr(d_mem_addr[D_MEM_ADDR_WIDTH-1:0]),
        .i_wr_en(mem_write),    
        .o_data(read_data)
    );

    
endmodule
