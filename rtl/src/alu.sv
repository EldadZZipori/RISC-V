// Arithmetic Logic Unit
import pkg::*;

module alu #(
    parameter D_WIDTH = 32
) (
    input  logic [D_WIDTH-1:0]      i_data_a,
    input  logic [D_WIDTH-1:0]      i_data_b,
    input  alu_cntr_t               i_operand,

    output logic [D_WIDTH-1:0]      o_data,
    output logic                    o_zero
);

    always_comb begin
        case (i_operand)
            ADD: begin
                o_data = i_data_a + i_data_b;
            end

            SUB: begin
                o_data = i_data_a - i_data_b;
            end

            // SHL: begin
            //     o_data = i_data_a << i_data_b;
            // end

            // SHR: begin
            //     o_data = i_data_a >> i_data_b;
            // end

            SLT: begin
                o_data = i_data_a < i_data_b ? {{(D_WIDTH-1){1'b0}}, 1'b1} : {D_WIDTH{1'b0}};
            end

            OR: begin
                o_data = i_data_a | i_data_b;
            end

            AND: begin
                o_data = i_data_a & i_data_b;
            end

            default: begin
                o_data = '0;
            end
        endcase
    end
    
endmodule
