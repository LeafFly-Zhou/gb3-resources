/*
 *		Tournament branch predictor
 */

module tournament_branch_predictor(
		clk,
		actual_branch_decision,
		branch_decode_sig,
		branch_mem_sig,
		pc_branch_addr,
		offset,
		update_branch_addr,
		mispredict,
		out_branch_addr,
		prediction
		// For debug and simulation purposes, hence disabled
		// selected_predictor
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
	input			mispredict;

	/*
	 *	outputs
	 */
	output [31:0]	out_branch_addr;
	output			prediction;
	// For debug and simulation purposes, hence disabled
	// output			selected_predictor;

	/*
	 *	internal state
	 */
	// reg				actual_branch_decision_reg;
	// A branch history array with 16 elements, each holding a saturating
	// counter
	reg [1:0]		branch_history_table [15:0];
	reg				branch_mem_sig_reg;
	reg [3:0]		update_branch_addr_reg;

	// For global predictor
	// A register for holding current global history
	reg [5:0]		curr_global_history;
	// A register for holding the previous global history for updating table
	reg [5:0]		prev_global_history;
	// A global history array with 64 elements, each holding a saturating
	// counter
	reg [1:0]		global_history_table [63:0];

	// For tournament predictor
	// A tournament history array with 16 elements, each holding a saturating
	// counter
	reg [1:0]		tournament_history_table [15:0];
	reg				prev_predictor;	
	// reg				mispredict_reg;

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
		prev_predictor <= 0;
		curr_global_history <= 6'b0;
		prev_global_history <= 6'b0;
		for (i=0; i < 16; i=i+1) begin
			branch_history_table[i] = 2'b10;
			tournament_history_table[i] = 2'b01;
		end
		for (i=0; i < 64; i=i+1)
			global_history_table[i] = 2'b10;
	end

	always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
		// actual_branch_decision_reg <= actual_branch_decision;
		update_branch_addr_reg <= update_branch_addr[3:0];
		prev_global_history <= curr_global_history;
		prev_predictor <= tournament_history_table[update_branch_addr[3:0]][1];
		// mispredict_reg <= mispredict;
	end

	/*
	 *	Using this microarchitecture, branches can't occur consecutively
	 *	therefore can use branch_mem_sig as every branch is followed by
	 *	a bubble, so a 0 to 1 transition
	 */

	// Update the predictor histories when an actual branch decision is received
	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
			// Update curr_global_history
			curr_global_history <= {curr_global_history[4:0], actual_branch_decision};

			// Check against actual branch decision
			if (actual_branch_decision == 1'b1) begin
				// Update local history predictor
				if (branch_history_table[update_branch_addr_reg] < 2'b11) begin
					branch_history_table[update_branch_addr_reg] <= branch_history_table[update_branch_addr_reg] + 1;
				end
				else begin
					branch_history_table[update_branch_addr_reg] <= 2'b11;
				end
				
				// Update global history predictor
				if (global_history_table[prev_global_history] < 2'b11) begin
					global_history_table[prev_global_history] <= global_history_table[prev_global_history] + 1;
				end
				else begin
					global_history_table[prev_global_history] <= 2'b11;
				end
			end
			else begin
				// Update local history predictor
				if (branch_history_table[update_branch_addr_reg] > 2'b00) begin
					branch_history_table[update_branch_addr_reg] <= branch_history_table[update_branch_addr_reg] - 1;
				end
				else begin
					branch_history_table[update_branch_addr_reg] <= 2'b00;
				end
				
				// Update global history predictor
				if (global_history_table[prev_global_history] > 2'b00) begin
					global_history_table[prev_global_history] <= global_history_table[prev_global_history] - 1;
				end
				else begin
					global_history_table[prev_global_history] <= 2'b00;
				end
			end

			// Update tournament predictor by looking at previous predictor
			// and mispredict flag
			if (prev_predictor == mispredict) begin
				if (tournament_history_table[update_branch_addr_reg] > 2'b00) begin
					tournament_history_table[update_branch_addr_reg] <= tournament_history_table[update_branch_addr_reg] - 1;
				end
				else begin
					tournament_history_table[update_branch_addr_reg] <= 2'b00;
				end
			end
			else begin
				if (tournament_history_table[update_branch_addr_reg] < 2'b11) begin
					tournament_history_table[update_branch_addr_reg] <= tournament_history_table[update_branch_addr_reg] + 1;
				end
				else begin
					tournament_history_table[update_branch_addr_reg] <= 2'b11;
				end
			end
		end
	end
	
	// For debug purposes and simulation only, hence disabled
	// assign selected_predictor = tournament_history_table[pc_branch_addr[3:0]][1];
	
	// Assign local and global prediction
	// Use global when the 2nd bit of tournament history table is 1, vice versa
	assign prediction = (tournament_history_table[pc_branch_addr[3:0]][1] == 1'b1) ? (global_history_table[curr_global_history][1] & branch_decode_sig) : (branch_history_table[pc_branch_addr[3:0]][1] & branch_decode_sig);
	assign out_branch_addr = pc_branch_addr + offset;
	
endmodule

