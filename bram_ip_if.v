module bram_ip_if(
    
    input clk, // clock input
    
    input [12:0] addra, // the spike train from the hidden layer
    input [12:0] addrb,   // the spike train from input layer
    
    output [32:0] dout_a,
    output [32:0] dout_b
);


      bram_wrapper bram_i
       (.addra(addra),
        .addrb(addrb),
        .clk(clk),
        .dout_a(dout_a),
        .dout_b(dout_b),
        .en(1'b1),
        .we(0));
        
        
        
endmodule 