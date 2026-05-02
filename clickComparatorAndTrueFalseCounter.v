module clickComparatorAndTrueFalseCounter (
    input clk,
    input _clicker,     // clicker is active low
    input _en,          // led flash singal from random decoder controller
    input rst,
    input [0:13] max_true_time,
    output reg [0:13] true_click_count,  
    output reg [0:13] false_click_count
);
    reg [0:13] true_click_count_prev;
    reg [0:13] counter_14b; // 14-bit 5-second counter (assuming 1kHz clock signal)
    reg true_click_detect_active;
    reg _clicker_level_prev;
    reg _en_level_prev;
    wire clicker_negedge;
    wire en_negedge;
    wire true_click_count_changed;

    // signal for negative edge detections
    assign clicker_negedge = (_clicker_level_prev == 1'b1 &&  _clicker == 1'b0);
    assign en_negedge = (_en_level_prev == 1'b1 &&  _en == 1'b0);
    assign true_click_count_changed = (true_click_count == true_click_count_prev + 1);

    always @(*) begin
        if (rst) begin
            true_click_detect_active = 1'b0;
        end
        else if (en_negedge) begin
            true_click_detect_active = 1'b1;
        end
        // stop counting when timer reaches max_true_time
        else if (counter_14b > max_true_time || true_click_count_changed) begin
            true_click_detect_active = 1'b0;
        end
    end

    always @(posedge clk or posedge rst) begin

        // update previous clicker level for negative edge detection
        _clicker_level_prev <= _clicker;
        _en_level_prev <= _en;
        true_click_count_prev <= (rst) ? 14'h0 : true_click_count;

        if (rst) begin
            true_click_count <= 0;
            false_click_count <= 0;
        end
        // if the counter is counting and a negative edge is detected on _clicker input
        else if (clicker_negedge) begin
            // increment true_click_count and stop counting
            if (true_click_detect_active) begin
                true_click_count <= true_click_count + 1;
            end
            // otherwise increment false_click_count
            else begin
                false_click_count <= false_click_count + 1;
            end
        end
        
        // start counting time whenever true_click_detect_active is high
        counter_14b <= (rst || !true_click_detect_active) ? 0 : counter_14b + 1;
        
    end

endmodule