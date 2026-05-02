`timescale 1ns / 1ps

module tb_binary_to_bcd_4digit;

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

            #1;

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
        $dumpfile("binary_to_bcd_4digit.vcd");
        $dumpvars(0, tb_binary_to_bcd_4digit);

        passed = 0;
        failed = 0;

        $display("\n--- Directed Tests ---");
        run_case(14'd0);
        run_case(14'd1);
        run_case(14'd9);
        run_case(14'd10);
        run_case(14'd15);
        run_case(14'd99);
        run_case(14'd100);
        run_case(14'd105);
        run_case(14'd999);
        run_case(14'd1000);
        run_case(14'd4592);
        run_case(14'd9999);
        run_case(14'd12034);
        run_case(14'd16383);

        $display("\n--- Summary ---");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);

        if (failed == 0)
            $display("All test cases passed.");
        else
            $display("Some test cases failed.");

        $finish;
    end

endmodule
