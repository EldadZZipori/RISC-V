// Dual-Port Memory 
module dp_ram # (
    parameter D_WIDTH = 32,
    parameter A_WIDTH = 8,
    localparam MEM_DEPTH = 2 ** A_WIDTH
)(
    input  logic                    clk,

    input  logic [D_WIDTH-1:0]      i_data_a,
    input  logic [A_WIDTH-1:0]      i_addr_a,
    input  logic                    i_wr_en_a,
    output logic [D_WIDTH-1:0]      o_data_a,

    input  logic [D_WIDTH-1:0]      i_data_b,
    input  logic [A_WIDTH-1:0]      i_addr_b,
    input  logic                    i_wr_en_b,
    output logic [D_WIDTH-1:0]      o_data_b
);

    // Memory o7
    logic [0:MEM_DEPTH-1][D_WIDTH-1:0] mem;

    always_ff @(posedge clk) begin
        if (i_wr_en_a) begin
            mem[i_addr_a] <= i_data_a;
        end
        if (i_wr_en_b) begin
            mem[i_addr_b] <= i_data_b;
        end
    end
   
    always_comb begin
        o_data_a = mem[i_addr_a];     
        o_data_b = mem[i_addr_b];
    end

endmodule