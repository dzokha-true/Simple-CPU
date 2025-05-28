module datapath (clk, rst_n, r_en_OH, tri_controller_OH, code, address, bus);
    input clk;
    input rst_n;
    input [19:0] r_en_OH, tri_controller_OH;
    input [22:0] code;
    input [5:0] address;
    input [15:0] bus;

    wire [15:0] reg_out[0:19]; // Output from registers
    wire [15:0] alu_out; // Output from ALU
    wire [5:0] address_delayed;

    genvar i; 
    generate
        for (i = 0; i<8; i=i+1) begin : reg_gen
            register my_regs(
                .clk(clk),
                .rst(rst_n),
                .en(r_en_OH[i]),
                .d(bus),
                .q(reg_out[i])
            );
        end

        for (i = 15; i<20; i=i+1) begin : tri_gen
            tri_buf my_tris(
                .enable(tri_controller_OH[i-15]),
                .a(bus),
                .b(reg_out[i])
            );
        end
    endgenerate
	 
	register A_reg(.d(bus), .clk(clk), .rst(rst_n), .en(r_en_OH[10]), .q(reg_out[10]));
    alu my_alu(
        .operand_a(reg_out[1]),
        .operand_b(reg_out[2]),
        .alu_op_select(code[22:20]),
        .result(alu_out)
    );
    register G_reg(.d(alu_out), .clk(clk), .rst(rst_n), .en(r_en_OH[9]), .q(reg_out[9]));
    //tri_buf for G_reg
    tri_buf G_tri(
        .enable(tri_controller_OH[9]),
        .a(reg_out[9]),
        .b(bus)
    );
    
    // tri_buf for bus
    tri_buf bus_tri(
        .enable(tri_controller_OH[11]),
        .a(code[15:0]),
        .b(bus)
    );

    
endmodule