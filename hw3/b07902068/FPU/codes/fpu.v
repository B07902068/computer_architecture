module fpu #(
    parameter DATA_WIDTH = 32,
    parameter INST_WIDTH = 1
)(
    input                   i_clk,
    input                   i_rst_n,
    input  [DATA_WIDTH-1:0] i_data_a,
    input  [DATA_WIDTH-1:0] i_data_b,
    input  [INST_WIDTH-1:0] i_inst,
    input                   i_valid,
    output [DATA_WIDTH-1:0] o_data,
    output                  o_valid
);

    // homework
	//wires and register
    reg [DATA_WIDTH-1:0] o_data_r, o_data_w;
	reg 				 o_valid_r, o_valid_w;

	wire [8:0]			exp_diff;
	wire 				sel_exp;
	wire				sel_frac1;
	wire				sel_frac2;
	wire [7:0]			sr_num;
	wire 				sel_alu_round;

	wire [7:0]			big_exp;
	
	wire [22:0]			i_sr;
	wire [22:0]			i_pad;

	wire 				alu_sign_a;
	wire 				alu_sign_b;
	wire [49:0]				i_alu_1;
	wire [49:0] 			i_alu_2;	

	wire [49:0]			sum;
	wire [49:0]			round_result;
	wire [7:0]			increment;
	wire 				final_sign;
	wire [7:0]			r_exp;
	wire [7:0]			i_rexp;
	wire [7:0] 			i_inc_dec;
	wire [49:0]			i_lr;
	wire [49:0]			i_round;

	wire [7:0]		exp_mul;
	wire [49:0]		mul_result;
	wire [49:0]			mul_round_result;
	wire [7:0]			mul_increment;
	wire 				mul_final_sign;
	wire [7:0]			mul_r_exp;
	wire [7:0]			mul_i_rexp;
	wire [7:0] 			mul_i_inc_dec;
	wire [49:0]			mul_i_lr;
	wire [49:0]			mul_i_round;
	wire 				mul_sel_alu_round;

	//reg alu_or_round;


	//continuous assignment
	assign o_data = o_data_r;
	assign o_valid = o_valid_r;




	//combinational
	control #(
		.DATA_WIDTH(32)
	) u_control (
		.i_clk(i_clk),
		.exp_diff(exp_diff),
		.big_alu_result(sum),
		.round_result(round_result),
		//.rounding(round_signal),
		.sel_exp(sel_exp),
		.sel_frac1(sel_frac1),
		.sel_frac2(sel_frac2),
		.sr_num(sr_num),
		.sel_alu_round(sel_alu_round),
		.increment(increment),
		.final_sign(final_sign)
	);

	small_alu #(
		.DATA_WIDTH(8)
	) s_alu (
		.i_data_a(i_data_a[30:23]),
		.i_data_b(i_data_b[30:23]),
		.o_data(exp_diff)
	);

	mux #(
		.DATA_WIDTH(8)
	) exp_mux (
		.i_data_a(i_data_a[30:23]),
		.i_data_b(i_data_b[30:23]),
		.select(sel_exp),
		.o_data(big_exp)
	);
	mux #(
		.DATA_WIDTH(23)
	) frac1_mux (
		.sign_a(i_data_a[31]),
		.sign_b(i_data_b[31]),
		.i_data_a(i_data_a[22:0]),
		.i_data_b(i_data_b[22:0]),
		.select(sel_frac1),
		.o_data(i_sr),
		.o_sign(alu_sign_a)
	);
	mux #(
		.DATA_WIDTH(23)
	) frac2_mux (
		.sign_a(i_data_a[31]),
		.sign_b(i_data_b[31]),
		.i_data_a(i_data_a[22:0]),
		.i_data_b(i_data_b[22:0]),
		.select(sel_frac2),
		.o_data(i_pad),
		.o_sign(alu_sign_b)
	);

	pad #(
		.DATA_WIDTH(23)
	) pad_i (
		.i_data(i_pad),
		.o_data(i_alu_2)
	);
	
	shift_right #(
		.DATA_WIDTH(23)
	) sright (
		.shift_num(sr_num),
		.i_data(i_sr),
		.o_data(i_alu_1)
	);

	big_alu #(
		.DATA_WIDTH(50)
	) frac_alu (
		.sign_a(alu_sign_a),
		.sign_b(alu_sign_b),
		.i_data_a(i_alu_1),
		.i_data_b(i_alu_2),
		.o_data(sum)
	);

	mux #(
		.DATA_WIDTH(50)
	) alu_round_mux (
		.i_data_a(sum),
		.i_data_b(round_result),
		.select(sel_alu_round),
		.o_data(i_lr)
	);
	mux #(
		.DATA_WIDTH(8)
	) rexp_mux (
		.i_data_a(big_exp),
		.i_data_b(r_exp),
		.select(sel_alu_round),
		.o_data(i_inc_dec)
	);

	inc_or_dec #(
		.DATA_WIDTH(8)
	) inc (
		.increment(increment),
		.i_data(i_inc_dec),
		.o_data(i_rexp)
	);

	left_or_right #(
		.DATA_WIDTH(50)
	) lr (
		.increment(increment),
		.i_data(i_lr),
		.o_data(i_round)
	);

	rounding #(
		.DATA_WIDTH(50)
	) u_round (
		.i_exp(i_rexp),
		.i_data(i_round),
		.o_data(round_result),
		.r_exp(r_exp)
	);


	exp_adder #(
		.DATA_WIDTH(8)
	) add_exp (
		.i_data_a(i_data_a[30:23]),
		.i_data_b(i_data_b[30:23]),
		.o_data(exp_mul)
	);

	multiply #(
		.DATA_WIDTH(23)
	) frac_mul (
		.i_data_a(i_data_a[22:0]),
		.i_data_b(i_data_b[22:0]),
		.o_data(mul_result)
	);

	mux #(
		.DATA_WIDTH(50)
	) mul_round_mux (
		.i_data_a(mul_result),
		.i_data_b(round_result),
		.select(sel_alu_round),
		.o_data(mul_i_lr)
	);
	mux #(
		.DATA_WIDTH(8)
	) mul_rexp_mux (
		.i_data_a(exp_mul),
		.i_data_b(mul_r_exp),
		.select(mul_sel_alu_round),
		.o_data(mul_i_inc_dec)
	);

	inc_or_dec #(
		.DATA_WIDTH(8)
	) inc_mul (
		.increment(mul_increment),
		.i_data(mul_i_inc_dec),
		.o_data(mul_i_rexp)
	);

	left_or_right #(
		.DATA_WIDTH(50)
	) lr_mul (
		.increment(mul_increment),
		.i_data(mul_i_lr),
		.o_data(mul_i_round)
	);

	rounding #(
		.DATA_WIDTH(50)
	) u_round_mul (
		.i_exp(mul_i_rexp),
		.i_data(mul_i_round),
		.o_data(mul_round_result),
		.r_exp(mul_r_exp)
	);
	multiply_control #(
		.DATA_WIDTH(32)
	) mul_control (
		.a_sign(i_data_a[31]),
		.b_sign(i_data_b[31]),
		.mul_result(mul_result),
		.round_result(mul_round_result),
		.sel_alu_round(mul_sel_alu_round),
		.increment(mul_increment),
		.final_sign(mul_final_sign)
	);
	//assign o_data_w[31] = sum[49];
	//assign o_data_w[30:23] = big;
	//assign o_data_w[22:0] = sum[45:23];
	always @(*) begin
		if (i_valid) begin
			case(i_inst)
				1'd0: begin
					o_data_w[31] = final_sign;
					o_data_w[30:23] = r_exp;
					o_data_w[22:0] = round_result[45:23];
					o_valid_w = 1;
					//$monitor("%x\n", sum);
				end
				1'd1: begin
					o_data_w[31] = mul_final_sign;
					o_data_w[30:23] = mul_r_exp;
					o_data_w[22:0] = mul_round_result[45:23];
					o_valid_w = 1;
				end
				default begin
					o_data_w = 0;
					o_valid_w = 1;
				end
			endcase
		end else begin
			o_data_w = 0;
			o_valid_w = 0;
		end	
	end
    
	//sequential
	always @(posedge i_clk or negedge i_rst_n) begin
		if (~i_rst_n) begin
			o_data_r <= 0;
			o_valid_r <= 0;
		end else begin
			o_data_r <= o_data_w;
			o_valid_r <= o_valid_w;
		end
	end
