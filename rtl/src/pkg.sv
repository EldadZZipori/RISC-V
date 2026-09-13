package pkg;

    // ALU Operation
    typedef enum logic[7:0] { 
        ALU_NULL, // no operation
        
        // Arithmetic operations
        ALU_ADD, 
        ALU_SUB, 
        
        // Logical operations
        ALU_OR,
        ALU_XOR,
        ALU_AND,
        ALU_SLL,    // shift left logic
        ALU_SRL,    // shift right logic
        ALU_SRA,    // shift right arithmetic

        // Set operations
        ALU_SLT,    // set if less than
        ALU_SLTU,   // set if less than unsigned

        // Load immediate operations
        ALU_LUI,    // load upper immediate

        // Branch operations
        ALU_BEQ,    // branch if equal
        ALU_BNE,    // branch if NOT equal
        ALU_BLT,    // branch if less than
        ALU_BGE,    // branch if greater than or equal
        ALU_BLTU,   // branch if less than unsigned
        ALU_BGEU    // branch if greather than or equal unsigned
    } alu_op_t;

    // Instruction Operation 
    typedef enum logic[7:0] {
        INSTR_NULL,
        // Arithmetic
        // Arithmetic R-Type
        INSTR_ADD,
        INSTR_SUB,
        INSTR_AND,
        INSTR_OR,
        INSTR_XOR,
        INSTR_SLL,
        INSTR_SRL,
        INSTR_SRA,
        INSTR_SLT,
        INSTR_SLTU,

        // Arithmetic I-Type
        INSTR_ADDI,
        INSTR_ANDI,
        INSTR_ORI,
        INSTR_XORI,
        INSTR_SLTI,
        INSTR_SLTIU,
        INSTR_SLLI,
        INSTR_SRLI,
        INSTR_SRAI,

        // Memory
        // Memory I-Type
        INSTR_LB,
        INSTR_LBU,
        INSTR_LH,
        INSTR_LHU,
        INSTR_LW,

        // Memory S-Type
        INSTR_SB,
        INSTR_SH,
        INSTR_SW,

        // Control
        // Control B-Tyoe
        INSTR_BEQ,
        INSTR_BNE,
        INSTR_BLT,
        INSTR_BLTU,
        INSTR_BGE,
        INSTR_BGEU,

        // Control J-Type & I-Type
        INSTR_JAL,
        INSTR_JALR,

        // Other
        // Other U-Type
        INSTR_AUIPC,
        INSTR_LUI,

        // Other I-Type
        INSTR_EBREAK,
        INSTR_ECALL
    } instr_op_t;

    // Instruction Type
    typedef enum logic[2:0] { 
        NULL_TYPE,
        I_TYPE, 
        S_TYPE, 
        B_TYPE, 
        U_TYPE, 
        J_TYPE, 
        R_TYPE
    } instr_type_t;

    // PC Mux 
    typedef enum logic [1:0] {
        PC_MUX_4,
        PC_MUX_JALR_TGT,
        PC_MUX_BR_TGT 
    } pc_mux_ctrl_t;

    // ALU Mux
    typedef enum logic [0:0] {
        ALU_CTRL_SRC1,
        ALU_CTRL_PC
    }   alu_HEHE_ctrl_t; // mux_a

    typedef enum logic [1:0] {
        ALU_CTRL_SRC2,
        ALU_CTRL_IMM,
        ALU_CTRL_4
    }   alu_HAHA_ctrl_t; // mux_b

    // RF Mux
    typedef enum logic[0:0] {
        RF_CTRL_ALU,
        RF_CTRL_DMEM
    }   rf_mux_ctrl_t;

endpackage
