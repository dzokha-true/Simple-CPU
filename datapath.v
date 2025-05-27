module datapath (
    input clk;
    input rst_n;
    input [19:0] r_en_OH, tri_controller_OH;
    input [22:0] code;
    input [5:0] address;
    input [15:0] bus;
);

    wire [15:0] reg_out[0:19]; // Output from registers
    wire [15:0] alu_out; // Output from ALU
    wire [5:0] address_delayed;

    genvar i; 
    generate
        for (i = 0; i<15; i=i+1) begin : reg_gen
            register my_regs(
                .clk(clk),
                .rst_n(rst_n),
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
endmodule