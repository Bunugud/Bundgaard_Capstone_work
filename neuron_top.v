`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Alex Bundgaard 101189931
// 
// Create Date: 03/12/2025 02:28:05 PM
// Design Name: 
// Module Name: neuron_top
// Project Name: SNN
// Target Devices: 
// Tool Versions: 
// Description: 
//  Neuron top module, all neurons from each layer are instantiated here
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module neuron_top #(
        parameter CLK_DIV_FACTOR = 1000,
        parameter NUM_INPUT_NEURONS = 8,
        parameter NUM_HIDDEN_NEURONS = 30,
        parameter NUM_OUTPUT_NEURONS = 4,
        parameter THRESHOLD = 16'h2000,
        parameter SHIFT_VALUE = 7
    )
    (
        input sys_clk,
        input rst,
        input boot_mode,
        
        input signed [31 :0]  i_output_neurons,
        input signed [31 :0]  i_hidden_neurons,
        input [NUM_INPUT_NEURONS - 1:0]  i_input_neurons,
        
        
        input data_ready_a,
        input data_ready_b,
        input data_start_a,
        input data_start_b,
        
        output [NUM_HIDDEN_NEURONS - 1:0] o_hidden_spike,
        output [NUM_OUTPUT_NEURONS - 1:0] o_output_spike,
        output [NUM_INPUT_NEURONS - 1: 0] o_input_spike
        
    );
    
    wire snn_clk; // comes from clk div
    wire spike_o_test;
    
    reg [63: 0]  i_output_packed = 0;
    reg [479:0]  i_hidden_packed = 0;
    /********************* 
    making bigger vector
    **********************/
    reg hidden_in_filling = 0;
    reg save_data_a = 0;
    always @(posedge sys_clk) begin
    
        if (rst) begin
            hidden_in_filling <= 0;
        
        end
        else if(data_start_a) begin
            hidden_in_filling <= 1;
            i_hidden_packed[479:448] <= i_hidden_neurons;
            save_data_a <= 0;
        end 
        else if (data_ready_a) begin
            save_data_a <= 1;
            hidden_in_filling <= 0;       
                
        end
        else if (hidden_in_filling) begin
            i_hidden_packed <= i_hidden_packed >> 32;
            i_hidden_packed[479:448] <= i_hidden_neurons;
        end
        else save_data_a <= 0;
    end
    
    reg output_in_filling = 0;
    reg save_data_b = 0;
    always @(posedge sys_clk) begin
    
        if (rst) begin
            output_in_filling <= 0;
        
        end
        else if(data_start_b) begin
            output_in_filling <= 1;
            i_output_packed[31: 0] <= i_output_neurons;
            save_data_b <= 0;
        end 
        else if (data_ready_b) begin
            save_data_b <= 1;
            output_in_filling <= 0;       
                
        end
        else if (output_in_filling) begin
            i_output_packed[63: 32] <= i_output_neurons;
        end
        else save_data_b <= 0;
    end
    
    genvar i;
    
    generate
    
    for (i = 0; i < NUM_OUTPUT_NEURONS; i = i+1) begin
        output_layer
        #(
            .SHIFT_VALUE(SHIFT_VALUE),
            .THRESHOLD(THRESHOLD)
        ) output_neuron_inst
        (
            .sys_clk(sys_clk),
            .snn_clk(snn_clk),
            .boot_mode(boot_mode),
            .data_ready(save_data_b),
            .rst(rst),
            .din(i_output_packed[i*16 + 15 : i*16]),
            .spike(o_output_spike[i])
        );
        
    end
    
    for (i = 0; i < NUM_HIDDEN_NEURONS; i = i+1) begin
        hidden_layer
        #(
            .SHIFT_VALUE(SHIFT_VALUE),
            .THRESHOLD(THRESHOLD)
        ) hidden_neuron_inst
        (
            .sys_clk(sys_clk),
            .snn_clk(snn_clk),
            .boot_mode(boot_mode),
            .data_ready(save_data_a),
            .rst(rst),
            .din(i_hidden_packed[i*16 + 15 : i*16]),
            .spike(o_hidden_spike[i])
        );
        
    end
    
    for (i = 0; i < NUM_INPUT_NEURONS; i = i+1) begin
        input_layer input_neuron_inst
        (
            .sys_clk(sys_clk),
            .snn_clk(snn_clk),
            .rst(rst),
            .din(i_input_neurons[i]),
            .spike(o_input_spike[i])
        );
    end
    endgenerate
    
    
    /***********************************************************
    Clock divider for SNN speed
    This generates a periodic pulse, not square wave
    ***********************************************************/
    clock_divider#(
                    .DIV_FACTOR(CLK_DIV_FACTOR)  // Parameter to set the clock division factor
    )   clk_div_inst(
                    .clk(sys_clk),           // Input clock
                    .reset(rst),         // Reset signal
                    .clk_out(snn_clk)       // Divided output clock
                    );
    
    
endmodule
