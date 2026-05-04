`timescale 1ns / 1ps

module tb_binary_to_bcd_4digit_waves;

    reg  [13:0] binary_score;
    wire [3:0] thousands;
    wire [3:0] hundreds;
    wire [3:0] tens;
    wire [3:0] ones;

    integer passed;
    integer failed;

    binary_to_bcd_4digit uut (
        .binary_score(binary_score),
        .thousands(thousands),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );

    task run_case;
        input [13:0] score;
        reg   [3:0] exp_thousands;
        reg   [3:0] exp_hundreds;
        reg   [3:0] exp_tens;
        reg   [3:0] exp_ones;
        begin
            binary_score   = score;
            exp_thousands  = score / 1000;
            exp_hundreds   = (score % 1000) / 100;
            exp_tens       = (score % 100) / 10;
            exp_ones       = score % 10;

            #10;  // Longer delay for wave viewing

            if ((thousands === exp_thousands) &&
                (hundreds  === exp_hundreds)  &&
                (tens      === exp_tens)      &&
                (ones      === exp_ones)) begin
                passed = passed + 1;
                $display("PASS: score=%0d -> %0d %0d %0d %0d",
                         score, thousands, hundreds, tens, ones);
            end else begin
                failed = failed + 1;
                $display("FAIL: score=%0d -> got %0d %0d %0d %0d, expected %0d %0d %0d %0d",
                         score, thousands, hundreds, tens, ones,
                         exp_thousands, exp_hundreds, exp_tens, exp_ones);
            end
        end
    endtask

    initial begin
        $dumpfile("tb_binary_to_bcd_4digit_waves.vcd");
        $dumpvars(0, tb_binary_to_bcd_4digit_waves);

        passed = 0;
        failed = 0;

        $display("\n========================================");
        $display("Binary to BCD 4-Digit Conversion Tests");
        $display("========================================\n");

        $display("--- Edge Cases ---");
        run_case(14'd0);        // Zero
        run_case(14'd1);        // One
        run_case(14'd9);        // Single digit max
        
        $display("\n--- Decade Boundaries ---");
        run_case(14'd10);       // 10
        run_case(14'd99);       // 99
        run_case(14'd100);      // 100
        run_case(14'd999);      // 999
        run_case(14'd1000);     // 1000
        
        $display("\n--- Random Values ---");
        run_case(14'd15);       // 15
        run_case(14'd105);      // 105
        run_case(14'd4592);     // 4592
        run_case(14'd9999);     // 9999
        run_case(14'd12034);    // 12034
        
        $display("\n--- Maximum Value ---");
        run_case(14'd16383);    // Max 14-bit value

        $display("\n========================================");
        $display("Test Summary");
        $display("========================================");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);

        if (failed == 0)
            $display("\n✓ All test cases passed!");
        else
            $display("\n✗ Some test cases failed.");
        $display("========================================\n");

        $finish;
    end

endmodule
