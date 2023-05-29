module tb_global_history_predictor();
	// Inputs
	reg clk = 0;
	reg [31:0] pc_branch_addr;
	reg [31:0] offset;
	reg actual_branch_decision;
	reg branch_decode_sig;
	reg branch_mem_sig;
	
	// Outputs
	wire [31:0] out_branch_addr;
	wire prediction;
	// wire [7:0] debug_output;
	// wire [1:0] debug_output_2;

	global_history_predictor ghp(
		.clk(clk),
		.actual_branch_decision(actual_branch_decision),
		.branch_decode_sig(branch_decode_sig),
		.branch_mem_sig(branch_mem_sig),
		.pc_branch_addr(pc_branch_addr),
		.offset(offset),
		.out_branch_addr(out_branch_addr),
		.prediction(prediction)
		// .debug_output(debug_output)
		// .debug_output_2(debug_output_2)
	);


	//simulation
	always
	 #1 clk = ~clk;

	initial begin
		$dumpfile ("tb_global_history_predictor.vcd");
	 	$dumpvars;
		
		// Initialise inputs
		branch_decode_sig = 0;
		branch_mem_sig = 0;
		actual_branch_decision = 0;
		pc_branch_addr = 32'b0;
		offset = 32'b0;
	 	#5

		// Check initial prediction, prediction = HIGH
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		#2

		// Check offset 1, out_branch_addr = 32'h00FFFFFF
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		offset = 32'hFFFFFF;
		pc_branch_addr = 32'h0;
		#2

		//Check offset 2, out_branch_addr = 32'h0000000A
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		offset = 32'b111;
		pc_branch_addr = 32'b011;
		#2

		// Write actual_branch_prediction = 0 to 00000000
		// and set curr_global_history = 00000000
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		#2

		// Check the prediction for 00000000 is LOW as 
		// saturaing counter should be at 01
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		#2

		// Write actual_branch_prediction = 0 to 00000000
		// and set curr_global_history = 00000000
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b0;
		#2

		// Check the prediction for 00000000 is LOW as 
		// saturaing counter should be at 00
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		#2

		// The curr_global_history is now at 00000000
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		// Check that prediction is LOW again, same as last test 
		#2

		// Write a actual_branch_decision = 1 to 00000000
		// to set curr_global_history = 00000001
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b1;
		// curr_global_history = 00000001

		#2
		// Check the prediction for 0000001 is still 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		// Prediction should be HIGH
		#2

		// Write an actual_branch_decision = 0 to 00000001 to
		// set curr_global_history to 00000010
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		#2
		
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		// 00000010 should have prediction = HIGH	
		#2

		// Write an actual_branch_decision = 0 to 00000010 to
		// set curr_global_history = 00000100
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		// curr_global_history = 00000100
		#2
		
		// Check that 00000100 should still have prediction = 1
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		#2

		// Write an actual_branch_decision = 0 to 00000100 to
		// set curr_global_history = 00001000
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		#2

		// Check that prediction for 00001000 is still 1 
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		#2

		// Write an actual_branch_decision = 0 to 00001000 to
		// set curr_global_history = 00010000
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		#2

		// Check that prediction for 000010000 is still 1 
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		#2

		// Write an actual_branch_decision = 0 to 00010000 to
		// set curr_global_history = 00100000
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		#2

		// Check that prediction for 00100000 is still 1 
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		#2

		// Write an actual_branch_decision = 0 to 00100000 to
		// set curr_global_history = 01000000
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		#2

		// Check that prediction for 01000000 is still 1 
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		#2

		// Write an actual_branch_decision = 0 to 01000000 to
		// set curr_global_history = 10000000
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		#2

		// Check that prediction for 10000000 is still 1 
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		#2

		// Write an actual_branch_decision = 0 to 10000000 to
		// set curr_global_history = 00000000
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		#2

		// Check that prediction for 00000000 is still 0 
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		#2
		
		// Write an actual_branch_decision = 1 to 00000000 to
		// set curr_global_history = 00000001
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b1;
		#2

		// Check that prediction for 00000001 is 0
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		#2
		
		// Write an actual_branch_decision = 0 to 00000001 to
		// set curr_global_history = 00000010
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		#2

		// Check that prediction for 00000010 is 0
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		#2
		
		// End of test, reset everything to 0
		branch_decode_sig = 0;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		#5

	 	$finish;
	end

endmodule
