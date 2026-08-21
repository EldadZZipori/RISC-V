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

    // Instruction Memory
    logic [BUS_WIDTH-1:0]           instr;

    // Register File
    logic [REG_FILE_A_WIDTH-1:0]    rs1;
    logic [REG_FILE_A_WIDTH-1:0]    rs2;
    logic [REG_FILE_A_WIDTH-1:0]    rd;

    // Instruction Decode
    logic [6:0]                     funct7;
    logic [2:0]                     funct3;
    logic [19:0]                    imm;

    // Immediate Extend
    logic [BUS_WIDTH-1:0]           imm_ext;

    //----------------------------//
    //  Intermediate Assignments  //
    //----------------------------//

    always_comb begin
        // Register File
        rs2     = instr[24:20];
        rs1     = instr[19:15];
        rd      = instr[11:7];

        // Instruction Decode
        funct7  = instr[31:25];
        funct3  = instr[14:12];

        // Immediate Extend
        imm_ext = {20{instr[31]}, instr[31:20]};

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
        .i_addr_rs1(rs1),
        .i_addr_rs2(rs2),

        .o_data_rs1(),
        .o_data_rs2(),

        // Write Port
        .i_data_rd(rd),
        .i_addr_rd(),
        .i_wr_en_rd()
    );

    // Arithmetic Logic Unit
    alu #(
        .D_WIDTH(BUS_WIDTH)
    ) u_alu (
        .i_data_a(),
        .i_data_b(),
        .i_operand(),

        .o_data()
    );

    // Data Memory
    data_mem #(
        .D_WIDTH(BUS_WIDTH),
        .A_WIDTH(D_MEM_ADDR_WIDTH)
    ) u_data_mem (
        .clk(clk),

        .i_data(),
        .i_addr(),
        .i_wr_en(),
        .o_data()
    );

    
endmodule