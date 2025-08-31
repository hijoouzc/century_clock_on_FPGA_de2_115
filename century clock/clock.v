module clock # (
    parameter DIVIDER = 50_000_000
)(
    input  wire clk, rst,
    output reg  clk_out
);
    localparam CNT_WIDTH = $clog2(DIVIDER >> 1);
    reg [CNT_WIDTH - 1:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count   <= 0;
            clk_out <= 0;
        end else begin
            if (count == (DIVIDER >> 1) - 1) begin
                clk_out <= ~clk_out;
                count   <= 0;
            end else begin
                count <= count + 1;
            end
        end
    end
endmodule