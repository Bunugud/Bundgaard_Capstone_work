`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Alex Bundgaard 101189931
// Purpose:
// Reduce the inputed VCO frequency to be compatible with our implemented SNN
//////////////////////////////////////////////////////////////////////////////////


module freq_reduce 
    #( // parameters
    parameter COUNTER_VALUE = 1000, // the counter goes to
    parameter SPIKE_LENGTH = 10 // The amount of clock cycles the spike is up
    )
    ( // IO
        input sys_clk,// system clock, 100MHz
        input i_vco,  // VCO input spikes from PMOD
        output reg o_spike = 1'b0, // output spikes for SNN
        output [31:0] counter_debug, // for debug purposes, remove later
        output [31:0] debug_spike_counter
    );
    //states
    localparam COUNTING = 0; // counting to COUNTER_VALUE
    localparam SPIKING = 1; // spiking for SPIKE_LENGTH system clock cycles
    localparam WAIT_FOR_POS = 2; // waits for VCO input to be positive
    localparam WAIT_FOR_NEG = 3; // waits for the VCO input to be negative
    reg [1:0] state = 2;   // stores current state
    
    // counters
    reg [$clog2(COUNTER_VALUE):0] count = 0; // gets the size of counter needed to reach COUNTER_VALUE
    reg [$clog2(SPIKE_LENGTH):0] spike_count = 0; // gets the size of counter needed to reach SPIKE_LENGTH
    
    assign counter_debug = count; // for debug purposes, remove later
    assign debug_spike_counter = spike_count;
    // we need to reduce the frequency of the inputted VCO by counting to the parameter "COUNTER_VALUE"
    // The spike also needs to be extended to the value of SPIKE_LENGTH
    
    always @(posedge sys_clk) begin
        case(state) 
        
            COUNTING: begin // checks if the counter reached goal, if not icnrements counter
                if (count >= COUNTER_VALUE) begin
                    state <= SPIKING;
                end
                else begin
                    count <= count + 1;
                    state <= WAIT_FOR_NEG;
                end
            end
                
            SPIKING: begin  // sets the spiking output, then sends to wait for the next negative edge
                if (spike_count >= SPIKE_LENGTH) begin
                    count <= 0;
                    spike_count <= 0;
                    o_spike <= 1'b0;
                    state <= WAIT_FOR_NEG;
                end
                else begin
                    spike_count <= spike_count + 1;
                    o_spike <= 1'b1;
                end
            end 
            
            WAIT_FOR_POS: begin // waits for the input to be positive
                if (i_vco) state <= COUNTING;
            end
            
            WAIT_FOR_NEG : begin  // waits for the input to be negative
                if (!i_vco) state <= WAIT_FOR_POS;
            end 
            
            
        endcase
    end
    
endmodule
