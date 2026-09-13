// ALU Wrapper
import pkg::*;

module alu_wrap #(
    parameter D_WIDTH = 32
) (
    input  alu_op_t         i_alu_op,
    input  alu_HEHE_ctrl_t  i_alu_mux_a_ctrl,
    input  alu_HAHA_ctrl_t  i_alu_mux_b_ctrl,

    input  logic [31:0]     i_src1,
    input  logic [31:0]     i_src2,
    input  logic [31:0]     i_pc,
    input  logic [31:0]     i_imm,

    output logic            o_taken_br,
    output logic [31:0]     o_alu_result
);
    logic [31:0] selected_data_a; // output of alu_mux_a
    logic [31:0] selected_data_b; // output of alu_mux_b

    always_comb begin : alu_muxes
        case (i_alu_mux_a_ctrl)
            ALU_CTRL_SRC1:  selected_data_a = i_src1;
            ALU_CTRL_PC:    selected_data_a = i_pc;
            default:        selected_data_a = i_src1;
        endcase

        case (i_alu_mux_b_ctrl)
            ALU_CTRL_SRC2:  selected_data_b = i_src2;
            ALU_CTRL_IMM:   selected_data_b = i_imm;
            ALU_CTRL_4:     selected_data_b = 32'h4;
            default:        selected_data_b = i_src2;
        endcase
    end

    alu #(
        .D_WIDTH(D_WIDTH)
    ) u_alu (
        .i_data_a(selected_data_a),
        .i_data_b(selected_data_b),
        .i_operand(i_alu_op),

        .o_data(o_alu_result),
        .o_taken_br(o_taken_br)
    );
endmodule
