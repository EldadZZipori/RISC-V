// Register File
module reg_file # (
    parameter D_WIDTH = 32,
    parameter A_WIDTH = 5,
    localparam N_REG = 32
)(
    input  logic                    clk,
    input  logic                    ares,
    input  logic                    sres,

    // Read Ports
    input  logic [A_WIDTH-1:0]      i_addr_rs1,     // Source register 1 address
    input  logic [A_WIDTH-1:0]      i_addr_rs2,     // Source register 2 address

    output logic [D_WIDTH-1:0]      o_data_rs1,
    output logic [D_WIDTH-1:0]      o_data_rs2,

    // Write Port
    input  logic [D_WIDTH-1:0]      i_data_rd,      // Destination register data
    input  logic [A_WIDTH-1:0]      i_addr_rd,      // Destination register address
    input  logic                    i_wr_en_rd      // Destination register write enable 

);

    // Register File o7
    logic [0:N_REG-1][D_WIDTH-1:0] mem;

    integer i;
    always_ff @(posedge clk or posedge ares) begin
        if (ares) begin
            for (i = 0; i < N_REG; i = i + 1) begin
                mem[i] <= '0;
            end
        end
        else if (sres) begin
            for (i = 0; i < N_REG; i = i + 1) begin
                mem[i] <= '0;
            end
        end
        else if (i_wr_en_rd) begin
            if (i_addr_rd == 5'b0) begin
                mem[i_addr_rd] <= '0;
            end
            else begin
                mem[i_addr_rd] <= i_data_rd;
            end
        end
    end
   
    always_comb begin
        o_data_rs1  = mem[i_addr_rs1];     
        o_data_rs2  = mem[i_addr_rs2];
    end

endmodule