module tri_buf (a,b,enable);
	input [15:0] a;
	output reg[15:0] b;
	input enable;

	parameter num_bits = 16;
	wire tri_val;
	assign tri_val = 1'bz;

	always @ (enable or a or tri_val) begin
		if (enable) begin
			b = a;
		end else begin
			b = {num_bits{tri_val}};
		end
	end
	
endmodule
