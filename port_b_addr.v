`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2025 02:27:45 PM
// Design Name: 
// Module Name: port_b_addr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// Logic to get the port b addresses
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module port_b_addr(
        input clk,
        input rst,
        input boot_mode, // fetches biases
        
        input [29:0] edge_detected,
        
        
        output reg [9:0] addr_b = 0,
        output reg port_b_start_out = 0, // flag to say the output from port a is starting 
        output reg port_b_done = 0 // signifies that port a is done transmitting
    );
    
   
    reg [29:0] port_b_queue = 0;
    reg start_port_b_access = 0;
    reg port_b_accessing_memory = 0;
    reg [12:0] base_addr = 0;
    reg [1:0] port_b_counter = 0;
    reg [1:0] port_b_outputting_counter = 0;
    reg fetch_start = 0;
    reg fetch_ready = 0;
// port a memory address management
// it takes the base address of the neurons synaptic weights, then increments through them
// by using a counter and adding the counter * 4 (two LSL)
 
    always @(posedge clk) begin
        
        if(rst) begin
            port_b_counter <= 0;
            port_b_accessing_memory <= 0;
            addr_b <= 0;
            fetch_ready <= 1;
        end
        
        else if(fetch_ready) begin
            fetch_ready <= 0;
            fetch_start <= 1;
        end
        // if the flag to start memory access or the counter is bellow 8
        else if (start_port_b_access || (boot_mode == 1 && fetch_start)) begin
            port_b_accessing_memory <= 1; // sets flag to show memory is being accesed
            addr_b <= base_addr; // sets address to base address
            port_b_counter <= 1; // sets counter to 1
            fetch_start <= 0;
        end
        
        else if (port_b_counter > 1 || !port_b_accessing_memory) begin
             port_b_counter <= 0; // sets to 8 so previous statement does not toggle
             port_b_accessing_memory <= 0; // resets flag
             addr_b <= 0;
        
        end
            
        else begin
            addr_b <= base_addr + port_b_counter; //(port_b_counter << 2); // increments address by base address + counter*4
            port_b_counter <= port_b_counter + 1; // increments counter
        end
        
    end
        
    always @(posedge clk) begin
    
        if (rst) begin
            port_b_start_out <= 0;
            port_b_done <= 0;
            port_b_outputting_counter <= 0;
        end
        // starts_output
        if(port_b_counter == 2) begin
            port_b_start_out <= 1;
            port_b_done <= 0;
            port_b_outputting_counter <= 1;
        end
        
         // last output happens
        else if (port_b_outputting_counter > 1) begin
            port_b_start_out <= 0;
            port_b_done <= 1;
            port_b_outputting_counter <= 0;
        end
        
        // not done cycling through all addresses
        else if (port_b_outputting_counter != 0) begin
            port_b_outputting_counter <= port_b_outputting_counter + 1;
            port_b_start_out <= 0;
        end
        
        // nothing otuputting
        else begin 
            port_b_done <= 0;
            port_b_outputting_counter <= 0;
            port_b_start_out<= 0;
        end
        
    end


    always @(posedge clk) begin
        if (rst) begin
            port_b_queue <= 0;
            base_addr <= 60;
        end
        else if (edge_detected != 0)
            port_b_queue <= port_b_queue | edge_detected;
    // if the memory is not already being accessed and there is a neuron waiting for
    // memory access, it enters this case statement, which will set the base address
    // dependent on the neuron which is detected to have a spike

    else if(!start_port_b_access && !port_b_accessing_memory && port_b_queue != 0 && !port_b_accessing_memory) begin
        start_port_b_access <= 1;
        casex (port_b_queue)
            30'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1: begin
                base_addr <= 0;
                port_b_queue[0] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxxxxxxxxxxxxx1x: begin
                base_addr <= 2;
                port_b_queue[1] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxxxxxxxxxxxx1xx: begin
                base_addr <= 4;
                port_b_queue[2] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxxxxxxxxxxx1xxx: begin
                base_addr <= 6;
                port_b_queue[3] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxxxxxxxxxx1xxxx: begin
                base_addr <= 8;
                port_b_queue[4] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxxxxxxxxx1xxxxx: begin
                base_addr <= 10;
                port_b_queue[5] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxxxxxxxx1xxxxxx: begin
                base_addr <= 12;
                port_b_queue[6] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxxxxxxx1xxxxxxx: begin
                base_addr <= 14;
                port_b_queue[7] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxxxxxx1xxxxxxxx: begin
                base_addr <= 16;
                port_b_queue[8] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxxxxx1xxxxxxxxx: begin
                base_addr <= 18;
                port_b_queue[9] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxxxx1xxxxxxxxxx: begin
                base_addr <= 20;
                port_b_queue[10] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxxx1xxxxxxxxxxx: begin
                base_addr <= 22;
                port_b_queue[11] <= 0;
            end
            30'bxxxxxxxxxxxxxxxxx1xxxxxxxxxxxx: begin
                base_addr <= 24;
                port_b_queue[12] <= 0;
            end
            30'bxxxxxxxxxxxxxxxx1xxxxxxxxxxxxx: begin
                base_addr <= 26;
                port_b_queue[13] <= 0;
            end
            30'bxxxxxxxxxxxxxxx1xxxxxxxxxxxxxx: begin
                base_addr <= 28;
                port_b_queue[14] <= 0;
            end
            30'bxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx: begin
                base_addr <= 30;
                port_b_queue[15] <= 0;
            end
            30'bxxxxxxxxxxxxx1xxxxxxxxxxxxxxxx: begin
                base_addr <= 32;
                port_b_queue[16] <= 0;
            end
            30'bxxxxxxxxxxxx1xxxxxxxxxxxxxxxxx: begin
                base_addr <= 34;
                port_b_queue[17] <= 0;
            end
            30'bxxxxxxxxxxx1xxxxxxxxxxxxxxxxxx: begin
                base_addr <= 36;
                port_b_queue[18] <= 0;
            end
            30'bxxxxxxxxxx1xxxxxxxxxxxxxxxxxxx: begin
                base_addr <= 38;
                port_b_queue[19] <= 0;
            end
            30'bxxxxxxxxx1xxxxxxxxxxxxxxxxxxxx: begin
                base_addr <= 40;
                port_b_queue[20] <= 0;
            end
            30'bxxxxxxxx1xxxxxxxxxxxxxxxxxxxxx: begin
                base_addr <= 42;
                port_b_queue[21] <= 0;
            end
            30'bxxxxxxx1xxxxxxxxxxxxxxxxxxxxxx: begin
                base_addr <= 44;
                port_b_queue[22] <= 0;
            end
            30'bxxxxxx1xxxxxxxxxxxxxxxxxxxxxxx: begin
                base_addr <= 46;
                port_b_queue[23] <= 0;
            end
            30'bxxxxx1xxxxxxxxxxxxxxxxxxxxxxxx: begin
                base_addr <= 48;
                port_b_queue[24] <= 0;
            end
            30'bxxxx1xxxxxxxxxxxxxxxxxxxxxxxxx: begin
                base_addr <= 50;
                port_b_queue[25] <= 0;
            end
            30'bxxx1xxxxxxxxxxxxxxxxxxxxxxxxxx: begin
                base_addr <= 52;
                port_b_queue[26] <= 0;
            end
            30'bxx1xxxxxxxxxxxxxxxxxxxxxxxxxxx: begin
                base_addr <= 54;
                port_b_queue[27] <= 0;
            end
            30'bx1xxxxxxxxxxxxxxxxxxxxxxxxxxxx: begin
                base_addr <= 56;
                port_b_queue[28] <= 0;
            end
            30'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx: begin
                base_addr <= 58;
                port_b_queue[29] <= 0;
            end
            default: base_addr <= 0;
            endcase
        end
        else start_port_b_access <= 0;
    end

endmodule
