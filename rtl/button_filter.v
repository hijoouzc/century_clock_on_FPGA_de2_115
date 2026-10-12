module button_filter #(
    parameter SIM_MODE = 0
)(
    input  wire clk,
    input  wire rst_n,
    input  wire btn_in,     // Active-low from DE2-115 pushbutton
    output reg  btn_pulse   // Single-cycle high pulse on press
);
    localparam LIMIT = SIM_MODE ? 20'd5 : 20'd1_000_000; // 20ms at 50MHz

    // 2-stage synchronizer with active-low inversion
    reg sync0, sync1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync0 <= 1'b0;
            sync1 <= 1'b0;
        end else begin
            sync0 <= ~btn_in; // Invert: pressed=1, released=0
            sync1 <= sync0;
        end
    end

    // Debounce counter
    reg [19:0] cnt;
    reg btn_state;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt       <= 20'd0;
            btn_state <= 1'b0;
        end else if (sync1 != btn_state) begin
            if (cnt == LIMIT - 1) begin
                cnt       <= 20'd0;
                btn_state <= sync1;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end else begin
            cnt <= 20'd0;
        end
    end

    // Rising edge detector: generate single-cycle pulse
    reg btn_state_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_state_d <= 1'b0;
            btn_pulse   <= 1'b0;
        end else begin
            btn_state_d <= btn_state;
            btn_pulse   <= btn_state & ~btn_state_d;
        end
    end
endmodule
