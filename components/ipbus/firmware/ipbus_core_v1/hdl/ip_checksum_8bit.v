`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:55:41 01/15/2010 
// Design Name: 
// Module Name:    ip_checksum_8bit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ip_checksum_8bit(
    input clk,
    input dv_even,
    input dv_odd,
    input reset,
    output reg [15:0] checksum,
    input [7:0] data
    );
	 
	reg [15:0] csum_intl;
	reg [7:0] deven;
	wire [16:0] csum_add;
	
always @(posedge clk) if (dv_even) deven<=data;

	assign csum_add={1'h0,csum_intl}+{1'h0,deven,data};

always @(posedge clk) 
	if (reset) csum_intl<=0;
	else if (dv_odd) 
		if (csum_add[16]) csum_intl<=csum_add[15:0]+1;
		else csum_intl<=csum_add[15:0];

always @(posedge clk) 
	checksum<=~csum_intl;

endmodule
