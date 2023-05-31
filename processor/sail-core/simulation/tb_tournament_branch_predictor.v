module tb_tournament_branch_predictor();
	// Inputs
	reg clk = 0;
	reg [31:0] pc_branch_addr;
	reg [31:0] offset;
	reg [31:0] update_branch_addr;
	reg actual_branch_decision;
	reg branch_decode_sig;
	reg branch_mem_sig;
	reg mispredict;
	
	// Outputs
	wire [31:0] out_branch_addr;
	wire prediction;
	// For debug and simulation purposes, enabled it for
	// simulation, remember to enable the lines associated
	// to simulation in tournament_branch_predictor.v 
	// as well
	// wire selected_predictor;

	tournament_branch_predictor tbp(
		.clk(clk),
		.actual_branch_decision(actual_branch_decision),
		.branch_decode_sig(branch_decode_sig),
		.branch_mem_sig(branch_mem_sig),
		.pc_branch_addr(pc_branch_addr),
		.offset(offset),
		.update_branch_addr(update_branch_addr),
		.mispredict(mispredict),
		.out_branch_addr(out_branch_addr),
		.prediction(prediction)
		// Enable this line for simulation and checking
		// .selected_predictor(selected_predictor)
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
		mispredict = 0;
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
		// Check selected_predictor = 0 & prediction = 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		#2


		// With pc_branch_addr = 32'b0, selected_predictor = 0 (local)
		// Write actual_branch_decision = 1 and mispredict = 0
		// Next cycle:
		// curr_global_history = 00000001
		// tht[4'b0000] = 00
		// local_predictor[0000] = 11
		// global_predictor[00000000] = 11
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b1;
		mispredict = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		update_branch_addr = 32'b0;
		#2

		// Check pc_branch_addr = 32'b0 
		// tht[pc_branch_addr] = 00, 
		// check selected_predictor = 0 & prediction => local_predictor[0000]
		// = 11 => 1 
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		#2

		// With pc_branch_addr = 32'b0, selected_predictor = 0 (local)
		// Write actual_branch_decision = 0 and mispredict = 1
		// Next cycle:
		// curr_global_history = 00000010
		// tht[4'b0000] = 01
		// local_predictor[0000] = 10
		// global_predictor[000000001] = 10
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		mispredict = 1'b1;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		update_branch_addr = 32'b0;
		#2

		// Check pc_branch_addr = 32'b0 
		// tht[pc_branch_addr] = 01
		// check selected_predictor = 0 & prediction => local_predictor[0000]
		// = 10 => 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		#2

		// With pc_branch_addr = 32'b0, selected_predictor = 0 (local)
		// Write actual_branch_decision = 0 and mispredict = 1
		// Next cycle:
		// curr_global_history = 00000100
		// tht[4b'0000] = 10
		// local_predictor[0000] = 01
		// global_predictor[00000010] = 01
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		mispredict = 1'b1;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		update_branch_addr = 32'b0;
		#2

		// Check pc_branch_addr = 32'b0 
		// tht[pc_branch_addr] = 10
		// check selected_predictor = 1 & prediction =>
		// global_predictor[00000100] = 10 => 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		#2

		// With pc_branch_addr = 32'b0, selected_predictor = 1 (global)
		// Write actual_branch_decision = 0 and mispredict = 0
		// Next cycle:
		// curr_global_history = 00001000
		// tht[4b'0000] = 11
		// local_predictor[0000] = 00
		// global_predictor[00000100] = 01
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		mispredict = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		update_branch_addr = 32'b0;
		#2

		// Check pc_branch_addr = 32'b0 
		// tht[pc_branch_addr] = 11, 
		// check selected_predictor = 1 & prediction =>
		// global_predictor[00001000] = 10 => 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		#2

		// With pc_branch_addr = 32'b0, selected_predictor = 1 (global)
		// Write actual_branch_decision = 0 and mispredict = 0
		// Next cycle:
		// curr_global_history = 00010000
		// tht[4b'0000] = 11
		// local_predictor[0000] = 00
		// global_predictor[00001000] = 01
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		mispredict = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		update_branch_addr = 32'b0;
		#2

		// Check pc_branch_addr = 32'b0 
		// tht[pc_branch_addr] = 11, 
		// check selected_predictor = 1 & prediction =>
		// global_predictor[00010000] = 10 => 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b0;
		#2
		
		// Check the pc_branch_addr is used to index tht
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		update_branch_addr = 0;
		pc_branch_addr = 32'h00FFFFFF;
		#2
		// Check selected_predictor = 0 & prediction =>
		// local_predictor[4b'1111] = 10 => 1

		// End of test, reset everything to 0
		branch_decode_sig = 0;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		#5

	 	$finish;
	end

endmodule
