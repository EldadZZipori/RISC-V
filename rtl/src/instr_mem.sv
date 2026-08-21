// Instruction Memory
module instr_mem #(
    parameter D_WIDTH = 32,
    parameter A_WIDTH = 8
) (
    input  logic                    clk,

    input  logic [A_WIDTH-1:0]      i_addr,
    output logic [D_WIDTH-1:0]      o_data
);

    dp_ram # (
    .D_WIDTH(D_WIDTH),
    .A_WIDTH(A_WIDTH)
    ) u_dp_ram (
        .clk(clk),

        .i_data_a(),
        .i_addr_a(i_addr),
        .i_wr_en_a(),
        .o_data_a(o_data),

        .i_data_b(),
        .i_addr_b(),
        .i_wr_en_b(),
        .o_data_b()
    );
    
endmodule