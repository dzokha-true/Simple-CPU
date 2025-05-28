module outputsig(state, instr, PC_step, tribuf, r_en);
	input [4:0] state;
	input [22:0] instr;
	output reg[3:0] r_en, tribuf;
	output reg PC_step;
	
	always @(instr, state) begin
		case (state)
			5'b00001: begin tribuf <= 4'd9;	         r_en <= instr[19:16]; end //load
			5'b00010: begin tribuf <= instr[15:12];	r_en <= instr[19:16]; end//mov
			5'b00011: begin tribuf <= instr[19:16];	r_en <= 4'd9; end//arithmetic
			5'b00100: begin tribuf <= instr[15:12];	r_en <= 4'd8; end
			5'b00101: begin tribuf <= 4'd8;	r_en <= instr[19:16]; end
			default:  begin tribuf <= 4'd0;	r_en <= 4'd0; end
		endcase
	end
	
	always @(state) begin
		case (state)
			5'b10000, 5'b00101: PC_step <= 1'b1;
			default: PC_step <= 1'b0;
		endcase
	end
endmodule
			
			
