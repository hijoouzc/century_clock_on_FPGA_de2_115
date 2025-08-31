`timescale 1ns/1ps

module tb_century_clock;

    // Clock & reset
    reg clk_1Hz;
    reg rst;    

    // Control signals
    reg en_count_sec;
    reg sec_set_up, sec_set_down;
    reg min_set_up, min_set_down;
    reg hour_set_up, hour_set_down;
    reg day_set_up, day_set_down;
    reg month_set_up, month_set_down;
    reg year_set_up, year_set_down;

    // Outputs
    wire [5:0] sec, min;
    wire [4:0] hour, day;
    wire [3:0] month;
    wire [13:0] year;

    // Instantiate DUT
    century_clock_counters #(
        .INIT_SEC   (0),
        .INIT_MIN   (0),
        .INIT_HOUR  (23),   // test nhanh rollover giờ
        .INIT_DAY   (31),   // test rollover ngày
        .INIT_MONTH (1),
        .INIT_YEAR  (2024)  // năm nhuận
    ) dut (
        .clk_1Hz(clk_1Hz),
        .rst(rst),
        .en_count_sec(en_count_sec),
        .sec_set_up(sec_set_up),   .sec_set_down(sec_set_down),
        .min_set_up(min_set_up),   .min_set_down(min_set_down),
        .hour_set_up(hour_set_up), .hour_set_down(hour_set_down),
        .day_set_up(day_set_up),   .day_set_down(day_set_down),
        .month_set_up(month_set_up), .month_set_down(month_set_down),
        .year_set_up(year_set_up),   .year_set_down(year_set_down),
        .sec(sec), .min(min), .hour(hour),
        .day(day), .month(month), .year(year)
    );

    // Clock generator (giả sử 10ns = 1Hz để mô phỏng nhanh)
    initial begin
        clk_1Hz = 0;
        forever #5 clk_1Hz = ~clk_1Hz;
    end

    // Stimulus
    initial begin
        // Add waveform dumping
        $dumpfile("century_clock.vcd");
        $dumpvars(0, tb_century_clock);
        
        // Init control
        en_count_sec   = 1;
        sec_set_up     = 0; sec_set_down   = 0;
        min_set_up     = 0; min_set_down   = 0;
        hour_set_up    = 0; hour_set_down  = 0;
        day_set_up     = 0; day_set_down   = 0;
        month_set_up   = 0; month_set_down = 0;
        year_set_up    = 0; year_set_down  = 0;

        // Reset
        rst = 1; #20; rst = 0;

        // Run simulation trong 2000 ns (~200 "giây" giả lập)
        repeat(200) begin
            @(posedge clk_1Hz);
            $display("Time=%0t | %0d:%0d:%0d %0d/%0d/%0d",
                     $time, hour, min, sec, day, month, year);
        end

        $finish;
    end

endmodule
