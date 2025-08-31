module debouncer (
        input  wire clk,
        input  wire rst,
        input  wire button_in,
        output wire button_out
    );
        parameter DEBOUNCE_TIME = 20_000_000; // Khoảng 20ms cho xung nhịp 50MHz
        reg [24:0] count;
        reg state;
        
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                count <= 0;
                state <= 0;
            end else begin
                if (state != button_in) begin
                    count <= 0;
                    state <= button_in;
                end else if (count < DEBOUNCE_TIME) begin
                    count <= count + 1;
                end
            end
        end
        assign button_out = state;
    endmodule