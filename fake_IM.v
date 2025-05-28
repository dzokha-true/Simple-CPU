module fake_IM(address,code);

	input[5:0] address;
	output reg[22:0] code;

	always @(address) begin
		case (address)
			6'h00 : begin code <= {3'b000, 4'h0, 10'h000}; end // Corrected: 6'h00 for address, 10'h000 for the last part of code
			6'h01 : begin code <= {3'b000, 4'h0, 10'h001}; end // Corrected: 6'h01, 10'h001
			6'h02 : begin code <= {3'b000, 4'h0, 10'h002}; end // Corrected: 6'h02, 10'h002
			6'h03 : begin code <= {3'b000, 4'h0, 10'h020}; end // Corrected: 6'h03, 10'h020
			6'h04 : begin code <= {3'b000, 4'h0, 10'h050}; end // Corrected: 6'h04, 10'h050
			// It's good practice to have a default case
			default: code <= 23'h0000000; // Or some other default value
		endcase
	end
endmodule
