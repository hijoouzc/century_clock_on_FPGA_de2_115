module century_clock_top #(
    parameter SIM_MODE   = 0,
    parameter INIT_SEC   = 6'd0,
    parameter INIT_MIN   = 6'd0,
    parameter INIT_HOUR  = 5'd0,
    parameter INIT_DAY   = 5'd1,
    parameter INIT_MONTH = 4'd1,
    parameter INIT_YEAR  = 14'd2024
)(
    input  wire       CLOCK_50, // 50 MHz clock tu pin PIN_Y2 tren DE2-115
    input  wire [3:0] KEY,      // KEY[3]: rst_n, KEY[0]: Chuyen truong, KEY[1]: Tang, KEY[2]: Giam
    input  wire [1:0] SW,       // SW[0]: 0=Run, 1=Set; SW[1]: 0=Time, 1=Date
    output wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7
);
    // Reset tich cuc thap tu KEY[3]
    wire rst_n = KEY[3];

    // Xung nhip 1s va xung nhap nhay
    wire tick_1s, blink;
    clk_div #(.SIM_MODE(SIM_MODE)) u_clk_div (
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .tick_1s(tick_1s),
        .blink(blink)
    );

    // Loc rung va tao xung nut bam
    wire key_change, key_up, key_down;
    button_filter #(.SIM_MODE(SIM_MODE)) u_btn0 (
        .clk(CLOCK_50), .rst_n(rst_n), .btn_in(KEY[0]), .btn_pulse(key_change)
    );
    button_filter #(.SIM_MODE(SIM_MODE)) u_btn1 (
        .clk(CLOCK_50), .rst_n(rst_n), .btn_in(KEY[1]), .btn_pulse(key_up)
    );
    button_filter #(.SIM_MODE(SIM_MODE)) u_btn2 (
        .clk(CLOCK_50), .rst_n(rst_n), .btn_in(KEY[2]), .btn_pulse(key_down)
    );

    // Loi dong ho va FSM
    wire [5:0]  sec, min;
    wire [4:0]  hour, day;
    wire [3:0]  month;
    wire [13:0] year;
    wire [2:0]  state;

    clock_core #(
        .INIT_SEC(INIT_SEC),
        .INIT_MIN(INIT_MIN),
        .INIT_HOUR(INIT_HOUR),
        .INIT_DAY(INIT_DAY),
        .INIT_MONTH(INIT_MONTH),
        .INIT_YEAR(INIT_YEAR)
    ) u_core (
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .tick_1s(tick_1s),
        .sw_mode(SW[0]),
        .sw_display(SW[1]),
        .key_change(key_change),
        .key_up(key_up),
        .key_down(key_down),
        .sec(sec),
        .min(min),
        .hour(hour),
        .day(day),
        .month(month),
        .year(year),
        .state(state)
    );

    // Bo dieu phoi hien thi
    wire [3:0] d7, d6, d5, d4, d3, d2, d1, d0;
    display_controller u_disp (
        .sw_mode(SW[0]),
        .sw_display(SW[1]),
        .state(state),
        .blink(blink),
        .sec(sec),
        .min(min),
        .hour(hour),
        .day(day),
        .month(month),
        .year(year),
        .d7(d7), .d6(d6), .d5(d5), .d4(d4),
        .d3(d3), .d2(d2), .d1(d1), .d0(d0)
    );

    // Giai ma 8 LED 7 doan
    seg7_decoder u_hex0 (.bcd(d0), .seg(HEX0));
    seg7_decoder u_hex1 (.bcd(d1), .seg(HEX1));
    seg7_decoder u_hex2 (.bcd(d2), .seg(HEX2));
    seg7_decoder u_hex3 (.bcd(d3), .seg(HEX3));
    seg7_decoder u_hex4 (.bcd(d4), .seg(HEX4));
    seg7_decoder u_hex5 (.bcd(d5), .seg(HEX5));
    seg7_decoder u_hex6 (.bcd(d6), .seg(HEX6));
    seg7_decoder u_hex7 (.bcd(d7), .seg(HEX7));

endmodule
