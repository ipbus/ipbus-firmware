`timescale 1ns / 1ps
`include "ipbus_v_defs.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:29:46 02/02/2010 
// Design Name: 
// Module Name:    sub_packetreq 
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
module sub_packetreq(
	input ipb_clk, mac_clk, reset,
	input incoming_ready, done_with_packet,
	output copydone, packet_avail, busy,
	input [`pbuf_awidth - 1:0] rxl,
	output reg [`pbuf_awidth - 1:0] rxa,
	input [7:0] rxd,
	input [`pbuf_awidth - 3:0] readAddr,
	output [31:0] readData,
	output [`pbuf_awidth - 3:0] len);

	reg half;
	reg topFull, bottomFull;
	reg [1:0] state;
	reg we;
	reg [`pbuf_awidth - 3:0] rqlen[1:0];

	initial
		begin
			half = 0;
			bottomFull = 0;
			topFull = 0;
			state = 2'b0;
			rqlen[0] = `pbuf_awidth_32'b0; 
			rqlen[1] = `pbuf_awidth_32'b0; 
		end
	
	parameter ST_IDLE = 2'h0;
	parameter ST_COPY = 2'h1;
	parameter ST_DONE = 2'h2;
	
	assign copydone=(state==ST_DONE);
	assign busy=topFull;

	reg packet_avail_ipb;

	always @(posedge ipb_clk)
		packet_avail_ipb <= bottomFull; // clock domain crossing - needs sync reg (multiple dest)

	assign packet_avail=packet_avail_ipb; 
	assign len=rqlen[half];

	reg [`pbuf_awidth - 1:0] rqAddr;
	reg [`pbuf_awidth - 1:0] iplen;

	initial
		begin
			rqAddr = `pbuf_awidth'b0; 
			iplen = `pbuf_awidth'b0; 
		end
		
	dpram_8x12_32x10 buffer(
		.clka(mac_clk),
		.wea(we),
		.addra({~half,rqAddr}),
		.dina(rxd),
		.clkb(ipb_clk),
		.web(1'b0),
		.addrb({half,readAddr}),
		.dinb(32'b0),
		.doutb(readData));

	reg dwp_mac;

	always @(posedge mac_clk)
		dwp_mac <= done_with_packet; // clock domain crossing - needs sync reg (multiple dest)

	always @(posedge mac_clk)
		if (reset) begin 
			state<=ST_IDLE;
			we<=0;
			topFull<=0;
			bottomFull<=0;
			half<=0;
		end
		else case (state)
			ST_IDLE:
				if (!topFull && incoming_ready) begin
					rqAddr<=1; // provide one delay state (should logically start at 2) 
					rxa<=0;
					we<=1;
					state<=ST_COPY;
				end else begin
					if (dwp_mac) begin
						bottomFull<=topFull;
						topFull<=0;
						half<=~half;
					end
				we<=0;
				state<=ST_IDLE;
			end
			ST_COPY:
				if (rxa==rxl) begin
					we<=0;
					state<=ST_DONE;
				end else begin
					we<=1;
					state<=ST_COPY;
					rxa<=rxa+1;
					rqAddr<=rqAddr+1;
					iplen<=rxl-`pbuf_awidth'd14;
				end
			ST_DONE: 
				if (!incoming_ready) begin
					rqlen[~half]<=iplen[`pbuf_awidth - 1:2]-9'd7; 		
					if (!bottomFull) begin
						bottomFull<=1;
						topFull<=0;
						half<=~half;
					end else begin
						topFull<=1;
						half<=half;
						bottomFull<=1;
					end
					state<=ST_IDLE;		
				end else state<=ST_DONE;
			endcase

endmodule
