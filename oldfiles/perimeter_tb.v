`timescale 1us / 1ns

module perimeter_tb;


    // uut paramters
    reg clk_16MHz;
    reg clk_mux_s;
    reg _start_test;
    reg _clicker;
    reg true_false_sel_switch;
    reg [0:15] seed;
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
    wire random_buttonpress_event_start;
    wire random_buttonpress_event_end;
    integer random_buttonpress_length;

    integer max_between_press_interval = 100; //FIXME
    integer max_button_press_time = 10; // clock cycles

    integer clockfreq = 16_000_000;
    integer s_to_ns = 1_000_000_000;
    integer ms_to_ns = 1_000_000;
    integer half_clk_cycle;

    time start_time_true_signal, duration_true_signal, led_delay;

    integer max_true_click_time;
    integer max_between_led_blink_time;
    integer min_led_blink_time;

    perimeter uut (
        .clk_16MHz(clk_16MHz),
        .clk_1kHz_ext(clk_1kHz_ext),
        .clk_mux_s(clk_mux_s),
        ._start_test(_start_test),
        ._clicker(_clicker),
        .true_false_display_sel_switch(true_false_sel_switch),
        .seed(seed),
        .rand_led_onehot(rand_led_onehot),
        .A_thousands(A_thousands), .B_thousands(B_thousands), .C_thousands(C_thousands),
        .D_thousands(D_thousands), .E_thousands(E_thousands), .F_thousands(F_thousands), .G_thousands(G_thousands),
        .A_hundreds(A_hundreds), .B_hundreds(B_hundreds), .C_hundreds(C_hundreds),
        .D_hundreds(D_hundreds), .E_hundreds(E_hundreds), .F_hundreds(F_hundreds), .G_hundreds(G_hundreds),
        .A_tens(A_tens), .B_tens(B_tens), .C_tens(C_tens), .D_tens(D_tens), .E_tens(E_tens), .F_tens(F_tens), .G_tens(G_tens),
        .A_ones(A_ones), .B_ones(B_ones), .C_ones(C_ones), .D_ones(D_ones), .E_ones(E_ones), .F_ones(F_ones), .G_ones(G_ones)
    );

    initial begin
        max_true_click_time = ms_to_ns * uut.max_true_time;
        max_between_led_blink_time = ms_to_ns * uut.maxVal_delay;
        min_led_blink_time = ms_to_ns * uut.minVal_delay;
        half_clk_cycle = s_to_ns /(2 * clockfreq);

        random_buttonpress_length = $random % (max_button_press_time + 1);
        counter                 = 0;
        clk_16MHz               = 0;
        // clk_1kHz_ext            = // simulation would run too slow with 1kHz clock
        clk_mux_s               = 1; // bypass clock divider by setting clock mux to 1
        _start_test             = 1'b0;
        _clicker               = 1;
        true_false_sel_switch   = 1;
        seed                    = $random;
        $display("seed = %d", seed);
    end

    always #(half_clk_cycle) clk_16MHz = ~clk_16MHz;
    assign clk_1kHz_ext = clk_16MHz; // run on faster clock for testbenching purposes

    wire [0:3] ones, tens, hundreds, thousands;

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
    
    // random button press length

    // random button presses -> button should go low and then be held low for some random amount of time
    assign random_buttonpress_event_start = (counter >= ($random % (max_between_press_interval + 1)));
    assign random_buttonpress_event_end = (($random % (max_between_press_interval + 1) + random_buttonpress_length) >= counter);

    always @(posedge clk_16MHz) begin

        _start_test <= 1'b1;

        if (counter == 16'd16) true_false_sel_switch <= ~max_between_press_interval;

        // "press" button when random_buttonpress_event goes high 
        if (random_buttonpress_event_start && random_buttonpress_event_end) begin
            _clicker <= 1'b0;
        end
        else if (random_buttonpress_event_end) begin
            counter <= 0;
        end
        else begin
            _clicker <= 1'b1;
            counter <= counter + 1;
        end

        // if()
        
        // //make sure only button presses occuring in the 0 - 5 second inverval from a led flash should be counted


        // //make sure that led blinks between 7 and 20 seconds
        // if (rand_led_onehot != 0) begin
        //     led_start_time = $time;
        //     le
        // end
        // else if ()

        //display decoder output and true and false clicks
        $display("False clicks: %d | True clicks: %d", uut.false_clicks, uut.true_clicks);
        $display("Decoder Output: %d %d %d %d", thousands, hundreds, tens, ones);
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