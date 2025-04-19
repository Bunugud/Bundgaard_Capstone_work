`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 01:33:23 PM
// Design Name: 
// Module Name: wrapper
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


module input_processing_wrapper(
        input clk,
        
        inout [53:0] FIXED_IO_mio,
        inout FIXED_IO_ddr_vrn,
        inout FIXED_IO_ddr_vrp,
        inout FIXED_IO_ps_clk,
        inout FIXED_IO_ps_porb,
        inout FIXED_IO_ps_srstb,
        
        output [3:0] led,
        
        input [3:0] btns_4bits_tri_i, 
        input [5:0] vco_data,
        input debug_pin,
        input [2:0] sw       
    );
    parameter FREQUENCY_REDUCE_VALUE = 400000;
    parameter SPIKE_SIZE = 40000;
    parameter NUM_INPUTS = 6;
    
    wire [5:0] sample_data_tri_i;
    reg [10:0] stupid_debug_counter = 0;
    reg led_reg = 0;
        wire [NUM_INPUTS * 32 : 0] spike_counter, debug_counter;
    assign led[0] = sample_data_tri_i[0];
    assign led[1] = led_reg;
    assign led[2] = vco_data[3];
    assign led[3] = vco_data[4];
    
    always @(posedge sample_data_tri_i[0]) begin
        if ( stupid_debug_counter < 5) begin
        stupid_debug_counter <= stupid_debug_counter + 1;
        end
        else begin
            stupid_debug_counter <= 0;
            led_reg <= !led_reg;
        end
        
    
    end
    
    /***************************************************************************************
    isntantiates the frequency reducing module, depending on how many inputs there are,
    set by the parameter "NUM_INPUTS"
    ***************************************************************************************/
    
    genvar i;    
    generate

        for (i = 0; i < NUM_INPUTS; i = i + 1) begin : freq_reduce_instances
            
            freq_reduce #(
                .COUNTER_VALUE(FREQUENCY_REDUCE_VALUE), // The counter goes to
                .SPIKE_LENGTH(SPIKE_SIZE)     // The amount of clock cycles the spike is up
            ) reduce_frequency_inst (
                .sys_clk(clk),                  // System clock (100MHz)
                .i_vco(vco_data[i]),   // Individual VCO input from PMOD
                .o_spike(sample_data_tri_i[i]),                     // Output spikes for SNN
                .counter_debug(),               // Debug signal (optional)
                .debug_spike_counter(spike_counter[i*32 +31 : i*32] )          // Debug spike counter
            );
        end
    endgenerate
    
    wire [6:0] o_pmod_data;
    assign o_pmod_data = sw[0] ? {debug_pin, vco_data[5:0]} : {debug_pin, sample_data_tri_i[5:0]};
    
    /***************************************************************************************
    isntantiates the block design for AXI interfacing
    ***************************************************************************************/
        
        axi_reg_axis_if_wrapper u_your_instance_name (
    .FIXED_IO_0_ddr_vrn (FIXED_IO_ddr_vrn),
    .FIXED_IO_0_ddr_vrp (FIXED_IO_ddr_vrp),
    .FIXED_IO_0_mio     (FIXED_IO_mio),
    .FIXED_IO_0_ps_clk  (FIXED_IO_ps_clk),
    .FIXED_IO_0_ps_porb (FIXED_IO_ps_porb),
    .FIXED_IO_0_ps_srstb(FIXED_IO_ps_srstb),
    .btns_4bits_tri_i   (btns_4bits_tri_i),
    .sample_data_tri_i  (o_pmod_data)
);


endmodule
