`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Project Name: bitonic_sort
// Module Name: bitonic_block
// Function: Bitonic Block module
// Designer: Otis Hung
// Time Stamp: 2025/12/10
//////////////////////////////////////////////////////////////////////////////////

module bitonic_block #(
	parameter DATA_WIDTH = 16,
	parameter ORDER = 0,
	parameter POLARITY = 0,
	parameter SIGNED = 0,
	parameter PIPE_REG = 1
)
(
	input wire clk,
	input wire [DATA_WIDTH*2**(ORDER+1)-1:0]data_in,
	output wire [DATA_WIDTH*2**(ORDER+1)-1:0]data_out
);

localparam STAGES = ORDER + 1;
localparam STAGE_DATA_WIDTH = DATA_WIDTH*2**(ORDER+1);

function integer index(input integer SS, input integer BS);
	integer i, j, ind;
begin
	ind = 0;
	for (i = 0; i < SS; i = i + 1) begin
		for (j = i+1; j < SS+1; j = j + 1) begin
			ind = ind + 1;
		end
	end
	index = ind + BS + 1;
end
endfunction

wire [DATA_WIDTH*2**(ORDER+1)-1:0]stage_data[STAGES:0];

assign stage_data[0] = data_in;
assign data_out = stage_data[STAGES];

genvar stage;
genvar node;

generate for (stage = 0; stage < STAGES; stage = stage + 1) begin: BLOCK_STAGE
	localparam NODES = 2**stage;
	localparam NODE_ORDER = STAGES - stage - 1;
		
	wire [STAGE_DATA_WIDTH-1:0]stage_data_in;
	wire [STAGE_DATA_WIDTH-1:0]stage_data_out;
		
	assign stage_data_in = stage_data[stage];
	assign stage_data[stage + 1] = 	stage_data_out;
		
	for (node = 0; node < NODES; node = node + 1) begin: NODE
		localparam NODE_DATA_WIDTH = DATA_WIDTH*2**(NODE_ORDER+1);
		wire [NODE_DATA_WIDTH-1:0]node_data_in;
		wire [NODE_DATA_WIDTH-1:0]node_data_out;
			
		assign node_data_in = stage_data_in[NODE_DATA_WIDTH*(node + 1)-1-:NODE_DATA_WIDTH];
		assign stage_data_out[NODE_DATA_WIDTH*(node + 1)-1-:NODE_DATA_WIDTH] = node_data_out;
			
		bitonic_node #(
			.DATA_WIDTH(DATA_WIDTH),
			.ORDER(NODE_ORDER),
			.POLARITY(POLARITY),
			.SIGNED(SIGNED),
			.PIPE_REG(PIPE_REG),
			.INDEX(index(ORDER, stage))
		) bitonic_node_inst (
			.clk(clk),
			.data_in(node_data_in),
			.data_out(node_data_out)
		);		
	end
end endgenerate

endmodule
