`timescale 1ns / 1ps

module tb_simple_processor;

    // Testbench signals
    reg clk;
    reg reset;
	 reg [3:0] count;
    reg start;
    reg write;
    reg [22:0] program_in;
	
    // Instantiate the Unit Under Test (UUT)

    simple_processor uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .write(write),
        .program_in(program_in)
    );
	 

    initial begin
          #1;
        count = 4'b0000;
		  start = 1'b1;
		  reset = 1'b0;
		  write = 1'b0;
    end

    initial begin
      clk = 1'b1;
      #1;
      repeat (1000) begin    // 1000 toggles, so 2000 edges total
         #25 clk = ~clk;
      end
    end


    always begin
          #50
        count = count + 4'b0001;
    end

     // op(zz)rx(zzzz)ry(zzzz)data(zzzzzzzzzzzzzzzz)

    always @(count) begin
        case (count)
            4'b0000: begin reset = 1'b1; program_in = 23'bzzzzzzzzzzzzzzzzzzzzzzz; end 
            4'b0001: begin reset = 1'b0; program_in = 23'b00000000000000000001001; end // load r1, 9
        endcase
    end
endmodule
