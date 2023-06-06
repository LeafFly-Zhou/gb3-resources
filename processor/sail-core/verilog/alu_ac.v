/*
	Authored 2018-2019, Ryan Voo.

	All rights reserved.
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:

	*	Redistributions of source code must retain the above
		copyright notice, this list of conditions and the following
		disclaimer.

	*	Redistributions in binary form must reproduce the above
		copyright notice, this list of conditions and the following
		disclaimer in the documentation and/or other materials
		provided with the distribution.

	*	Neither the name of the author nor the names of its
		contributors may be used to endorse or promote products
		derived from this software without specific prior written
		permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/



`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"




/*
 *	Description:
 *
 *		This module implements the ALU for the RV32I.
 */



/*
 *	Not all instructions are fed to the ALU. As a result, the ALUctl
 *	field is only unique across the instructions that are actually
 *	fed to the ALU.
 */
 module alu(ALUctl, A, B, ALUOut, Branch_Enable, clk);
	input [6:0]		ALUctl;
	input [31:0]		A;
	input [31:0]		B;
	output reg [31:0]	ALUOut;
	output reg		Branch_Enable;
	input clk;
	/*
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
	initial begin
		ALUOut = 32'b0;
		Branch_Enable = 1'b0;
	end

	wire carry_add;
	wire cary_sub;
 	
	reg [15:0] dsp_c;
   	reg [15:0] dsp_a;
   	reg [15:0] dsp_b;
   	reg [15:0] dsp_d;

	wire [31:0] add_dsp_o;
	wire [31:0] sub_dsp_o;
	// For params, if all of them are ones or zeroes and I'm not changing this code, then I can't be asked to type out all the registers
	reg zero_reg = 1'b0;
	reg one_reg = 1'b1;

   	reg dsp_oloadtop;
   	reg dsp_oloadbot;
	reg dsp_co;
   	reg dsp_ci;
	//reg add_sub_toggle;
	// You COULD use this such that only one DSP need be used by Yosus, but it'd be another challenege to impl. 

	SB_MAC16 add_dsp
	( // port interfaces 
	.A(dsp_a),
	.B(dsp_b), 
	.C(dsp_c), 
	.D(dsp_d), 
	.O(add_dsp_o), 
	.CLK(clk), 
	.CE(one_reg), 
	.IRSTTOP(zero_reg),
	.IRSTBOT(zero_reg),
	.ORSTTOP(zero_reg),
	.ORSTBOT(zero_reg),
	.AHOLD(zero_reg),
	.BHOLD(zero_reg),
	.CHOLD(zero_reg),
	.DHOLD(zero_reg),
	.OHOLDTOP(zero_reg), 
	.OHOLDBOT(zero_reg), 
	.OLOADTOP(zero_reg),
	.OLOADBOT(zero_reg),
	.ADDSUBTOP(zero_reg), 
	.ADDSUBBOT(zero_reg), 
	.CO(carry_add), 
	.CI(zero_reg), 
	.ACCUMCI(), 
	.ACCUMCO(), 
	.SIGNEXTIN(), 
	.SIGNEXTOUT() 
	// If these values are zero, then you can define zero_reg, and have all these ports be equal to zero_reg. Or one_reg
	); 
	defparam add_dsp.NEG_TRIGGER = 1'b0; 
	defparam add_dsp.C_REG = 1'b0; 
	defparam add_dsp.A_REG = 1'b0; 
	defparam add_dsp.B_REG = 1'b0; 
	defparam add_dsp.D_REG = 1'b0; 
	defparam add_dsp.TOP_8x8_MULT_REG = 1'b0; 
	defparam add_dsp.BOT_8x8_MULT_REG = 1'b0; 
	defparam add_dsp.PIPELINE_16x16_MULT_REG1 = 1'b0; 
	defparam add_dsp.PIPELINE_16x16_MULT_REG2 = 1'b0; 
	defparam add_dsp.TOPOUTPUT_SELECT = 2'b00; // accum register output at O[31:16] ac - b01  
	defparam add_dsp.TOPADDSUB_LOWERINPUT = 2'b00; 
	defparam add_dsp.TOPADDSUB_UPPERINPUT = 1'b1; 
	defparam add_dsp.TOPADDSUB_CARRYSELECT = 2'b10;  // ac - b11
	defparam add_dsp.BOTOUTPUT_SELECT = 2'b00; // accum regsiter output at O[15:0] // ac - b01 
	defparam add_dsp.BOTADDSUB_LOWERINPUT = 2'b00; 
	defparam add_dsp.BOTADDSUB_UPPERINPUT = 1'b1; 
	defparam add_dsp.BOTADDSUB_CARRYSELECT = 2'b00; //bottom adder carry input 00 -> const 0 
	defparam add_dsp.MODE_8x8 = 1'b0; // ac- 0 
	defparam add_dsp.A_SIGNED = 1'b1; 
	defparam add_dsp.B_SIGNED = 1'b1;

	//defparam add_dsp.BOTOUTPUT_SELECT = 2'b01 ;// accum regsiter output at O[15:0]. 
	//defparam add_dsp.TOPOUTPUT_SELECT = 2'b01 ;// accum register output at O[31:16] 

	SB_MAC16 sub_dsp
	( // port interfaces 
	.A(dsp_a),
	.B(dsp_b), 
	.C(dsp_c), 
	.D(dsp_d), 
	.O(add_dsp_o), 
	.CLK(clk), 
	.CE(one_reg), 
	.IRSTTOP(zero_reg),
	.IRSTBOT(zero_reg),
	.ORSTTOP(zero_reg),
	.ORSTBOT(zero_reg),
	.AHOLD(zero_reg),
	.BHOLD(zero_reg),
	.CHOLD(zero_reg),
	.DHOLD(zero_reg),
	.OHOLDTOP(zero_reg), 
	.OHOLDBOT(zero_reg), 
	.OLOADTOP(zero_reg),
	.OLOADBOT(zero_reg),
	.ADDSUBTOP(one_reg), 
	.ADDSUBBOT(one_reg), 
	.CO(carry_sub), 
	.CI(zero_reg), 
	.ACCUMCI(), 
	.ACCUMCO(), 
	.SIGNEXTIN(), 
	.SIGNEXTOUT() 
	); 

	defparam sub_dsp.NEG_TRIGGER = 1'b0; 
	defparam sub_dsp.C_REG = 1'b0; 
	defparam sub_dsp.A_REG = 1'b0; 
	defparam sub_dsp.B_REG = 1'b0; 
	defparam sub_dsp.D_REG = 1'b0; 
	defparam sub_dsp.TOP_8x8_MULT_REG = 1'b0; 
	defparam sub_dsp.BOT_8x8_MULT_REG = 1'b0; 
	defparam sub_dsp.PIPELINE_16x16_MULT_REG1 = 1'b0; 
	defparam sub_dsp.PIPELINE_16x16_MULT_REG2 = 1'b0; 
	defparam sub_dsp.TOPOUTPUT_SELECT = 2'b00; // accum register output at O[31:16] 
	defparam sub_dsp.TOPADDSUB_LOWERINPUT = 2'b00; 
	defparam sub_dsp.TOPADDSUB_UPPERINPUT = 1'b1; 
	defparam sub_dsp.TOPADDSUB_CARRYSELECT = 2'b10; // Docs say this should be 11, apparently acc needs to bee 10
	defparam sub_dsp.BOTOUTPUT_SELECT = 2'b00; // accum regsiter output at O[15:0] 
	defparam sub_dsp.BOTADDSUB_LOWERINPUT = 2'b00; 
	defparam sub_dsp.BOTADDSUB_UPPERINPUT = 1'b1; 
	defparam sub_dsp.BOTADDSUB_CARRYSELECT = 2'b00; //bottom adder carry input 00 -> const 0 
	defparam sub_dsp.MODE_8x8 = 1'b0; 
	defparam sub_dsp.A_SIGNED = 1'b1; 
	defparam sub_dsp.B_SIGNED = 1'b1;
	/*
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
	 
	always @(ALUctl, A, B) begin
		dsp_a <= A[31:16];
		dsp_b <= A[15:0];
		dsp_c <= B[31:16];
		dsp_d <= B[15:0];
		case (ALUctl[3:0])
			/*
			 *	AND (the fields also match ANDI and LUI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:	ALUOut = A & B;

			/*
			 *	OR (the fields also match ORI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:	ALUOut = A | B;

			/*
			 *	ADD (the fields also match AUIPC, all loads, all stores, and ADDI)
			 */
			//`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:	ALUOut = A + B;
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:	ALUOut = add_dsp_o;

			/*
			 *	SUBTRACT (the fields also matches all branches)
			 */
			//`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:	ALUOut = A - B;
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:	ALUOut = sub_dsp_o;

			/*
			 *	SLT (the fields also matches all the other SLT variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:	ALUOut = $signed(A) < $signed(B) ? 32'b1 : 32'b0;

			/*
			 *	SRL (the fields also matches the other SRL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:	ALUOut = A >> B[4:0];

			/*
			 *	SRA (the fields also matches the other SRA variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:	ALUOut = $signed(A) >>> B[4:0];

			/*
			 *	SLL (the fields also match the other SLL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:	ALUOut = A << B[4:0];

			/*
			 *	XOR (the fields also match other XOR variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:	ALUOut = A ^ B;

			/*
			 *	CSRRW  only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:	ALUOut = A;

			/*
			 *	CSRRS only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:	ALUOut = A | B;

			/*
			 *	CSRRC only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC:	ALUOut = (~A) & B;

			/*
			 *	Should never happen.
			 */
			default:					ALUOut = 0;
		endcase
	end

	always @(ALUctl, ALUOut, A, B) begin
		case (ALUctl[6:4])
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:	Branch_Enable = (ALUOut == 0);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:	Branch_Enable = !(ALUOut == 0);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:	Branch_Enable = ($signed(A) < $signed(B));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:	Branch_Enable = ($signed(A) >= $signed(B));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU:	Branch_Enable = ($unsigned(A) < $unsigned(B));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU:	Branch_Enable = ($unsigned(A) >= $unsigned(B));
			//Change to make these functions use the DSP
			//`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU:	Branch_Enable = (sub_dsp_o < 0);
			//`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU:	Branch_Enable = (sub_dsp_o > 0);

			default:					Branch_Enable = 1'b0;
		endcase
	end
 endmodule

