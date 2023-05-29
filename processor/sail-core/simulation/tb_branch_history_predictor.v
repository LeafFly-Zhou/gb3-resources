module tb_branch_history_predictor();
	// Inputs
	reg clk = 0;
	reg [31:0] pc_branch_addr;
	reg [31:0] update_branch_addr;
	reg [31:0] offset;
	reg actual_branch_decision;
	reg branch_decode_sig;
	reg branch_mem_sig;
	
	// Outputs
	wire [31:0] out_branch_addr;
	wire prediction;
	wire [1:0] debug_output;
	wire [1:0] debug_output_2;

	branch_history_predictor bhp(
		.clk(clk),
		.actual_branch_decision(actual_branch_decision),
		.branch_decode_sig(branch_decode_sig),
		.branch_mem_sig(branch_mem_sig),
		.pc_branch_addr(pc_branch_addr),
		.offset(offset),
		.update_branch_addr(update_branch_addr),
		.out_branch_addr(out_branch_addr),
		.prediction(prediction),
		.debug_output(debug_output),
		.debug_output_2(debug_output_2)
	);


	//simulation
	always
	 #1 clk = ~clk;

	initial begin
		$dumpfile ("tb_branch_history_predictor.vcd");
	 	$dumpvars;
		
		// Initiliase inputs
		branch_decode_sig = 0;
		branch_mem_sig = 0;
		actual_branch_decision = 0;
		pc_branch_addr = 32'b0;
		offset = 32'b0;
		update_branch_addr = 32'b0;

	 	#5

		// Write
	 	// Increment update_branch_addr towards 11
		branch_decode_sig = 0;
	 	branch_mem_sig = 1;
		actual_branch_decision = 1'b1;
		update_branch_addr = 32'b01;

		#2

		// Read
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b01;


		#2
		// Write
	 	// Increment update_branch_addr towards 11
		branch_decode_sig = 0;
	 	branch_mem_sig = 1;
		actual_branch_decision = 1'b1;
		update_branch_addr = 32'b01;

		#2

		// Read
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b01;

		#2
		// Write
	 	// Increment update_branch_addr towards 11
		branch_decode_sig = 0;
	 	branch_mem_sig = 1;
		actual_branch_decision = 1'b1;
		update_branch_addr = 32'b01;

		#2

		// Read
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b01;

		#2

		// Write
		// Decrement update_branch_addr towards 00
		branch_decode_sig = 0;
	 	branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		update_branch_addr = 32'b01;

		#2

		// Read
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b01;


		#2
		// Write
		// Decrement update_branch_addr towards 00
		branch_decode_sig = 0;
	 	branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		update_branch_addr = 32'b01;

		#2

		// Read
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b01;


		#2
		// Write
		// Decrement update_branch_addr towards 00
		branch_decode_sig = 0;
	 	branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		update_branch_addr = 32'b01;

		#2

		// Read
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		offset = 32'b0;
		pc_branch_addr = 32'b01;

		// Test offset
	 	#6
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		pc_branch_addr = 32'b10;
		offset = 32'b01;

		#2
		// Decrement pc_branch_addr = 32'b10 and check prediction
		// Write
		branch_decode_sig = 0;
		branch_mem_sig = 1;
		actual_branch_decision = 1'b0;
		update_branch_addr = 32'b10;
		
		#2
		// Read
		branch_decode_sig = 1;
		branch_mem_sig = 0;
		actual_branch_decision = 1'b0;
		pc_branch_addr = 32'b10;
		offset = 0;
		
		#10

	 	$finish;
	end

endmodule
