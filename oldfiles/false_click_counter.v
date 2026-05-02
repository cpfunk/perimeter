module false_click_counter (
    input             clk,
    input             rst,
    input             hit,
    output reg [13:0] count
);

    wire [13:0] next_count;

    assign next_count = hit ? (count + 14'd1) : count;

    always @(posedge clk or posedge rst) begin
        if (rst)
            count <= 14'd0;
        else
            count <= next_count;
    end

endmodule