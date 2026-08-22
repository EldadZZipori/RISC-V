package pkg;
    parameter NUM_OPS = 8;
    parameter IMM_SRC_WIDTH = 3;
    parameter OP_WIDTH = $clog2(NUM_OPS);

    typedef enum logic[OP_WIDTH-1:0] { 
        ADD, SUB, SHL, SHR
    } alu_op_t;

    typedef enum logic[6:0] {
        LW = 7'b000011
    } instr_op_t;

    typedef enum logic[IMM_SRC_WIDTH-1:0] { 
        I_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE, R_TYPE
    } instr_t;

    typedef enum logic {
        IMM_EXT = 1, PLUS_4 = 0 
    } pc_src_t;

    typedef enum logic {
        IMM_EXT = 1, RF_RD2 = 0 
    }   alu_src_b_ctrl_t;


endpackage