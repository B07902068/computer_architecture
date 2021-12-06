module cpu #( // Do not modify interface
	parameter ADDR_W = 64,
	parameter INST_W = 32,
	parameter DATA_W = 64
)(
    input                   i_clk,
    input                   i_rst_n,
    input                   i_i_valid_inst, // from instruction memory
    input  [ INST_W-1 : 0 ] i_i_inst,       // from instruction memory
    input                   i_d_valid_data, // from data memory
    input  [ DATA_W-1 : 0 ] i_d_data,       // from data memory
    output                  o_i_valid_addr, // to instruction memory
    output [ ADDR_W-1 : 0 ] o_i_addr,       // to instruction memory
    output [ DATA_W-1 : 0 ] o_d_data,       // to data memory
    output [ ADDR_W-1 : 0 ] o_d_addr,       // to data memory
    output                  o_d_MemRead,    // to data memory
    output                  o_d_MemWrite,   // to data memory
    output                  o_finish
);

// homework

	reg                  o_i_valid_addr_r, o_i_valid_addr_w; // to instruction memory
    reg [ ADDR_W-1 : 0 ] o_i_addr_r, o_i_addr_w;       // to instruction memory
    reg [ DATA_W-1 : 0 ] o_d_data_r, o_d_data_w;       // to data memory
    reg [ ADDR_W-1 : 0 ] o_d_addr_r, o_d_addr_w;       // to data memory
    reg                  o_d_MemRead_r, o_d_MemRead_w;   // to data memory
    reg                  o_d_MemWrite_r, o_d_MemWrite_w;   // to data memory
    reg                  o_finish_r, o_finish_w;
	
	assign o_i_valid_addr = o_i_valid_addr_r; // to instruction memory
    assign o_i_addr = o_i_addr_r;       // to instruction memory
    assign o_d_data = o_d_data_r;       // to data memory
    assign o_d_addr = o_d_addr_r;       // to data memory
    assign o_d_MemRead = o_d_MemRead_r;   // to data memory
    assign o_d_MemWrite = o_d_MemWrite_r;   // to data memory
    assign o_finish = o_finish_r;


	wire [1:0] Branch;
	wire MemRead;
	wire MemtoReg;
	wire [2:0] ALUop;
	wire MemWrite;
	wire ALUsrc;
	wire RegWrite;
	wire [1:0] ImmCtrl;

	wire [31:0] inst_imm;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd;

	wire [63:0] immediate;

	wire [63:0] i_adder_2;

	wire [63:0] next_addr;
	wire [63:0] current_addr;
	wire [63:0] i_pc_mux_0;
	wire [63:0] i_pc_mux_1;

	wire [63:0] i_rs_data;
	wire [63:0] rs1_data;
	wire [63:0] rs2_data;

	wire [63:0] i_ALU_2;
	wire [63:0] ALU_result;
	wire zero;

	wire select_addr;

	reg [3:0] cs;
	reg [3:0] ns;
	



	control #(
		.DATA_WIDTH(32)
	) u_control (
		.inst(i_i_inst),
		.i_i_valid_inst(i_i_valid_inst),

		.Branch(Branch),
		.MemRead(MemRead),
		.MemtoReg(MemtoReg),
		.ALUop(ALUop),
		.MemWrite(MemWrite),
		.ALUsrc(ALUsrc),
		.RegWrite(RegWrite),
		.ImmCtrl(ImmCtrl),
		.o_inst(inst_imm),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd)
	);
	ImmGen #(
		.DATA_WIDTH(32)
	) u_ImmGen (
		.ImmCtrl(ImmCtrl),
		.inst(inst_imm),
		.immediate(immediate)
	);

	shift_left_1 #(
		.DATA_WIDTH(64)
	) u_shift_left_1 (
		.immediate(immediate),
		.o_output(i_adder_2)
	);

	program_counter #(
		.DATA_WIDTH(64)
	) u_pc (
		.i_i_valid_inst(i_i_valid_inst),
		.o_i_valid_addr(o_i_valid_addr),

		.next(next_addr), //input
		.current(current_addr)  //output
	);
	add4 #(
		.DATA_WIDTH(64)
	) u_add4 (
		.i_data(current_addr),
		.o_data(i_pc_mux_0)
	);

	adder #(
		.DATA_WIDTH(64)
	) u_adder (
		.i_data_1(current_addr),
		.i_data_2(i_adder_2),
		.o_data(i_pc_mux_1)
	);

	register_file #(
		.REG_WIDTH(5),
		.DATA_WIDTH(64)
	) u_register (
		.i_d_valid_data(i_d_valid_data),
		.MemRead(MemRead),
		.RegWrite(RegWrite),
		.i_rs1(rs1),
		.i_rs2(rs2),
		.i_rd(rd),
		.i_data(i_rs_data),
		.o_data_1(rs1_data),
		.o_data_2(rs2_data)
	);

	ALU #(
		.DATA_WIDTH(64)
	) u_ALU (
		.ALUop(ALUop),
		.i_data_1(rs1_data),
		.i_data_2(i_ALU_2),
		.o_data(ALU_result),
		.zero(zero)
	);

	branch_and #(
		.DATA_WIDTH(1)
	) u_branch_and (
		.branch(Branch),
		.zero(zero),
		.select_addr(select_addr)
	);

	mux #(
		.DATA_WIDTH(64)
	) mux_addr (
		.select(select_addr),
		.i_data_0(i_pc_mux_0),
		.i_data_1(i_pc_mux_1),
		.o_data(next_addr)
	);
	mux #(
		.DATA_WIDTH(64)
	) mux_ALUsrc (
		.select(ALUsrc),
		.i_data_0(rs2_data),
		.i_data_1(immediate),
		.o_data(i_ALU_2)
	);
	mux #(
		.DATA_WIDTH(64)
	) mux_data (
		.select(MemtoReg),
		.i_data_0(ALU_result),
		.i_data_1(i_d_data),
		.o_data(i_rs_data)
	);

	initial begin
		o_i_addr_w = 0;
		o_finish_w = 0;
		cs = 0;
		ns = 0;
	end
	always @(*) begin
		o_i_addr_w = current_addr;
		//$monitor("%d %d\n", o_i_addr_w, MemRead);
		if (i_i_valid_inst) begin
			o_i_valid_addr_w = 0;
			//$monitor("%b\n", i_i_inst);
			if (i_i_inst === 32'b11111111111111111111111111111111) begin
				o_finish_w = 1;
			end
			o_d_MemRead_w = MemRead;
			o_d_MemWrite_w = MemWrite;
		end else begin
			o_d_MemRead_w = 0;
			o_d_MemWrite_w = 0;
		end
		/*o_d_MemRead_w = MemRead;
		o_d_MemWrite_w = MemWrite;*/
		o_d_data_w = rs2_data;
		o_d_addr_w = ALU_result;
	end
	
	always @(*) begin
		if (cs == 15) begin
			o_i_valid_addr_w = 1;
		end else begin
			o_i_valid_addr_w = 0;
		end
	end

	always @(*) begin
		case (cs)
			0: ns = 1;
			1: ns = 2;
			2: ns = 3;
			3: ns = 4;
			4: ns = 5;
			5: ns = 6;
			6: ns = 7;
			7: ns = 8;
			8: ns = 9;
			9: ns = 10;
			10: ns = 11;
			11: ns = 12;
			12: ns = 13;
			13: ns = 14;
			14: ns = 15;
			15: ns = 0;
			
		endcase
	end

	always @(posedge i_clk or negedge i_rst_n) begin
		if (~i_rst_n) begin
			o_i_valid_addr_r <= 0; // to instruction memory
			o_i_addr_r <= 0;       // to instruction memory
			o_d_data_r <= 0;       // to data memory
			o_d_addr_r <= 0;       // to data memory
			o_d_MemRead_r <= 0;   // to data memory
			o_d_MemWrite_r <= 0;   // to data memory
			o_finish_r <= 0;
			cs <= 0;
		end else begin
			o_i_valid_addr_r <= o_i_valid_addr_w; // to instruction memory
			o_i_addr_r <= o_i_addr_w;       // to instruction memory
			o_d_data_r <= o_d_data_w;       // to data memory
			o_d_addr_r <= o_d_addr_w;       // to data memory
			o_d_MemRead_r <= o_d_MemRead_w;   // to data memory
			o_d_MemWrite_r <= o_d_MemWrite_w;   // to data memory
			o_finish_r <= o_finish_w;
			cs <= ns;
		end
	end
endmodule


module control #(
	parameter DATA_WIDTH = 32
)(
	input [DATA_WIDTH-1:0] inst,
	input i_i_valid_inst,

	output [1:0] Branch,
	output 		MemRead,
	output 		MemtoReg,
	output [2:0]	ALUop,
	output 		MemWrite,
	output		ALUsrc,
	output		RegWrite,
	output [1:0] ImmCtrl,
	output [DATA_WIDTH-1:0] o_inst,
	output [4:0] rs1,
	output [4:0] rs2,
	output [4:0] rd
);


	reg [6:0] opcode;
	reg [2:0] funct3;
	reg			bit30;
	
	
	reg [1:0]	Branch_r;
	reg 		MemRead_r;
	reg 		MemtoReg_r;
	reg [2:0]	ALUop_r;
	reg 		MemWrite_r;
	reg		ALUsrc_r;
	reg		RegWrite_r;
	reg [1:0]	ImmCtrl_r;
	reg [DATA_WIDTH-1:0] o_inst_r;
	reg [4:0] rs1_r;
	reg [4:0] rs2_r;
	reg [4:0] rd_r;

	assign 		Branch = Branch_r;
	assign 		MemRead = MemRead_r;
	assign 		MemtoReg = MemtoReg_r;
	assign 		ALUop = ALUop_r;
	assign 		MemWrite = MemWrite_r;
	assign		ALUsrc = ALUsrc_r;
	assign		RegWrite = RegWrite_r;
	assign 		ImmCtrl = ImmCtrl_r;
	assign 		o_inst = o_inst_r;
	assign 		rs1 = rs1_r;
	assign 		rs2 = rs2_r;
	assign		rd = rd_r;

	/*
	Branch:
		0: no branch
		1: beq
		2: bne
	ALUop:
		0: add
		1: sub
		2: xor
		3: or
		4: and
		5: slli
		6: srli

	ALUsrc:
		0: rs2
		1: imm

	ImmCtrl:  decide format
		0: imm[11:0]
		1: imm[11:5] [4:0]
		2: imm[12] [10:5] [4:1] [11]
	*/
	initial begin
		opcode = 0;
		funct3 = 0;
		bit30 = 0;
		rs1_r = 0;
		rs2_r = 0;
		rd_r = 0;
		Branch_r = 0;
		MemRead_r = 0;
		MemtoReg_r = 0;
		ALUop_r = 0;
		MemWrite_r = 0;
		ALUsrc_r = 0;
		RegWrite_r = 0;
		ImmCtrl_r = 0;
	end

	always @(*) begin
		if (i_i_valid_inst) begin
			o_inst_r = inst;
			opcode = inst[6:0];
			funct3 = inst[14:12];
			bit30 = inst[30];
			rs1_r = inst[19:15];
			rs2_r = inst[24:20];
			rd_r = inst[11:7];
			case(opcode)
				7'b0000011: begin //ld
					Branch_r = 0;
					MemRead_r = 1;
					MemtoReg_r = 1;
					ALUop_r = 0;
					MemWrite_r = 0;
					ALUsrc_r = 1;
					RegWrite_r = 1;
					ImmCtrl_r = 0;
				end
				7'b0100011: begin //sd
					Branch_r = 0;
					MemRead_r = 0;
					MemtoReg_r = 0;
					ALUop_r = 0;
					MemWrite_r = 1;
					ALUsrc_r = 1;
					RegWrite_r = 0;
					ImmCtrl_r = 1;
				end
				7'b1100011: begin //beq bne
					MemRead_r = 0;
					MemtoReg_r = 0;
					ALUop_r = 1;
					MemWrite_r = 0;
					ALUsrc_r = 0;
					RegWrite_r = 0;
					ImmCtrl_r = 2;
					case(funct3)
						3'b000: begin //beq
							Branch_r = 1;
						end
						3'b001: begin //bne
							Branch_r = 2;
						end
						default begin
							Branch_r = 0;
						end
					endcase

				end
				7'b0010011: begin // ALU i type
					Branch_r = 0;
					MemRead_r = 0;
					MemtoReg_r = 0;
					MemWrite_r = 0;
					ALUsrc_r = 1;
					RegWrite_r = 1;
					ImmCtrl_r = 0;
					case(funct3)
						3'b000: begin //addi
							ALUop_r = 0;
						end
						3'b100: begin //xori
							ALUop_r = 2;
						end
						3'b110: begin //ori
							ALUop_r = 3;
						end
						3'b111: begin //andi
							ALUop_r = 4;
						end
						3'b001: begin //addi
							ALUop_r = 5;
						end
						3'b101: begin //xori
							ALUop_r = 6;
						end
						default begin
							ALUop_r = 0;
						end
					endcase
				end
				7'b0110011: begin //ALU r type
					Branch_r = 0;
					MemRead_r = 0;
					MemtoReg_r = 0;
					MemWrite_r = 0;
					ALUsrc_r = 0;
					RegWrite_r = 1;
					ImmCtrl_r = 0;
					case(funct3)
						3'b000: begin //add sub
							if (bit30 == 0) begin
								ALUop_r = 0;
							end else begin
								ALUop_r = 1;
							end
						end
						3'b100: begin //xor
							ALUop_r = 2;
						end
						3'b110: begin //or
							ALUop_r = 3;
						end
						3'b111: begin //and
							ALUop_r = 4;
						end
						default begin
							ALUop_r = 0;
						end
					endcase
				end
				default begin
					Branch_r = 0;
					MemRead_r = 0;
					MemtoReg_r = 0;
					ALUop_r = 0;
					MemWrite_r = 0;
					ALUsrc_r = 0;
					RegWrite_r = 0;
					ImmCtrl_r = 0;
				end
			endcase
		end
	end

