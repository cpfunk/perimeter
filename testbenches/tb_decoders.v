`timescale 1ns / 1ps

module tb_decoders;

    reg        enable;
    reg  [2:0] in;

    wire [7:0] row_out;
    wire [7:0] col_out;

    integer i;
    integer passed;
    integer failed;

    Decoder_3to8_row uut_row (
        .enable(enable),
        .in(in),
        .out(row_out)
    );

    Decoder_3to8_col uut_col (
        .enable(enable),
        .in(in),
        .out(col_out)
    );

    initial begin
        $dumpfile("outputs/tb_decoders.vcd");
        $dumpvars(0, tb_decoders);

        passed = 0;
        failed = 0;

        $display("--- Testing Decoder_3to8_row and Decoder_3to8_col ---");

        // Sweep every enable/in combination. Bit 3 is enable, bits 2:0 are the decoded input.
        for (i = 0; i < 16; i = i + 1) begin
            reg [7:0] expected_row;
            reg [7:0] expected_col;

            {enable, in} = i[3:0];

            expected_row = enable ? (8'b00000001 << in) : 8'b00000000;
            expected_col = enable ? ~(8'b00000001 << in) : 8'b11111111;

            #1;

            if ((row_out === expected_row) && (col_out === expected_col)) begin
                passed = passed + 1;
                $display("PASS: EN=%b IN=%b -> row=%b col=%b", enable, in, row_out, col_out);
            end else begin
                failed = failed + 1;
                $display("FAIL: EN=%b IN=%b -> got row=%b col=%b expected row=%b col=%b",
                         enable, in, row_out, col_out, expected_row, expected_col);
            end

            #9;
        end
        
        $display("--- Summary ---");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);

        if (failed == 0)
            $display("All decoder test cases passed.");
        else
            $display("Some decoder test cases failed.");
        
        $finish;
    end

endmodule
