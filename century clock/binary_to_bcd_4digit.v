module binary_to_bcd_4digit #(
    parameter BIN_WIDTH = 14  // đủ cho 0–9999
)(
    input  wire [BIN_WIDTH-1:0] bin,
    output reg [3:0] thousands,
    output reg [3:0] hundreds,
    output reg [3:0] tens,
    output reg [3:0] ones
);
    integer i;
    reg [BIN_WIDTH+15:0] shift_reg;

    always @(*) begin
        // reset thanh ghi
        shift_reg = 0;
        shift_reg[BIN_WIDTH-1:0] = bin;

        // Double dabble
        for (i = 0; i < BIN_WIDTH; i = i + 1) begin
            if (shift_reg[BIN_WIDTH+3:BIN_WIDTH] >= 5)
                shift_reg[BIN_WIDTH+3:BIN_WIDTH] = shift_reg[BIN_WIDTH+3:BIN_WIDTH] + 3;
            if (shift_reg[BIN_WIDTH+7:BIN_WIDTH+4] >= 5)
                shift_reg[BIN_WIDTH+7:BIN_WIDTH+4] = shift_reg[BIN_WIDTH+7:BIN_WIDTH+4] + 3;
            if (shift_reg[BIN_WIDTH+11:BIN_WIDTH+8] >= 5)
                shift_reg[BIN_WIDTH+11:BIN_WIDTH+8] = shift_reg[BIN_WIDTH+11:BIN_WIDTH+8] + 3;
            if (shift_reg[BIN_WIDTH+15:BIN_WIDTH+12] >= 5)
                shift_reg[BIN_WIDTH+15:BIN_WIDTH+12] = shift_reg[BIN_WIDTH+15:BIN_WIDTH+12] + 3;

            shift_reg = shift_reg << 1;
        end

        // Lấy ra BCD
        ones      = shift_reg[BIN_WIDTH+3 : BIN_WIDTH];
        tens      = shift_reg[BIN_WIDTH+7 : BIN_WIDTH+4];
        hundreds  = shift_reg[BIN_WIDTH+11: BIN_WIDTH+8];
        thousands = shift_reg[BIN_WIDTH+15: BIN_WIDTH+12];
    end
endmodule
