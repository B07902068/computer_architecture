module alu #(
    parameter DATA_WIDTH = 32,
    parameter INST_WIDTH = 4
)(
    input                   i_clk,
    input                   i_rst_n,
    input  [DATA_WIDTH-1:0] i_data_a,
    input  [DATA_WIDTH-1:0] i_data_b,
    input  [INST_WIDTH-1:0] i_inst,
    input                   i_valid,
    output [DATA_WIDTH-1:0] o_data,
    output                  o_overflow,
    output                  o_valid
);

    // homework

	//wires and register
    reg [DATA_WIDTH-1:0] o_data_r, o_data_w;
	reg 				 o_overflow_r, o_overflow_w;
	reg 				 o_valid_r, o_valid_w;

	reg signed [DATA_WIDTH-1:0] signed_data_a, signed_data_b;
	reg [2*DATA_WIDTH-1:0] product;
	reg signed [2 * DATA_WIDTH - 1:0] signed_product;
	integer i;
	

	//continuous assignment
	assign o_data = o_data_r;
	assign o_overflow = o_overflow_r;
	assign o_valid = o_valid_r;
	

	//combinational
	always @(*) begin
		if (i_valid) begin
			case(i_inst)
				4'd0: begin
					signed_data_a = i_data_a;
					signed_data_b = i_data_b;
					o_data_w = signed_data_a + signed_data_b;
					if (signed_data_a > 0 && signed_data_b > 0 && o_data_w[DATA_WIDTH-1] == 1) begin
						o_overflow_w = 1;
					end
					if (signed_data_a < 0 && signed_data_b < 0 && o_data_w[DATA_WIDTH-1] == 0) begin
						o_overflow_w = 1;
					end
					o_valid_w = 1;
				end
				4'd1: begin
					signed_data_a = i_data_a;
					signed_data_b = i_data_b;
					o_data_w = signed_data_a - signed_data_b;
					if (signed_data_a > 0 && signed_data_b < 0 && o_data_w[DATA_WIDTH-1] == 1) begin
						o_overflow_w = 1;
					end
					if (signed_data_a < 0 && signed_data_b > 0 && o_data_w[DATA_WIDTH-1] == 0) begin
						o_overflow_w = 1;
					end
					o_valid_w = 1;
				end
				4'd2: begin
					signed_data_a = i_data_a;
					signed_data_b = i_data_b;
					signed_product = signed_data_a * signed_data_b;
					o_data_w = signed_product[DATA_WIDTH-1:0];
					if (signed_product > 2147483647 || signed_product < -2147483648) begin
						o_overflow_w = 1;
					end
					o_valid_w = 1;
				end
				4'd3: begin
					signed_data_a = i_data_a;
					signed_data_b = i_data_b;
					if (signed_data_a > signed_data_b) begin
						o_data_w = signed_data_a;
					end else begin
						o_data_w = signed_data_b;
					end
					o_overflow_w = 0;
					o_valid_w = 1;
				end
				4'd4: begin
					signed_data_a = i_data_a;
					signed_data_b = i_data_b;
					if (signed_data_a < signed_data_b) begin
						o_data_w = signed_data_a;
					end else begin
						o_data_w = signed_data_b;
					end
					o_overflow_w = 0;
					o_valid_w = 1;
				end
				
				//		33bits						32bits	32bits
				4'd5: begin
					{o_overflow_w, o_data_w} = i_data_a + i_data_b;
					o_valid_w = 1;
				end
				4'd6: begin
					o_data_w = i_data_a - i_data_b;
					if (i_data_a < i_data_b) begin
						o_overflow_w = 1;
					end
					o_valid_w = 1;
				end
				4'd7: begin
					product = i_data_a * i_data_b;
					o_data_w = product[DATA_WIDTH-1:0];
					if (product >= 2**DATA_WIDTH) begin
						o_overflow_w = 1;
					end
					o_valid_w = 1;
				end
				4'd8: begin
					if (i_data_a > i_data_b) begin
						o_data_w = i_data_a;
					end else begin
						o_data_w = i_data_b;
					end
					o_overflow_w = 0;
					o_valid_w = 1;
				end
				4'd9: begin
					if (i_data_a < i_data_b) begin
						o_data_w = i_data_a;
					end else begin
						o_data_w = i_data_b;
					end
					o_overflow_w = 0;
					o_valid_w = 1;
				end
				4'd10: begin
					o_data_w = i_data_a & i_data_b;
					o_overflow_w = 0;
					o_valid_w = 1;
				end
				4'd11: begin
					o_data_w = i_data_a | i_data_b;
					o_overflow_w = 0;
					o_valid_w = 1;
				end
				4'd12: begin
					o_data_w = i_data_a ^ i_data_b;
					o_overflow_w = 0;
					o_valid_w = 1;
				end
				4'd13: begin
					o_data_w = ~i_data_a;
					o_overflow_w = 0;
					o_valid_w = 1;
				end
				4'd14: begin
					for (i = 0; i < DATA_WIDTH; i=i+1) begin
						o_data_w[i] = i_data_a[DATA_WIDTH-1-i];
					end
					o_overflow_w = 0;
					o_valid_w = 1;
				end
				default begin
					o_overflow_w = 0;
					o_data_w = 0;
					o_valid_w = 1;
				end
			endcase
		end else begin
			o_overflow_w = 0;
			o_data_w = 0;
			o_valid_w = 0;
		end	
	end

	//sequential
	always @(posedge i_clk or negedge i_rst_n) begin
		if (~i_rst_n) begin
			o_data_r <= 0;
			o_overflow_r <= 0;
			o_valid_r <= 0;
		end else begin
			o_data_r <= o_data_w;
			o_overflow_r <= o_overflow_w;
			o_valid_r <= o_valid_w;
		end
	end
endmodule
