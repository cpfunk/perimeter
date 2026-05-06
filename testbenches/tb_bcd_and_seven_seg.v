`timescale 1ns / 1ps

module tb_bcd_and_seven_seg;

    // Inputs
    reg  [13:0] binary_score;

    // BCD Outputs
    wire [3:0] thousands;
    wire [3:0] hundreds;
    wire [3:0] tens;
    wire [3:0] ones;

    // Seven Segment Display Outputs
    wire [6:0] seg_thousands;
    wire [6:0] seg_hundreds;
    wire [6:0] seg_tens;
    wire [6:0] seg_ones;

    integer passed;
    integer failed;

    // Binary to BCD converter
    binary_to_bcd_4digit bcd_converter (
        .binary_score(binary_score),
        .thousands(thousands),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );

    // Seven segment decoders for each digit
    seven_seg_decoder seg_decoder_thousands (
        .number(thousands),
        .A(seg_thousands[6]),
        .B(seg_thousands[5]),
        .C(seg_thousands[4]),
        .D(seg_thousands[3]),
        .E(seg_thousands[2]),
        .F(seg_thousands[1]),
        .G(seg_thousands[0])
    );

    seven_seg_decoder seg_decoder_hundreds (
        .number(hundreds),
        .A(seg_hundreds[6]),
        .B(seg_hundreds[5]),
        .C(seg_hundreds[4]),
        .D(seg_hundreds[3]),
        .E(seg_hundreds[2]),
        .F(seg_hundreds[1]),
        .G(seg_hundreds[0])
    );

    seven_seg_decoder seg_decoder_tens (
        .number(tens),
        .A(seg_tens[6]),
        .B(seg_tens[5]),
        .C(seg_tens[4]),
        .D(seg_tens[3]),
        .E(seg_tens[2]),
        .F(seg_tens[1]),
        .G(seg_tens[0])
    );

    seven_seg_decoder seg_decoder_ones (
        .number(ones),
        .A(seg_ones[6]),
        .B(seg_ones[5]),
        .C(seg_ones[4]),
        .D(seg_ones[3]),
        .E(seg_ones[2]),
        .F(seg_ones[1]),
        .G(seg_ones[0])
    );

    task run_test_case;
        input [13:0] score;
        reg   [3:0] exp_thousands;
        reg   [3:0] exp_hundreds;
        reg   [3:0] exp_tens;
        reg   [3:0] exp_ones;
        reg   [6:0] exp_seg_thousands;
        reg   [6:0] exp_seg_hundreds;
        reg   [6:0] exp_seg_tens;
        reg   [6:0] exp_seg_ones;
        begin
            binary_score   = score;
            exp_thousands  = score / 1000;
            exp_hundreds   = (score % 1000) / 100;
            exp_tens       = (score % 100) / 10;
            exp_ones       = score % 10;

            #10;  // Wait for combinational logic

            // Get expected 7-seg patterns (hardcoded for reference)
            case(exp_thousands)
                4'd0: exp_seg_thousands = 7'b1111110;
                4'd1: exp_seg_thousands = 7'b0110000;
                4'd2: exp_seg_thousands = 7'b1101101;
                4'd3: exp_seg_thousands = 7'b1111001;
                4'd4: exp_seg_thousands = 7'b0110011;
                4'd5: exp_seg_thousands = 7'b1011011;
                4'd6: exp_seg_thousands = 7'b1011111;
                4'd7: exp_seg_thousands = 7'b1110000;
                4'd8: exp_seg_thousands = 7'b1111111;
                4'd9: exp_seg_thousands = 7'b1111011;
                default: exp_seg_thousands = 7'hX;
            endcase

            case(exp_hundreds)
                4'd0: exp_seg_hundreds = 7'b1111110;
                4'd1: exp_seg_hundreds = 7'b0110000;
                4'd2: exp_seg_hundreds = 7'b1101101;
                4'd3: exp_seg_hundreds = 7'b1111001;
                4'd4: exp_seg_hundreds = 7'b0110011;
                4'd5: exp_seg_hundreds = 7'b1011011;
                4'd6: exp_seg_hundreds = 7'b1011111;
                4'd7: exp_seg_hundreds = 7'b1110000;
                4'd8: exp_seg_hundreds = 7'b1111111;
                4'd9: exp_seg_hundreds = 7'b1111011;
                default: exp_seg_hundreds = 7'hX;
            endcase

            case(exp_tens)
                4'd0: exp_seg_tens = 7'b1111110;
                4'd1: exp_seg_tens = 7'b0110000;
                4'd2: exp_seg_tens = 7'b1101101;
                4'd3: exp_seg_tens = 7'b1111001;
                4'd4: exp_seg_tens = 7'b0110011;
                4'd5: exp_seg_tens = 7'b1011011;
                4'd6: exp_seg_tens = 7'b1011111;
                4'd7: exp_seg_tens = 7'b1110000;
                4'd8: exp_seg_tens = 7'b1111111;
                4'd9: exp_seg_tens = 7'b1111011;
                default: exp_seg_tens = 7'hX;
            endcase

            case(exp_ones)
                4'd0: exp_seg_ones = 7'b1111110;
                4'd1: exp_seg_ones = 7'b0110000;
                4'd2: exp_seg_ones = 7'b1101101;
                4'd3: exp_seg_ones = 7'b1111001;
                4'd4: exp_seg_ones = 7'b0110011;
                4'd5: exp_seg_ones = 7'b1011011;
                4'd6: exp_seg_ones = 7'b1011111;
                4'd7: exp_seg_ones = 7'b1110000;
                4'd8: exp_seg_ones = 7'b1111111;
                4'd9: exp_seg_ones = 7'b1111011;
                default: exp_seg_ones = 7'hX;
            endcase

            // Check all outputs
            if ((thousands === exp_thousands) &&
                (hundreds  === exp_hundreds)  &&
                (tens      === exp_tens)      &&
                (ones      === exp_ones)      &&
                (seg_thousands === exp_seg_thousands) &&
                (seg_hundreds  === exp_seg_hundreds)  &&
                (seg_tens      === exp_seg_tens)      &&
                (seg_ones      === exp_seg_ones)) begin
                passed = passed + 1;
                $display("PASS: %5d -> BCD: %d%d%d%d | Seg: %07b %07b %07b %07b",
                         score, thousands, hundreds, tens, ones,
                         seg_thousands, seg_hundreds, seg_tens, seg_ones);
            end else begin
                failed = failed + 1;
                $display("FAIL: %5d", score);
                if ((thousands !== exp_thousands) || (hundreds !== exp_hundreds) || 
                    (tens !== exp_tens) || (ones !== exp_ones))
                    $display("      BCD: got %d%d%d%d, expected %d%d%d%d",
                             thousands, hundreds, tens, ones,
                             exp_thousands, exp_hundreds, exp_tens, exp_ones);
                if ((seg_thousands !== exp_seg_thousands) || (seg_hundreds !== exp_seg_hundreds) || 
                    (seg_tens !== exp_seg_tens) || (seg_ones !== exp_seg_ones))
                    $display("      Seg: got %07b %07b %07b %07b, expected %07b %07b %07b %07b",
                             seg_thousands, seg_hundreds, seg_tens, seg_ones,
                             exp_seg_thousands, exp_seg_hundreds, exp_seg_tens, exp_seg_ones);
            end
        end
    endtask

    initial begin
        $dumpfile("tb_bcd_and_seven_seg.vcd");
        $dumpvars(0, tb_bcd_and_seven_seg);

        passed = 0;
        failed = 0;

        $display("\n================================================================");
        $display("   Binary to BCD + Seven Segment Display Pipeline Tests");
        $display("================================================================\n");

        $display("--- Edge Cases ---");
        run_test_case(14'd0);        // 0000
        run_test_case(14'd1);        // 0001
        run_test_case(14'd9);        // 0009
        
        $display("\n--- Decade Boundaries ---");
        run_test_case(14'd10);       // 0010
        run_test_case(14'd99);       // 0099
        run_test_case(14'd100);      // 0100
        run_test_case(14'd999);      // 0999
        run_test_case(14'd1000);     // 1000
        
        $display("\n--- Random Values ---");
        run_test_case(14'd15);       // 0015
        run_test_case(14'd105);      // 0105
        run_test_case(14'd567);      // 0567
        run_test_case(14'd1234);     // 1234
        run_test_case(14'd4592);     // 4592
        run_test_case(14'd9999);     // 9999
        
        $display("\n--- Maximum Values ---");
        run_test_case(14'd10000);    // 10000
        run_test_case(14'd16383);    // Max 14-bit value

        $display("\n================================================================");
        $display("   Test Summary");
        $display("================================================================");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);

        if (failed == 0)
            $display("\n✓ All pipeline tests passed!");
        else
            $display("\n✗ Some pipeline tests failed.");
        $display("================================================================\n");

        $finish;
    end

endmodule
