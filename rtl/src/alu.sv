// Arithmetic Logic Unit
import pkg::*;

module alu #(
    parameter D_WIDTH = 32
) (
    input  logic [D_WIDTH-1:0]      i_data_a,
    input  logic [D_WIDTH-1:0]      i_data_b,
    input  alu_op_t                 i_operand,

    output logic [D_WIDTH-1:0]      o_data,
    output logic                    o_taken_br
);

    logic [2*D_WIDTH-1:0] data_a_ext; // sign extended version of i_data_a
    assign data_a_ext = {{32{i_data_a[31]}}, i_data_a};
    logic same_sign;
    assign same_sign = i_data_a[31] == i_data_b[31];
    logic a_less_than_b;
    assign a_less_than_b = i_data_a < i_data_b;

    always_comb begin
        o_data = 32'b0;  
        o_taken_br = 1'b0; 
        case (i_operand)
            // Arithmetic operations
            ALU_ADD:
                o_data = i_data_a + i_data_b;
            ALU_SUB:
                o_data = i_data_a - i_data_b;
            
            // Logical operations
            ALU_OR:
                o_data = i_data_a | i_data_b;
            ALU_XOR:
                o_data = i_data_a ^ i_data_b;
            ALU_AND:
                o_data = i_data_a & i_data_b;
            ALU_SLL:    // shift left logic
                o_data = i_data_a << i_data_b[4:0];
            ALU_SRL:    // shift right logic
                o_data = i_data_a >> i_data_b[4:0];
            ALU_SRA:    // shift right arithmetic
                o_data = 32'({data_a_ext >> i_data_b[4:0]});

            // Set operations
            ALU_SLT:    // set if less than
                o_data = (same_sign ? {31'b0, a_less_than_b} : {31'b0, i_data_a[31]});
            ALU_SLTU:   // set if less than unsigned
                o_data = {31'b0, a_less_than_b};

            // Load immediate operations
            ALU_LUI:    // load upper immediate
                o_data = {i_data_b[31:12], 12'b0};

            // Branch operations
            ALU_BEQ:    // branch if equal
                o_taken_br = i_data_a == i_data_b;
            ALU_BNE:    // branch if NOT equal
                o_taken_br = i_data_a != i_data_b;
            ALU_BLT:    // branch if less than
                o_taken_br = (a_less_than_b) ^ (!same_sign);    // (i_data_a <  i_data_b) ^ (i_data_a[31] != i_data_b[31])
            ALU_BGE:    // branch if greater than or equal
                o_taken_br = (!a_less_than_b) ^ (!same_sign);   // (i_data_a >= i_data_b) ^ (i_data_a[31] != i_data_b[31])
            ALU_BLTU:   // branch if less than unsigned
                o_taken_br = a_less_than_b;                     // i_data_a < i_data_b
            ALU_BGEU:   // branch if greather than or equal unsigned
                o_taken_br = a_less_than_b;                     // i_data_a >= i_data_b
            ALU_NULL: begin
                o_data = 32'b0;  
                o_taken_br = 1'b0;   
            end       
            default: begin
                o_data = 32'b0;
                o_taken_br = 1'b0;
            end
        endcase
    end
    
endmodule
