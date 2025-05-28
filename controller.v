module controller(clk, rst, start, code, inst_reg, r_en_OH, tri_controller_OH, inc_pc);
    input clk, rst, start;
    input [22:0] code, inst_reg;
    output [9:0] r_en_OH, tri_controller_OH;
    output inc_pc;

    wire [4:0] curr_state, next_state;
	 wire [3:0] r_en, tri_controller;
    wire end_instruction;

    find_ns next(.state(curr_state), .code(code[22:20]), .next_state(next_state), .start(start), .rst(rst));
	 
	 state_reg state_register(.d(next_state), .clk(clk), .rst(rst), .q(curr_state));
	 
	 outputsig outsig(.state(curr_state), .instr(code), .r_en(r_en), .tribuf(tri_controller), .PC_step(inc_pc));
    
    //decoder
    binary_to_onehot r_en_decoder(.fourBit(r_en), .onehot(r_en_OH));
    binary_to_onehot tri_decoder(.fourBit(tri_controller), .onehot(tri_controller_OH));
endmodule
