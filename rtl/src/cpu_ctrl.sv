module cpu_ctrl #(
    
) (
    input instr_op_t        i_op,
    input logic     [2:0]   i_funct3,
    input logic             i_funct7_5,
    input logic             i_zero,

    output pc_src_t         o_pc_src,
    output cpu_res_src_t    o_cpu_result_src,
    output logic            o_mem_write,
    output alu_cntr_t       o_alu_cntr,
    output alu_src_b_ctrl_t o_alu_srcb_ctrl,
    output instr_t          o_imm_src,
    output logic            o_reg_file_wr
);
    logic branch;
    logic jump;
    alu_cntr_t alu_op;

    // op code decoder
    always_comb begin
        case (i_op)
            LW: begin
                o_reg_file_wr    = 1'b1;
                o_imm_src        = I_TYPE;
                o_alu_srcb_ctrl  = IMM_EXT;
                o_mem_write      = 1'b0;
                o_cpu_result_src = DATA_MEM;
                branch           = 1'b0;
                o_alu_cntr       = ADD;
                jump             = 1'b0;
            end
            SW: begin
                o_reg_file_wr    = 1'b0;
                o_imm_src        = S_TYPE;
                o_alu_srcb_ctrl  = IMM_EXT;
                o_mem_write      = 1'b1;
                o_cpu_result_src = ALU;
                branch           = 1'b0;
                o_alu_cntr       = ADD;
                jump             = 1'b0;
            end
            BEQ: begin
                o_reg_file_wr    = 1'b0;
                o_imm_src        = B_TYPE;
                o_alu_srcb_ctrl  = RF_RD2;
                o_mem_write      = 1'b0;
                o_cpu_result_src = ALU;
                branch           = 1'b1;
                o_alu_cntr       = SUB;
                jump             = 1'b0;
            end
            R_TYPE: begin
                o_reg_file_wr    = 1'b0;
                o_imm_src        = R_TYPE;
                o_alu_srcb_ctrl  = RF_RD2;
                o_mem_write      = 1'b0;
                o_cpu_result_src = ALU;
                branch           = 1'b1;
                o_alu_cntr       = R_TYPE;
                jump             = 1'b0;
            end
            ADDI: begin
                o_reg_file_wr    = 1'b1;
                o_imm_src        = I_TYPE;
                o_alu_srcb_ctrl  = IMM_EXT;
                o_mem_write      = 1'b0;
                o_cpu_result_src = ALU;
                branch           = 1'b1;
                o_alu_cntr       = R_TYPE;
                jump             = 1'b0;
            end
            I_TYPE: begin
                o_reg_file_wr    = 1'b1;
                o_imm_src        = R_TYPE;
                o_alu_srcb_ctrl  = RF_RD2;
                o_mem_write      = 1'b0;
                o_cpu_result_src = ALU;
                branch           = 1'b0;
                o_alu_cntr       = R_TYPE;
                jump             = 1'b0;
            end
            JAL: begin
                o_reg_file_wr    = 1'b1;
                o_imm_src        = J_TYPE;
                o_alu_srcb_ctrl  = RF_RD2;
                o_mem_write      = 1'b0;
                o_cpu_result_src = PC_P4;
                branch           = 1'b0;
                o_alu_cntr       = ADD;
                jump             = 1'b1;
            end
            default: begin
                o_reg_file_wr    = 1'b0;
                o_imm_src        = R_TYPE;
                o_alu_srcb_ctrl  = RF_RD2;
                o_mem_write      = 1'b0;
                o_cpu_result_src = ALU;
                branch           = 1'b0;
                o_alu_cntr       = ADD;
                jump             = 1'b0;
            end
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

    assign o_pc_src = (branch & i_zero) | (jump);
    
endmodule