module binary_to_onehot (fourBit, onehot);
	input [3:0] fourBit; // 5-bit binary input
    	output reg [9:0] onehot; // 32-bit one-hot output

	always @(fourBit) begin
        // Set the corresponding bit in one-hot encoding
		case (fourBit)
	            4'b0000: onehot <= 10'd1; // 11
	            4'b0001: onehot <= 10'd2; // 1
	            4'b0010: onehot <= 10'd4; // 2
	            4'b0011: onehot <= 10'd8; // 3
	            4'b0100: onehot <= 10'd16; // 4
	            4'b0101: onehot <= 10'd32; // 5
	            4'b0110: onehot <= 10'd64; // 6
	            4'b0111: onehot <= 10'd128; // 7
	            4'b1000: onehot <= 10'd256; // 8
	            4'b1001: onehot <= 10'd512; // 9
		    default: onehot <= 10'd0;
	        endcase
    	end
endmodule
