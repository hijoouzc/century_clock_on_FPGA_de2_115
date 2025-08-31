module binary_to_bcd_2digit #(
    parameter BIN_WIDTH = 6  // Độ rộng đủ chứa giá trị lớn nhất
)(
    input  [BIN_WIDTH-1:0] bin,
    output reg [3:0] tens,
    output reg [3:0] ones
);
    integer i;
    reg [BIN_WIDTH+7:0] shift_reg; // BIN_WIDTH bits + 8 bits BCD (2 digits)

    always @(*) begin
        shift_reg = 0;
        shift_reg[BIN_WIDTH-1:0] = bin;

        for (i = 0; i < BIN_WIDTH; i = i + 1) begin
            if (shift_reg[BIN_WIDTH+3:BIN_WIDTH] >= 5) begin
                shift_reg[BIN_WIDTH+3:BIN_WIDTH] = shift_reg[BIN_WIDTH+3:BIN_WIDTH] + 3;
            end
            if (shift_reg[BIN_WIDTH+7:BIN_WIDTH+4] >= 5) begin
                shift_reg[BIN_WIDTH+7:BIN_WIDTH+4] = shift_reg[BIN_WIDTH+7:BIN_WIDTH+4] + 3;
            end
            shift_reg = shift_reg << 1;
        end

        tens = shift_reg[BIN_WIDTH+7:BIN_WIDTH+4];
        ones = shift_reg[BIN_WIDTH+3:BIN_WIDTH];
    end
endmodule
