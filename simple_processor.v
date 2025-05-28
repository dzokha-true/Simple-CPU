module simple_processor(reset, clk, start, write, program_in);
    input reset, clk, start, write;
    input[22:0] program_in;
	 
	 wire [5:0] address;
    wire [9:0] r_en_OH, tri_controller_OH;
    wire [15:0] bus;
    wire inc_pc;
    wire [22:0] code,inst_reg;
	 
	 

controller my_controller(
    .clk(clk), 
    .rst(reset), 
    .start(start), 
    .code(code), 
    .inst_reg(inst_reg), 
    .r_en_OH(r_en_OH), 
    .tri_controller_OH(tri_controller_OH), 
    .inc_pc(inc_pc)
);


datapath my_datapath(
    .clk(clk), 
    .rst_n(reset), 
    .r_en_OH(r_en_OH), 
    .tri_controller_OH(tri_controller_OH),
    .bus(bus),
    .code(code)
);

pc program_counter(.clk(clk), .rst(reset), .inc_pc(inc_pc), .start(start), .address(address));

fake_IM im(.address(address),.code(code));

endmodule
