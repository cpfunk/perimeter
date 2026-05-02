`timescale 1ns/1ps

// divide system clock by 10
module clkDivBy16384_tb();
    wire clkOut;
    reg clk, rst;

    clkDivBy16384 clkDiv(.clk_16MHz(clk), .clk_1kHz(clkOut), .rst(rst));

    initial begin
        clk = 1'b0;
        rst = 1'b1;
    end

    always #31.25 clk <= ~clk;
    always @(posedge clk) rst <= 1'b0;

endmodule