endmodule

module mux #(
	parameter DATA_WIDTH = 32
)(
	input 				sign_a,
	input 				sign_b,
	input 					select,
	input  [DATA_WIDTH-1:0] i_data_a,
    input  [DATA_WIDTH-1:0] i_data_b,
	output [DATA_WIDTH-1:0] o_data,
	output  				o_sign
);
	reg [DATA_WIDTH-1:0] o_data_r;
	reg sel;
	reg o_sign_r;
	
	assign o_data = o_data_r;
	assign o_sign = o_sign_r;

	always @(*) begin
		sel = select;
		if (sel == 0) begin
			o_data_r = i_data_a;
			o_sign_r = sign_a;
		end else begin
			o_data_r = i_data_b;
			o_sign_r = sign_b;
		end
	end

endmodule

module control #(
	parameter DATA_WIDTH = 32
)(
	input        i_clk,
	input [8:0] exp_diff,
	input [49:0] big_alu_result,
	input [49:0] round_result,
	//input rounding,
	output sel_exp,
	output sel_frac1,
	output sel_frac2,
	output [7:0] sr_num,
	output sel_alu_round,
	output [7:0] increment,
	output final_sign
	//output [49:0] abso_alu_sum
	
);
	reg [7:0] sr_num_r;
	reg signed [8:0] exp_diff_r;
	reg signed [8:0] diff_r;
	reg sel_exp_r, sel_frac1_r, sel_alu_round_r;
	reg signed [49:0] big_alu_result_r;
	reg [49:0] round_result_r;
	reg final_sign_r;
	reg signed [7:0] increment_r;
	reg signed [49:0] last_alu_result_r;
	reg flag;

	integer i;

	assign sr_num = sr_num_r;
	assign sel_exp = sel_exp_r;
	assign sel_frac1 = sel_frac1_r;
	assign sel_frac2 = ~sel_frac1_r;
	assign sel_alu_round = sel_alu_round_r;
	assign final_sign = final_sign_r;
	assign increment = increment_r;

	always @(*) begin
		exp_diff_r = exp_diff;
		big_alu_result_r = big_alu_result;
		round_result_r = round_result;
		if (exp_diff_r > 0) begin
			sel_exp_r = 0;
			sel_frac1_r = 1;
			sr_num_r = exp_diff_r[7:0];
		end	else begin
			sel_exp_r = 1;
			sel_frac1_r = 0;
			diff_r = -exp_diff_r;
			sr_num_r = diff_r[7:0];
		end
		//if (round_result_r[47] === 1'bx || last_alu_result_r !== big_alu_result_r) begin
		//if (flag == 0) begin
		//if (last_alu_result_r !== big_alu_result_r) begin
		//	last_alu_result_r = big_alu_result_r;
			sel_alu_round_r = 0;
			if (big_alu_result_r >= 0) begin
				final_sign_r = 0;				
			end else begin
				final_sign_r = 1;
				big_alu_result_r = -big_alu_result_r;
			end
			if (big_alu_result_r[47]) begin
				increment_r = 1;
			end else begin
				if (big_alu_result_r[46] == 0) begin
					increment_r = -1;
					for (i = 45; i >= 0 && big_alu_result_r[i] == 0; i = i - 1) begin
						increment_r = increment_r - 1;
					end
					
				end else begin
					increment_r = 0;
				end
			end
		/*end else begin
			sel_alu_round_r = 1;
			if (round_result_r[47]) begin
				increment_r = 1;
			end else begin
				if (round_result_r[46] == 0) begin
					increment_r = -1;
					for (i = 45; i >= 0 && round_result_r[i] == 0; i = i - 1) begin
						increment_r = increment_r - 1;
					end
					
				end else begin
					increment_r = 0;
				end
			end
		end*/
	end
