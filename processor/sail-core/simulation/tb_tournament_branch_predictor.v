module tb_tournament_branch_predictor();
	// Inputs
	reg clk = 0;
	reg [31:0] pc_branch_addr;
	reg [31:0] offset;
	reg [31:0] update_branch_addr;
	reg actual_branch_decision;
	reg branch_decode_sig;
	reg branch_mem_sig;
	
	// Outputs
	wire [31:0] out_branch_addr;
	wire prediction;
	wire selected_predictor;
	// wire [7:0] debug_output;
	// wire [1:0] debug_output_2;

	tournament_branch_predictor tbp(
		.clk(clk),
		.actual_branch_decision(actual_branch_decision),
		.branch_decode_sig(branch_decode_sig),
		.branch_mem_sig(branch_mem_sig),
		.pc_branch_addr(pc_branch_addr),
		.offset(offset),
		.update_branch_addr(update_branch_addr),
		.out_branch_addr(out_branch_addr),
		.prediction(prediction),
		.selected_predictor(selected_predictor)
	);

	// The functionality of the branch history predictor
	// & global history predictor have been tested in their
	// own tb respectively. Hence, only the functionality
	// of the tournament predictor is tested here.

	//simulation
	always
	 #1 clk = ~clk;

	initial begin
		$dumpfile ("tb_tournament_branch_predictor.vcd");
	 	$dumpvars;
		
		// Initialise inputs
		branch_decode_sig = 0;
		branch_mem_sig = 0;
		actual_branch_decision = 0;
		pc_branch_addr = 32'b0;
		update_branch_addr = 32'b0;
		offset = 32'b0;
	 	#5

		// Check offset 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		offset = 32'hFFFFFF;
		// Check out_branch_addr = 32'hFFFFFF
		#2

		// Check offset 2
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b011;
		offset = 32'b111;
		// Check out_branch_addr = 32'b1010
		#2

		// Using pc_branch_addr = 32'b0 & initial conditions,	
		// Check selected_predictor = 1 & prediction = 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		#2


		// With pc_branch_addr = 32'b0, selected_predictor = 1 (global)
		// Write actual_branch_decision = 1 to pc_branch_addr = 32'b0,
		// setting curr_global_history = 00000001
		// local_predictor[0000] = 11
		// global_predictor[00000000] = 11
		// Because selected_predictor == actual_branch_history in write,
		// tournament_history_table[pc_branch_addr] = 11, 
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b1;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		update_branch_addr = 32'b0;
		#2

		// Check pc_branch_addr = 32'b0 
		// tournament_history_table[pc_branch_addr] = 11, 
		// check selected_predictor = 1 & prediction = 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		#2

		// With pc_branch_addr = 32'b0, selected_predictor = 1 (global)
		// Write actual_branch_decision = 0 to pc_branch_addr = 32'b0,
		// setting curr_global_history = 00000010
		// local_predictor[0000] = 10
		// global_predictor[000000001] = 01
		// Because selected_predictor != actual_branch_history in write,
		// tournament_history_table[pc_branch_addr] = 10, 
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		update_branch_addr = 32'b0;
		#2

		// Check pc_branch_addr = 32'b0 
		// tournament_history_table[pc_branch_addr] = 10, 
		// check selected_predictor = 1 & prediction = 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		#2

		// With pc_branch_addr = 32'b0, selected_predictor = 1 (global)
		// Write actual_branch_decision = 0 to pc_branch_addr = 32'b0,
		// setting curr_global_history = 00000100
		// local_predictor[0000] = 01
		// global_predictor[00000010] = 01
		// Because selected_predictor != actual_branch_history in write,
		// tournament_history_table[pc_branch_addr] = 01, 
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		update_branch_addr = 32'b0;
		#2

		// Check pc_branch_addr = 32'b0 
		// tournament_history_table[pc_branch_addr] = 01, 
		// check selected_predictor = 0 & prediction = 0
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		#2

		// With pc_branch_addr = 32'b0, selected_predictor = 0 (local)
		// Write actual_branch_decision = 0 to pc_branch_addr = 32'b0,
		// setting curr_global_history = 00001000
		// local_predictor[0000] = 00
		// global_predictor[00000100] = 01
		// Because selected_predictor == actual_branch_history in write,
		// tournament_history_table[pc_branch_addr] = 10, 
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		update_branch_addr = 32'b0;
		#2

		// Check pc_branch_addr = 32'b0 
		// Because selected_predictor == actual_branch_history in write,
		// tournament_history_table[pc_branch_addr] = 10, 
		// check selected_predictor = 1 & prediction = 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		#2

		// End of test, reset everything to 0
		branch_decode_sig = 0;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		#5

	 	$finish;
	end

endmodule
