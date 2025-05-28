module fake_IM(address,code);

	input[5:0] address;
	output reg[22:0] code;

	always @(address) begin
		case (address)
			6'h00 : begin code <= {3'b000, 4'h0, 16'h000}; end // 
			6'h01 : begin code <= {3'b000, 4'h1, 16'h001}; end // 
			6'h02 : begin code <= {3'b000, 4'h2, 16'h002}; end // 
			6'h03 : begin code <= {3'b000, 4'h3, 16'h003}; end // 
			6'h04 : begin code <= {3'b000, 4'h4, 16'h004}; end // 
			// It's good practice to have a default case
			default: code <= 23'd0; // Or some other default value
		endcase
	end
endmodule
