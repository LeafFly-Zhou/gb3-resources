/*
 *		Branch history predictor
 */

module branch_history_predictor(
		clk,
		actual_branch_decision,
		branch_decode_sig,
		branch_mem_sig,
		pc_branch_addr,
		offset,
		update_branch_addr,
		out_branch_addr,
		prediction
	);

	/*
	 *	inputs
	 */
	input			clk;
	input			actual_branch_decision;
	input			branch_decode_sig;
	input			branch_mem_sig;
	input [31:0]	pc_branch_addr;
	input [31:0]    offset;
	input [31:0]	update_branch_addr;

	/*
	 *	outputs
	 */
	output [31:0]	out_branch_addr;
	output			prediction;

	/*
	 *	internal state
	 */
	// A branch history array with 16 elements, each holding a saturating
	// counter
	reg [1:0]		branch_history_table [15:0];
	reg				branch_mem_sig_reg;
	reg [3:0]		update_branch_addr_reg;
	// reg				actual_branch_decision_reg;
	// Declare as unsigned int using reg
	// reg [3:0]		pc_branch_target_addr;
	// reg [3:0]		update_branch_target_addr;
	// For initialising branch_history
	integer			i;

	/*
	 *	The `initial` statement below uses Yosys's support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	initial begin
		for (i=0; i < 16; i=i+1)
			branch_history_table[i] = 2'b10;
	end

	always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
		update_branch_addr_reg <= update_branch_addr[3:0];
		// actual_branch_decision_reg <= actual_branch_decision;

	end

	/*
	 *	Using this microarchitecture, branches can't occur consecutively
	 *	therefore can use branch_mem_sig as every branch is followed by
	 *	a bubble, so a 0 to 1 transition
	 */

	// Update the branch_history when an actual branch decision is received
	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
			if (actual_branch_decision == 1'b1) begin
				if (branch_history_table[update_branch_addr_reg] < 2'b11) begin
					branch_history_table[update_branch_addr_reg] <= branch_history_table[update_branch_addr_reg] + 1;
				end
				else begin
					branch_history_table[update_branch_addr_reg] <= 2'b11;
				end
			end
			else begin
				if (branch_history_table[update_branch_addr_reg] > 2'b00) begin
					branch_history_table[update_branch_addr_reg] <= branch_history_table[update_branch_addr_reg] - 1;
				end
				else begin
					branch_history_table[update_branch_addr_reg] <= 2'b00;
				end
			end
		end
	end
	
	assign prediction = branch_history_table[pc_branch_addr[3:0]][1] & branch_decode_sig;
	assign out_branch_addr = pc_branch_addr + offset;
endmodule

