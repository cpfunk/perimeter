`timescale 1ns/1ps

// divide 16 MHz clock by 2^14 (16384) to get ~977 Hz
module clkDivBy16384 (
    output reg clk_1kHz,
    input clk_16MHz,
    rst
);
    reg [0:12] counter_14b;
    localparam maxCount_14b = ~13'h0;

    always @(posedge clk_16MHz) begin
        if (rst) begin
            counter_14b <= 0;
            clk_1kHz <= 0;
        end
        else begin
            counter_14b <= counter_14b + 1;
        end

        if (counter_14b == maxCount_14b) begin
            clk_1kHz <= ~clk_1kHz;
        end
    end

endmodule
