`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2025 02:27:45 PM
// Design Name: 
// Module Name: port_b\a_addr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Logic to get the port a addresses
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module port_a_addr(
        input clk,
        input rst,
        input boot_mode, // fetches biases
        
        input [7:0] edge_detected,
        
        
        output reg [9:0] addr_a = 0,
        output reg port_a_start_out = 0, // flag to say the output from port a is starting 
        output reg port_a_done = 0 // signifies that port a is done transmitting
    );
        
        
    reg [7:0] port_a_queue = 0;
    reg start_port_a_access = 0;
    reg port_a_accessing_memory = 0;
    reg [12:0] base_addr = 0;
    reg [7:0] port_a_counter = 0;
    reg [7:0] port_a_outputting_counter = 0;
    reg fetch_start = 0;
    reg fetch_ready = 0;
    
    // port a memory address management
    // it takes the base address of the neurons synaptic weights, then increments through them
    // by using a counter and adding the counter * 4 (two LSL)
    // it goes through the neurons 8, 32 bit memory areas 
    always @(posedge clk) begin 
        if(rst) begin
            port_a_counter <= 0;
            port_a_accessing_memory <= 0;
            addr_a <= 0;
            fetch_ready <= 1;
        end 
                
        else if(fetch_ready) begin
            fetch_ready <= 0;
            fetch_start <= 1;
        end
        // if the flag to start memory access or the counter is bellow 8
        else if (start_port_a_access || (boot_mode == 1 && fetch_start)) begin 
            port_a_accessing_memory <= 1; // sets flag to show memory is being accesed
            addr_a <= base_addr; // sets address to base address
            port_a_counter <= 1; // sets counter to 1
            fetch_start <= 0;
        end
        
        else if (port_a_counter > 14 || !port_a_accessing_memory) begin
             port_a_counter <= 0; // sets to 8 so previous statement does not toggle
             port_a_accessing_memory <= 0; // resets flag
             addr_a <= 0;
        
        end
            
        else begin
            addr_a <= base_addr + port_a_counter; //(port_a_counter << 2); // increments address by base address + counter*4
            port_a_counter <= port_a_counter + 1; // increments counter
        end
        
    end
        
    always @(posedge clk) begin
        if (rst) begin
            port_a_start_out <= 0;
            port_a_done <= 0;
            port_a_outputting_counter <= 0;
        end
        // starts_output
        else if(port_a_counter == 2) begin
            port_a_start_out <= 1;
            port_a_done <= 0;
            port_a_outputting_counter <= 1;
        end
        
         // last output happens
        else if (port_a_outputting_counter > 14) begin
            port_a_start_out <= 0;
            port_a_done <= 1;
            port_a_outputting_counter <= 0;
        end
        // not done cycling through all addresses
        else if (port_a_outputting_counter != 0) begin
            port_a_start_out <= 0;
            port_a_outputting_counter <= port_a_outputting_counter + 1;
        end
        
        // nothing otuputting
        else begin 
            port_a_done <= 0;
            port_a_outputting_counter <= 0;
            port_a_start_out <= 0;
        end
        
    end

    
    always @(posedge clk) begin
        if (rst) begin
                port_a_queue <= 0;
                base_addr <= 120;
            end
    // this lines add any new positive edge detected data to the "queue"
        else if (edge_detected != 0 && !boot_mode)
            port_a_queue <= port_a_queue | edge_detected;
        // if the memory is not already being accessed and there is a neuron waiting for
        // memory access, it enters this case statement, which will set the base address
        // dependent on the neuron which is detected to have a spike
    
        else if(!boot_mode && !start_port_a_access && !port_a_accessing_memory && port_a_queue != 0 && !port_a_accessing_memory) begin
            start_port_a_access <= 1;
            casex (port_a_queue)
                8'bxxxxxxx1: begin 
                                base_addr <= 0;
                                port_a_queue[0] <= 0;
                            end
                8'bxxxxxx1x: begin
                                base_addr <= 15;
                                port_a_queue[1] <= 0;
                            end
                8'bxxxxx1xx: begin
                                base_addr <= 30;
                                port_a_queue[2] <= 0;
                            end
                8'bxxxx1xxx: begin 
                                base_addr <= 45;
                                port_a_queue[3] <= 0;
                            end
                8'bxxx1xxxx: begin
                                base_addr <= 60;
                                port_a_queue[4] <= 0;
                            end
                8'bxx1xxxxx: begin 
                                base_addr <= 75;
                                port_a_queue[5] <= 0;
                            end
                8'bx1xxxxxx: begin 
                                base_addr <= 90;
                                port_a_queue[6] <= 0;
                            end
                8'b1xxxxxxx: begin 
                                base_addr <= 105;
                                port_a_queue[7] <= 0;
                            end
                default : base_addr <= 0;
            endcase
        
        end
        
        else start_port_a_access <= 0;
    end 
    
endmodule
