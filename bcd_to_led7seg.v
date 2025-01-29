module bcd_to_led7seg(
    input       [3:0] bcd,          // BCD input
    output reg  [7:0] led7seg       // Common cathode - DP G F E D C B A
    );

    always @(bcd) begin
        case (bcd)
            4'd0:   led7seg = ~8'b11000000;
            4'd1:   led7seg = ~8'b11111001;
            4'd2:   led7seg = ~8'b10100100;
            4'd3:   led7seg = ~8'b10110000;
            4'd4:   led7seg = ~8'b10011001;
            4'd5:   led7seg = ~8'b10010010;
            4'd6:   led7seg = ~8'b10000010;
            4'd7:   led7seg = ~8'b11111000;
            4'd8:   led7seg = ~8'b10000000;
            4'd9:   led7seg = ~8'b10010000;
            default:led7seg = ~8'b11111111;
        endcase
    end 

endmodule
