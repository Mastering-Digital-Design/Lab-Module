module pulse_gen (
    input   logic clk,  // clock signal
    input   logic rst,  // asynchronous reset
    input   logic in,   // input trigger signal
    output  logic pulse // output pulse signal
);
    // Define our states
    typedef enum {IDLE, IN_HIGH, WAIT_LOW}  my_state;
    my_state current_state, next_state;

    // state transition
    always_ff @(posedge clk)
        if (rst)    current_state <= IDLE;
        else        current_state <= next_state; 

    // next state logic
    always_comb
        case (current_state)
            IDLE:       if (in==1'b1)   next_state = IN_HIGH;
                        else            next_state = current_state;
            IN_HIGH:    if (in==1'b1)   next_state = WAIT_LOW;
                        else            next_state = IDLE;
            WAIT_LOW:   if (in==1'b0)   next_state = IDLE;
                        else            next_state = current_state;
            default: next_state = IDLE;
        endcase
    
    // output logic
    always_comb
        case (current_state)
            IDLE:       pulse = 1'b0;
            IN_HIGH:    pulse = 1'b1;
            WAIT_LOW:   pulse = 1'b0;
            default:    pulse = 1'b0;
        endcase
endmodule

