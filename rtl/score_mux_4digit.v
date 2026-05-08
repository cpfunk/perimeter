module score_mux_4digit (
    input      [13:0] true_clicks,   // 14-bit input
    input      [13:0] false_clicks,  // 14-bit input
    input             sel_switch,    // 1 = Show True, 0 = Show False
    output reg [13:0] display_score  // 14-bit output
);

    always @(*) begin
        display_score = sel_switch ? true_clicks : false_clicks;
    end

endmodule
