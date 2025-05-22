module ff(
	input D, clk, en, reset,
	output Q
);
	always @(posedge clk, reset) begin
    case ({rest, en}) 
      2'b1x: Q <= 0; // set output to zero on clear signal
      2'b01: Q <= D; // on rising clock edge, set output to data if enabled
      2'b00: Q <= Q; // hold output when disabled
      default: Q <= 0; // default to prevent latch being formed
    endcase
  end  
endmodule

module reg_4b(
	input [3:0] D, 
   input clk, en, reset,
   output [3:0] Q);
	
  dff(.D(D[0]), .clk(clk), .en(en), .reset(reset), .Q(Q[0])); // connect each input and output to flip flop
  dff(.D(D[1]), .clk(clk), .en(en), .reset(reset), .Q(Q[1]));
  dff(.D(D[2]), .clk(clk), .en(en), .reset(reset), .Q(Q[2]));
  dff(.D(D[3]), .clk(clk), .en(en), .reset(reset), .Q(Q[3]));
  
endmodule

module reg_16b(
	input [15:0] D, 
   input clk, en, reset,
   output [15:0] Q);
	
  reg_4b(.D(D[3:0]), .clk(clk), .en(en), .reset(reset), .Q(Q[3:0])); // connect each input and output to flip flop
  reg_4b(.D(D[7:4]), .clk(clk), .en(en), .reset(reset), .Q(Q[7:4]));
  reg_4b(.D(D[11:8]), .clk(clk), .en(en), .reset(reset), .Q(Q[11:8]));
  reg_4b(.D(D[15:12]), .clk(clk), .en(en), .reset(reset), .Q(Q[15:12]));
  
endmodule