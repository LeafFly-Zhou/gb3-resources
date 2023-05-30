module data_mem_sim;
    reg 			clk;
	reg[31:0]		addr;
	reg[31:0]		write_data;
	reg 			memwrite;
	reg 			memread;
	reg[3:0]		sign_mask;
	wire[31:0]	read_data;
	wire[7:0]		led;
	wire		clk_stall;
    data_mem data_mem_inst(
        .clk(clk),
        .addr(addr),
        .write_data(write_data),
        .memwrite(memwrite),
        .memread(memread),
        .sign_mask(sign_mask),
        .read_data(read_data),
        .led(led),
        .clk_stall(clk_stall)
    );
    initial begin
        clk=0; addr=32'h1001;write_data=32'h1748;memwrite=1'b0;memread=1'b0;sign_mask=4'b0010;
        #1 clk=1;
        memread=1;
        #1 clk=0;
        memread=0;
        
        #1 clk=1;
        
        #1 clk=0;
        
        #1 clk=1;
        
        #1 clk=0;
        
        #1 clk=1;
        
        #1 clk=0;
        
        #1 clk=1;
        
        #1 clk=0;
        
        #1 clk=1;
        
        #1 clk=0;
        
        #1 clk=1;
        

    end
    initial begin
        $dumpfile("data_mem_sim.vcd");
        $dumpvars;
    end
endmodule