endmodule

module mux #(
	parameter DATA_WIDTH = 64
)(
	input 					select,
	input  [DATA_WIDTH-1:0] i_data_0,
    input  [DATA_WIDTH-1:0] i_data_1,
	output [DATA_WIDTH-1:0] o_data
);
	reg [DATA_WIDTH-1:0] o_data_r;
	
	assign o_data = o_data_r;
	/*initial begin
		o_data_r = 0;
	end*/

	always @(*) begin
		if (select === 1'b0) begin
			o_data_r = i_data_0;
		end else begin
			o_data_r = i_data_1;
		end
	end

endmodule


module ImmGen #(
	parameter DATA_WIDTH = 32
)(
	input [1:0] ImmCtrl,
	input [DATA_WIDTH-1:0] inst,
	output [2*DATA_WIDTH-1:0] immediate
);

	reg [2*DATA_WIDTH-1:0] immediate_r;

	assign immediate = immediate_r;

	always @(*) begin
		immediate_r = 0;
		case (ImmCtrl)
			2'b00: begin
				immediate_r[11:0] = inst[31:20];
			end
			2'b01: begin
				immediate_r[11:5] = inst[31:25];
				immediate_r[4:0] = inst[11:7];
			end
			2'b10: begin
				/*immediate_r[12] = inst[31];
				immediate_r[10:5] = inst[30:25];
				immediate_r[4:1] = inst[11:8];
				immediate_r[11] = inst[7];*/

				immediate_r[11] = inst[31];
				immediate_r[9:4] = inst[30:25];
				immediate_r[3:0] = inst[11:8];
				immediate_r[10] = inst[7];
			end
			default begin
				immediate_r = 0;
			end
		endcase
	end

