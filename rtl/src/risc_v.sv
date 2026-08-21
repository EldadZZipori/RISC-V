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

    // Instruction Memory
    logic [BUS_WIDTH-1:0]           instr;

    // Register File
    logic [REG_FILE_A_WIDTH-1:0]    instr_rs1;
    logic [REG_FILE_A_WIDTH-1:0]    instr_rs2;
    logic [REG_FILE_A_WIDTH-1:0]    instr_rd;
    logic [REG_FILE_A_WIDTH-1:0]    rd1;
    logic [REG_FILE_A_WIDTH-1:0]    rd2;
    logic [BUS_WIDTH-1:0]           reg_file_wd3;


    // Instruction Decode
    logic [6:0]                     funct7;
    logic [2:0]                     funct3;
    logic [19:0]                    imm;

    // Immediate Extend
    logic [BUS_WIDTH-1:0]           imm_ext;

    // ALU
    logic [BUS_WIDTH-1:0]           alu_src_a;
    logic [BUS_WIDTH-1:0]           alu_src_b;
    logic                           alu_zero;
    logic [BUS_WIDTH-1:0]           alu_result;

    // Data Memory
    logic [BUS_WIDTH-1:0]           write_data;
    logic [BUS_WIDTH-1:0]           d_mem_addr;
    logic [BUS_WIDTH-1:0]           read_data;

    //----------------------------//
    //  Intermediate Assignments  //
    //----------------------------//

    always_comb begin
        // Register File
        instr_rs2   = instr[24:20];
        instr_rs1   = instr[19:15];
        instr_rd    = instr[11:7];

        // Instruction Decode
        funct7      = instr[31:25];
        funct3      = instr[14:12];

        // Program Counter
        pc_target   = pc + imm_ext;
        pc_plus_4   = pc + 4;

        next_pc = ? pc_target : pc_plus_4; // #TODO: add pc_src

    end


    //------------------------//
    //  Module Instantiation  //
    //------------------------//

    // Program Counter
    pc # (
        .BUS_WIDTH(BUS_WIDTH)
    ) u_pc (
        .clk(clk),
        .ares(ares),
        .sres(sres),

        .i_next_pc(next_pc),
        .i_en(1'b1),        // Always Enabled
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
        .i_wr_en_rd()   // TODO: add reg_write
    );

    // Sign Extend
    sign_ext #(
        .BUS_WIDTH(BUS_WIDTH)
    ) u_sign_ext (
        .i_instr(instr),
        .i_imm_src(),

        .o_imm_ext(imm_ext)
    );

    always_comb begin
        alu_src_a   = rd1;
        alu_src_b   = ? imm_ext : rd2;  // TODO: add alu_src
    end

    // Arithmetic Logic Unit
    alu #(
        .D_WIDTH(BUS_WIDTH)
    ) u_alu (
        .i_data_a(alu_src_a),
        .i_data_b(alu_src_b),
        .i_operand(),       // TODO: add alu_control

        .o_data(alu_result),
        .o_zero(alu_zero)
    );

    always_comb begin
        write_data  = rd2;
        d_mem_addr  = alu_result;

        reg_file_wd3 = ? read_data : alu_result; // TODO: add result_src
    end

    // Data Memory
    data_mem #(
        .D_WIDTH(BUS_WIDTH),
        .A_WIDTH(D_MEM_ADDR_WIDTH)
    ) u_data_mem (
        .clk(clk),

        .i_data(write_data),
        .i_addr(d_mem_addr),
        .i_wr_en(),     // TODO: add mem_write
        .o_data(read_data)
    );

    
endmodule