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
    reg _clicker_sync_prev;
    reg _clicker_sync;
    reg _en_prev;
    wire clicker_negedge;
    wire en_negedge;
    wire true_click_count_changed;
    wire within_true_time;

    // signal for negative edge detections
    assign clicker_negedge = (_clicker_sync_prev == 1'b1 &&  _clicker_sync == 1'b0);
    assign en_negedge = (_en_prev == 1'b1 &&  _en == 1'b0);
    assign true_click_count_changed = (true_click_count > true_click_count_prev);
    assign true_time_timeout = (counter_14b >= max_true_time - 1); // -1 because counter starts at 0

    // syncronize the clicker input to the clock
    always @(posedge clk) begin
        _clicker_sync <= _clicker;
        _clicker_sync_prev <= _clicker_sync;
    end

    // update previous clicker level for negative edge detection
    always @(posedge clk) begin
        _en_prev <= _en;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            true_click_detect_active <= 1'b0;
        end
        else if (en_negedge) begin
            true_click_detect_active <= 1'b1;
        end
        // stop counting when timer reaches max_true_time
        else if (true_time_timeout || true_click_count_changed) begin
            true_click_detect_active <= 1'b0;
        end
        else begin
            // latch current state
            true_click_detect_active <= true_click_detect_active;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            true_click_count <= 0;
            false_click_count <= 0;
        end
        // if the counter is counting and a negative edge is detected on _clicker input
        else if (clicker_negedge) begin
            // increment true_click_count and stop counting
            if (en_negedge || true_click_detect_active) begin
                true_click_count <= true_click_count + 1;
            end
            // otherwise increment false_click_count
            else begin
                false_click_count <= false_click_count + 1;
            end
        end
    end

    // start counting time whenever true_click_detect_active is high
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_14b <= 0;
        end
        else if (!true_click_detect_active) begin
            counter_14b <= 0; 
        end
        else begin
            counter_14b <= counter_14b + 1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            true_click_count_prev <= 14'h0;
        end
        else begin
            true_click_count_prev <= true_click_count;
        end
    end

endmodule