endmodule

module shift_left_1 #(
	parameter DATA_WIDTH = 64
)(
	input [DATA_WIDTH-1:0] immediate,
	output [DATA_WIDTH-1:0] o_output
);

	reg [DATA_WIDTH-1:0] o_output_r;

	assign o_output = o_output_r;

	always @(*) begin
		o_output_r = immediate << 1;
	end

endmodule

module program_counter #(
	parameter DATA_WIDTH = 64
)(
	input i_i_valid_inst, ///test
	input o_i_valid_addr, ///test
	input [DATA_WIDTH -1:0] next,
	output [DATA_WIDTH-1:0] current
);

	//reg [DATA_WIDTH-1:0] current_r;
	reg signed [DATA_WIDTH:0] current_r;
	assign current = current_r[DATA_WIDTH-1:0];

	initial begin
		current_r = -4; //0;
	end

	//always @(*) begin
	always @(negedge i_i_valid_inst) begin
		//if (i_i_valid_inst) begin
			current_r = next;
		//end
	end
	/*always @(posedge o_i_valid_addr) begin
		//if (i_i_valid_inst) begin
			current_r = next;
		//end
	end*/

endmodule

module add4 #(
	parameter DATA_WIDTH = 64
)(
	input [DATA_WIDTH-1:0] i_data,
	output [DATA_WIDTH-1:0] o_data
);
	
	reg [DATA_WIDTH-1:0] o_data_r;

	assign o_data = o_data_r;
	
	initial begin
		o_data_r = 0;
	end
	always @(*) begin
		o_data_r = i_data + 4;
	end

