`timescale 1us/1ns

module decoder6to64(
    output [63:0] Y,
    input [0:5] X,
    input _en
);

    assign Y = (_en) ? 0 : 64'h1 << X;

endmodule