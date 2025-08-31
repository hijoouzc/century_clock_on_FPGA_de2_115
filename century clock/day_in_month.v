module day_in_month (
    input [3:0] month,  
    input [13:0] year, 
    output reg [4:0] max_day 
);
    wire is_leap_year;
  
    // Logic năm nhuận chính xác
    wire divisible_by_4 = (year % 4 == 0);
    wire divisible_by_100 = (year % 100 == 0);
    wire divisible_by_400 = (year % 400 == 0);

    // Quy tắc năm nhuận: chia hết cho 4, trừ khi chia hết cho 100, nhưng vẫn đúng
    // nếu chia hết cho 400.
    assign is_leap_year = (divisible_by_4 && !divisible_by_100) || divisible_by_400;

    always @(*) begin
        case (month)
            4'd1, 4'd3, 4'd5, 4'd7, 4'd8, 4'd10, 4'd12: begin
                max_day = 5'd31;
            end
            
            4'd4, 4'd6, 4'd9, 4'd11: begin
                max_day = 5'd30;
            end
            
            4'd2: begin
                if (is_leap_year) begin
                    max_day = 5'd29;
                end else begin
                    max_day = 5'd28;
                end
            end  

            default: begin
                max_day = 5'd31; 
            end
        endcase
    end
endmodule