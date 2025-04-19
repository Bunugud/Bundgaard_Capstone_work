`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2025 02:28:05 PM
// Design Name: 
// Module Name: input_layer
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


`timescale 1ns / 1ps

module input_layer (
    input sys_clk,             // 100 MHz system clock
    input snn_clk,             // 3 kHz clock pulse (1-cycle wide)
    input rst,
    input din,                 // Incoming binary pulse from testbench
    output reg spike = 0       // 1-cycle output spike
);

    reg spike_buffer = 0;

always @(posedge sys_clk) begin
    if (rst)
        spike <= 0;
    else if (snn_clk)
        spike <= din;  // Check input only on snn_clk pulse
    else
        spike <= 0;    // Reset spike immediately after
end

endmodule
