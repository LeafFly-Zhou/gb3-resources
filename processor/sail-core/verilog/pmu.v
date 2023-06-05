// power management unit

module pmu(fast_clk, clkhf_enable,clkhf_powerup,rdsp);
    input       fast_clk;
    input[31:0] rdsp;
    output      clkhf_enable;
    output      clkhf_powerup;
    
    integer     state=0;
    integer     instruction_state=0;

    //assign clkhf_powerup=(instruction_state==0);
    assign clkhf_powerup=1'b1;
    assign clkhf_enable=clkhf_powerup;
    //always@(posedge slow_clk) begin
    //    case(state)
    //    0:begin
    //        clkhf_enable <=1'b1;
    //        clkhf_powerup <=1'b1;
    //        state <=1;
    //    end
    //    1:begin
    //        clkhf_enable <=1'b1;
    //        clkhf_powerup <=1'b1;
    //        if(instruction_state==2) begin
    //            state <=2;
    //        end
    //    end
    //    2: begin
    //        clkhf_enable <=1'b1;
    //        clkhf_powerup <=1'b1;
    //    end
    //    endcase
    //end

    //always @(posedge fast_clk) begin
    //    if (rdsp==32'h1000 && instruction_state<2) begin
    //        instruction_state<=instruction_state+1;
    //    end
    //end
    

endmodule
