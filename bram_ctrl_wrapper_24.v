`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Alex Bundgaard
// 
// Create Date: 03/07/2025 02:27:45 PM
// Design Name: BRAM controller
// Module Name: bram_ctrl_wrapper_24
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Wrapper for BRAM controller for 24-bit SNN bias and synaptic weight fetching
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module bram_ctrl_wrapper_24(
    
    input clk, // clock input
    input rst, // reset input
    
    input [29:0] hidden_neuron_spike_out, // the spike train from the hidden layer
    input [7:0] input_neuron_spike_out,   // the spike train from input layer
    input boot_mode,

    output [31:0] dout_a,
    output [31:0] dout_b,
    output port_a_start,
    output port_a_done,
    output port_b_start,
    output port_b_done
    
);

    parameter BOOT_CYCLES = 100;
    parameter PORTB_ADDR_START = 135;
    
    // edge detected signals
    wire [29:0]     hidden_layer_edge;
    wire [7:0]      input_layer_edge;
    
    // port a modules wires
    wire [9:0]     addr_a;
    wire [9:0]     addr_b;
    

    /**
    -----------------------------------------------------------------------------------------------
        Edge Detection. Takes neuron spike trains and gets the edges
        edges get sent to address controllers
    -----------------------------------------------------------------------------------------------
    **/
    edge_detection spike_train_edge_detection_inst(
            .clk(clk),                     // input clk, clock input
            .rst(rst),                     // input rst,  reset input
            .boot_mode(boot_mode),         // input boot_mode, // fetches biases
            
            .hidden_neuron_spike_out(hidden_neuron_spike_out), // input [29:0] hidden_neuron_spike_out, the spike train from the hidden layer
            .input_neuron_spike_out(input_neuron_spike_out),  // input [5:0] input_neuron_spike_out, the spike train from input layer
    
            .hidden_layer_edge(hidden_layer_edge),       // output reg [29:0] hidden_layer_edge, // found edges in hidden layer spike train
            .input_layer_edge(input_layer_edge)         // output reg [7:0] input_layer_edge    // found edges in input neuron spike train
    );
    
    /**
    -----------------------------------------------------------------------------------------------
        Port a address logic, takes edge detection and gets the needed address bursts
        Address gets sent to BRAM accessing
    -----------------------------------------------------------------------------------------------
    **/
    
    port_a_addr port_a_addr_inst (
            .clk(clk), //input clk,
            .rst(rst), //input rst,
            .boot_mode(boot_mode),         // input boot_mode, // fetches biases
            
            .edge_detected(input_layer_edge), //input [7:0] edge_detected,
            
            .addr_a(addr_a), //output reg [31:0] addr_a = 0,
            .port_a_start_out(port_a_start), //output reg port_a_start_out = 0, // flag to say the output from port a is starting 
            .port_a_done(port_a_done) //output reg port_a_done = 0 // signifies that port a is done transmitting
    );
    
    /**
    -----------------------------------------------------------------------------------------------
        Port b address logic, takes edge detection and gets the needed address bursts
        Address gets sent to BRAM accessing
    -----------------------------------------------------------------------------------------------
    **/

    port_b_addr port_b_addr_inst (
            .clk(clk), //input clk,
            .rst(rst), //input rst,
            .boot_mode(boot_mode),
          
            .edge_detected(hidden_layer_edge), //input [7:0] edge_detected,
          
            .addr_b(addr_b), //output reg [31:0] addr_b = 0,
            .port_b_start_out(port_b_start), //output reg port_b_start_out = 0, // flag to say the output from port a is starting 
            .port_b_done(port_b_done) //output reg port_b_done = 0 // signifies that port a is done transmitting
  );

    /**
    -----------------------------------------------------------------------------------------------
        BRAM block instantiation
    -----------------------------------------------------------------------------------------------
    **/
    wire [9:0] addrb_shifted;
    assign addrb_shifted = addr_b + PORTB_ADDR_START;

      bram_wrapper bram_i
   (.addr_a(addr_a),
    .addr_b(addrb_shifted),
    .clk(clk),
    .dout_a(dout_a),
    .dout_b(dout_b),
    .we(1'b0)
    );

endmodule