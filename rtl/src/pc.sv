// Program Counter
module pc # (
    parameter BUS_WIDTH = 32
)(
    input  logic                    clk,
    input  logic                    ares,
    input  logic                    sres,

    input  logic [BUS_WIDTH-1:0]    i_next_pc,
    input  logic                    i_en,
    output logic [BUS_WIDTH-1:0]    o_pc
);

    always_ff @(posedge clk or posedge ares) begin
        if (ares) begin
            o_pc <= '0;
        end 
        else if (sres) begin
            o_pc <= '0;
        end 
        else if (i_en) begin
            o_pc <= i_next_pc; 
        end
    end
    
endmodule