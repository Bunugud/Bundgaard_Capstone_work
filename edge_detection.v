`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Alex Bundgaard
// 
// Create Date: 03/07/2025 02:27:45 PM
// Design Name: BRAM controller
// Module Name: edge_detection
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Parameterized edge detector, used for the spike train edge detection
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/*
    edge_detection edge_detection_inst(
        .clk(),                     // input clk, clock input
        .rst(),                     // input rst,  reset input

        .hidden_neuron_spike_out(), // input [29:0] hidden_neuron_spike_out, the spike train from the hidden layer
        .input_neuron_spike_out(),  // input [5:0] input_neuron_spike_out, the spike train from input layer

        .output_layer_edge(),       // output reg [29:0] output_layer_edge, // found edges in hidden layer spike train
        .input_layer_edge()         // output reg [7:0] input_layer_edge    // found edges in input neuron spike train

);
*/
//////////////////////////////////////////////////////////////////////////////////

module edge_detection(
    
    input clk, // clock input
    input rst, // reset input
    input boot_mode,
    
    input [29:0] hidden_neuron_spike_out, // the spike train from the hidden layer
    input [7:0] input_neuron_spike_out,   // the spike train from input layer
    
    output reg [29:0] hidden_layer_edge = 0, // found edges in hidden layer spike train
    output reg [7:0] input_layer_edge = 0    // found edges in input neuron spike train
);
    // previous state for neuron. used for edge detection
    reg [7:0]  input_prev_state = 0;
    reg [29:0] hidden_prev_state = 0;
    
    
    // finds positive edges
    always @(posedge clk) begin
    
        if(rst) begin
            hidden_layer_edge   <= 0;
            hidden_prev_state   <= 0;
            input_layer_edge    <= 0;
            input_prev_state    <= 0;
        end
        
        else if (!boot_mode) begin
            hidden_layer_edge <= hidden_neuron_spike_out & ~hidden_prev_state; // detects posedge
            hidden_prev_state <= hidden_neuron_spike_out; // updates neurons values
            
            input_layer_edge <= input_neuron_spike_out & ~input_prev_state; // detects posedge
            input_prev_state <= input_neuron_spike_out; // updates neurons values
        end
    end
endmodule