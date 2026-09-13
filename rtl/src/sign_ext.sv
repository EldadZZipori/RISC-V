// Sign Extend
import pkg::*;

module sign_ext #(
    parameter BUS_WIDTH = 32
) (
    input logic     [BUS_WIDTH-1:0] i_instr,
    input instr_type_t                   i_imm_dec_ctrl,

    output logic    [BUS_WIDTH-1:0] o_imm_ext
);

    always_comb begin
        case (i_imm_dec_ctrl)
            I_TYPE: begin
                o_imm_ext = {{20{i_instr[31]}}, i_instr[31:20]};
            end

            S_TYPE: begin
                o_imm_ext = {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]};
            end

            B_TYPE: begin
                o_imm_ext = {{19{i_instr[31]}}, i_instr[7], i_instr[30:25], i_instr[11:8], i_instr[20], 1'b0};    
            end

            U_TYPE: begin
                o_imm_ext = {i_instr[31:12], 12'b0}; 
            end

            J_TYPE: begin
                o_imm_ext = {{11{i_instr[31]}}, i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0};
            end

            R_TYPE: begin
                o_imm_ext = '0;
            end

            default: begin
                o_imm_ext = '0;
            end
        endcase
    end
    
endmodule
