module pc(clk, rst, inc_pc, start, address);
    input clk, rst, start, inc_pc; // Control signals
    output reg[5:0] address; // Address output
    
    parameter num_bits = 6;
 
	 
	 
	 always @(posedge clk or posedge rst) begin
		if (rst == 1'b1) 
			  address <= {num_bits{1'b0}};
		else if (inc_pc == 1'b1)
			  address <= address + 1'b1;
		else
			  address <= address;
	 end

endmodule
