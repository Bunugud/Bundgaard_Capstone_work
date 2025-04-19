`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2025 05:38:00 PM
// Design Name: 
// Module Name: sim_top
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


module sim_top(

    );
    
    reg [6:0] vco_data_internal = 0;
    reg [4:0] btns_4bits_tri_i_internal = 0;
    reg clk = 0;
    reg debug_pin_internal = 0;
    
    always begin
        clk <= ~clk;
        #5;
    
    end
    
    always begin
        vco_data_internal[0] <= ~vco_data_internal[0];
        vco_data_internal[1] <= ~vco_data_internal[1];
        vco_data_internal[2] <= ~vco_data_internal[2];
        vco_data_internal[3] <= ~vco_data_internal[3];
        vco_data_internal[4] <= ~vco_data_internal[4];
        vco_data_internal[5] <= ~vco_data_internal[5];
        #40;
    
    end
    
    
input_processing_wrapper DUT (
        .clk(clk), //input clk,
        

      
       .led(), // output [3:0] led,
        
        .btns_4bits_tri_i(), //input [3:0] btns_4bits_tri_i, 
        .vco_data(vco_data_internal), //input [5:0] vco_data,
        .debug_pin(1'b0), //input debug_pin,
        .sw(3'b000) //input sw     
    );
    
    
    
    
endmodule