endmodule

module small_alu #(
	parameter DATA_WIDTH = 8
)(
	input  [DATA_WIDTH-1:0] i_data_a,
    input  [DATA_WIDTH-1:0] i_data_b,
	output [DATA_WIDTH:0] o_data
);
	reg [DATA_WIDTH:0] o_data_r;
	reg signed [DATA_WIDTH:0] signed_data_a;
	reg signed [DATA_WIDTH:0] signed_data_b;


	assign o_data = o_data_r;

	always @(*) begin
		signed_data_a = 0;
		signed_data_b = 0;
		signed_data_a[DATA_WIDTH-1:0] = i_data_a;
		signed_data_b[DATA_WIDTH-1:0] = i_data_b;
		o_data_r = signed_data_a - signed_data_b;
	end
endmodule

module shift_right #(
	parameter DATA_WIDTH = 23
)(
	input  [7:0]			shift_num,
	input  [DATA_WIDTH-1:0] i_data,
	output [49:0] o_data
);
	reg [49:0] o_data_r;
	reg [7:0]			shift_nr;
	
	assign o_data = o_data_r;

	always @(*) begin
		o_data_r = 0;
		shift_nr = shift_num;
		o_data_r[46] = 1;
		o_data_r[45:23] = i_data;
		o_data_r = o_data_r >> shift_nr;		
	end

