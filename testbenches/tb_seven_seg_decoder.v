`timescale 1ns / 1ps

module tb_seven_seg_decoder;

    // 1. Declare inputs as registers
    reg x3, x2, x1, x0;
    
    // 2. Declare outputs as wires
    wire A, B, C, D, E, F, G;

    // 3. Instantiate the 7-Segment Decoder (Unit Under Test)
    seven_seg_decoder uut (
        .A(A), .B(B), .C(C), .D(D), .E(E), .F(F), .G(G),
        .x3(x3), .x2(x2), .x1(x1), .x0(x0)
    );

    // 4. Use an integer to loop through all input combinations
    integer i;

    initial begin
        // Setup waveform dumping for Cadence/SimVision
        $dumpfile("seven_seg.vcd");
        $dumpvars(0, tb_seven_seg_decoder);

        // Print a clean header for the console output
        // Includes a hex representation for easy reading
        $display("Time | x3 x2 x1 x0 (Hex) | A B C D E F G");
        $display("----------------------------------------");

        // Loop from 0 to 15 to test every possible 4-bit state
        for (i = 0; i < 16; i = i + 1) begin
            
            // Map the lowest 4 bits of integer 'i' to our inputs
            {x3, x2, x1, x0} = i[3:0]; 
            
            // Wait 10ns for the combinational logic to update
            #10; 
            
            // Print the current state to the console
            // %X prints the value in Hexadecimal (0-F)
            $display("%4t |  %b  %b  %b  %b  (%X)  | %b %b %b %b %b %b %b", 
                     $time, x3, x2, x1, x0, i[3:0], A, B, C, D, E, F, G);
        end
        
        $display("----------------------------------------");
        $display("7-Segment Decoder testbench complete.");
        
        // Stop the simulation
        $finish; 
    end

endmodule
