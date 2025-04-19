`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2025 09:46:43 PM
// Design Name: 
// Module Name: input_edge_detect
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module input_edge_detect(
    
    input clk, // clock input
    input rst, // reset input
    input boot_mode,
    
    input [7:0] input_signal, // the spike train from the hidden layer

  
    output reg [7:0] input_edge_spike = 0    // found edges in input neuron spike train
);
    // previous state for neuron. used for edge detection
    reg [7:0]  input_prev_state = 0;
    
    
    // finds positive edges
    always @(posedge clk) begin
    
        if(rst) begin
            input_edge_spike    <= 0;
            input_prev_state    <= 0;
        end
        
        else if (!boot_mode) begin
            input_edge_spike <= input_signal & ~input_prev_state; // detects posedge
            input_prev_state <= input_signal; // updates neurons values
        end
    end
endmodule
