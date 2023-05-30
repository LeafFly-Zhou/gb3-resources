`timescale 1ns/1ns

module gated_clk_sim;
    reg clk_sig, enable_sig;
    wire gated_clk_sig;
    GatedClk gated_clk_inst(
        .clk(clk_sig),
        .enable(enable_sig),
        .gated_clk(gated_clk_sig)
    );
    initial begin
        #1 clk_sig=0; 
        #1 enable_sig=0;
        #1 clk_sig=1;
        #1
        #1 clk_sig=0;
        #1
        #1 clk_sig=1; 
        #1 enable_sig=1;
        #1 clk_sig=0;
        #1
        #1 clk_sig=1;
        #1
        #1 clk_sig=0; enable_sig=0;
        #1
        #1 clk_sig=1;
        #1
        #1 clk_sig=0;enable_sig=1;
        #1
        #1 clk_sig=1;
        #1
        #1 clk_sig=0;
        #1
        #1 clk_sig=1; 
        #1
        #1 clk_sig=0; 
        #1
        #1 clk_sig=1;enable_sig=0;
        #1
        #1 clk_sig=0;
        #1
        #1 clk_sig=1; 
    end
    initial begin
        $dumpfile("gated_clk_sim.vcd");
        $dumpvars;
    end
endmodule