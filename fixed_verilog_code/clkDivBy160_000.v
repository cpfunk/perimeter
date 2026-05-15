`timescale 1ns/1ps

// divide 16 MHz clock by 160_000 to get 100 Hz
module clkDivBy160_000 (
    output reg clk_100Hz,
    input clk_16MHz,
    input rst
);
    reg [0:16] counter_18b;
    localparam maxCount_18b = 80_000 - 1; // 160,000 clock cycles

    always @(posedge clk_16MHz or posedge rst) begin
        if (rst) begin
            counter_18b <= 0;
            clk_100Hz <= 0;
        end
        else if (counter_18b >= maxCount_18b) begin
            counter_18b <= 0; // reset counter
            clk_100Hz <= ~clk_100Hz; // toggle output clock
        end
        else begin
            counter_18b <= counter_18b + 1;
        end
    end

endmodule
