`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2025 10:55:27 AM
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
 // Clock parameters
  parameter CLK_FREQ_HZ = 100_000_000;         // 100 MHz
  parameter CLK_PERIOD_NS = 1_000_000_000 / CLK_FREQ_HZ;

  // Spike input frequency
  parameter SPIKE_HZ = 100000;
  parameter SPIKE_PERIOD_NS = 1_000_000_000 / SPIKE_HZ;

  // Memory size (update as needed)
  parameter MEM_SIZE = 1000;

  // Signals
  reg clk = 0;
  reg rst = 0;
  reg [7:0] mem [0:MEM_SIZE-1];
  reg [7:0] i_input_neurons;
  wire o_output_spike;

  integer i;
  integer logfile;

  // DUT instantiation
  snn_wrapper DUT (
    .clk(clk),
    .rst(rst),
    .i_input_neurons(i_input_neurons),
    .o_output_spike(o_output_spike)
  );

  // Clock generation (100 MHz)
  always #(CLK_PERIOD_NS / 2) clk = ~clk;

  // Stimulus
  initial begin
  
    i_input_neurons <= 0;
    // Open log file
    //logfile = $fopen("spike_output.log", "w");

    // Load the memory file
    $readmemh("Trial1_Hand_Close_spikes.hex", mem);

    // Optional waveform dump
    $dumpfile("waveform.vcd");
    $dumpvars(0, sim_top);

    // Reset pulse
    rst = 1;
    #100;
    rst = 0;
    #10000;
    // Drive inputs at 500 Hz and log output
    for (i = 0; i < MEM_SIZE; i = i + 1) begin
      i_input_neurons = mem[i];
      #(SPIKE_PERIOD_NS);
      //$fwrite(logfile, "%0d\n", o_output_spike);
    end

    $fclose(logfile);
    $finish;
  end
endmodule
