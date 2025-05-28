module simple_processor(reset, clk, start, write, program_in);
    input reset, clk, start, write;
    input[22:0] program_in;

    wire [19:0] r_en_OH, tri_controller_OH;
    wire [15:0] bus;
    wire inc_PC, branch;
    wire [5:0] address;
    wire [22:0] code, inst_reg;

controller my_controller(
    .clk(clk), 
    .rst(reset), 
    .start(start), 
    .code(code), 
    .inst_reg(inst_reg), 
    .r_en_OH(r_en_OH), 
    .tri_controller_OH(tri_controller_OH), 
    .branch(branch), 
    .inc_pc(inc_PC)
);

datapath my_datapath(
    .clk(clk), 
    .rst_n(reset), 
    .r_en_OH(r_en_OH), 
    .tri_controller_OH(tri_controller_OH), 
    .bus(bus), 
    .address(address), 
    .code(code), 
);
/*
pc my_pc(
    .bus(bus), 
    .clk(clk), 
    .rst(reset), 
    .start(start), 
    .inc_pc(inc_PC), 
    .write(write), 
    .address(address)
);
*/

//decoder

endmodule
