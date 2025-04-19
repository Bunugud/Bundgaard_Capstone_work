`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2025 08:16:30 PM
// Design Name: 
// Module Name: snn_wrapper
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


module snn_wrapper(
        input clk,
        input rst,
        input [7:0] i_input_neurons,
        output [3:0] o_output_spike
    );
    parameter CLK_DIV_FACTOR = 1000;
    parameter NUM_INPUT_NEURONS = 8;
    parameter NUM_HIDDEN_NEURONS = 30;
    parameter NUM_OUTPUT_NEURONS = 4;
    parameter THRESHOLD = 16'h1000;
    parameter SHIFT_VALUE = 4;
    
    
    wire [29:0] o_hidden_spike; // the spike trains leaving hidden neurons
    wire [7:0] o_input_spike; // the spike trains leaving input neurons
    wire signed [31:0] dout_a; // data from a port (weights for connections between input and hidden
    wire signed [31:0] dout_b; // data from b port (weights for connections between hidden to output)
    
    wire port_a_start, data_ready_b, port_b_start, data_ready_a; // control flags for memory controller
    
    
    reg boot_mode = 0;
    reg [7:0] boot_counter;
    
    always @(posedge clk) begin 
        if (rst) begin
            boot_mode <= 1;
            boot_counter <= 0; 
        end
        
        else if(boot_mode == 1 && boot_counter < 100)
            boot_counter <= boot_counter + 1;
        
        else begin
            boot_mode <= 0;
            boot_counter <= 0;
        end
        
    end 
    
    
    /****************************************************
  BRAM controller instantiation
   ****************************************************/    
    bram_ctrl_wrapper_24 u_bram_ctrl_wrapper_24 (
    .clk                (clk),                  // Clock input
    .rst                (rst),                  // Reset input
    .boot_mode          (boot_mode),             // signifies system is in boot mode
    
    .hidden_neuron_spike_out (o_hidden_spike), // 30-bit hidden neuron spike train
    .input_neuron_spike_out  (o_input_spike),  // 8-bit input neuron spike train
    
    .dout_a                  (dout_a),                // 32-bit data output A
    .dout_b                  (dout_b),                // 32-bit data output B
    .port_a_start            (port_a_start),          // Start signal for port A
    .port_a_done             (data_ready_a),           // Done signal for port A
    .port_b_start            (port_b_start),          // Start signal for port B
    .port_b_done             (data_ready_b)            // Done signal for port B
);
    
   /****************************************************
   Neural Network Instantiation
   ****************************************************/ 
    neuron_top #(
    .CLK_DIV_FACTOR(CLK_DIV_FACTOR),        // Clock division factor
    .NUM_INPUT_NEURONS(NUM_INPUT_NEURONS),        // Number of input neurons
    .NUM_HIDDEN_NEURONS(NUM_HIDDEN_NEURONS),      // Number of hidden neurons
    .NUM_OUTPUT_NEURONS(NUM_OUTPUT_NEURONS),        // Number of output neurons
    .THRESHOLD(THRESHOLD),
    .SHIFT_VALUE(SHIFT_VALUE)
) u_neuron_top (
    .sys_clk(clk),                     // System clock input
    .rst(rst),                             // Reset signal
    .boot_mode(boot_mode),                 // Boot mode control signal

    .i_output_neurons(dout_b),   // Flattened 32-bit output neuron array
    .i_hidden_neurons(dout_a),   // Flattened 32-bit hidden neuron array
    .i_input_neurons(i_input_neurons),     // Input neuron spike signals

    .data_start_a(port_a_start),           // Data ready signal A
    .data_ready_a(data_ready_a),           
    .data_start_b(port_b_start),
    .data_ready_b(data_ready_b),

    .o_hidden_spike(o_hidden_spike),       // Output spikes from hidden neurons
    .o_output_spike(o_output_spike),       // Output spikes from output neurons
    .o_input_spike(o_input_spike)          // Output spikes from input neurons
);



endmodule