endmodule

module pad #(
	parameter DATA_WIDTH = 23
)(
	input  [DATA_WIDTH-1:0] i_data,
	output [49:0] o_data
);
	reg [49:0] o_data_r;
	
	assign o_data = o_data_r;

	always @(*) begin
		o_data_r = 0;
		o_data_r[46] = 1;
		o_data_r[45:23] = i_data;		
	end
endmodule

module big_alu #(
	parameter DATA_WIDTH = 50
)(
	input sign_a,
	input sign_b,
	input  [DATA_WIDTH-1:0] i_data_a,
    input  [DATA_WIDTH-1:0] i_data_b,
	output [DATA_WIDTH-1:0] o_data
);
	reg signed [DATA_WIDTH-1:0] o_data_r;
	reg signed [DATA_WIDTH-1:0] signed_data_a;
	reg signed [DATA_WIDTH-1:0] signed_data_b;
	


	assign o_data = o_data_r;

	always @(*) begin
		signed_data_a = i_data_a;
		signed_data_b = i_data_b;
		if (sign_a) begin
			signed_data_a = -signed_data_a;
		end
		if (sign_b) begin
			signed_data_b = -signed_data_b;
		end
		o_data_r = signed_data_a + signed_data_b;
	end
endmodule

module left_or_right #(
	parameter DATA_WIDTH = 50
)(
	input [7:0] increment,
	input  [DATA_WIDTH-1:0] i_data,
	output [DATA_WIDTH-1:0] o_data
);
	reg [DATA_WIDTH-1:0] o_data_r;
	reg signed [DATA_WIDTH-1:0] i_data_r;
	reg signed [7:0] increment_r;

	assign o_data = o_data_r;

	always @(*) begin
		i_data_r = i_data;
		if (i_data_r < 0) begin 
			i_data_r = -i_data_r;
		end
		increment_r = increment;
		if (increment_r > 0) begin
			o_data_r = i_data_r >> increment;
		end else begin
			o_data_r = i_data_r << increment;
		end
	end

endmodule

module inc_or_dec #(
	parameter DATA_WIDTH = 8
)(
	input	[7:0] increment,
	input  [DATA_WIDTH-1:0] i_data,
	output [DATA_WIDTH-1:0] o_data
);
	reg [DATA_WIDTH-1:0] o_data_r;
	reg [DATA_WIDTH-1:0] i_data_r;
	reg signed [7:0] increment_r;

	assign o_data = o_data_r;

	always @(*) begin
		i_data_r = i_data;
		increment_r = increment;
		o_data_r = i_data_r + increment_r;
	end

endmodule

