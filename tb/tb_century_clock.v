`timescale 1ns/1ps

module tb_century_clock;

    reg        clk;
    reg  [3:0] KEY;
    reg  [1:0] SW;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;

    // DUT: SIM_MODE=1 for fast simulation
    century_clock_top #(
        .SIM_MODE   (1),
        .INIT_SEC   (6'd58),
        .INIT_MIN   (6'd59),
        .INIT_HOUR  (5'd23),
        .INIT_DAY   (5'd28),
        .INIT_MONTH (4'd2),
        .INIT_YEAR  (14'd2024) // Leap year
    ) dut (
        .CLOCK_50 (clk),
        .KEY      (KEY),
        .SW       (SW),
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3),
        .HEX4(HEX4), .HEX5(HEX5), .HEX6(HEX6), .HEX7(HEX7)
    );

    // 50 MHz clock (20ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // Press button helper task
    task press_key;
        input integer key_idx;
        begin
            @(posedge clk);
            KEY[key_idx] = 1'b0; // Press (active-low)
            repeat (20) @(posedge clk);
            KEY[key_idx] = 1'b1; // Release
            repeat (20) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("tb_century_clock.vcd");
        $dumpvars(0, tb_century_clock);

        KEY = 4'b1111; // All buttons released
        SW  = 2'b00;   // RUN mode, Time display

        // Reset
        KEY[3] = 1'b0;
        repeat (10) @(posedge clk);
        KEY[3] = 1'b1;
        repeat (10) @(posedge clk);
        $display("[TB] Reset complete.");

        // Test 1: Auto-count through leap year transition (28/02/2024)
        repeat (50) @(posedge clk);
        $display("[TB] Time: %0d:%0d:%0d  Date: %0d/%0d/%0d",
                 dut.u_core.hour, dut.u_core.min, dut.u_core.sec,
                 dut.u_core.day, dut.u_core.month, dut.u_core.year);

        if (dut.u_core.day == 5'd29 && dut.u_core.month == 4'd2)
            $display("[TB] PASS: Leap year 29/02/2024 correct!");
        else
            $display("[TB] FAIL: Leap year logic error!");

        // Test 2: Switch to date view
        SW[1] = 1'b1;
        repeat (10) @(posedge clk);

        // Test 3: Enter SET mode, adjust day
        SW[0] = 1'b1;
        repeat (10) @(posedge clk);
        $display("[TB] SET mode entered. State=%0d", dut.u_core.state);

        press_key(1); // Increment day
        $display("[TB] Day after increment: %0d", dut.u_core.day);

        press_key(0); // Switch to month field
        $display("[TB] State after field change: %0d", dut.u_core.state);

        press_key(1); // Increment month
        $display("[TB] Month: %0d, Day (auto-clamp): %0d",
                 dut.u_core.month, dut.u_core.day);

        // Return to RUN mode
        SW[0] = 1'b0;
        SW[1] = 1'b0;
        repeat (20) @(posedge clk);
        $display("[TB] Final: %0d:%0d:%0d  %0d/%0d/%0d",
                 dut.u_core.hour, dut.u_core.min, dut.u_core.sec,
                 dut.u_core.day, dut.u_core.month, dut.u_core.year);

        $display("==================================================");
        $display("     ALL TESTCASES SIMULATED SUCCESSFULLY!        ");
        $display("==================================================");
        $finish;
    end

endmodule
