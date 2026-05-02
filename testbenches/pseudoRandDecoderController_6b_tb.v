`timescale 1us/1ns

module pseudoRandDecoderController_6b_tb();
    wire [0:5] randOut;
    wire _enOut;
    reg clk;
    reg rst;
    reg [0:15] seed;
    localparam maxVal_delay = 20, // should be 20000 ms //FIXME
    minVal_delay            = 7, // should be 7000 ms //FIXME
    ledflashTime            = 10; 

    initial begin
        seed = $random; $display("seed = %d", seed);
        clk = 0;
        rst = 1;
    end

    pseudoRandDecoderController_6b randController(
        .randOut(randOut),
        ._enOut(_enOut),
        .clk(clk),
        .seed(seed),
        .maxVal_delay(maxVal_delay),
        .minVal_delay(minVal_delay),
        .ledflashTime(ledflashTime),
        .rst(rst)
    );

    always #0.5 clk <= ~clk;

    always @(posedge clk) begin
        rst <= 1'b0;
    end

    always @(*) begin
        if (randOut > 64) begin
            $display("ERROR: outside of 0-64 range: randOut = %d", randOut);
        end
    end

endmodule