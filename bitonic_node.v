`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Project Name: bitonic_sort
// Module Name: bitonic_node
// Function: Bitonic Sorter Node
// Designer: Otis Hung
// Time Stamp: 2025/12/01
//////////////////////////////////////////////////////////////////////////////////

module bitonic_node #(
	parameter DATA_WIDTH = 16,
	parameter ORDER = 0, // 0 - first stage (1 inputs), 1 - second stage (2 inputs), etc.
	parameter POLARITY = 0, // 0 - ascending, 1 - descending
	parameter SIGNED = 0, // 0 - unsigned, 1 - signed
	parameter PIPE_REG = 1,
	parameter INDEX = 0 // index of this node in the stage
)
(
	input wire clk,
	input wire [DATA_WIDTH*2**(ORDER+1)-1:0]data_in,
	output wire [DATA_WIDTH*2**(ORDER+1)-1:0]data_out
);

localparam COMP_NUM = 2**ORDER; // number of comparators in this stage
localparam REGOUT_EN = (PIPE_REG == 0) ? 0 : ((INDEX % PIPE_REG) == 0);

genvar i;

generate for (i = 0; i < COMP_NUM; i = i + 1) begin: COMP
	wire [DATA_WIDTH-1:0]A;
	wire [DATA_WIDTH-1:0]B;
	wire [DATA_WIDTH-1:0]H;
	wire [DATA_WIDTH-1:0]L;
	
	assign A = data_in[DATA_WIDTH*(i + 1 + COMP_NUM * 0)-1-:DATA_WIDTH];
	assign B = data_in[DATA_WIDTH*(i + 1 + COMP_NUM * 1)-1-:DATA_WIDTH];
	assign data_out[DATA_WIDTH*(i + 1 + COMP_NUM * 0)-1-:DATA_WIDTH] = H;
	assign data_out[DATA_WIDTH*(i + 1 + COMP_NUM * 1)-1-:DATA_WIDTH] = L;

	CAS #(
		.DATA_WIDTH(DATA_WIDTH),
		.POLARITY(POLARITY),
		.SIGNED(SIGNED),
		.REGOUT_EN(REGOUT_EN)
	) comp_inst (
		.CLK(clk),
		.A(A),
		.B(B),
		.H(H),
		.L(L)
	);
end endgenerate

endmodule
