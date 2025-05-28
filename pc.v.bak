module pc(bus, clk, rst, start, inc_pc, write, branch, address);
    input [15:0] bus; // Data bus input
    input clk, rst, start, inc_pc, write, branch; // Control signals
    output reg[5:0] address; // Address output
    
    param num_bits = 6;
    wire low_val;
    assign low_val = 1'b0; // Low value for address
    reg [6:0] temp, temp1, temp2; // Temporary registers for address calculation
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            address <= {num_bits}'b0; // Reset address to zero
        end
            address <= bus[5:0]; // Load address from bus when start signal is high
        else if (inc_pc) begin
            temp = {low_val, address}; // Concatenate low value with current address
            temp1 <= temp + 1; // Increment the address by 1
            temp2 <= temp1[6:1]; // Shift right to get the new address
            address <= temp2[5:0]; // Update the address output
        end
    end
endmodule