endmodule

module adder #(
	parameter DATA_WIDTH = 64
)(
	input [DATA_WIDTH-1:0] i_data_1,
	input [DATA_WIDTH-1:0] i_data_2,
	output [DATA_WIDTH-1:0] o_data
);

	reg [DATA_WIDTH-1:0] o_data_r;

	assign o_data = o_data_r;
	initial begin
		o_data_r = 0;
	end
	always @(*) begin 
		o_data_r = i_data_1 + i_data_2;
	end

endmodule


module register_file #(
	parameter REG_WIDTH = 5,
	parameter DATA_WIDTH = 64
)(
	input i_d_valid_data,
	input MemRead,
	input RegWrite,
	input [REG_WIDTH-1:0] i_rs1,
	input [REG_WIDTH-1:0] i_rs2,
	input [REG_WIDTH-1:0] i_rd,
	input [DATA_WIDTH-1:0] i_data,
	output [DATA_WIDTH-1:0] o_data_1,
	output [DATA_WIDTH-1:0] o_data_2
);

	reg [DATA_WIDTH-1:0] register_array [0:31];
	reg [DATA_WIDTH-1:0] o_data_1_r;
	reg [DATA_WIDTH-1:0] o_data_2_r;

	assign o_data_1 = o_data_1_r;
	assign o_data_2 = o_data_2_r;

	integer i;
	initial begin
		for (i = 0; i < 32; i = i + 1) begin 
			register_array[i] = 0;
		end
	end

	always @(*) begin
		o_data_1_r = register_array[i_rs1];
		o_data_2_r = register_array[i_rs2];
		if (RegWrite && (i_d_valid_data || ~MemRead)) begin
			register_array[i_rd] = i_data;
		end
	end
