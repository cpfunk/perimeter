module click_comparator (
    input clk,
    input _btn_press, // button is normally high -> goes low when pressed
    input _en,
    input rst,
    output true_click_pulse,  
    output false_click_pulse
);
    reg [0:13] counter_14b; // 14-bit 5-second counter (assuming 1kHz clock signal)
    reg pulse_captured;
    reg counter_trigger;
    localparam max_valid_time = 15; // change as needed //FIXME 5000

    wire trueClick,
    falseClick;

    assign trueClick    = ((~_en || counter_14b != 0) && ~_btn_press && ~pulse_captured);
    assign falseClick   = ((_en && counter_14b == 0) && ~_btn_press);

    always @(posedge clk or posedge rst) begin
        if (rst || counter_14b == max_valid_time) begin
            counter_trigger <= 0;
        end
        else if (~_en) begin
            counter_trigger <= 1;
        end

        if(counter_trigger) begin
            counter_14b <= counter_14b + 1;
        end
        else begin
            counter_14b <= 0;
            pulse_captured <= 1'b0;
        end

        if (trueClick) begin
            pulse_captured <= 1'b1;
        end
    end

    assign true_click_pulse     = (trueClick) ? 1'b1 : 1'b0;
    assign false_click_pulse    = (falseClick) ? 1'b1 : 1'b0;

endmodule