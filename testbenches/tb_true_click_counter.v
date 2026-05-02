`timescale 1ns / 1ps

module tb_true_click_counter;

    reg clk;
    reg rst;
    reg hit;
    wire [13:0] count;

    integer passed;
    integer failed;

    true_click_counter uut (
        .clk(clk),
        .rst(rst),
        .hit(hit),
        .count(count)
    );

    always #5 clk = ~clk;

    task check_count;
        input [13:0] expected;
        begin
            #1;
            if (count === expected) begin
                passed = passed + 1;
                $display("PASS: count=%0d", count);
            end else begin
                failed = failed + 1;
                $display("FAIL: got count=%0d expected=%0d", count, expected);
            end
        end
    endtask

    initial begin
        $dumpfile("outputs/tb_true_click_counter.vcd");
        $dumpvars(0, tb_true_click_counter);

        clk = 0;
        rst = 1;
        hit = 0;
        passed = 0;
        failed = 0;

        #12;
        rst = 0;
        check_count(14'd0);

        @(negedge clk);
        hit = 0;
        @(negedge clk);
        check_count(14'd0);

        @(negedge clk);
        hit = 1;
        @(negedge clk);
        hit = 0;
        check_count(14'd1);

        @(negedge clk);
        hit = 1;
        @(negedge clk);
        hit = 1;
        @(negedge clk);
        hit = 0;
        check_count(14'd3);

        rst = 1;
        @(negedge clk);
        rst = 0;
        check_count(14'd0);

        $display("--- Summary ---");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);

        if (failed == 0)
            $display("true_click_counter testbench complete.");
        else
            $display("true_click_counter testbench found failures.");

        $finish;
    end

endmodule
