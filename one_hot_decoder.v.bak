module binary_to_onehot (fiveBit, onehot);
    input [4:0] fiveBit; // 5-bit binary input
    output reg [19:0] onehot; // 32-bit one-hot output

    always @(fiveBit) begin
        // Set the corresponding bit in one-hot encoding
        case (fiveBit)
            5'b00000: onehot <= 10'h0; // 11
            5'b00001: onehot <= 10'd1; // 1
            5'b00010: onehot <= 10'd2; // 2
            5'b00011: onehot <= 10'd4; // 3
            5'b00100: onehot <= 10'd8; // 4
            5'b00101: onehot <= 10'd16; // 5
            5'b00110: onehot <= 10'd32; // 6
            5'b00111: onehot <= 10'd64; // 7
            5'b01000: onehot <= 10'd128; // 8
            5'b01001: onehot <= 10'd256; // 9
            5'b01010: onehot <= 10'd512; // 10
        endcase
    end
endmodule