`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Project Name: bitonic_sort
// Module Name: bitonic_sort
// Function: Top-level Bitonic Sorter module
// Designer: Otis Hung
// Time Stamp: 2025/12/24
//////////////////////////////////////////////////////////////////////////////////

module bitonic_sort #(
	parameter DATA_WIDTH = 16,	// data width
	parameter CHAN_NUM = 8,		// number of input data channels
	parameter DIR = 0,			// 0 - ascending, 1 - descending
	parameter SIGNED = 0,		// 0 - unsigned, 1 - signed
	parameter PIPE_REG = 1		// pipeline bypass, enable each N-th out reg 
)
(
	input wire clk,
	input wire [DATA_WIDTH*CHAN_NUM-1:0]data_in,
	output wire [DATA_WIDTH*CHAN_NUM-1:0]data_out
);

localparam CHAN_ACT = 2**$clog2(CHAN_NUM); // if CHAN_NUM is not power of 2, extend to next power of 2
localparam CHAN_ADD = CHAN_ACT - CHAN_NUM; // number of added channels

localparam STAGES = $clog2(CHAN_ACT);
localparam STAGE_DATA_WIDTH = DATA_WIDTH*CHAN_ACT;

wire [STAGE_DATA_WIDTH-1:0]stage_data[STAGES:0];
wire [STAGE_DATA_WIDTH-1:0]data_out_tmp;

assign stage_data[0] = {data_in, {CHAN_ADD{SIGNED?{1'b1,{(DATA_WIDTH-1){1'b0}}}:{DATA_WIDTH{1'b0}}}}}; // extend input data with min
assign data_out_tmp = stage_data[STAGES];
assign data_out = DIR ? data_out_tmp[DATA_WIDTH*CHAN_NUM-1:0] : data_out_tmp[DATA_WIDTH*CHAN_ACT-1-:DATA_WIDTH*CHAN_NUM]; // truncated output data

genvar stage;
genvar block;

generate for (stage = 0; stage < STAGES; stage = stage + 1) begin: SORT_STAGE
	localparam BLOCKS = CHAN_ACT / 2**(stage+1);
	localparam BLOCK_ORDER = stage;
		
	wire [STAGE_DATA_WIDTH-1:0]stage_data_in;
	wire [STAGE_DATA_WIDTH-1:0]stage_data_out;
		
	assign stage_data_in = stage_data[stage];
	assign stage_data[stage + 1] = stage_data_out;

	for (block = 0; block < BLOCKS; block = block + 1) begin: BLOCK
		localparam BLOCK_DATA_WIDTH = DATA_WIDTH*2**(BLOCK_ORDER+1);
		localparam BLOCK_POLARITY = DIR ? (~block & 1) : (block & 1);
			
		wire [BLOCK_DATA_WIDTH-1:0]block_data_in;
		wire [BLOCK_DATA_WIDTH-1:0]block_data_out;
			
		assign block_data_in = stage_data_in[BLOCK_DATA_WIDTH*(block+1)-1 -:BLOCK_DATA_WIDTH];
		assign stage_data_out[BLOCK_DATA_WIDTH*(block+1)-1 -:BLOCK_DATA_WIDTH] = block_data_out;
		
		bitonic_block #(
			.DATA_WIDTH(DATA_WIDTH),
			.ORDER(BLOCK_ORDER),
			.POLARITY(BLOCK_POLARITY),
			.SIGNED(SIGNED),
			.PIPE_REG(PIPE_REG)
		) bitonic_block_inst (
			.clk(clk),
			.data_in(block_data_in),
			.data_out(block_data_out)
		);
	end
end endgenerate

endmodule
