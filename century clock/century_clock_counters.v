module century_clock_counters #(
    parameter INIT_SEC    = 6'd0,
    parameter INIT_MIN    = 6'd0,
    parameter INIT_HOUR   = 5'd0,
    parameter INIT_DAY    = 5'd1,  
    parameter INIT_MONTH  = 4'd1,  
    parameter INIT_YEAR   = 14'd2000
)(
    input clk_1Hz,
    input rst,
    input en_count_sec,
    input sec_set_up,   sec_set_down,
    input min_set_up,   min_set_down,
    input hour_set_up,  hour_set_down,
    input day_set_up,   day_set_down,
    input month_set_up, month_set_down,
    input year_set_up,  year_set_down,
    output wire [5:0] sec,
    output wire [5:0] min,
    output wire [4:0] hour,
    output wire [4:0] day,
    output wire [3:0] month,
    output wire [13:0] year
);

    // Rollover wires
    wire sec_roll, min_roll, hour_roll, day_roll, month_roll;

    // max_day phụ thuộc vào month + year
    wire [4:0] max_day;
    day_in_month u_dim (.month(month), .year(year), .max_day(max_day));

    // Seconds (0–59)
    mod_counter_range #(.WIDTH(6), .MIN_VAL(0), .INIT_VAL(INIT_SEC)) u_sec (
        .clk(clk_1Hz), .rst(rst),
        .en_count(en_count_sec),
        .up_set(sec_set_up),
        .down_set(sec_set_down),
        .limit(59),
        .count(sec),
        .rollover(sec_roll)
    );

    // Minutes (0–59)
    mod_counter_range #(.WIDTH(6), .MIN_VAL(0), .INIT_VAL(INIT_MIN)) u_min (
        .clk(clk_1Hz), .rst(rst),
        .en_count(sec_roll),
        .up_set(min_set_up),
        .down_set(min_set_down),
        .limit(59),
        .count(min),
        .rollover(min_roll)
    );

    // Hours (0–23)
    mod_counter_range #(.WIDTH(5), .MIN_VAL(0), .INIT_VAL(INIT_HOUR)) u_hour (
        .clk(clk_1Hz), .rst(rst),
        .en_count(min_roll),
        .up_set(hour_set_up),
        .down_set(hour_set_down),
        .limit(23),
        .count(hour),
        .rollover(hour_roll)
    );

    // Days (1–max_day)
    mod_counter_range #(.WIDTH(5), .MIN_VAL(1), .INIT_VAL(INIT_DAY)) u_day (
        .clk(clk_1Hz), .rst(rst),
        .en_count(hour_roll),
        .up_set(day_set_up),
        .down_set(day_set_down),
        .limit(max_day),
        .count(day),
        .rollover(day_roll)
    );

    // Months (1–12)
    mod_counter_range #(.WIDTH(4), .MIN_VAL(1), .INIT_VAL(INIT_MONTH)) u_month (
        .clk(clk_1Hz), .rst(rst),
        .en_count(day_roll),
        .up_set(month_set_up),
        .down_set(month_set_down),
        .limit(12),
        .count(month),
        .rollover(month_roll)
    );

    // Years (1–9999)
    mod_counter_range #(.WIDTH(13), .MIN_VAL(1), .INIT_VAL(INIT_YEAR)) u_year (
        .clk(clk_1Hz), .rst(rst),
        .en_count(month_roll),
        .up_set(year_set_up),
        .down_set(year_set_down),
        .limit(9999),
        .count(year),
        .rollover()
    );

endmodule
