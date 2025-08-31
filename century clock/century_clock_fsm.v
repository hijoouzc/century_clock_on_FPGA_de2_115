module century_clock_fsm (
    input  wire clk, rst,
    input  wire [1:0] SW,           // SW[0]: run/set, SW[1]: time/date select
    input  wire KEY0_pulse,         // Change field
    input  wire KEY1_pulse,         // Increase value
    input  wire KEY2_pulse,         // Decrease value
    output reg  [2:0] current_state, // FSM state
    output reg  sec_set_up, sec_set_down,
    output reg  min_set_up, min_set_down,
    output reg  hour_set_up, hour_set_down,
    output reg  day_set_up, day_set_down,
    output reg  month_set_up, month_set_down,
    output reg  year_set_up, year_set_down
);

    // FSM states
    localparam [2:0] 
        S_RUN_MODE   = 3'b000,
        S_SET_HOUR   = 3'b001,
        S_SET_MIN    = 3'b010,
        S_SET_SEC    = 3'b011,
        S_SET_DAY    = 3'b100,
        S_SET_MONTH  = 3'b101,
        S_SET_YEAR   = 3'b110;

    reg [2:0] next_state;

    // Next State Logic

    always @(*) begin
        next_state = current_state; // default: stay

        case (current_state)
            S_RUN_MODE: begin
                if (SW[0]) // enter set mode
                    next_state = SW[1] ? S_SET_DAY : S_SET_HOUR;
            end

            // ----- Time setting group -----
            S_SET_HOUR: begin
                if (~SW[0]) next_state = S_RUN_MODE;
                else if (SW[1]) next_state = S_SET_DAY; // switch to date mode
                else if (KEY0_pulse) next_state = S_SET_MIN;
            end
            S_SET_MIN: begin
                if (~SW[0]) next_state = S_RUN_MODE;
                else if (SW[1]) next_state = S_SET_DAY;
                else if (KEY0_pulse) next_state = S_SET_SEC;
            end
            S_SET_SEC: begin
                if (~SW[0]) next_state = S_RUN_MODE;
                else if (SW[1]) next_state = S_SET_DAY;
                else if (KEY0_pulse) next_state = S_SET_HOUR;
            end

            // ----- Date setting group -----
            S_SET_DAY: begin
                if (~SW[0]) next_state = S_RUN_MODE;
                else if (~SW[1]) next_state = S_SET_HOUR; // switch to time mode
                else if (KEY0_pulse) next_state = S_SET_MONTH;
            end
            S_SET_MONTH: begin
                if (~SW[0]) next_state = S_RUN_MODE;
                else if (~SW[1]) next_state = S_SET_HOUR;
                else if (KEY0_pulse) next_state = S_SET_YEAR;
            end
            S_SET_YEAR: begin
                if (~SW[0]) next_state = S_RUN_MODE;
                else if (~SW[1]) next_state = S_SET_HOUR;
                else if (KEY0_pulse) next_state = S_SET_DAY;
            end

            default: next_state = S_RUN_MODE;
        endcase
    end

    // -----------------------------------------------------------------------------------
    // State Register
    // -----------------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= S_RUN_MODE;
        else
            current_state <= next_state;
    end

    // Output Logic (Counter Control)
    always @(*) begin
        // Default: all signals low
        sec_set_up   = 0; sec_set_down   = 0;
        min_set_up   = 0; min_set_down   = 0;
        hour_set_up  = 0; hour_set_down  = 0;
        day_set_up   = 0; day_set_down   = 0;
        month_set_up = 0; month_set_down = 0;
        year_set_up  = 0; year_set_down  = 0;

        if (SW[0]) begin
            case (current_state)
                S_SET_HOUR: begin
                    if (KEY1_pulse) hour_set_up   = 1;
                    else if (KEY2_pulse) hour_set_down = 1; // priority: KEY1 > KEY2
                end
                S_SET_MIN: begin
                    if (KEY1_pulse) min_set_up    = 1;
                    else if (KEY2_pulse) min_set_down = 1;
                end
                S_SET_SEC: begin
                    if (KEY1_pulse) sec_set_up    = 1;
                    else if (KEY2_pulse) sec_set_down = 1;
                end
                S_SET_DAY: begin
                    if (KEY1_pulse) day_set_up    = 1;
                    else if (KEY2_pulse) day_set_down = 1;
                end
                S_SET_MONTH: begin
                    if (KEY1_pulse) month_set_up  = 1;
                    else if (KEY2_pulse) month_set_down = 1;
                end
                S_SET_YEAR: begin
                    if (KEY1_pulse) year_set_up   = 1;
                    else if (KEY2_pulse) year_set_down = 1;
                end
            endcase
        end
    end

endmodule
