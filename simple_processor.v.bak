module simple_processor(
    input reset, clk, start, write;
    input[22:0] program_in;

    wire [19:0] r_en_OH, tri_controler_OH;
    wire [15:0] bus;
    wire inc_PC, branch;
    wire [5:0] address;
    wire [22:0] code, inst_reg;
);

controller my_controller(
    .clk(clk), 
    .rst(reset), 
    .start(start), 
    .code(code), 
    .inst_reg(inst_reg), 
    .r_en_OH(r_en_OH), 
    .tri_controler_OH(tri_controler_OH), 
    .branch(branch), 
    .inc_pc(inc_PC)
);

datapath my_datapath(
    .clk(clk), 
    .reset(reset), 
    .write(write), 
    .r_en_OH(r_en_OH), 
    .tri_controler_OH(tri_controler_OH), 
    .bus(bus), 
    .inc_PC(inc_PC), 
    .branch(branch), 
    .address(address), 
    .code(code), 
    .inst_reg(inst_reg)
);

pc my_pc(
    .bus(bus), 
    .clk(clk), 
    .rst(reset), 
    .start(start), 
    .inc_pc(inc_PC), 
    .write(write), 
    .address(address)
);

//decoder

endmodule
