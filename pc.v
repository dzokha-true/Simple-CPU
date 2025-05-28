module pc(bus, clk, rst, start, inc_pc, write, branch, address);
    input [15:0] bus; // Data bus input
    input clk, rst, start, inc_pc, write, branch; // Control signals
    output reg[5:0] address; // Address output
    
    localparam num_bits = 6;
    wire low_val;
    assign low_val = 1'b0; // Low value for address
    reg [6:0] temp, temp1, temp2; // Temporary registers for address calculation
    
	// Behavioral description of the Program Counter
	always @(posedge clk or posedge rst) begin // Asynchronous reset, positive clock edge
		 if (rst == 1'b1) begin
			  address <= {num_bits{1'b0}}; // Reset PC to 0 (e.g., 6'b000000)
		 end
		 // The following 'else if' conditions maintain the priority implied by the snippet
		 else if (write == 1'b1) begin
			  address <= address + 1'b1;    // 'write' signal causes an increment (as per snippet's visible logic)
		 end
		 else if (start == 1'b1) begin
			  address <= {{num_bits-1{1'b0}}, 1'b1}; // On 'start', load address with 1 (e.g., 6'b000001)
		 end
		 else if (inc_pc == 1'b1) begin
			  address <= address + 1'b1;    // 'inc_PC' signal causes PC to increment
		 end
		 else if (branch == 1'b1) begin
			  // Snippet's original action for branch:
			  temp <= {1'b0, address};      // Store {0, current_address} (zero-extended to 7 bits) in 'temp'.
													  // This might be for saving PC for a subroutine call (if temp were an output or used later).

			  // To make the Program Counter actually branch, 'address' must be updated to the branch target.
			  // Assuming the branch target address comes from the lower bits of the 'bus' input:
			  address <= bus[num_bits-1:0]; // Load new address from bus (e.g., bus[5:0])
		 end
		 else begin
			  // If no other control signal is active, PC holds its current value.
			  // Alternatively, in some designs, PC might increment by default if inc_PC is not used exclusively.
			  address <= address;
		 end
	end

// Note:
// - The 'input ir' is declared as per the snippet but is not used in this specific PC logic.
//   In a full processor, 'ir' would typically be decoded to generate control signals like 'inc_PC', 'branch',
//   and might provide offsets or target addresses for branches.
// - The 'temp' register is written to during a branch condition but is not used to determine the next 'address'
//   within this module. Its value might be intended for other parts of a larger system if it were an output.
// - The 'write' signal causing an increment is based on the snippet's `address <= address+`. If 'write'
//   was intended as a general "load PC from bus" signal, its logic would be different (e.g., `address <= bus[num_bits-1:0];`).

endmodule