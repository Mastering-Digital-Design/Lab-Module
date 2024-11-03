//------------------------------
// Module name: spi2dac
// Function: SPI interface for MPC4911 DAC
// Creator:  Peter Cheung
// Version:  2.0
// Date:     8 Nov 2016
//------------------------------

module spi2dac (
	input logic	sysclk,			// 50MHz system clock of DE1
	input logic	[9:0]	data_in,	// input data to DAC
	input logic	load,				// Pulse to load data to dac
    input logic reset,
	output logic dac_sdi,		// SPI serial data out
	output logic dac_cs,		// chip select - low when sending data to dac
	output logic dac_sck,		// SPI clock, 16 cycles at half sysclk freq
	output logic dac_ld 
);

//-------------Input Ports-----------------------------
// All the input ports should be wires
	// logic sysclk, load;
	// logic [9:0]	data_in;
	
//-------------Output Ports-----------------------------
// Output port can be a storage element (reg) or a wire
	// logic			dac_cs, dac_ld;
	// logic			dac_sck, dac_sdi;
	// logic reset;
	// assign reset = reset_n;
	parameter	BUF=1'b1;		// 0:no buffer, 1:Vref buffered
	parameter	GA_N=1'b1;		// 0:gain = 2x, 1:gain = 1x
	parameter	SHDN_N=1'b1;	// 0:power down, 1:dac active
	
	logic [3:0] cmd = {1'b0,BUF,GA_N,SHDN_N};  // wire to VDD or GND
	
	// --- internal 1MHz symmetical clock generator -----
	logic clk_1MHz;	// 1Mhz clock derived from 50MHz
	logic [4:0]	ctr;			// internal counter
	
	parameter	TC = 5'd24;  // Terminal count - change this for diff clk freq
	// initial begin
		// clk_1MHz = 0;			// don't need to reset - don't care if it is 1 or 0 to start
		// ctr = 5'b0;				//  ... Initialise when FPGA is configured
	// end
		// 
	// always @ (posedge sysclk)    
	//   if (ctr==0) begin
		//   ctr <= TC;
		//   clk_1MHz <= ~clk_1MHz; // toggle the output clock for squarewave
		// end
	//   else
		//   ctr <= ctr - 1'b1;
    
    always_ff @(posedge sysclk or posedge reset) begin
        if (reset) begin
            clk_1MHz <= 0;
            ctr <= 5'b0;
        end else begin
            if (ctr == 0) begin
                ctr <= TC;
                clk_1MHz <= ~clk_1MHz;
            end
            else begin
                ctr <= ctr - 1'b1;
            end
        end
    end
	// ---- end internal 1MHz symmetical clock generator ----------

	// ---- FSM to detect rising edge of load and falling edge of dac_cs
	// .... sr_state set on posedge of load
	// .... sr_state reset when dac_cs goes high at the end of DAC output cycle
	logic [1:0] 	sr_state;
	parameter	IDLE  = 2'b00,WAIT_CSB_FALL = 2'b01, WAIT_CSB_HIGH = 2'b10;
	logic			dac_start;		 // set if a DAC write is detected
	
	// initial begin
		// sr_state = IDLE;
		// dac_start = 1'b0;	// set while sending data to DAC
		// end
	// 
	// always @ (posedge sysclk)  // state transition
		// case (sr_state)
			// IDLE:	if (load==1'b1) sr_state <= WAIT_CSB_FALL;
			// WAIT_CSB_FALL: if (dac_cs==1'b0) sr_state <= WAIT_CSB_HIGH;
			// WAIT_CSB_HIGH: if (dac_cs==1'b1) sr_state <= IDLE;
			// default: sr_state <= IDLE;
		// endcase
    
    always_ff @(posedge sysclk or posedge reset) begin
        if (reset) begin
            sr_state <= IDLE;
        end else begin
            case (sr_state)
           	IDLE:	if (load==1'b1) sr_state <= WAIT_CSB_FALL;
			WAIT_CSB_FALL: if (dac_cs==1'b0) sr_state <= WAIT_CSB_HIGH;
			WAIT_CSB_HIGH: if (dac_cs==1'b1) sr_state <= IDLE;
			default: sr_state <= IDLE; 
        endcase
        end
    end
	
	// always @ (*)
	// 	case (sr_state)
	// 		IDLE: dac_start = 1'b0;
	// 		WAIT_CSB_FALL: dac_start = 1'b1;
	// 		WAIT_CSB_HIGH: dac_start = 1'b0;
	// 		default: dac_start = 1'b0;
	// 	endcase
    
    always_comb begin
		case (sr_state)
			IDLE: dac_start = 1'b0;
			WAIT_CSB_FALL: dac_start = 1'b1;
			WAIT_CSB_HIGH: dac_start = 1'b0;
			default: dac_start = 1'b0;
		endcase
    end
		
	//------- End circuit to detect start and end of conversion	state machine

	//------- spi controller FSM
	// .... with 17 states (idle, and S1-S16 
	// .... for the 16 cycles each sending 1-bit to dac)
	logic [4:0] 	state;
	
	// initial	begin	
	// 	state = 5'b0; dac_ld = 1'b0; dac_cs = 1'b1; 
	// 	end
		
	always_ff @(posedge clk_1MHz or posedge reset)  begin // FSM state transition
        if (reset) begin
            state <= 5'b0;
        end else begin 
		case (state)
			5'd0:	if (dac_start == 1'b1)    // waiting to start
						state <= state + 1'b1; 
					else 
						state <= 5'b0; 
			5'd17: 	state <= 5'd0;  // go back to idle state
			default: state <= state + 1'b1;	// default go to next state
		endcase
        end
    end
	
	always_comb	begin			// FSM output
		dac_cs = 1'b0;  dac_ld = 1'b1;
		case (state)
			5'd0: 	dac_cs = 1'b1;
			5'd17: 	begin dac_cs = 1'b1; dac_ld = 1'b0; end
			default: begin dac_cs = 1'b0;	dac_ld = 1'b1;	end
			endcase
		end //always
	// --------- END of spi controller FSM
	
	// shift register for output data
	logic [15:0] shift_reg;
	// initial	begin	
		// shift_reg = 16'b0; 
	// end

	always_ff @(posedge clk_1MHz or posedge reset) begin
        if (reset) begin
            shift_reg <= 16'b0;
        end else begin
            
		if((dac_start==1'b1)&&(dac_cs==1'b1))		// parallel load data to shift reg
			shift_reg <= {cmd,data_in,2'b00};
		else 													// .. else start shifting
			shift_reg <= {shift_reg[14:0],1'b0};
        end
    end
	
	// Assign outputs to drive SPI interface to DAC
	assign dac_sck = !clk_1MHz&!dac_cs;
//	assign dac_sck = !clk_1MHz;
	assign dac_sdi = shift_reg[15];
//	assign dac_sdi = reset;
endmodule