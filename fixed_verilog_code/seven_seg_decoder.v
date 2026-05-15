module seven_seg_decoder(
    output reg A,
    output reg B,
    output reg C,
    output reg D,
    output reg E,
    output reg F,
    output reg G,
    input [0:3] number
);
    
    always @ (*)
    begin
        case(number)
            4'd0: {A, B, C, D, E, F, G} = 7'b1111110;
            4'd1: {A, B, C, D, E, F, G} = 7'b0110000;
            4'd2: {A, B, C, D, E, F, G} = 7'b1101101;
            4'd3: {A, B, C, D, E, F, G} = 7'b1111001;
            4'd4: {A, B, C, D, E, F, G} = 7'b0110011;
            4'd5: {A, B, C, D, E, F, G} = 7'b1011011;
            4'd6: {A, B, C, D, E, F, G} = 7'b1011111;
            4'd7: {A, B, C, D, E, F, G} = 7'b1110000;
            4'd8: {A, B, C, D, E, F, G} = 7'b1111111;
            4'd9: {A, B, C, D, E, F, G} = 7'b1111011;
            default: {A,B,C,D,E,F,G} = 7'hX; 
        endcase
    end
endmodule
