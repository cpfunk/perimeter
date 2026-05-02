`timescale 1us/1ns

module clickComparatorAndTrueFalseCounter_tb;

    reg clk;
    reg reset;
    reg button_press;
    reg _en;
    reg [0:13] counter;

    wire [0:13] true_click_count;
    wire [0:13] false_click_count;
    wire [0:13] internal_counter;
    wire true_click_detect_active;

    integer max_between_press_interval = 100; //FIXME
    integer max_button_press_time = 10; // clock cycles

    assign internal_counter = uut.counter_14b;
    assign true_click_detect_active = uut.true_click_detect_active;
    wire true_click_count_changed;
    assign true_click_count_changed = uut.true_click_count_changed;

    localparam max_true_time = 14'd15; // change as needed //FIXME 5000 
    localparam max_between_en = 14'd50;

    wire click_negedge;

    reg [0:13] random_14b;

    assign click_negedge = uut.clicker_negedge;

    clickComparatorAndTrueFalseCounter uut (
        .clk(clk),
        ._clicker(button_press),
        ._en(_en),
        .rst(reset),
        .max_true_time(max_true_time),
        .true_click_count(true_click_count),
        .false_click_count(false_click_count)
    );

    initial begin
        random_14b    = $random;
        clk          = 0;
        reset        = 1;
        button_press = 1;
        _en          = 0;
        counter      = 0;
    end

    always #0.5 clk <= ~clk;

    assign button_press = ~((uut.counter_14b >= (random_14b)%(max_true_time) + 1) || (counter == (random_14b)%(max_between_en) + 1));

    always @(posedge clk) begin
        reset <= 1'b0;

        if (counter == max_between_en) begin
            _en <= 1'b0;
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
            _en <= 1'b1;
        end

        if (button_press) begin
            random_14b <= ($random) % (~(14'h0));
        end
    end

endmodule