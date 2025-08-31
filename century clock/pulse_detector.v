module pulse_detector (
    input  wire clk,
    input  wire rst,
    input  wire sig_in,
    output reg  sig_pulse
);
    reg sig_reg;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sig_reg   <= 1'b0;
            sig_pulse <= 1'b0;
        end else begin
            sig_reg   <= sig_in;
            // Corrected logic to detect a rising edge
            sig_pulse <= ~sig_reg & sig_in;
        end
    end
endmodule