`timescale 1us/1ns

module tb_click_comparator;

    reg clk;
    reg reset;
    reg button_press;
    reg _en;

    wire true_click_pulse;
    wire false_click_pulse;
    wire [0:13] internal_timer;

    assign internal_timer = uut.counter_14b;

    reg [0:13] counter; 

    click_comparator uut (
        .clk(clk),
        ._btn_press(button_press),
        ._en(_en),
        .rst(reset),
        .true_click_pulse(true_click_pulse),
        .false_click_pulse(false_click_pulse)
    );

    initial begin
        clk          = 0;
        reset        = 1;
        button_press = 1;
        _en          = 0;
        counter      = 0;
    end

    always #0.5 clk <= ~clk;

    always @(posedge clk) begin
        reset <= 1'b0;

        if (counter == 14'd40) begin
            _en <= 1'b0;
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
            _en <= 1'b1;
        end

        if (counter % 15 == 0 || (counter + 1) % 15 == 0) begin
            button_press <= 1'b0;
        end
        else begin
            button_press <= 1'b1;
        end
    end

endmodule

// module click_comparator_tb();
 
//     // Testbench signals
//     reg clk;
//     reg _btn_press;
//     reg _en;
//     reg rst;
//     wire true_click_pulse;
//     wire false_click_pulse;
 
//     // Instantiate the module under test
//     click_comparator uut (
//         .clk(clk),
//         ._btn_press(_btn_press),
//         ._en(_en),
//         .rst(rst),
//         .true_click_pulse(true_click_pulse),
//         .false_click_pulse(false_click_pulse)
//     );
 
//     // Clock generation (1kHz clock = 1ms period)
//     initial begin
//         clk = 0;
//         forever #500 clk = ~clk;  // 500ns half period = 1000ns full period = 1us, but scale as needed
//     end
 
//     // Test task to wait for a specific number of clock cycles
//     task wait_cycles(input integer num_cycles);
//         repeat(num_cycles) @(posedge clk);
//     endtask
 
//     // Main testbench logic
//     initial begin
//         // Initialize signals
//         _btn_press = 1'b1;  // Button normally high (not pressed)
//         _en = 1'b1;         // Enable normally high
//         rst = 1'b0;
 
//         $display("=== Click Comparator Testbench ===");
//         $display("Time\t\tTest Description");
//         $display("====================================");
 
//         // Test 1: Valid click (button pressed early within window)
//         $display("\nTest 1: Valid Click - Button pressed at 1 second");
//         $display("$time\t\t_en\t_btn_press\ttrue_click\tfalse_click");
        
//         _en = 1'b0;  // Start the enable window
//         wait_cycles(1000);  // Wait 1 second (1000 clock cycles)
//         _btn_press = 1'b0;  // Button pressed
//         wait_cycles(10);    // Hold button for 10 cycles
//         _btn_press = 1'b1;  // Release button
//         wait_cycles(5000);  // Wait for the window to close
        
//         if (true_click_pulse)
//             $display("%t: PASS - True click detected", $time);
//         else
//             $display("%t: FAIL - True click not detected", $time);
 
//         // Reset for next test
//         rst = 1'b1;
//         wait_cycles(10);
//         rst = 1'b0;
//         _en = 1'b1;
//         wait_cycles(100);
 
//         // Test 2: False click (button pressed after 5-second window)
//         $display("\nTest 2: False Click - Button pressed at 6 seconds");
        
//         _en = 1'b0;  // Start the enable window
//         wait_cycles(6000);  // Wait 6 seconds (6000 clock cycles) - past the 5-second window
//         _btn_press = 1'b0;  // Button pressed
//         wait_cycles(10);    // Hold button for 10 cycles
//         _btn_press = 1'b1;  // Release button
//         wait_cycles(500);   // Wait a bit more
        
//         if (false_click_pulse)
//             $display("%t: PASS - False click detected", $time);
//         else
//             $display("%t: FAIL - False click not detected", $time);
 
//         // Reset for next test
//         rst = 1'b1;
//         wait_cycles(10);
//         rst = 1'b0;
//         _en = 1'b1;
//         wait_cycles(100);
 
//         // Test 3: No click (button never pressed)
//         $display("\nTest 3: No Click - Button never pressed");
        
//         _en = 1'b0;  // Start the enable window
//         wait_cycles(5500);  // Wait for entire window to pass
        
//         if (!true_click_pulse && !false_click_pulse)
//             $display("%t: PASS - No spurious pulses detected", $time);
//         else
//             $display("%t: FAIL - Unexpected pulse detected", $time);
 
//         // Reset for next test
//         rst = 1'b1;
//         wait_cycles(10);
//         rst = 1'b0;
//         _en = 1'b1;
//         wait_cycles(100);
 
//         // Test 4: Multiple button presses (only first should count)
//         $display("\nTest 4: Multiple Clicks - Only first click should register");
        
//         _en = 1'b0;  // Start the enable window
//         wait_cycles(1000);  // Wait 1 second
//         _btn_press = 1'b0;  // First button press
//         wait_cycles(10);
//         _btn_press = 1'b1;  // Release
//         wait_cycles(1000);  // Wait 1 more second
//         _btn_press = 1'b0;  // Second button press
//         wait_cycles(10);
//         _btn_press = 1'b1;  // Release
//         wait_cycles(3000);  // Wait for window to close
        
//         if (true_click_pulse && !false_click_pulse)
//             $display("%t: PASS - Only first click registered", $time);
//         else
//             $display("%t: FAIL - Unexpected behavior on multiple clicks", $time);
 
//         // Reset for next test
//         rst = 1'b1;
//         wait_cycles(10);
//         rst = 1'b0;
//         _en = 1'b1;
//         wait_cycles(100);
 
//         // Test 5: Button press right at 5-second boundary
//         $display("\nTest 5: Boundary Condition - Button pressed at exactly 5 seconds");
        
//         _en = 1'b0;  // Start the enable window
//         wait_cycles(4999);  // Wait 4999 cycles (just before boundary)
//         _btn_press = 1'b0;  // Button pressed at 5-second mark
//         wait_cycles(10);
//         _btn_press = 1'b1;  // Release
//         wait_cycles(500);
        
//         if (true_click_pulse)
//             $display("%t: PASS - Boundary click registered as valid", $time);
//         else
//             $display("%t: FAIL - Boundary click not registered", $time);
 
//         // Reset for final test
//         rst = 1'b1;
//         wait_cycles(10);
//         rst = 1'b0;
//         _en = 1'b1;
//         wait_cycles(100);
 
//         // Test 6: Reset behavior
//         $display("\nTest 6: Reset Behavior - System resets during operation");
        
//         _en = 1'b0;  // Start the enable window
//         wait_cycles(2000);  // Wait 2 seconds
//         rst = 1'b1;  // Assert reset mid-operation
//         wait_cycles(10);
//         rst = 1'b0;
//         _en = 1'b1;
        
//         if (!true_click_pulse && !false_click_pulse)
//             $display("%t: PASS - Reset cleared all state", $time);
//         else
//             $display("%t: FAIL - Reset did not clear state properly", $time);
 
//         $display("\n====================================");
//         $display("Testbench Complete");
//         $finish;
//     end
 
//     // Monitor signal changes
//     initial begin
//         $monitor("%t | _en=%b _btn=%b | true_click=%b false_click=%b", 
//                  $time, _en, _btn_press, true_click_pulse, false_click_pulse);
//     end
 
// endmodule

