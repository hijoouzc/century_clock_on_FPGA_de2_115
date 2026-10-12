module clock_core #(
    parameter INIT_SEC   = 6'd0,
    parameter INIT_MIN   = 6'd0,
    parameter INIT_HOUR  = 5'd0,
    parameter INIT_DAY   = 5'd1,
    parameter INIT_MONTH = 4'd1,
    parameter INIT_YEAR  = 14'd2024
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tick_1s,
    input  wire        sw_mode,     // 0: RUN, 1: SET
    input  wire        sw_display,  // 0: TIME, 1: DATE
    input  wire        key_change,  // Chuyen truong
    input  wire        key_up,      // Tang
    input  wire        key_down,    // Giam
    output reg  [5:0]  sec,
    output reg  [5:0]  min,
    output reg  [4:0]  hour,
    output reg  [4:0]  day,
    output reg  [3:0]  month,
    output reg  [13:0] year,
    output reg  [2:0]  state
);
    // Dinh nghia cac trang thai FSM
    localparam S_RUN       = 3'd0;
    localparam S_SET_HOUR  = 3'd1;
    localparam S_SET_MIN   = 3'd2;
    localparam S_SET_SEC   = 3'd3;
    localparam S_SET_DAY   = 3'd4;
    localparam S_SET_MONTH = 3'd5;
    localparam S_SET_YEAR  = 3'd6;

    // FSM chuyen trang thai cai dat
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_RUN;
        end else if (!sw_mode) begin
            state <= S_RUN;
        end else begin
            if (state == S_RUN) begin
                state <= sw_display ? S_SET_DAY : S_SET_HOUR;
            end else if (key_change) begin
                case (state)
                    S_SET_HOUR:  state <= S_SET_MIN;
                    S_SET_MIN:   state <= S_SET_SEC;
                    S_SET_SEC:   state <= S_SET_HOUR;
                    S_SET_DAY:   state <= S_SET_MONTH;
                    S_SET_MONTH: state <= S_SET_YEAR;
                    S_SET_YEAR:  state <= S_SET_DAY;
                    default:     state <= sw_display ? S_SET_DAY : S_SET_HOUR;
                endcase
            end else begin
                // Tu dong chuyen nhom khi gat cong tac sw_display
                if (!sw_display && (state == S_SET_DAY || state == S_SET_MONTH || state == S_SET_YEAR))
                    state <= S_SET_HOUR;
                else if (sw_display && (state == S_SET_HOUR || state == S_SET_MIN || state == S_SET_SEC))
                    state <= S_SET_DAY;
            end
        end
    end

    // Kiem tra nam nhuan: chia het cho 4 nhung khong chia het cho 100, hoac chia het cho 400
    wire is_leap = ((year[1:0] == 2'b00) && (year % 100 != 0)) || (year % 400 == 0);

    // Xac dinh so ngay toi da trong thang
    reg [4:0] max_day;
    always @(*) begin
        case (month)
            4'd2:    max_day = is_leap ? 5'd29 : 5'd28;
            4'd4, 4'd6, 4'd9, 4'd11: max_day = 5'd30;
            default: max_day = 5'd31;
        endcase
    end

    // Logic dem thoi gian va chinh sua
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sec   <= INIT_SEC;
            min   <= INIT_MIN;
            hour  <= INIT_HOUR;
            day   <= INIT_DAY;
            month <= INIT_MONTH;
            year  <= INIT_YEAR;
        end else if (!sw_mode) begin
            // Che do chay binh thuong (RUN)
            if (tick_1s) begin
                if (sec == 6'd59) begin
                    sec <= 6'd0;
                    if (min == 6'd59) begin
                        min <= 6'd0;
                        if (hour == 5'd23) begin
                            hour <= 5'd0;
                            if (day >= max_day) begin
                                day <= 5'd1;
                                if (month == 4'd12) begin
                                    month <= 4'd1;
                                    year  <= (year == 14'd9999) ? 14'd2000 : year + 1'b1;
                                end else begin
                                    month <= month + 1'b1;
                                end
                            end else begin
                                day <= day + 1'b1;
                            end
                        end else begin
                            hour <= hour + 1'b1;
                        end
                    end else begin
                        min <= min + 1'b1;
                    end
                end else begin
                    sec <= sec + 1'b1;
                end
            end
        end else begin
            // Che do cai dat (SET)
            if (key_up) begin
                case (state)
                    S_SET_SEC:   sec   <= (sec == 6'd59) ? 6'd0 : sec + 1'b1;
                    S_SET_MIN:   min   <= (min == 6'd59) ? 6'd0 : min + 1'b1;
                    S_SET_HOUR:  hour  <= (hour == 5'd23) ? 5'd0 : hour + 1'b1;
                    S_SET_DAY:   day   <= (day >= max_day) ? 5'd1 : day + 1'b1;
                    S_SET_MONTH: month <= (month == 4'd12) ? 4'd1 : month + 1'b1;
                    S_SET_YEAR:  year  <= (year == 14'd9999) ? 14'd2000 : year + 1'b1;
                    default: ;
                endcase
            end else if (key_down) begin
                case (state)
                    S_SET_SEC:   sec   <= (sec == 6'd0) ? 6'd59 : sec - 1'b1;
                    S_SET_MIN:   min   <= (min == 6'd0) ? 6'd59 : min - 1'b1;
                    S_SET_HOUR:  hour  <= (hour == 5'd0) ? 5'd23 : hour - 1'b1;
                    S_SET_DAY:   day   <= (day <= 5'd1) ? max_day : day - 1'b1;
                    S_SET_MONTH: month <= (month <= 4'd1) ? 4'd12 : month - 1'b1;
                    S_SET_YEAR:  year  <= (year <= 14'd2000) ? 14'd9999 : year - 1'b1;
                    default: ;
                endcase
            end

            // Tu dong kep ngay hop le neu doi thang/nam lam day > max_day
            if (day > max_day) begin
                day <= max_day;
            end
        end
    end
endmodule
