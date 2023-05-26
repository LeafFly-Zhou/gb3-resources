
module gatedclk(clk, enable, gclk);
    input clk;
    input enable;
    output wire gclk;
    wire latched1;
    wire latched2;
    SB_DFF SB_DFF_inst1(
        .Q(latched1),
        .C(clk),
        .D(enable)
    );
    SB_DFF SB_DFF_inst2(
        .Q(latched2),
        .C(clk),
        .D(latched1)
    );
    assign gclk = (latched1 | latched2) & clk;
endmodule