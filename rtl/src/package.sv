package pkg;
    parameter NUM_OPS = 8;
    parameter IMM_SRC_WIDTH = 3;
    parameter OP_WIDTH = $clog2(NUM_OPS);

    typedef enum logic[OP_WIDTH-1:0] { 
        ADD, SUB, SHL, SHR
    } operand_t;

    typedef enum logic[IMM_SRC_WIDTH-1:0] { 
        I_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE, R_TYPE
    } operand_t;


endpackage