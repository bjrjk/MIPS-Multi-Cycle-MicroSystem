module singleLED(
    input [4:0]data,
    output reg[7:0] LEDout
    );
	always @(data) begin
			case(data)
                5'b00000:LEDout=8'b11111100;
                5'b00001:LEDout=8'b01100000;
                5'b00010:LEDout=8'b11011010;
                5'b00011:LEDout=8'b11110010;
                5'b00100:LEDout=8'b01100110;
                5'b00101:LEDout=8'b10110110;
                5'b00110:LEDout=8'b10111110;
                5'b00111:LEDout=8'b11100000;
                5'b01000:LEDout=8'b11111110;
                5'b01001:LEDout=8'b11110110;
                5'b01010:LEDout=8'b11111101;
                5'b01011:LEDout=8'b01100001;
                5'b01100:LEDout=8'b11011011;
                5'b01101:LEDout=8'b11110011;
                5'b01110:LEDout=8'b01100111;
                5'b01111:LEDout=8'b10110111;
                5'b10000:LEDout=8'b10111111;
                5'b10001:LEDout=8'b11100001;
                5'b10010:LEDout=8'b11111111;
                5'b10011:LEDout=8'b11110111;
                default:LEDout=8'b00000000;
			endcase
	end
endmodule