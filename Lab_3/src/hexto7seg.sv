module hexto7seg	(
	output logic [6:0]	out,	// low-active output to drive 7 segment display
	input  logic [3:0] 	in		// 4-bit binary input of a hexademical number	
);
	always_comb
	  case (in) 
		4'h0: out = 7'b1000000;
		4'h1: out = 7'b1111001;		// -- 0 ---
		4'h2: out = 7'b0100100; 	// |	  |
		4'h3: out = 7'b0110000; 	// 5      1
		4'h4: out = 7'b0011001; 	// |	  |
		4'h5: out = 7'b0010010; 	// -- 6 ---
		4'h6: out = 7'b0000010; 	// |	  |
		4'h7: out = 7'b1111000; 	// 4      2
		4'h8: out = 7'b0000000; 	// |	  |
		4'h9: out = 7'b0011000; 	// -- 3 ---
		4'ha: out = 7'b0001000;
		4'hb: out = 7'b0000011;
		4'hc: out = 7'b1000110;
		4'hd: out = 7'b0100001;
		4'he: out = 7'b0000110;
		4'hf: out = 7'b0001110; 
		default: out = 7'b0000000; // default all segment ON
	  endcase
endmodule


