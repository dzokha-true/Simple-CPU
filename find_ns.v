module find_ns(state, opcode, rst, start, next_state);
	
	input[4:0] state;
	input[3:0] opcode;
	input rst, start;
	output reg[4:0] next_state;
	
	always @(rst, state, start, code) begin
		if (rst == 1'b1)
			next_state <= 5'b11111;
		else begin
			case (state)
				5'b00000:
					begin
						case (code)
							3'b000:  next_state <= 5'b00001; //load
							3'b001:  next_state <= 5'b00010; //mov
							3'b010:  next_state <= 5'b00011; //add
							3'b011:  next_state <= 5'b00011; //xor
							3'b100:  next_state <= 5'b00011; //or
							3'b101:  next_state <= 5'b00011; //and
							3'b110:  next_state <= 5'b00110; //branch
							default: next_state <= 5'b10000;
						endcase
					end
				5'b00001, 5'b00010, 5'b00101, 5'b00110: next_state <= 5'b10000;
				5'b00011: next_state <= 5'b00100;
				5'b00100: next_state <= 5'b00101;
		
				
				
				
				5'b10000: next_state <= 5'b00000;
				5'b11111: if (start == 1'b1)
								next_state <= 5'b10000;
							 else
								next_state <= 5'b11111;
				default: next_state <= 5'b11111;
			endcase
		end
	end
endmodule