module in_out_register(din, dout, clk, en, rst, qin, qout);
		input [15:0] din, dout;
		input clk, rst, en;
		output reg [15:0] qin, qout;
		
		parameter num_bits = 16;
		
		always @ (posedge clk or posedge rst) begin
			if (rst == 1'b1)
				q <= {num_bits{1'b0}};
			else begin
				if (en == 1'b1)
					q <= d;
				else
					q <= q;
			end
		end

endmodule
