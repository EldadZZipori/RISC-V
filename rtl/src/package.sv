package pkg;
    parameter NUM_OPS = 8;
    parameter IMM_SRC_WIDTH = 3;
    parameter OP_WIDTH = $clog2(NUM_OPS);

    typedef enum logic[1:0] { // TODO: formalize bit width
        ADD     = 2'b00, 
        SUB     = 2'b01, 
        R_TYPE  = 2'b10,
    } alu_op_t;

    typedef enum logic[OP_WIDTH-1:0] { 
        ADD = 3'b000,
        SUB = 3'b001,
        SLT = 3'b101,
        OR  = 3'b011,
        AND = 3'b011
    } alu_cntr_t;

    typedef enum logic[6:0] {
        LW      = 7'b000011,
        SW      = 7'b0100011,
        BEQ     = 7'b1100011,
        R_TYPE  = 7'b1100011,
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