module button_filter #(
    parameter SIM_MODE = 0
)(
    input  wire clk,
    input  wire rst_n,
    input  wire btn_in,     // Active-low tu kit DE2-115
    output reg  btn_pulse   // Xung tich cuc cao 1 chu ky khi nhan nut
);
    // Gioi han dem khu rung 20ms tai 50MHz
    localparam LIMIT = SIM_MODE ? 20'd5 : 20'd1_000_000;

    // Dong bo 2 tang FF & dao muc tich cuc
    reg sync0, sync1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync0 <= 1'b0;
            sync1 <= 1'b0;
        end else begin
            sync0 <= ~btn_in; // Nhan = 1, Nha = 0
            sync1 <= sync0;
        end
    end

    // Bo dem loc rung
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

    // Bat suon len tao 1 xung duy nhat
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