module rounding #(
	parameter DATA_WIDTH = 50
)(
	input [7:0]	i_exp,
	input  [DATA_WIDTH-1:0] i_data,
	output [DATA_WIDTH-1:0] o_data,
	output [7:0] r_exp
);
	reg [DATA_WIDTH-1:0] o_data_r;
	reg [DATA_WIDTH-1:0] i_data_r;
	reg [21:0] S;
	reg R;
	reg [49:0] I;

	assign o_data = o_data_r;
	assign r_exp = i_exp;

	always @(*) begin
		o_data_r = 0;
		i_data_r = i_data;
		R = i_data_r[22];
		S = i_data_r[21:0];
		o_data_r[49:23] = i_data_r[49:23];
		I = 0;
		I[23] = 1;
		if (R == 1 && S > 1) begin
			o_data_r = o_data_r + I;
		end else if (R == 1 && S == 0) begin
			if (i_data_r[23] == 1) begin
				o_data_r = o_data_r + I;
			end
		end
	end

endmodule

module exp_adder #(
	parameter DATA_WIDTH = 8
)(
	input  [DATA_WIDTH-1:0] i_data_a,
    input  [DATA_WIDTH-1:0] i_data_b,
	output [DATA_WIDTH-1:0] o_data
);
	reg [DATA_WIDTH:0] o_data_r;
	reg [DATA_WIDTH:0] i_a_r;
	reg [DATA_WIDTH:0] i_b_r;

	assign o_data = o_data_r[DATA_WIDTH-1:0];

	always @(*) begin
		i_a_r = 0;
		i_b_r = 0;
		i_a_r[DATA_WIDTH-1:0] = i_data_a;
		i_b_r[DATA_WIDTH-1:0] = i_data_b;
		o_data_r = i_a_r + i_b_r - 127;
	end

endmodule

module multiply #(
	parameter DATA_WIDTH = 23
)(
	input  [DATA_WIDTH-1:0] i_data_a,
    input  [DATA_WIDTH-1:0] i_data_b,
	output [49:0] o_data
);
	reg [49:0] o_data_r;
	reg [49:0] i_a_r;
	reg [49:0] i_b_r;

	assign o_data = o_data_r;

	always @(*) begin
		i_a_r = 0;
		i_b_r = 0;
		i_a_r[23] = 1;
		i_b_r[23] = 1;
		i_a_r[22:0] = i_data_a;
		i_b_r[22:0] = i_data_b;
		o_data_r = i_a_r * i_b_r;
	end

endmodule

module multiply_control #(
	parameter DATA_WIDTH = 32
)(
	input a_sign,
	input b_sign,
	input [49:0] mul_result,
	input [49:0] round_result,
	output sel_alu_round,
	output [7:0] increment,
	output final_sign
	
);
	reg sel_alu_round_r;
	reg [49:0] mul_result_r;
	reg [49:0] round_result_r;
	reg final_sign_r;
	reg signed [7:0] increment_r;

	reg signed [49:0] last_alu_result_r;
	reg flag;

	integer i;

	assign sel_alu_round = sel_alu_round_r;
	assign final_sign = final_sign_r;
	assign increment = increment_r;

	always @(*) begin
		mul_result_r = mul_result;
		round_result_r = round_result;
		final_sign_r = a_sign ^ b_sign;
		
		//if (round_result_r[47] === 1'bx || last_alu_result_r !== big_alu_result_r) begin
		//if (flag == 0) begin
		//if (last_alu_result_r !== big_alu_result_r) begin
		//	last_alu_result_r = big_alu_result_r;
			sel_alu_round_r = 0;
			
			if (mul_result_r[47]) begin
				increment_r = 1;
			end else begin
				if (mul_result_r[46] == 0) begin
					increment_r = -1;
					for (i = 45; i >= 0 && mul_result_r[i] == 0; i = i - 1) begin
						increment_r = increment_r - 1;
					end
					
				end else begin
					increment_r = 0;
				end
			end
		/*end else begin
			sel_alu_round_r = 1;
			if (round_result_r[47]) begin
				increment_r = 1;
			end else begin
				if (round_result_r[46] == 0) begin
					increment_r = -1;
					for (i = 45; i >= 0 && round_result_r[i] == 0; i = i - 1) begin
						increment_r = increment_r - 1;
					end
					
				end else begin
					increment_r = 0;
				end
			end
		end*/
	end
endmodule













