`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2025 02:28:05 PM
// Design Name: 
// Module Name: hidden_layer
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


module hidden_layer   #(
        parameter SHIFT_VALUE = 2,
        parameter signed THRESHOLD = 100
    )
    (
        input sys_clk,
        input snn_clk,
        input boot_mode,
        input data_ready,
        input rst,
        input signed [15:0] din,
        output reg spike = 0
    );
    
    reg signed [20:0] saved_value = 24'sd0;
    reg signed [15:0] bias = 0;
    reg signed [20:0] v_mem = 24'sd0;
    
    /*******************************************
     Data saving at a fast rate
     data need to be summed at sys_clk speed to catch
     all the inptus
    ********************************************/
    
    always @(posedge sys_clk) begin
        if(rst)begin
            saved_value <= 32'sd0;
            v_mem <= 32'sd0;
            spike <= 0;
        end
        else if (boot_mode && data_ready)  bias <= din;      
        else if (snn_clk) begin // performs LIF equation and clears buffer
            v_mem <= v_mem + ((saved_value + bias - v_mem) >>> SHIFT_VALUE);
            saved_value <= 32'sd0;
            if (v_mem >= THRESHOLD) begin // checks spike condition
                spike <= 1;
                v_mem <= 32'sd0;
            end
            else spike <= 0;
        end      
        else if(data_ready) begin
            spike <= 0;
            saved_value <= saved_value + din;
        end
        else spike <= 0;
    end
endmodule
