`timescale 1ns / 1ps

module perimeter_tb;
    // uut paramters
    reg clk;
    reg clk_mux_s;
    reg _start_test;
    reg _clicker;
    reg true_false_sel_switch;
    reg [0:15] counter;

    wire clk_1kHz_ext;

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

    // testbench parameters
    reg [0:13] initial_false_clicks;
    reg [0:13] initial_true_clicks;
    reg [0:15] test_counter;
    reg [0:15] test_counter_at_true;
    reg [0:2] end_test_3;
    wire [0:13] false_clicks;
    wire [0:13] true_clicks;
    reg [0:3] testcase;
    wire [0:3] ones, tens, hundreds, thousands;
    wire clk_1kHz_div;
    wire rand_led_enable;
    wire [0:15] randDelayTime;

    wire true_click_detect_active;

    integer random_buttonpress_length;

    integer max_between_press_interval = 100; //FIXME
    integer max_button_press_time = 10; // clock cycles

    integer clockfreq = 10_000_000;
    integer s_to_ns = 1_000_000_000;
    integer ms_to_ns = 1_000_000;
    integer half_clk_cycle;

    integer maxVal_delay;
    integer minVal_delay;

    reg d1;
    reg d2;
    reg d3;
    
    // these reverse seven segment decoders
    // this enables the output of the seven segment display decoder to be easily observed 
    reverseSevenSegDecoder rssd1(
        .a(A_ones),
        .b(B_ones),
        .c(C_ones),
        .d(D_ones),
        .e(E_ones),
        .f(F_ones),
        .g(G_ones),
        .digit(ones)
    );

    reverseSevenSegDecoder rssd2(
        .a(A_tens),
        .b(B_tens),
        .c(C_tens),
        .d(D_tens),
        .e(E_tens),
        .f(F_tens),
        .g(G_tens),
        .digit(tens)
    );

    reverseSevenSegDecoder rssd3(
        .a(A_hundreds),
        .b(B_hundreds),
        .c(C_hundreds),
        .d(D_hundreds),
        .e(E_hundreds),
        .f(F_hundreds),
        .g(G_hundreds),
        .digit(hundreds)
    );

    reverseSevenSegDecoder rssd4(
        .a(A_thousands),
        .b(B_thousands),
        .c(C_thousands),
        .d(D_thousands),
        .e(E_thousands),
        .f(F_thousands),
        .g(G_thousands),
        .digit(thousands)
    );

    perimeter uut (
        .clk_16MHz(0),
        .clk_1kHz_ext(clk_1kHz_ext),
        .clk_mux_s(clk_mux_s),
        ._start_test(_start_test),
        ._clicker(_clicker),
        .true_false_display_sel_switch(true_false_sel_switch),
        .seed(16'hX),
        .seed_mux_s(0),
        .rand_led_onehot(rand_led_onehot),
        .A_thousands(A_thousands), .B_thousands(B_thousands), .C_thousands(C_thousands),
        .D_thousands(D_thousands), .E_thousands(E_thousands), .F_thousands(F_thousands), .G_thousands(G_thousands),
        .A_hundreds(A_hundreds), .B_hundreds(B_hundreds), .C_hundreds(C_hundreds),
        .D_hundreds(D_hundreds), .E_hundreds(E_hundreds), .F_hundreds(F_hundreds), .G_hundreds(G_hundreds),
        .A_tens(A_tens), .B_tens(B_tens), .C_tens(C_tens), .D_tens(D_tens), .E_tens(E_tens), .F_tens(F_tens), .G_tens(G_tens),
        .A_ones(A_ones), .B_ones(B_ones), .C_ones(C_ones), .D_ones(D_ones), .E_ones(E_ones), .F_ones(F_ones), .G_ones(G_ones)
    );

    initial begin
        testcase                = 1;
        counter                 = 0;
        clk               = 0;
        // clk_1kHz_ext            = // simulation would run too slow with 1kHz clock
        clk_mux_s               = 1; // bypass clock divider by setting clock mux to 1
        _start_test             = 1'b0;
        _clicker                = 1;
        true_false_sel_switch   = 0;
        initial_false_clicks    = 0;
        initial_true_clicks     = 0;
        test_counter            = 0;
        end_test_3              = 3'b001;
        test_counter_at_true    = ($random) % (16'd5000);

        maxVal_delay = uut.maxVal_delay;
        minVal_delay = uut.minVal_delay;
        half_clk_cycle = s_to_ns /(2 * clockfreq);
        random_buttonpress_length = $random % (max_button_press_time + 1);
        d1 = 0;
        d2 = 0;
        d3 = 0;
    end

    assign clk_1kHz_ext = clk; // run on faster clock for testbenching purposes
    assign true_click_detect_active = uut.comparator_inst.true_click_detect_active;
    assign false_clicks = uut.false_clicks;
    assign true_clicks = uut.true_clicks;
    assign clk_1kHz_div = uut.clk_1kHz_div;
    assign rand_led_enable = uut.rand_led_enable;
    assign randDelayTime = uut.rand_controller_inst.randDelayTime_w;
    // random button presses -> button should go low and then be held low for some random amount of time
    // assign random_buttonpress_event_start = (counter >= ($random % (max_between_press_interval + 1)));
    // assign random_buttonpress_event_end = (($random % (max_between_press_interval + 1) + random_buttonpress_length) >= counter);

    // triggering of synchronous testbench signals
    always #(half_clk_cycle) clk = ~clk;

    displayStartTest dt1 (.test(1), .display(d1));
    displayStartTest dt2 (.test(2), .display(d2));
    displayStartTest dt3 (.test(3), .display(d3));
    always @(posedge clk) begin

        case(testcase)
            default: // Test Case #1
            begin
                d1 <= 1;
                _start_test <= 1'b1;

                // patient presses & holds clicker when false
                if (test_counter == 0) begin
                    initial_false_clicks <= false_clicks;
                    initial_true_clicks <= true_clicks;
                end

                if (~true_click_detect_active) begin
                    test_counter <= test_counter + 1;
                end
                
                if (test_counter >= ($random) % (16'd5000) && ~true_click_detect_active) begin
                    _clicker <= 0;
                end
                else if (false_clicks == initial_false_clicks + 1 && initial_true_clicks == true_clicks && true_click_detect_active) begin
                    $display("Test #1 passed");
                    //advance testcase
                    testcase <= 2;
                    test_counter <= 0;
                    _clicker <= 1;
                end
            end
            4'd2: // Test Case #2
            begin
                d2 <= 1;

                // patient presses & holds clicker while true
                if (test_counter == 0) begin
                    initial_false_clicks <= false_clicks;
                    initial_true_clicks <= true_clicks;
                end

                if (true_click_detect_active) begin
                    test_counter <= test_counter + 1;
                end
                
                if (test_counter >= ($random) % (16'd5000) && true_click_detect_active) begin
                    _clicker <= 0;
                end
                else if (false_clicks == initial_false_clicks && initial_true_clicks + 1 == true_clicks && test_counter >= 16'd10_000) begin
                    $display("Test #2 passed");
                    //advance testcase
                    testcase <= 3;
                    test_counter <= 0;
                    _clicker <= 1;
                end
                else if (test_counter >= 16'd10_000) begin
                    $display("Test #2 failed");
                    $stop;
                end
            end
            4'd3: // Test Case #3
            begin
                d3 <= 1;

                if (test_counter == 0) begin
                    initial_false_clicks <= false_clicks;
                    initial_true_clicks <= true_clicks;
                end

                if (true_click_detect_active || ~true_click_detect_active && test_counter != 0) begin
                    test_counter <= test_counter + 1;
                end

                if (test_counter >= test_counter_at_true % 16'd2500 && true_click_detect_active) begin
                    _clicker <= 0;
                end
                else if (~_clicker) begin
                    _clicker <= 1;
                end
                else if (test_counter >= test_counter_at_true && ~true_click_detect_active) begin
                    _clicker <= 0;
                    end_test_3 <= end_test_3 << 1;
                end
                
                if (false_clicks == initial_false_clicks + 1 && initial_true_clicks + 1 == true_clicks) begin
                    $display("Test #3 passed");
                    //advance testcase
                    testcase <= 4;
                    test_counter <= 0;
                    _clicker <= 1;
                end
                else if (end_test_3 & 2'b100 && test_counter != 0) begin
                    $display("Test #3 failed");
                    $stop;
                end
            end
            4'd4: // Test Case #4
            begin
                _clicker <= ~_clicker;

                if (false_clicks != true_clicks) begin
                    $display("Decoder Output: %d %d %d %d", thousands, hundreds, tens, ones);
                    true_false_sel_switch <= 1;
                end

                if (true_false_sel_switch) begin

                    //display decoder output and true and false clicks
                    $display("### All tests Passed ###");
                    $display("False clicks: %d | True clicks: %d", uut.false_clicks, uut.true_clicks);
                    testcase <= 1;
                    _start_test <= 0;
                    true_false_sel_switch <= 0;
                    $stop; //FIXME
                end
            end
        endcase
    end

endmodule

module reverseSevenSegDecoder(
        input a, b, c, d, e, f, g,
        output reg [3:0] digit
    );

    always @(*) begin
        case({a, b, c, d, e, f, g})
            7'b1111110: digit = 4'd0;
            7'b0110000: digit = 4'd1;
            7'b1101101: digit = 4'd2;
            7'b1111001: digit = 4'd3;
            7'b0110011: digit = 4'd4;
            7'b1011011: digit = 4'd5;
            7'b1011111: digit = 4'd6;
            7'b1110000: digit = 4'd7;
            7'b1111111: digit = 4'd8;
            7'b1111011: digit = 4'd9;
            default:    digit = 4'hX;
        endcase
    end
    
endmodule

module displayStartTest(input [0:16] test, input display);
    reg displayed;

    initial begin
        displayed = 0;
    end

    always @(*) begin
        if (display && !displayed) begin
            $display("Starting test case #%d", test);
            displayed <= 1;
        end
    end

endmodule