endmodule

module ALU #(
	parameter DATA_WIDTH = 64
)(
	input [2:0] ALUop,
	input [DATA_WIDTH-1:0] i_data_1,
	input [DATA_WIDTH-1:0] i_data_2,
	output [DATA_WIDTH-1:0] o_data,
	output zero
);

	reg [DATA_WIDTH-1:0] o_data_r;
	reg zero_r;

	assign o_data = o_data_r;
	assign zero = zero_r;

	always @(*) begin
		case (ALUop)
			3'b000: begin
				o_data_r = i_data_1 + i_data_2;
				zero_r = 0;
			end
			3'b001: begin
				o_data_r = i_data_1 - i_data_2;
				//if (o_data_r === 64'd0) begin
				if (i_data_1 === i_data_2) begin
					zero_r = 1;
				end else begin
					zero_r = 0;
				end
			end
			3'b010: begin
				o_data_r = i_data_1 ^ i_data_2;
				zero_r = 0;
			end
			3'b011: begin
				o_data_r = i_data_1 | i_data_2;
				zero_r = 0;
			end
			3'b100: begin
				o_data_r = i_data_1 & i_data_2;
				zero_r = 0;
			end
			3'b101: begin
				o_data_r = i_data_1 << i_data_2;
				zero_r = 0;
			end
			3'b110: begin
				o_data_r = i_data_1 >> i_data_2;
				zero_r = 0;
			end
			default begin
				o_data_r = 0;
				zero_r = 0;
			end
		endcase
	end

endmodule

module branch_and #(
	parameter DATA_WIDTH = 1
)(
	input [1:0] branch,
	input zero,
	output select_addr
);

	reg select_addr_r;

	assign select_addr = select_addr_r;

	always @(*) begin
		if (zero && branch === 2'b01) begin
			select_addr_r = 1;
		end else if (~zero && branch === 2'b10) begin
			select_addr_r = 1;
		end else begin
			select_addr_r = 0;
		end
	end

endmodule









