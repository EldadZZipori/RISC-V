import pkg::*;

module cpu_ctrl #(
) (
    input  logic [31:0]     i_instr,
    input  logic            i_taken_br,

    output pc_mux_ctrl_t    o_pc_mux_ctrl,
    output instr_type_t     o_imm_dec_ctrl, // 
    output logic            o_rf_wren,
    output alu_op_t         o_alu_op,
    output alu_HEHE_ctrl_t  o_alu_mux_a_ctrl,
    output alu_HAHA_ctrl_t  o_alu_mux_b_ctrl,
    output rf_mux_ctrl_t    o_rf_mux_ctrl,
    output logic            o_dmem_wren
);

    //-------------------------------//
    //  Instruction Breakdown Wires  //
    //-------------------------------//
    logic [6:0]         opcode;
    logic [2:0]         funct3;
    logic [6:0]         funct7;
    logic [4:0]         rd;
    
    assign opcode   = i_instr[6:0];
    assign funct3   = i_instr[14:12];
    assign funct7   = i_instr[31:25];
    assign rd       = i_instr[11:7];
    
    //--------------------------//
    //  Instruction Type Wires  //
    //--------------------------//
    instr_type_t    instr_type;

    //-------------------------------//
    //  Instruction Operation Wires  //
    //-------------------------------//
    instr_op_t      instr_op;
    logic           is_load;
    logic           i_type_imm_0;
    
    assign is_load      = (opcode == 7'b000_0011);
    assign i_type_imm_0 = i_instr[20];

    //-----------------------------------//
    //  DMEM Write Enable Wires & Logic  //
    //-----------------------------------//
    assign o_dmem_wren  = (instr_type == S_TYPE);

    //---------------------------------//
    //  RF Write Enable Wires & Logic  //
    //---------------------------------//
    assign o_rf_wren = (rd == 5'b0) ? 1'b0 : (instr_type inside {R_TYPE, I_TYPE, U_TYPE, J_TYPE});

    //----------------------------------//
    //  Immediate Decode Wires & Logic  //
    //----------------------------------//
    assign o_imm_dec_ctrl = instr_type;

    //---------------------------//
    //  Instruction Type Decode  //
    //---------------------------//
    always_comb begin : instr_type_decode
        casez (opcode)
            7'b011_00??: 
                instr_type = R_TYPE;
            7'b001_00??, 7'b000_00??, 7'b110_01??, 7'b111_00??: 
                instr_type = I_TYPE;
            7'b010_00??:
                instr_type = S_TYPE;
            7'b110_00??:
                instr_type = B_TYPE;
            7'b110_11??:
                instr_type = J_TYPE;
            7'b011_01??, 7'b001_011??:
                instr_type = U_TYPE;
            default: 
                instr_type = NULL_TYPE;
        endcase
    end

    //-------------------------------//
    //  Instruction Operation Logic  //
    //-------------------------------//
    always_comb begin : instr_op_decode
        casez ({funct7, funct3, opcode})
            // Arithmetic 
            // Arithmetic R-Type
            17'b?0?????_000_0110111: instr_op = INSTR_ADD;
            17'b?1?????_000_0110111: instr_op = INSTR_SUB;
            17'b?0?????_111_0110111: instr_op = INSTR_AND;
            17'b?0?????_110_0110111: instr_op = INSTR_OR;
            17'b?0?????_100_0110111: instr_op = INSTR_XOR;
            17'b?0?????_001_0110111: instr_op = INSTR_SLL;
            17'b?0?????_101_0110111: instr_op = INSTR_SRL;
            17'b?1?????_101_0110111: instr_op = INSTR_SRA;
            17'b?0?????_010_0110111: instr_op = INSTR_SLT;
            17'b?0?????_011_0110111: instr_op = INSTR_SLTU;

            // Arithmetic I-Type
            17'b???????_000_0010011: instr_op = INSTR_ADDI;
            17'b???????_111_0010011: instr_op = INSTR_ANDI;
            17'b???????_110_0010011: instr_op = INSTR_ORI;
            17'b???????_100_0010011: instr_op = INSTR_XORI;
            17'b???????_010_0010011: instr_op = INSTR_SLTI;
            17'b???????_011_0010011: instr_op = INSTR_SLTIU;
            17'b?0?????_001_0010011: instr_op = INSTR_SLLI;
            17'b?0?????_101_0010011: instr_op = INSTR_SRLI;
            17'b?1?????_101_0010011: instr_op = INSTR_SRAI;

            // Memory
            // Memory I-Type
            17'b???????_000_0000011: instr_op = INSTR_LB;
            17'b???????_100_0000011: instr_op = INSTR_LBU;
            17'b???????_001_0000011: instr_op = INSTR_LH;
            17'b???????_101_0000011: instr_op = INSTR_LHU;
            17'b???????_010_0000011: instr_op = INSTR_LW;

            // Memory S-Type 
            17'b???????_000_0100011: instr_op = INSTR_SB;
            17'b???????_001_0100011: instr_op = INSTR_SH;
            17'b???????_010_0100011: instr_op = INSTR_SW;

            // Control
            // Control B-Type
            17'b???????_000_1100011: instr_op = INSTR_BEQ;
            17'b???????_001_1100011: instr_op = INSTR_BNE;
            17'b???????_100_1100011: instr_op = INSTR_BLT;
            17'b???????_110_1100011: instr_op = INSTR_BLTU;
            17'b???????_101_1100011: instr_op = INSTR_BGE;
            17'b???????_111_1100011: instr_op = INSTR_BGEU;

            // Control J-Type & I-Type
            17'b???????_???_1101111: instr_op = INSTR_JAL;
            17'b???????_000_1100111: instr_op = INSTR_JALR;

            // Other
            // Other U-Type
            17'b???????_???_0010111: instr_op = INSTR_AUIPC;
            17'b???????_???_0110111: instr_op = INSTR_LUI;

            // Other I-Type
            17'b???????_000_1110011: 
                instr_op = i_type_imm_0 ? INSTR_ECALL : INSTR_EBREAK;

            default: instr_op = INSTR_NULL;
        endcase
    end

    //------------------------//
    //  RF Mux Control Logic  //
    //------------------------//
    always_comb begin : rf_mux
        if (is_load) begin
            o_rf_mux_ctrl = RF_CTRL_DMEM;
        end
        else begin
            o_rf_mux_ctrl = RF_CTRL_ALU;
        end
    end

    //------------------------//
    //  PC Mux Control Wires  //
    //------------------------//
    always_comb begin : pc_mux
        if (i_taken_br || instr_op == INSTR_JAL) begin
            o_pc_mux_ctrl = PC_MUX_BR_TGT;
        end
        else if (instr_op == INSTR_JALR) begin
            o_pc_mux_ctrl = PC_MUX_JALR_TGT;
        end
        else begin
            o_pc_mux_ctrl = PC_MUX_4;
        end
    end

    //---------------------//
    //  ALU Control Logic  //
    //---------------------//
    always_comb begin : ALU_ctrl
        casez (instr_op)
            // Arithmetic I-Type
            INSTR_ANDI: begin
                o_alu_op          = ALU_AND;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_IMM;
            end
            INSTR_ORI: begin
                o_alu_op          = ALU_OR;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_IMM;
            end
            INSTR_XORI: begin
                o_alu_op          = ALU_XOR;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_IMM;
            end
            INSTR_ADDI: begin
                o_alu_op          = ALU_ADD;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_IMM;
            end
            INSTR_SLLI: begin
                o_alu_op          = ALU_SLL;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_IMM;
            end
            INSTR_SRLI: begin
                o_alu_op          = ALU_SRL;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_IMM;
            end
            INSTR_SRAI: begin
                o_alu_op          = ALU_SRA;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_IMM;
            end

            // Arithmetic R-Type
            INSTR_AND: begin
                o_alu_op          = ALU_AND;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_OR: begin
                o_alu_op          = ALU_OR;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_XOR: begin
                o_alu_op          = ALU_XOR;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_ADD: begin
                o_alu_op          = ALU_ADD;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_SUB: begin
                o_alu_op          = ALU_SUB;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_SLL: begin
                o_alu_op          = ALU_SLL;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_SRL: begin
                o_alu_op          = ALU_SRL;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_SRA: begin
                o_alu_op          = ALU_SRA;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end

            // Set Instructions
            INSTR_SLTU: begin
                o_alu_op          = ALU_SLTU;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_SLTIU: begin
                o_alu_op          = ALU_SLTU;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_IMM;
            end
            INSTR_SLT: begin
                o_alu_op          = ALU_SLT;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_SLTI: begin
                o_alu_op          = ALU_SLT;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_IMM;
            end

            INSTR_LUI: begin
                o_alu_op          = ALU_LUI;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1; // Not used
                o_alu_mux_b_ctrl  = ALU_CTRL_IMM;
            end
            INSTR_AUIPC: begin
                o_alu_op          = ALU_ADD;
                o_alu_mux_a_ctrl  = ALU_CTRL_PC;
                o_alu_mux_b_ctrl  = ALU_CTRL_IMM;
            end
            INSTR_JAL, INSTR_JALR: begin
                o_alu_op          = ALU_ADD;
                o_alu_mux_a_ctrl  = ALU_CTRL_PC;
                o_alu_mux_b_ctrl  = ALU_CTRL_4;
            end

            // Branch Logic
            INSTR_BEQ: begin
                o_alu_op          = ALU_BEQ;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_BNE: begin
                o_alu_op          = ALU_BNE;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_BLT: begin
                o_alu_op          = ALU_BLT;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_BGE: begin
                o_alu_op          = ALU_BGE;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_BLTU: begin
                o_alu_op          = ALU_BLTU;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end
            INSTR_BGEU: begin
                o_alu_op          = ALU_BGEU;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1;
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2;
            end

            default: begin 
                o_alu_op          = ALU_NULL;
                o_alu_mux_a_ctrl  = ALU_CTRL_SRC1; // Not used
                o_alu_mux_b_ctrl  = ALU_CTRL_SRC2; // Not used
            end
        endcase
    end

    
endmodule
