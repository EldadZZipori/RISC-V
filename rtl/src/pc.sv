// Program Counter
module pc # (
    parameter BUS_WIDTH = 32
)(
    input  logic                    clk,
    input  logic                    ares,
    input  logic                    sres,

    input  logic [BUS_WIDTH-1:0]    i_src1,
    input  logic [BUS_WIDTH-1:0]    i_imm,

    input  logic                    i_en,
    input  logic                    i_pc_mux_ctrl,

    output logic [BUS_WIDTH-1:0]    o_pc
);
    // PC internal
    logic [BUS_WIDTH-1:0]   pc;

    // PC mux wires
    logic [BUS_WIDTH-1:0]   jalr_tgt_pc_inter;
    logic [BUS_WIDTH-1:0]   jalr_tgt_pc;
    logic [BUS_WIDTH-1:0]   br_tgt_pc;
    logic [BUS_WIDTH-1:0]   i_next_pc;

    // Intermediate wires
    assign jalr_tgt_pc_inter = src1 + imm;
    assign jalr_tgt_pc  = {jalr_tgt_pc_inter[31:1], 1'b0};
    assign br_tgt_pc    = pc + imm;

    // PC mux logic
    always_comb begin : pc_mux
        case (i_pc_mux_ctrl) : pc_mux
            PC_MUX_4: begin
                i_next_pc = pc + 4;
            end
            PC_MUX_JALR_TGT: begin
                i_next_pc = jalr_tgt_pc;
            end
            PC_MUX_BR_TGT: begin
                i_next_pc = br_tgt_pc;
            end
            default: begin
                i_next_pc = pc + 4;
            end
        endcase
    end

    // PC Register
    always_ff @(posedge clk or posedge ares) begin
        if (ares) begin
            pc <= '0;
        end 
        else if (sres) begin
            pc <= '0;
        end 
        else if (i_en) begin
            pc <= i_next_pc; 
        end
    end

    assign o_pc = pc;
    
endmodule
