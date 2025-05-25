module tri_buf (a,b,enable);
input a;
output reg b;
input enable;
always @ (enable or a) begin
	if (enable) begin
		b = a;
	end else begin
		b =1’bz;
	end
endmodule
