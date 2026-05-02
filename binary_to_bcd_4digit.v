module binary_to_bcd_4digit (
    input      [0:13] binary_score, // 14-bit input from the MUX
    output reg [0:3] thousands,    // 4-bit output for Thousands display
    output reg [0:3] hundreds,     // 4-bit output for Hundreds display
    output reg [0:3] tens,         // 4-bit output for Tens display
    output reg [0:3] ones          // 4-bit output for Ones display
);

    always @(*) begin
        // Example: If score is 4592
        
        // 4592 / 1000 = 4
        thousands = binary_score / 1000;
        
        // (4592 % 1000) gives 592. Then 592 / 100 = 5
        hundreds  = (binary_score % 1000) / 100;
        
        // (4592 % 100) gives 92. Then 92 / 10 = 9
        tens      = (binary_score % 100) / 10;
        
        // 4592 % 10 = 2
        ones      = binary_score % 10;
    end

endmodule
