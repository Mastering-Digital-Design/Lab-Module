//------------------------------
// Module name: pwm
// Function: 	converter data_in to a 10-bit PWM signal
//						... range of data_in - 0 to max
// Creator:  Peter Cheung
// Version:  2.0
// Date:     18 Nov 2022
//------------------------------
module pwm # (parameter WIDTH = 10)(
	input  logic			    clk,		// system clock
	input  logic [WIDTH-1:0]    data_in,	// input data for conversion (limited to 10-bit)
	input  logic		        load,		// high pulse to load new data
	input  logic [WIDTH-1:0]	max,		// maximum value of data_in
	output logic		        pwm_out	    // PWM output
);
	logic [WIDTH-1:0]		d;				// internal register
	logic [WIDTH-1:0]		count;		    // internal 10-bit counter

	always_ff @ (posedge clk)
		if (load == 1'b1) d <= data_in;
	
	initial count = {WIDTH{1'b0}};	        // init count - ok for FPGAs
	
	always_ff @ (posedge clk) begin
		if (count == max)  
            count <= {WIDTH{1'b0}};
		else
			count <= count + 1'b1;
            
		if (count >= d)
			pwm_out <= 1'b0;
		else	
			pwm_out <= 1'b1;
		end

endmodule
