`timescale 1us/1ns

module pseudoRandDecoderController_6b(
    output [0:5] randOut,
    output _enOut,
    input clk,
    input [0:15] seed,
    maxVal_delay,
    minVal_delay,
    ledflashTime,
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

    // for debugging purposes: Note: will assert initially since the output of the demux is ~16'h0
    always @(*) begin
        if (randDelayTime_w > maxVal_delay || minVal_num > randDelayTime_w) begin
            $display("ERROR: randDelayTime_w outside of %d-%d range: randDelayTime_w = %d", minVal_delay, maxVal_delay, randDelayTime_w);
        end
    end

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
    timeInState1,
    input clk,
    rst
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
        if (rst || isAtEnd0_w) begin
            time_16b <= 0;

            // begin in state 1 on reset
            currentState <= 1;
        end else begin
            time_16b <= time_16b + 1;

            if (isAtEnd1_w) begin
                currentState <= 0;
            end
        end

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
    increment,
    seed,
    input clk,
    trigger,
    rst
);
    reg [0:15] randNum_prev;

    always @(posedge clk or posedge rst) begin
            if (rst) begin
                randNum = seed;
                randNum_prev = seed;
            end

            if (trigger) begin // output new random number on positive and negative edges
                randNum <= randNum_prev * multiplier + increment; // generate a pseudo random number sequence
            end

            randNum_prev <= randNum; // update previous random number
    end

endmodule

module demux_16b(
    output reg [0:15] y_0,
    y_1,
    input [0:15] x,
    input s,
    rst
);
    // output should hold its previous value if not selected
    always @(*) begin
        if (rst) begin
            y_0 = 0;
            y_1 = ~16'h0;
        end

        case(s)
            0: y_0 = x;
            1: y_1 = x;
        endcase
    end

endmodule

module minMaxScalarMux_16b(
    output [0:15] maxVal_out,
    minVal_out,
    input [0:15] maxVal_0,
    minVal_0,
    maxVal_1,
    minVal_1,
    input s
);
    assign maxVal_out = s ? maxVal_1 : maxVal_0;
    assign minVal_out = s ? minVal_1 : minVal_0;

endmodule

module scaleToMinMaxRange_16b(
    output [0:15] outputNum, 
    input [0:15] inputNum, 
    maxVal, 
    minVal
);
    // for debugging purposes
    always @(*) begin
        if (minVal >= maxVal) begin
            $display("scaleToMinMaxRange_16b ERROR: minVal >= maxVal: minVal = %d; maxVal = %d", maxVal, minVal);
        end
    end

    assign outputNum = inputNum % (maxVal - minVal + 1) + minVal;

endmodule
