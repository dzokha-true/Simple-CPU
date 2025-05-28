module state_reg(d, clk, rst, q);
		input [4:0] d;
		input clk, rst;
		output reg [4:0] q;
		
		parameter num_bits = 5;
		
		always @ (posedge clk or posedge rst) begin
			if (rst == 1'b1)
				q <= {num_bits{1'b0}};
			else begin
				q <= d;
			end
		end

endmodule
