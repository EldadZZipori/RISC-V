`define SET_CTRL_SIGNALS(wr, imm, alu_b, mem_w, res_src, br, alu) \
    begin \
        o_reg_file_wr    = wr; \
        o_imm_src        = imm; \
        o_alu_srcb_ctrl  = alu_b; \
        o_mem_write      = mem_w; \
        o_cpu_result_src = res_src; \
        branch           = br; \
        o_alu_cntr           = alu; \
    end

module cpu_ctrl #(
    
) (
    input instr_op_t        i_op,
    input logic     [2:0]   i_funct3,
    input logic             i_funct7_5,
    input logic             i_zero,

    output pc_src_t         o_pc_src,
    output logic            o_cpu_result_src,
    output logic            o_mem_write,
    output alu_cntr_t       o_alu_cntr,
    output alu_src_b_ctrl_t o_alu_srcb_ctrl,
    output instr_t          o_imm_src,
    output logic            o_reg_file_wr
);
    logic branch;
    alu_cntr_t alu_op;

    always_comb begin
        case (i_op)
            LW:     `SET_CTRL_SIGNALS(1'b1, I_TYPE, IMM_EXT, 1'b0, 1'b1, 1'b0, ADD)
            SW:     `SET_CTRL_SIGNALS(1'b0, S_TYPE, IMM_EXT, 1'b1, 1'b0, 1'b0, ADD)
            BEQ:    `SET_CTRL_SIGNALS(1'b0, B_TYPE, RF_RD2, 1'b0, 1'b0, 1'b1, SUB)
            R_TYPE: `SET_CTRL_SIGNALS(1'b0, R_TYPE, RF_RD2, 1'b0, 1'b0, 1'b1, R_TYPE)
            default: `SET_CTRL_SIGNALS(1'b0, R_TYPE, RF_RD2, 1'b0, 1'b0, 1'b0 ADD)
        endcase
    end

    // alu control decoder
    always_comb begin
        case (alu_op)
            ADD: begin
                o_alu_cntr = ADD;
            end
            SUB: begin
                o_alu_cntr = SUB;
            end
            R_TYPE: begin
                case (i_funct3)
                    3'b000: begin
                        if ({i_op[5], i_funct7_5} == 2'b11) o_alu_cntr = SUB;
                        else o_alu_cntr = ADD;
                    end 
                    3'b010: begin
                        o_alu_cntr = SLT;
                    end
                    3'b110: begin
                        o_alu_cntr = OR;
                    end
                    default: o_alu_cntr = AND;
                endcase
            end
            default:
        endcase
    end

    assign o_pc_src = branch & i_zero;
    
endmodule