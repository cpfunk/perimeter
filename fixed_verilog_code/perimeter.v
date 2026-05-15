`timescale 1us / 1ns

module perimeter (
    input             clk_16MHz,
    input             clk_100Hz_ext,
    input             clk_mux_s,
    input             _clicker,
    input             true_false_display_sel_switch,
    input             _start_test,
    input      [0:15] seed,
    input             seed_mux_s,
    output     [0:63] rand_led_onehot,
    output            A_thousands,
    output            B_thousands,
    output            C_thousands,
    output            D_thousands,
    output            E_thousands,
    output            F_thousands,
    output            G_thousands,
    output            A_hundreds,
    output            B_hundreds,
    output            C_hundreds,
    output            D_hundreds,
    output            E_hundreds,
    output            F_hundreds,
    output            G_hundreds,
    output            A_tens,
    output            B_tens,
    output            C_tens,
    output            D_tens,
    output            E_tens,
    output            F_tens,
    output            G_tens,
    output            A_ones,
    output            B_ones,
    output            C_ones,
    output            D_ones,
    output            E_ones,
    output            F_ones,
    output            G_ones
);
    wire [13:0] true_clicks;
    wire [13:0] false_clicks;
    wire [13:0] display_score;
    wire [0:3] thousands;
    wire [0:3] hundreds;
    wire [0:3] tens;
    wire [0:3] ones;
    wire       clk_100Hz;
    wire       clk_100Hz_div;
    wire       comparator_true_hit;
    wire       comparator_false_hit;
    wire [5:0] rand_led_index;
    wire rand_led_enable;
    wire rst;
    wire [0:15] seed_w;

    assign clk_div = clk_100Hz_div; //FIXME

    localparam [0:15] maxVal_delay     = 16'd2000;    // 2000 clock cycles
    localparam [0:15] minVal_delay     = 16'd700;     // 700 clock cycles
    localparam [0:15] ledflashTime     = 16'd100;     // 100 clock cycles
    localparam [0:13] max_true_time    = 14'd500 + ledflashTime; // 600 clock cycles

    //clock mux
    assign clk_100Hz = (clk_mux_s) ? clk_100Hz_ext : clk_100Hz_div;

    assign seed_w = (seed_mux_s) ? seed : 16'd40267;

    //assign reset signal to _start_test signal
    assign rst = ~_start_test;

    clkDivBy160_000 clk_div_160k_inst (
        .clk_100Hz(clk_100Hz_div),
        .clk_16MHz(clk_16MHz),
        .rst(rst)
    );
    
    pseudoRandDecoderController_6b rand_controller_inst (
        .randOut(rand_led_index),
        ._enOut(rand_led_enable),
        .clk(clk_100Hz),
        .seed(seed_w),
        .maxVal_delay(maxVal_delay),
        .minVal_delay(minVal_delay),
        .ledflashTime(ledflashTime),
        .rst(rst)
    );

    decoder6to64 rand_decoder_inst (
        .Y(rand_led_onehot),
        .X(rand_led_index),
        ._en(rand_led_enable)
    );

    clickComparatorAndTrueFalseCounter comparator_inst (
        .clk(clk_100Hz),
        ._clicker(_clicker),   // button is normally high -> goes low when pressed
        ._en(rand_led_enable),    // led flash singal from random decoder controller
        .rst(rst),
        .max_true_time(max_true_time),
        .true_click_count(true_clicks),  
        .false_click_count(false_clicks)
    );

    score_mux_4digit score_mux_inst (
        .true_clicks(true_clicks),
        .false_clicks(false_clicks),
        .sel_switch(true_false_display_sel_switch),
        .display_score(display_score)
    );

    binaryToBCD4digit bcd_inst (
        .binary_score(display_score),
        .thousands(thousands),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );

    seven_seg_decoder thousands_decoder (
        .A(A_thousands),
        .B(B_thousands),
        .C(C_thousands),
        .D(D_thousands),
        .E(E_thousands),
        .F(F_thousands),
        .G(G_thousands),
        .number(thousands)
    );

    seven_seg_decoder hundreds_decoder (
        .A(A_hundreds),
        .B(B_hundreds),
        .C(C_hundreds),
        .D(D_hundreds),
        .E(E_hundreds),
        .F(F_hundreds), 
        .G(G_hundreds),
        .number(hundreds)
    );

    seven_seg_decoder tens_decoder (
        .A(A_tens),
        .B(B_tens),
        .C(C_tens),
        .D(D_tens),
        .E(E_tens),
        .F(F_tens), 
        .G(G_tens),
        .number(tens)
    );

    seven_seg_decoder ones_decoder (
        .A(A_ones),
        .B(B_ones),
        .C(C_ones),
        .D(D_ones),
        .E(E_ones),
        .F(F_ones), 
        .G(G_ones),
        .number(ones)
    );

endmodule`timescale 1us / 1ns

