module binaryToBCD4digit (
    input      [13:0] binary_score, // 14-bit input from the MUX
    output reg [3:0]  thousands,    // 4-bit output for Thousands display
    output reg [3:0]  hundreds,     // 4-bit output for Hundreds display
    output reg [3:0]  tens,         // 4-bit output for Tens display
    output reg [3:0]  ones          // 4-bit output for Ones display
);
    reg [15:0] bcd;
    reg [13:0] bin;
    integer i;

    always @(*) begin
        
        bin = binary_score;
        bcd = 28'h0;
        
        // using the Double Dabble algorithm
        for (i = 0; i < 14; i = i + 1) begin
            if (bcd[27:24] >= 5) bcd[27:24] = bcd[27:24] + 3;
            if (bcd[23:20] >= 5) bcd[23:20] = bcd[23:20] + 3;
            if (bcd[19:16] >= 5) bcd[19:16] = bcd[19:16] + 3;
            if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;
            if (bcd[11:8]  >= 5) bcd[11:8]  = bcd[11:8]  + 3;
            if (bcd[7:4]   >= 5) bcd[7:4]   = bcd[7:4]   + 3;
            if (bcd[3:0]   >= 5) bcd[3:0]   = bcd[3:0]   + 3;
            
            bcd = {bcd[26:0], bin[13]};
            bin = {bin[12:0], 1'b0};
        end
        
        thousands = bcd[15:12];
        hundreds  = bcd[11:8];
        tens      = bcd[7:4];
        ones      = bcd[3:0];
    end

endmodule