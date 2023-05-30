// power management unit

module pmu(slow_clk,fast_clk, clkhf_enable,clkhf_powerup,rdsp);
    input       slow_clk;
    input       fast_clk;
    input[31:0] rdsp;
    output reg  clkhf_enable;
    output reg  clkhf_powerup;
    
    integer state=0;
    integer idle_count=0;
    integer     instruction_state=0;

    always@(posedge slow_clk) begin
        case(state)
        0:begin
            state <=1;
            clkhf_enable <=1'b1;
            clkhf_powerup <=1'b1;
        end
        1:begin
            if(instruction_state==2) begin
                state <=2;
            end
        end
        2: begin
            clkhf_enable <=1'b0;
            clkhf_powerup <=1'b0;
        end
        endcase
    end

    always @(posedge fast_clk) begin
        if (rdsp==32'h1000 && instruction_state<2) begin
            instruction_state<=instruction_state+1;
        end
    end
    

endmodule