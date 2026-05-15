`timescale 1us/1ns

module pseudoRandDecoderController_6b(
    output [0:5] randOut,
    output _enOut,
    input clk,
    input [0:15] seed,
    input [0:15] maxVal_delay,
    input [0:15] minVal_delay,
    input [0:15] ledflashTime,
    input rst
);
    wire trigger_w, state_w;
    wire [0:15] randDelayTime_w,
    scalarModule_demux_w,
    minVal_w,
    maxVal_w,
    randNum_w,
    to64bitEncoder_w;

    localparam multiplier   = 16'd25173,
    increment               = 16'd13849,
    maxVal_num              = 16'd64,
    minVal_num              = 16'd0;

    genNextRand_16b genNextRand(
        .randNum(randNum_w),
        .multiplier(multiplier),
        .increment(increment),
        .seed(seed),
        .clk(clk),
        .trigger(trigger_w),
        .rst(rst)
    );

    stateController_1b stateControl(
        .currentState(state_w),
        .stateChangedTrigger(trigger_w),
        .timeInState0(ledflashTime), 
        .timeInState1(randDelayTime_w),
        .clk(clk),
        .rst(rst)
    );

    minMaxScalarMux_16b scalarMux(
        .maxVal_out(maxVal_w),
        .minVal_out(minVal_w),
        .maxVal_0(maxVal_num),
        .minVal_0(minVal_num),
        .maxVal_1(maxVal_delay),
        .minVal_1(minVal_delay),
        .s(state_w)
    );

    scaleToMinMaxRange_16b scalarModule(
        .outputNum(scalarModule_demux_w),
        .inputNum(randNum_w),
        .maxVal(maxVal_w),
        .minVal(minVal_w)
    );

    demux_16b numDemux(
        .y_0(to64bitEncoder_w),
        .y_1(randDelayTime_w),
        .x(scalarModule_demux_w),
        .s(state_w),
        .clk(clk),
        .rst(rst)
    );

    assign randOut = to64bitEncoder_w[10:15];
    assign _enOut = state_w;

endmodule

// state goes low for timeInState0 miliseconds and goes high for timeInState1 miliseconds
// highTime + timeInState0 must be a number less than 16-bit
module stateController_1b(
    output reg currentState,
    output reg stateChangedTrigger,
    input [0:15] timeInState0,
    input [0:15] timeInState1,
    input clk,
    input rst
);
    reg [0:15] time_16b;
    wire [0:15] totTime_w,
    beforetotTime_w,
    timeInState1_w,
    beforetimeInState1_w;
    wire isAtEnd0_w,
    beforeIsAtEnd0_w,
    isAtEnd1_w,
    beforeIsAtEnd1_w;
    wire triggerEvent;

    assign timeInState1_w = timeInState1 - 1;
    assign beforetimeInState1_w = timeInState1_w - 1;
    assign totTime_w =  timeInState1_w + timeInState0;
    assign beforetotTime_w = totTime_w - 1;
    assign isAtEnd1_w = (time_16b == timeInState1_w);
    assign beforeIsAtEnd1_w = (time_16b == beforetimeInState1_w);
    assign isAtEnd0_w = (time_16b == totTime_w);
    assign beforeIsAtEnd0_w = (time_16b == beforetotTime_w);
    assign triggerEvent = (beforeIsAtEnd1_w || beforeIsAtEnd0_w);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            time_16b <= 0;

            // begin in state 1 on reset
            currentState <= 1;
        end
        else if (isAtEnd0_w) begin
            time_16b <= 0;

            // begin in state 1 on reset
            currentState <= 1;
        end
        else begin
            time_16b <= time_16b + 1;

            if (isAtEnd1_w) begin
                currentState <= 0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            stateChangedTrigger <= 0;
        end 
        else if (triggerEvent) begin
            stateChangedTrigger <= 1;
        end
        else stateChangedTrigger <= 0;
    end

endmodule

// module for generating a psuedorandom numbers
// generates a new random number whenever a  positive or negative edge occurs on trigger
module genNextRand_16b(
    output reg  [0:15] randNum,
    input [0:15] multiplier,
    input [0:15] increment,
    input [0:15] seed,
    input clk,
    input trigger,
    input rst
);
    reg [0:15] randNum_prev;

    always @(posedge clk or posedge rst) begin
            if (rst) begin
                randNum <= seed;
            end
            else if (trigger) begin // output new random number on positive and negative edges
                randNum <= randNum_prev * multiplier + increment; // generate a pseudo random number sequence
            end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            randNum_prev <= seed;
        end
        else begin
            randNum_prev <= randNum; // update previous random number
        end
    end

endmodule

module demux_16b(
    output [0:15] y_0,
    output [0:15] y_1,
    input [0:15]  x,
    input         s,
    input         clk,
    input         rst
);
    reg [0:15] y_0_prev;
    reg [0:15] y_1_prev;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_0_prev <= ~16'h0;
            y_1_prev <= ~16'h0;
        end
        else begin
            y_0_prev <= y_0;
            y_1_prev <= y_1;
        end
    end
    
    // demux logic with synchronous reset; when not selected, outputs hold their previous value
    // output should hold its previous value if not selected
    assign y_0 = s ? y_0_prev : x;
    assign y_1 = s ? x : y_1_prev;

endmodule

module minMaxScalarMux_16b(
    output [0:15] maxVal_out,
    output [0:15] minVal_out,
    input [0:15] maxVal_0,
    input [0:15] minVal_0,
    input [0:15] maxVal_1,
    input [0:15] minVal_1,
    input s
);
    assign maxVal_out = s ? maxVal_1 : maxVal_0;
    assign minVal_out = s ? minVal_1 : minVal_0;

endmodule

// realize: this module can (at maximum) scale numbers between
module scaleToMinMaxRange_16b(
    output [0:15] outputNum, 
    input [0:15] inputNum,
    input [0:15] maxVal, 
    input [0:15] minVal
);
    assign outputNum = inputNum % (maxVal - minVal + 1) + minVal;

endmodule