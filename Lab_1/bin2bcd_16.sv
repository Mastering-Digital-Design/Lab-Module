// Design Name : bin2bcd_16
// File Name : bin2bcd_16.sv
// Function : convert 16-bit binary number x to five BCD digits
// Author:  Peter Cheung
// Version: 2.0  8 Nov 2022
//---------------------------------------------------
//ALGORITHM: (See explanation on course webpage)
//   Shift binary number x left by one bit into temporary register 'result'
//   If bottom 4 bits of result  >= 5
//		add 3 (only once)
//   Continue shifting x into result until all bit in x have been processed


module bin2bcd_16(
	input  logic [15:0] x,			// value ot be converted
	output logic [3:0]  BCD0, BCD1, BCD2, BCD3, BCD4;  // BCD digits
);
	 // Concatenation of input and output
   logic [35:0] result;  // no of bits = no_of_bit of x + 4* no of digits
   integer i;
   
   always_comb
        begin
            result[35:0] = 0;
            result[15:0] = x;

            for (i=0; i<16; i=i+1) begin
                    // Check if unit digit >= 5
                if (result[19:16] >= 5)
                    result[19:16] = result[19:16] + 4'd3;
                        
                // Check if ten digita >= 5
                if (result[23:20] >= 5)
                    result[23:20] = result[23:20] + 4'd3;
                    
                    // CHeck if hundred digit >= 5
                if (result[27:24] >= 5)
                    result[27:24] = result[27:24] + 4'd3;
                        
                    // check if thousand digit > 5
                if (result[31:28] >= 5)
                    result[31:28] = result[31:28] + 4'd3;

                    // Shift everything left
                result = result << 1;
            end
            
            // Decode output from result
            BCD0 = result[19:16];
                BCD1 = result[23:20];		
                BCD2 = result[27:24];
                BCD3 = result[31:28];
                BCD4 = result[35:32];
        end
	
endmodule
	