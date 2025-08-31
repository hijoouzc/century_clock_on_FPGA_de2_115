module century_clock_display (
    input clk_blink,
    input [1:0] SW,           // SW[1]: chọn hiển thị (time/date), SW[0]: blink enable
    input [2:0] current_state,
    input [5:0] sec, min,
    input [4:0] hour,
    input [4:0] day,
    input [3:0] month,
    input [13:0] year,        // 0000–9999 (14 bit đủ để chứa 9999)
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7
);

    // Internal signals for BCD values
    wire [3:0] sec_ones, sec_tens;
    wire [3:0] min_ones, min_tens;
    wire [3:0] hour_ones, hour_tens;
    wire [3:0] day_ones, day_tens;
    wire [3:0] month_ones, month_tens;
    wire [3:0] year_ones, year_tens, year_hundreds, year_thousands;
    
    // Internal registers for display values (before blinking)
    reg [3:0] hex_bcd [7:0];
    // Internal registers for final display values (with blinking)
    reg [3:0] display_bcd [7:0];

    // FSM states for setting mode
    localparam [2:0] 
        S_RUN_MODE    = 3'b000,
        S_SET_HOUR    = 3'b001,
        S_SET_MIN     = 3'b010,
        S_SET_SEC     = 3'b011,
        S_SET_DAY     = 3'b100,
        S_SET_MONTH   = 3'b101,
        S_SET_YEAR    = 3'b110;

    // Binary to BCD Converters
    binary_to_bcd_2digit #(6) conv_sec   (.bin(sec),   .tens(sec_tens),   .ones(sec_ones));
    binary_to_bcd_2digit #(6) conv_min   (.bin(min),   .tens(min_tens),   .ones(min_ones));
    binary_to_bcd_2digit #(5) conv_hr    (.bin(hour),  .tens(hour_tens),  .ones(hour_ones));
    binary_to_bcd_2digit #(5) conv_day   (.bin(day),   .tens(day_tens),   .ones(day_ones));
    binary_to_bcd_2digit #(4) conv_month (.bin(month), .tens(month_tens), .ones(month_ones));
    binary_to_bcd_4digit #(14) conv_year (.bin(year),  .thousands(year_thousands),
                                                .hundreds(year_hundreds),
                                                .tens(year_tens),
                                                .ones(year_ones));

    // Select display values based on SW[1]
    always @(*) begin
        if (SW[1] == 1'b0) begin 
            // Display Time (HH:MM:SS) -> [--:HH:MM:SS]
            hex_bcd[7] = hour_tens;      
            hex_bcd[6] = hour_ones;       
            hex_bcd[5] = min_tens;
            hex_bcd[4] = min_ones;
            hex_bcd[3] = sec_tens;
            hex_bcd[2] = sec_ones;
            hex_bcd[1] = 4'hF;      // blank
            hex_bcd[0] = 4'hF;      // blank
        end else begin 
            // Display Date (DD/MM/YYYY) -> [DD/MM/YYYY]
            hex_bcd[7] = day_tens;
            hex_bcd[6] = day_ones;
            hex_bcd[5] = month_tens;
            hex_bcd[4] = month_ones;
            hex_bcd[3] = year_thousands;
            hex_bcd[2] = year_hundreds;
            hex_bcd[1] = year_tens;
            hex_bcd[0] = year_ones;
        end
    end
    
    // Variable for loop counter
    integer i;
    
    // Blinking logic for setting mode
    always @(*) begin
        for (i = 0; i < 8; i = i + 1)
            display_bcd[i] = hex_bcd[i];
        if (SW[0] && !clk_blink) begin
            case (current_state)
                S_SET_HOUR:   {display_bcd[7], display_bcd[6]} = {4'hF, 4'hF};
                S_SET_MIN:    {display_bcd[5], display_bcd[4]} = {4'hF, 4'hF};
                S_SET_SEC:    {display_bcd[3], display_bcd[2]} = {4'hF, 4'hF};
                S_SET_DAY:    {display_bcd[7], display_bcd[6]} = {4'hF, 4'hF};
                S_SET_MONTH:  {display_bcd[5], display_bcd[4]} = {4'hF, 4'hF};
                S_SET_YEAR:   {display_bcd[3], display_bcd[2], display_bcd[1], display_bcd[0]} = {4'hF,4'hF,4'hF,4'hF};
            endcase
        end
    end

    // BCD to 7-segment Decoders
    bcd_to_7seg u_hex0 (.bcd(display_bcd[0]), .seg(HEX0));
    bcd_to_7seg u_hex1 (.bcd(display_bcd[1]), .seg(HEX1));
    bcd_to_7seg u_hex2 (.bcd(display_bcd[2]), .seg(HEX2));
    bcd_to_7seg u_hex3 (.bcd(display_bcd[3]), .seg(HEX3));
    bcd_to_7seg u_hex4 (.bcd(display_bcd[4]), .seg(HEX4));
    bcd_to_7seg u_hex5 (.bcd(display_bcd[5]), .seg(HEX5));
    bcd_to_7seg u_hex6 (.bcd(display_bcd[6]), .seg(HEX6));
    bcd_to_7seg u_hex7 (.bcd(display_bcd[7]), .seg(HEX7));
    
endmodule
