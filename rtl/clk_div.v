module clk_div #(
    parameter SIM_MODE = 0
)(
    input  wire clk,
    input  wire rst_n,
    output reg  tick_1s,  // 1-cycle pulse every 1 second
    output reg  blink     // 2 Hz toggle for blinking display
);
    localparam CNT_1S_MAX    = SIM_MODE ? 32'd10 : 32'd50_000_000;
    localparam CNT_BLINK_MAX = SIM_MODE ? 32'd5  : 32'd12_500_000;

    reg [31:0] cnt_1s;
    reg [31:0] cnt_blink;

    // Generate 1-second tick pulse
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_1s  <= 32'd0;
            tick_1s <= 1'b0;
        end else if (cnt_1s == CNT_1S_MAX - 1) begin
            cnt_1s  <= 32'd0;
            tick_1s <= 1'b1;
        end else begin
            cnt_1s  <= cnt_1s + 1'b1;
            tick_1s <= 1'b0;
        end
    end

    // Generate 2 Hz blink signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt_blink <= 32'd0;
            blink     <= 1'b0;
        end else if (cnt_blink == CNT_BLINK_MAX - 1) begin
            cnt_blink <= 32'd0;
            blink     <= ~blink;
        end else begin
            cnt_blink <= cnt_blink + 1'b1;
        end
    end
endmodule
