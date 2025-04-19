`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2025 12:16:53 PM
// Design Name: 
// Module Name: clock_divider
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


module clock_divider #(
    parameter DIV_FACTOR = 2  // Parameter to set the clock division factor
)(
    input wire clk,           // Input clock
    input wire reset,         // Reset signal
    output reg clk_out       // Divided output clock
);

    // Internal counter to count clock cycles
    reg [$clog2(DIV_FACTOR)-1:0] counter; 

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (clk_out) begin
                clk_out <= 0;
            end else if (counter == DIV_FACTOR - 1) begin
                counter <= 0;
                clk_out <= 1;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
