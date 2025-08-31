module mod_counter_range #(
    parameter WIDTH    = 6,    // độ rộng thanh ghi đếm
    parameter MIN_VAL  = 0,    // giá trị nhỏ nhất
    parameter INIT_VAL = 0     // giá trị khởi tạo
)(
    input  wire clk, rst,
    input  wire en_count,
    input  wire up_set,
    input  wire down_set,
    input  wire [WIDTH:0] limit,  
    output reg  [WIDTH:0] count,
    output wire rollover
);

    assign rollover = en_count && (count == limit);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= INIT_VAL;
        end else if (up_set) begin
            if (count == limit)
                count <= MIN_VAL;
            else
                count <= count + 1;
        end else if (down_set) begin
            if (count == MIN_VAL)
                count <= limit;
            else
                count <= count - 1;
        end else if (en_count) begin
            if (count == limit)
                count <= MIN_VAL;
            else
                count <= count + 1;
        end
    end

endmodule