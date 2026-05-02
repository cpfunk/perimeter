`timescale 1us/1ns

module decoder6to64_tb();
    wire [0:63] Y;
    reg [0:5] X;
    reg _en;
    reg clk;

    decoder6to64 decoder(
        .Y(Y),
        .X(X),
        ._en(_en)
    );

    initial begin
        _en = 0;
        clk= 0;
        X = 0;
    end

    always #500 clk <= ~clk;

    always @(posedge clk) begin
        X <= X + 1; 
    end

endmodule