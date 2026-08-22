module cpu_ctrl #(
    
) (
    input instr_op_t        i_op,
    input logic     [2:0]   i_funct3,
    input logic             i_funct7_5,
    input logic             i_zero,

    output pc_src_t         o_pc_src,
    output logic            o_cpu_result_src,
    output logic            o_mem_write,
    output alu_op_t         o_alu_op,
    output alu_src_b_ctrl_t o_alu_srcb_ctrl,
    output instr_t          o_imm_src,
    output logic            o_reg_file_wr
);
    logic branch;

    always_comb begin
        case (i_op)
            LW : begin
                o_reg_file_wr       = 1'b1;
                o_imm_src           = I_TYPE;
                o_alu_srcb_ctrl     = IMM_EXT;
                o_mem_write         = 1'b0;
                o_cpu_result_src    = 1'b1;
                o_alu_op            = ADD;
                branch = 1'b0;
            end
            default: 
        endcase
    end

    assign o_pc_src = branch & i_zero;
    
endmodule