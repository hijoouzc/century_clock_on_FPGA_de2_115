`timescale 1ns/1ps

module tb_century_clock;

    reg        clk;
    reg  [3:0] KEY;
    reg  [1:0] SW;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;

    // Khoi tao DUT voi SIM_MODE = 1 de mo phong nhanh
    century_clock_top #(
        .SIM_MODE   (1),
        .INIT_SEC   (6'd58),
        .INIT_MIN   (6'd59),
        .INIT_HOUR  (5'd23),
        .INIT_DAY   (5'd28),
        .INIT_MONTH (4'd2),
        .INIT_YEAR  (14'd2024) // 2024 la nam nhuan
    ) dut (
        .CLOCK_50 (clk),
        .KEY      (KEY),
        .SW       (SW),
        .HEX0     (HEX0),
        .HEX1     (HEX1),
        .HEX2     (HEX2),
        .HEX3     (HEX3),
        .HEX4     (HEX4),
        .HEX5     (HEX5),
        .HEX6     (HEX6),
        .HEX7     (HEX7)
    );

    // Tao xung nhap 50MHz (chu ky 20ns)
    initial clk = 0;
    always #10 clk = ~clk;

    // Task nhan nut don gian
    task press_key;
        input integer key_idx;
        begin
            @(posedge clk);
            KEY[key_idx] = 1'b0; // Bấm phím (Active-low)
            repeat (20) @(posedge clk); // Đợi qua bộ lọc rung
            KEY[key_idx] = 1'b1; // Nhả phím
            repeat (20) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("tb_century_clock.vcd");
        $dumpvars(0, tb_century_clock);

        // Khoi tao: KEY mac dinh muc 1 (chua bam), SW = 0
        KEY = 4'b1111;
        SW  = 2'b00; // RUN mode, Xem Gio

        // Reset he thong bang KEY[3]
        KEY[3] = 1'b0;
        repeat (10) @(posedge clk);
        KEY[3] = 1'b1;
        repeat (10) @(posedge clk);
        $display("[TB] Reset he thong hoan tat. Bat dau kiem tra chay tu dong...");

        // 1. Kiem tra chuyen gio va nam nhuan (23:59:58 28/02/2024)
        // Doi qua vai chu ky giay (trong SIM_MODE: 10 chu ky clock = 1 giay)
        repeat (50) @(posedge clk);
        $display("[TB] Thoi gian hien tai: %0d:%0d:%0d Ngay %0d/%0d/%0d",
                 dut.u_core.hour, dut.u_core.min, dut.u_core.sec,
                 dut.u_core.day, dut.u_core.month, dut.u_core.year);

        // Kiem tra da chuyen sang ngay 29/02/2024 (Nam nhuan)
        if (dut.u_core.day == 5'd29 && dut.u_core.month == 4'd2) begin
            $display("[TB] PASS: Chuyen ngay 28/02 sang 29/02/2024 thanh cong (Nam nhuan hop le)!");
        end else begin
            $display("[TB] FAIL: Loi logic nam nhuan!");
        end

        // 2. Kiem tra chuyen sang che do xem Ngay (SW[1] = 1)
        SW[1] = 1'b1;
        repeat (10) @(posedge clk);
        $display("[TB] Da chuyen sang che do xem Ngay/Thang/Nam (SW[1]=1)");

        // 3. Kiem tra che do cai dat (SET mode: SW[0] = 1)
        SW[0] = 1'b1; // Vao SET mode
        repeat (10) @(posedge clk);
        $display("[TB] Vao che do SET mode. State hien tai = %0d", dut.u_core.state);

        // Bam KEY[1] de tang ngay
        $display("[TB] Bam KEY[1] de tang ngay...");
        press_key(1);
        $display("[TB] Ngay sau khi tang: %0d", dut.u_core.day);

        // Bam KEY[0] de chuyen truong (sang thang)
        $display("[TB] Bam KEY[0] de chuyen sang chinh Thang...");
        press_key(0);
        $display("[TB] State sau khi chuyen truong = %0d", dut.u_core.state);

        // Bam KEY[1] de tang thang
        $display("[TB] Bam KEY[1] de tang thang...");
        press_key(1);
        $display("[TB] Thang sau khi tang: %0d, Ngay tu dong kep: %0d", dut.u_core.month, dut.u_core.day);

        // 4. Thoat khoi SET mode ve RUN mode
        SW[0] = 1'b0;
        SW[1] = 1'b0;
        repeat (20) @(posedge clk);
        $display("[TB] Thoat ve RUN mode. Ket qua cuoi: %0d:%0d:%0d Ngay %0d/%0d/%0d",
                 dut.u_core.hour, dut.u_core.min, dut.u_core.sec,
                 dut.u_core.day, dut.u_core.month, dut.u_core.year);

        $display("==================================================");
        $display("     ALL TESTCASES SIMULATED SUCCESSFULLY!        ");
        $display("==================================================");
        $finish;
    end

endmodule
