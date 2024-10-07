//------------------------------
// Module name: allpass processor
// Function: Simply to pass input to output
// Creator:  Peter Cheung
// Version:  2.0
// Date:     26 Nov 2022
//------------------------------

module processor (
	input  logic		sysclk,			// system clock
	input  logic [9:0]	data_in,		// 10-bit input data
	input  logic		data_valid,		// asserted when sample data is ready for processing
	output logic [9:0] 	data_out		// 10-bit output data
);

	logic [9:0]			x,y;
	logic				enable;

	parameter 		ADC_OFFSET = 10'd512;
	parameter 		DAC_OFFSET = 10'd512;

	assign x = data_in[9:0] - ADC_OFFSET;		// x is input in 2's complement
	
	// This part should include your own processing hardware 
	// ... that takes x to produce y
	// ... In this case, it is ALL PASS.
	assign y = x;
	
	pulse_gen  PULSE (.clk(sysclk), .rst(1'b0), 
				.in(data_valid), .pulse(enable) );
	
	//  Now clock y output with system clock
	always @(posedge sysclk)
		if (enable == 1'b1)
			data_out <=  y + DAC_OFFSET;
		
endmodule
	