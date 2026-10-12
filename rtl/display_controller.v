/* verilator lint_off WIDTHTRUNC */
module display_controller (
    input  wire        sw_mode,     // 0: RUN, 1: SET
    input  wire        sw_display,  // 0: TIME, 1: DATE
    input  wire [2:0]  state,       // FSM state
    input  wire        blink,       // 2 Hz blink signal
    input  wire [5:0]  sec,
    input  wire [5:0]  min,
    input  wire [4:0]  hour,
    input  wire [4:0]  day,
    input  wire [3:0]  month,
    input  wire [13:0] year,
    output reg  [3:0]  d7, d6, d5, d4, d3, d2, d1, d0 // BCD for HEX7..HEX0
);
    localparam S_SET_HOUR  = 3'd1;
    localparam S_SET_MIN   = 3'd2;
    localparam S_SET_SEC   = 3'd3;
    localparam S_SET_DAY   = 3'd4;
    localparam S_SET_MONTH = 3'd5;
    localparam S_SET_YEAR  = 3'd6;
    localparam BLANK       = 4'hF; // Turns off all LED segments

    // BCD digit extraction
    wire [3:0] sec_tens   = sec / 10;
    wire [3:0] sec_ones   = sec % 10;
    wire [3:0] min_tens   = min / 10;
    wire [3:0] min_ones   = min % 10;
    wire [3:0] hour_tens  = hour / 10;
    wire [3:0] hour_ones  = hour % 10;

    wire [3:0] day_tens   = day / 10;
    wire [3:0] day_ones   = day % 10;
    wire [3:0] month_tens = month / 10;
    wire [3:0] month_ones = month % 10;
    wire [3:0] year_thou  = (year / 1000) % 10;
    wire [3:0] year_hund  = (year / 100) % 10;
    wire [3:0] year_tens  = (year / 10) % 10;
    wire [3:0] year_ones  = year % 10;

    always @(*) begin
        if (!sw_display) begin
            // Time display: HH:MM:SS (HEX7..HEX2), HEX1-HEX0 off
            d7 = hour_tens;  d6 = hour_ones;
            d5 = min_tens;   d4 = min_ones;
            d3 = sec_tens;   d2 = sec_ones;
            d1 = BLANK;      d0 = BLANK;

            // Blink active field in SET mode
            if (sw_mode && !blink) begin
                case (state)
                    S_SET_HOUR: begin d7 = BLANK; d6 = BLANK; end
                    S_SET_MIN:  begin d5 = BLANK; d4 = BLANK; end
                    S_SET_SEC:  begin d3 = BLANK; d2 = BLANK; end
                    default: ;
                endcase
            end
        end else begin
            // Date display: DD:MM:YYYY (HEX7..HEX0)
            d7 = day_tens;    d6 = day_ones;
            d5 = month_tens;  d4 = month_ones;
            d3 = year_thou;   d2 = year_hund;
            d1 = year_tens;   d0 = year_ones;

            // Blink active field in SET mode
            if (sw_mode && !blink) begin
                case (state)
                    S_SET_DAY:   begin d7 = BLANK; d6 = BLANK; end
                    S_SET_MONTH: begin d5 = BLANK; d4 = BLANK; end
                    S_SET_YEAR:  begin d3 = BLANK; d2 = BLANK; d1 = BLANK; d0 = BLANK; end
                    default: ;
                endcase
            end
        end
    end
endmodule
