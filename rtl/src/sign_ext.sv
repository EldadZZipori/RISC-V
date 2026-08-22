// Sign Extend
import pkg::*;

module sign_ext #(
    parameter BUS_WIDTH = 32
) (
    input logic     [BUS_WIDTH-1:0] i_instr,
    input instr_t                   i_imm_src,

    output logic    [BUS_WIDTH-1:0] o_imm_ext
);

    always_comb begin
        case (i_imm_src)
            I_TYPE: begin
                o_imm_ext = {20{instr[31]}, instr[31:20]};
            end

            S_TYPE: begin
                o_imm_ext = {20{instr[31]}, instr[30:25], instr[11:7]}
            end

            B_TYPE: begin
                o_imm_ext = '0; // TODO: IMPLEMENT LATER
            end

            U_TYPE: begin
                o_imm_ext = '0; // TODO: IMPLEMENT LATER
            end

            J_TYPE: begin
                o_imm_ext = '0; // TODO: IMPLEMENT LATER
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