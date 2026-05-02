`timescale 1ns / 1ps

module tb_perimeter_system;

    reg clk_16MHz;
    wire clk_game;
    reg rst;
    reg start_test;
    reg button_press;
    reg led_enable;
    reg true_hit;
    reg false_hit;
    reg sel_switch;
    reg [0:15] seed;
    reg [0:15] maxVal_delay;
    reg [0:15] minVal_delay;
    reg [0:15] ledflashTime;

    wire [0:5]  rand_led_index;
    wire        rand_led_enable;
    wire [0:63] rand_led_onehot;

    wire A_thousands;
    wire B_thousands;
    wire C_thousands;
    wire D_thousands;
    wire E_thousands;
    wire F_thousands;
    wire G_thousands;

    wire A_hundreds;
    wire B_hundreds;
    wire C_hundreds;
    wire D_hundreds;
    wire E_hundreds;
    wire F_hundreds;
    wire G_hundreds;

    wire A_tens;
    wire B_tens;
    wire C_tens;
    wire D_tens;
    wire E_tens;
    wire F_tens;
    wire G_tens;

    wire A_ones;
    wire B_ones;
    wire C_ones;
    wire D_ones;
    wire E_ones;
    wire F_ones;
    wire G_ones;

    integer passed;
    integer failed;
    integer i;
    integer j;
    integer bit_count;
    integer saw_rand_active;

    reg [13:0] exp_true;
    reg [13:0] exp_false;

    perimeter uut (
        .clk_16MHz(clk_16MHz),
        .rst(rst),
        .start_test(start_test),
        .button_press(button_press),
        .led_enable(led_enable),
        .true_hit(true_hit),
        .false_hit(false_hit),
        .sel_switch(sel_switch),
        .seed(seed),
        .maxVal_delay(maxVal_delay),
        .minVal_delay(minVal_delay),
        .ledflashTime(ledflashTime),
        .rand_led_index(rand_led_index),
        .rand_led_enable(rand_led_enable),
        .rand_led_onehot(rand_led_onehot),
        .A_thousands(A_thousands), .B_thousands(B_thousands), .C_thousands(C_thousands),
        .D_thousands(D_thousands), .E_thousands(E_thousands), .F_thousands(F_thousands), .G_thousands(G_thousands),
        .A_hundreds(A_hundreds), .B_hundreds(B_hundreds), .C_hundreds(C_hundreds),
        .D_hundreds(D_hundreds), .E_hundreds(E_hundreds), .F_hundreds(F_hundreds), .G_hundreds(G_hundreds),
        .A_tens(A_tens), .B_tens(B_tens), .C_tens(C_tens), .D_tens(D_tens), .E_tens(E_tens), .F_tens(F_tens), .G_tens(G_tens),
        .A_ones(A_ones), .B_ones(B_ones), .C_ones(C_ones), .D_ones(D_ones), .E_ones(E_ones), .F_ones(F_ones), .G_ones(G_ones)
    );

    assign clk_game = uut.clk_1kHz;

    always #5 clk_16MHz = ~clk_16MHz;

    function [6:0] seg7;
        input [3:0] value;
        begin
            case (value)
                4'd0: seg7 = 7'b0000001;
                4'd1: seg7 = 7'b1001111;
                4'd2: seg7 = 7'b0010010;
                4'd3: seg7 = 7'b0000110;
                4'd4: seg7 = 7'b1001100;
                4'd5: seg7 = 7'b0100100;
                4'd6: seg7 = 7'b0100000;
                4'd7: seg7 = 7'b0001111;
                4'd8: seg7 = 7'b0000000;
                4'd9: seg7 = 7'b0000100;
                default: seg7 = 7'b1111111;
            endcase
        end
    endfunction

    task pulse_true_hit;
        begin
            @(negedge clk_game);
            true_hit = 1'b1;
            @(negedge clk_game);
            true_hit = 1'b0;
        end
    endtask

    task pulse_false_hit;
        begin
            @(negedge clk_game);
            false_hit = 1'b1;
            @(negedge clk_game);
            false_hit = 1'b0;
        end
    endtask

    task pulse_button;
        begin
            @(negedge clk_game);
            button_press = 1'b1;
            @(negedge clk_game);
            button_press = 1'b0;
        end
    endtask

    task check_display_and_counts;
        input [13:0] expected_true;
        input [13:0] expected_false;
        input [13:0] expected_display;
        reg [3:0] th;
        reg [3:0] hu;
        reg [3:0] te;
        reg [3:0] on;
        reg [6:0] seg_th;
        reg [6:0] seg_hu;
        reg [6:0] seg_te;
        reg [6:0] seg_on;
        begin
            th = expected_display / 1000;
            hu = (expected_display % 1000) / 100;
            te = (expected_display % 100) / 10;
            on = expected_display % 10;

            seg_th = seg7(th);
            seg_hu = seg7(hu);
            seg_te = seg7(te);
            seg_on = seg7(on);

            #1;

            if (uut.true_clicks === expected_true &&
                uut.false_clicks === expected_false &&
                uut.display_score === expected_display &&
                uut.thousands === th &&
                uut.hundreds === hu &&
                uut.tens === te &&
                uut.ones === on &&
                {A_thousands, B_thousands, C_thousands, D_thousands, E_thousands, F_thousands, G_thousands} === seg_th &&
                {A_hundreds,  B_hundreds,  C_hundreds,  D_hundreds,  E_hundreds,  F_hundreds,  G_hundreds}  === seg_hu &&
                {A_tens,      B_tens,      C_tens,      D_tens,      E_tens,      F_tens,      G_tens}      === seg_te &&
                {A_ones,      B_ones,      C_ones,      D_ones,      E_ones,      F_ones,      G_ones}      === seg_on) begin
                passed = passed + 1;
                $display("PASS: true=%0d false=%0d display=%0d digits=%0d%0d%0d%0d", expected_true, expected_false, expected_display, th, hu, te, on);
            end else begin
                failed = failed + 1;
                $display("FAIL: expected true=%0d false=%0d display=%0d", expected_true, expected_false, expected_display);
                $display("      observed true=%0d false=%0d display=%0d", uut.true_clicks, uut.false_clicks, uut.display_score);
            end
        end
    endtask

    initial begin
        $dumpfile("outputs/tb_perimeter_system.vcd");
        $dumpvars(0, tb_perimeter_system);

        clk_16MHz = 1'b0;
        rst = 1'b1;
        start_test = 1'b0;
        button_press = 1'b0;
        led_enable = 1'b0;
        true_hit = 1'b0;
        false_hit = 1'b0;
        sel_switch = 1'b1;

        // Values chosen to keep random-controller debug prints from flooding.
        seed = 16'h1A2B;
        maxVal_delay = 16'd64;
        minVal_delay = 16'd0;
        ledflashTime = 16'd8;

        passed = 0;
        failed = 0;
        exp_true = 14'd0;
        exp_false = 14'd0;
        saw_rand_active = 0;

        repeat (3) @(negedge clk_game);
        rst = 1'b0;

        // 1) Base reset check and display path.
        sel_switch = 1'b1;
        check_display_and_counts(exp_true, exp_false, exp_true);

        // 2) Manual true counter path.
        pulse_true_hit(); exp_true = exp_true + 1;
        pulse_true_hit(); exp_true = exp_true + 1;
        pulse_true_hit(); exp_true = exp_true + 1;
        sel_switch = 1'b1;
        check_display_and_counts(exp_true, exp_false, exp_true);

        // 3) Manual false counter path + mux switch.
        pulse_false_hit(); exp_false = exp_false + 1;
        pulse_false_hit(); exp_false = exp_false + 1;
        sel_switch = 1'b0;
        check_display_and_counts(exp_true, exp_false, exp_false);

        sel_switch = 1'b1;
        check_display_and_counts(exp_true, exp_false, exp_true);

        // 4) Comparator valid click with manual led_enable.
        led_enable = 1'b0;
        repeat (2) @(negedge clk_game);
        led_enable = 1'b1;
        repeat (20) @(negedge clk_game);
        pulse_button();
        led_enable = 1'b0;
        repeat (2) @(negedge clk_game);
        exp_true = exp_true + 1;
        sel_switch = 1'b1;
        check_display_and_counts(exp_true, exp_false, exp_true);

        // 5) Comparator false click in dark.
        pulse_button();
        repeat (2) @(negedge clk_game);
        exp_false = exp_false + 1;
        sel_switch = 1'b0;
        check_display_and_counts(exp_true, exp_false, exp_false);

        // 6) Comparator timeout (>5000 cycles).
        led_enable = 1'b0;
        repeat (2) @(negedge clk_game);
        led_enable = 1'b1;
        repeat (5005) @(negedge clk_game);
        pulse_button();
        led_enable = 1'b0;
        repeat (2) @(negedge clk_game);
        exp_false = exp_false + 1;
        sel_switch = 1'b0;
        check_display_and_counts(exp_true, exp_false, exp_false);

        // 7) Random controller + decoder interface sanity checks.
        for (i = 0; i < 200; i = i + 1) begin
            @(negedge clk_game);

            if (rand_led_enable === 1'b0) begin
                saw_rand_active = 1;
                bit_count = 0;
                for (j = 0; j < 64; j = j + 1) begin
                    if (rand_led_onehot[j] === 1'b1)
                        bit_count = bit_count + 1;
                end

                if (bit_count !== 1 || rand_led_onehot[rand_led_index] !== 1'b1) begin
                    failed = failed + 1;
                    $display("FAIL: decoder active state mismatch. index=%0d onehot=%b", rand_led_index, rand_led_onehot);
                end else begin
                    passed = passed + 1;
                end
            end else if (rand_led_enable === 1'b1) begin
                if (rand_led_onehot !== 64'b0) begin
                    failed = failed + 1;
                    $display("FAIL: decoder should be disabled when rand_led_enable=1");
                end else begin
                    passed = passed + 1;
                end
            end else begin
                failed = failed + 1;
                $display("FAIL: rand_led_enable is X/Z");
            end
        end

        if (saw_rand_active == 0)
            $display("WARN: rand_led_enable did not go low during sample window; active decoder state not observed.");

        $display("--- tb_perimeter_system Summary ---");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);

        if (failed == 0)
            $display("tb_perimeter_system complete.");
        else
            $display("tb_perimeter_system found failures.");

        $finish;
    end

endmodule
