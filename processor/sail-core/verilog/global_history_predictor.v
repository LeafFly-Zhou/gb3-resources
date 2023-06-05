/*
 *		Global history predictor
 */

module global_history_predictor(
		clk,
		actual_branch_decision,
		branch_decode_sig,
		branch_mem_sig,
		pc_branch_addr,
		offset,
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

	/*
	 *	outputs
	 */
	output [31:0]	out_branch_addr;
	output			prediction;

	/*
	 *	internal state
	 */
	// A register for holding current global history
	reg [7:0]		curr_global_history;
	// A register for holding the previous global history for updating table
	reg [7:0]		prev_global_history;
	// A global history array with 256 elements, each holding a saturating
	// counter
	reg [1:0]		global_history_table [255:0];
	reg				branch_mem_sig_reg;
	// reg				actual_branch_decision_reg;
	// For initialising global_history_table
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
		for (i=0; i < 256; i=i+1)
			global_history_table[i] = 2'b10;
		curr_global_history <= 8'b0;
		prev_global_history <= 8'b0;
	end

	always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
		// actual_branch_decision_reg <= actual_branch_decision;
		prev_global_history <= curr_global_history;
	end

	/*
	 *	Using this microarchitecture, branches can't occur consecutively
	 *	therefore can use branch_mem_sig as every branch is followed by
	 *	a bubble, so a 0 to 1 transition
	 */

	// Update the global_history_table and curr_global_history when an actual branch decision is received
	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
			curr_global_history <= {curr_global_history[6:0], actual_branch_decision};
			if (actual_branch_decision == 1'b1) begin
				if (global_history_table[prev_global_history] < 2'b11) begin
					global_history_table[prev_global_history] <= global_history_table[prev_global_history] + 1;
				end
				else begin
					global_history_table[prev_global_history] <= 2'b11;
				end
			end
			else begin
				if (global_history_table[prev_global_history] > 2'b00) begin
					global_history_table[prev_global_history] <= global_history_table[prev_global_history] - 1;
				end
				else begin
					global_history_table[prev_global_history] <= 2'b00;
				end
			end
		end
	end
	
	assign prediction = global_history_table[curr_global_history][1] & branch_decode_sig;
	assign out_branch_addr = pc_branch_addr + offset;
endmodule

