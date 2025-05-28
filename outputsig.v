module outputsig(state, opcode, inst_reg, branch, PC_step, tribuf, r_en);
	input [4:0] state;
	input [22:0] opcode,inst_reg;
	output reg[3:0] r_en, tribuf;
	output reg branch, PC_step;
	
	always @(opcode, state) begin
		case (state)
			5'b00001:
				begin tribuf <= 4'd10;	   r_en <= opcode[19:16]; //load 
			end
			5'b00010:
				begin tribuf <= opcode[15:12];	r_en <= opcode[19:16]; //mov
			end
			5'b00011:
				begin tribuf <= opcode[19:16];	r_en <= 4'd10; //arithmetic
			end
			5'b00100:
				begin tribuf <= opcode[15:12];	r_en <= 4'd9;
			end
			5'b00101:
				begin tribuf <= 4'd9;	r_en <= opcode[19:16];
			end
			default:  begin tribuf <= 4'd0;	r_en <= 4'd0;
			end
		endcase
	end
	always @(state) begin
		case (state)
			5'b00001, 5'b00001, 5'b00001: PC_step <= 1'b1;
		endcase
	end
endmodule