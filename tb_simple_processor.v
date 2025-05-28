`timescale 1ns / 1ps

module tb_simple_processor;

    // Testbench signals
    reg clk, reset, start;
	 reg [3:0] count;
    reg [22:0] instruction;
	
    // Instantiate the Unit Under Test (UUT)

    simple_processor uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .write(write),
        .program_in(instruction)
    );
	 
	 

    initial begin
		  instruction = 23'd0;
        count = 4'b0000;
		  clk = 1'b0;
		  reset = 1'b0;
		  start = 1'b1;
    end


    always begin
        #50
        count = count + 4'b0001;
    end
	 
	 always begin
		#25
		clk = 1'b0;
		#25
		clk = 1'b1;
	 end

    

    always @(count) begin
        case (count)
            4'h0: begin reset = 1'b1; start = 1'b1; end
				4'h1: begin reset = 1'b1; start = 1'b1; end
				4'h2: begin reset = 1'b0; start = 1'b1; end
				4'h3: begin reset = 1'b0; start = 1'b1; end
        endcase
    end
endmodule
