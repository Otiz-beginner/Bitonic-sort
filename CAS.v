`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Project Name: bitonic_sort
// Module Name: bitonic_comp
// Function: Compare-and-Swap (CAS) unit for Bitonic Sorter
// Designer: Otis Hung
// Time Stamp: 2025/11/29
//////////////////////////////////////////////////////////////////////////////////

module CAS #(
	parameter DATA_WIDTH = 16,
	parameter POLARITY = 0, // 0 - ascending, 1 - descending
	parameter SIGNED = 0, // 0 - unsigned, 1 - signed
	parameter REGOUT_EN = 0 // 0 - combinational output, 1 - registered output
)
(
	input wire CLK,
	input wire [DATA_WIDTH-1:0]A,
	input wire [DATA_WIDTH-1:0]B,
	output reg [DATA_WIDTH-1:0]H, 
	output reg [DATA_WIDTH-1:0]L
);

reg [DATA_WIDTH-1:0]H_REG;
reg [DATA_WIDTH-1:0]L_REG;

wire LESS; // A < B

generate
	if (SIGNED == 0) begin
		assign LESS = $unsigned(A) < $unsigned(B);	
	end else begin
		assign LESS = $signed(A) < $signed(B);
	end
	
	if (POLARITY == 0) begin
		always @(*) begin
			H_REG = (LESS) ? A : B;
			L_REG = (LESS) ? B : A;
		end
	end else begin
		always @(*) begin
			H_REG = (LESS) ? B : A;
			L_REG = (LESS) ? A : B;
		end
	end
	if (REGOUT_EN == 1) begin
		always @(posedge CLK) begin
			H <= H_REG;
			L <= L_REG;
		end
	end else begin
		always @(*) begin
			H = H_REG;
			L = L_REG;
		end
	end
endgenerate

endmodule
