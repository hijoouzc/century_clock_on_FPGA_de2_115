module century_clock #(
    parameter SIM_MODE    = 0, // 0 for normal operation, 1 for fast simulation
    parameter INIT_SEC    = 6'd9,
    parameter INIT_MIN    = 6'd9,
    parameter INIT_HOUR   = 5'd9,
    parameter INIT_DAY    = 5'd27,  
    parameter INIT_MONTH  = 4'd2,  
    parameter INIT_YEAR   = 14'd2024
) (
    input  wire clk, rst,
    input  wire [1:0] SW,  // SW[0]: mode (run/set), SW[1]: display (time/date)
    input  wire [2:0] KEY, // KEY[0]: change field, KEY[1]: up, KEY[2]: down
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7
);

    // Internal Wires and Signals
    wire clk_1Hz;       // 1Hz clock for time/date counting
    wire clk_blink;     // Blink clock for showing the setting field
    wire KEY0_debounced, KEY1_debounced, KEY2_debounced;
    wire KEY0_pulse, KEY1_pulse, KEY2_pulse;    

    wire [2:0] current_state;

    // Counter output wires
    wire [5:0] sec, min;
    wire [4:0] hour;
    wire [4:0] day;
    wire [3:0] month;
    wire [13:0] year; 

    // Counter control signals
    wire sec_set_up, sec_set_down;
    wire min_set_up, min_set_down;
    wire hour_set_up, hour_set_down;
    wire day_set_up, day_set_down;
    wire month_set_up, month_set_down;
    wire year_set_up, year_set_down;

    // FSM -> Counter enables
    // In SIM_MODE, enable all counters to run continuously for quick testing.
    wire en_count;
    assign en_count = ~SW[0];

    // Sub-module Instantiations

    // Debouncers for push buttons
    // debouncer u_deb_key0 (.clk(clk), .rst(rst), .button_in(KEY[0]), .button_out(KEY0_debounced));
    // debouncer u_deb_key1 (.clk(clk), .rst(rst), .button_in(KEY[1]), .button_out(KEY1_debounced));
    // debouncer u_deb_key2 (.clk(clk), .rst(rst), .button_in(KEY[2]), .button_out(KEY2_debounced));
    
    // // Pulse detectors for button presses
    // pulse_detector u_pulse_key0 (.clk(clk), .rst(rst), .sig_in(KEY0_debounced), .sig_pulse(KEY0_pulse));
    // pulse_detector u_pulse_key1 (.clk(clk), .rst(rst), .sig_in(KEY1_debounced), .sig_pulse(KEY1_pulse));
    // pulse_detector u_pulse_key2 (.clk(clk), .rst(rst), .sig_in(KEY2_debounced), .sig_pulse(KEY2_pulse));

    // Clock generators
    clock #(50_000_000) u_clock_1Hz   (.clk(clk), .rst(rst), .clk_out(clk_1Hz));
    clock #(25_000_000) u_clock_blink (.clk(clk), .rst(rst), .clk_out(clk_blink));

    // FSM
    century_clock_fsm u_fsm (
        .clk(clk), 
        .rst(rst), 
        .SW(SW), 
        .KEY0_pulse(KEY0_pulse), 
        .KEY1_pulse(KEY1_pulse), 
        .KEY2_pulse(KEY2_pulse),
        .current_state(current_state),
        .sec_set_up(sec_set_up),
        .sec_set_down(sec_set_down),
        .min_set_up(min_set_up),
        .min_set_down(min_set_down),
        .hour_set_up(hour_set_up),
        .hour_set_down(hour_set_down),
        .day_set_up(day_set_up),
        .day_set_down(day_set_down),
        .month_set_up(month_set_up),
        .month_set_down(month_set_down),
        .year_set_up(year_set_up),
        .year_set_down(year_set_down)
    );

    // Counters - with initial value parameters passed down
    century_clock_counters #(
        .INIT_SEC(INIT_SEC), 
        .INIT_MIN(INIT_MIN), 
        .INIT_HOUR(INIT_HOUR), 
        .INIT_DAY(INIT_DAY), 
        .INIT_MONTH(INIT_MONTH), 
        .INIT_YEAR(INIT_YEAR)
    )
        u_counters (
        .clk_1Hz((SIM_MODE == 1) ? clk : clk_1Hz), // Use fast clock in sim mode
        .rst(rst),
        .en_count_sec(en_count), 
        .sec_set_up(sec_set_up),
        .sec_set_down(sec_set_down),
        .min_set_up(min_set_up),
        .min_set_down(min_set_down),
        .hour_set_up(hour_set_up),
        .hour_set_down(hour_set_down),
        .day_set_up(day_set_up),
        .day_set_down(day_set_down),
        .month_set_up(month_set_up),
        .month_set_down(month_set_down),
        .year_set_up(year_set_up),
        .year_set_down(year_set_down),
        .sec(sec),
        .min(min),
        .hour(hour),
        .day(day),
        .month(month),
        .year(year)
    );

    // Display
    century_clock_display u_display (
        .clk_blink((SIM_MODE == 1) ? clk : clk_blink), // Use fast clock in sim mode for blinking
        .SW(SW),
        .current_state(current_state),
        .sec(sec),
        .min(min),
        .hour(hour),
        .day(day),
        .month(month),
        .year(year),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .HEX6(HEX6),
        .HEX7(HEX7)
    );

endmodule
