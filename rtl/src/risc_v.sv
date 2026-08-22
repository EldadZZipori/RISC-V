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
    logic [BUS_WIDTH-1:0]           next_pc;
    logic [BUS_WIDTH-1:0]           pc_target;
    logic [BUS_WIDTH-1:0]           pc_plus_4;
    pc_src_t                        pc_src;

    // Instruction Memory
    logic [BUS_WIDTH-1:0]           instr;

    // Register File
    logic [REG_FILE_A_WIDTH-1:0]    instr_rs1;
    logic [REG_FILE_A_WIDTH-1:0]    instr_rs2;
    logic [REG_FILE_A_WIDTH-1:0]    instr_rd;
    logic [REG_FILE_A_WIDTH-1:0]    rd1;
    logic [REG_FILE_A_WIDTH-1:0]    rd2;
    logic [BUS_WIDTH-1:0]           reg_file_wd3;
    logic                           reg_file_wr;


    // Instruction Decode
    logic [6:0]                     instr_funct7;
    logic [2:0]                     instr_funct3;
    logic [19:0]                    instr_imm;
    instr_op_t                      instr_op;

    // Immediate Extend
    logic [BUS_WIDTH-1:0]           imm_ext;
    instr_t                         imm_src;

    // ALU
    logic [BUS_WIDTH-1:0]           alu_src_a;
    logic [BUS_WIDTH-1:0]           alu_src_b;
    logic                           alu_zero;
    logic [BUS_WIDTH-1:0]           alu_result;
    logic [2:0]                     alu_op;
    alu_src_b_ctrl_t                alu_srcb_ctrl;

    // Data Memory
    logic [BUS_WIDTH-1:0]           write_data;
    logic [BUS_WIDTH-1:0]           d_mem_addr;
    logic [BUS_WIDTH-1:0]           read_data;
    logic                           mem_write;

    logic                           cpu_result_src;
    //----------------------------//
    //  Intermediate Assignments  //
    //----------------------------//

    always_comb begin
        // Register File
        instr_rs2   = instr[24:20];
        instr_rs1   = instr[19:15];
        instr_rd    = instr[11:7];

        // Instruction Decode
        instr_funct7      = instr[31:25];
        instr_funct3      = instr[14:12];
        instr_op          = instr_op_t'(instr[6:0]);

        // Program Counter
        pc_target   = pc + imm_ext;
        pc_plus_4   = pc + 4;

    end

    // pc source
    always_comb begin 
        case (pc_src)
            IMM_EXT: next_pc = pc_target;
            default: next_pc = pc_plus_4;
        endcase
    end


    //------------------------//
    //  Module Instantiation  //
    //------------------------//

    // Control Unit
    cpu_ctrl u_cpu_ctrl (
        .i_op(instr_op),
        .i_funct3(instr_funct3),
        .i_funct7_5(instr_funct7[5]),
        .i_zero(alu_zero),
        .o_pc_src(pc_src)
        .o_cpu_result_src(cpu_result_src)
        .o_mem_write(mem_write),
        .o_alu_op(alu_op),
        .o_alu_srcb_ctrl(alu_srcb_ctrl),
        .o_imm_src(imm_src),
        .o_rreg_file_wr(reg_file_wr)
    );
    
    // Program Counter
    pc # (
        .BUS_WIDTH(BUS_WIDTH)
    ) u_pc (
        .clk(clk),
        .ares(ares),
        .sres(sres),

        .i_next_pc(next_pc),
        .i_en(1'b1),        // Always Enabled for single cycle processor
        .o_pc(pc)
    );

    // Instruction Memory
    instr_mem #(
        .D_WIDTH(BUS_WIDTH),
        .A_WIDTH(I_MEM_ADDR_WIDTH)
    ) u_instr_mem (
        .clk(clk),

        .i_addr(pc),
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
        .i_data_rd(instr_rd),
        .i_addr_rd(reg_file_wd3),
        .i_wr_en_rd(reg_file_wr)
    );

    // Sign Extend
    sign_ext #(
        .BUS_WIDTH(BUS_WIDTH)
    ) u_sign_ext (
        .i_instr(instr),
        .i_imm_src(imm_src),

        .o_imm_ext(imm_ext)
    );

    always_comb begin
        alu_src_a   = rd1;
    end

    always_comb begin
        case (alu_srcb_ctrl)
            IMM_EXT: alu_src_b = imm_ext;
            default: alu_src_b = rd2;
        endcase
    end

    // Arithmetic Logic Unit
    alu #(
        .D_WIDTH(BUS_WIDTH)
    ) u_alu (
        .i_data_a(alu_src_a),
        .i_data_b(alu_src_b),
        .i_operand(alu_op),

        .o_data(alu_result),
        .o_zero(alu_zero)
    );

    always_comb begin
        write_data  = rd2;
        d_mem_addr  = alu_result;

        reg_file_wd3 = cpu_result_src ? read_data : alu_result;
    end

    // Data Memory
    data_mem #(
        .D_WIDTH(BUS_WIDTH),
        .A_WIDTH(D_MEM_ADDR_WIDTH)
    ) u_data_mem (
        .clk(clk),

        .i_data(write_data),
        .i_addr(d_mem_addr),
        .i_wr_en(mem_write),    
        .o_data(read_data)
    );

    
endmodule