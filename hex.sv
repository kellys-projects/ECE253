`timescale 1ns / 1ns 

module hex_top
(
 input logic CLOCK_50,
 output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
 input logic [3:0] KEY,
 output logic [9:0] LEDR,
 input logic [9:0] SW
);
hex_decoder h0(.c(SW[3:0]), .display(HEX0));
endmodule

module hex_decoder(input logic [3:0] c, output logic [6:0] display);
   always_comb 
   begin
	case (c)
	 4'b0000: display = 7'b1000000; //0
	 4'b0001: display = 7'b1111001; // 1
	 4'b0010: display = 7'b0100100; // 2
	 4'b0011: display = 7'b0110000; // 3
	 4'b0100: display = 7'b0011001; // 4
	 4'b0101: display = 7'b0010010; // 5
	 4'b0110: display = 7'b0000010; // 6
	 4'b0111: display = 7'b1111000; // 7
	 4'b1000: display = 7'b0000000; // 8
	 4'b1001: display = 7'b0010000; // 9
	 4'b1010: display = 7'b0001000; // A
	 4'b1011: display = 7'b0000011; // B
	 4'b1100: display = 7'b1000110; // C
	 4'b1101: display = 7'b0100001; // D
	 4'b1110: display = 7'b0000110; // E
	 4'b1111: display = 7'b0001110; // F
	 default: display = 7'b1111111; // Default case for invalid input
	endcase
   end
endmodule
