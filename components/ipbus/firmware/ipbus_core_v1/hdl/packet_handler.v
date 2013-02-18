`timescale 1ns / 1ps
`include "ipbus_v_defs.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:41:40 01/15/2010 
// Design Name: 
// Module Name:    packet_handler 
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
module packet_handler(
	input clk, reset,
	input rx_ready,
	output reg rx_done,
	input [7:0] rxd,
	output [`pbuf_awidth - 1:0] rxa,
	output [7:0] txd,
	output [`pbuf_awidth - 1:0] txa, tx_len,
	output tx_we, tx_done,
	input [31:0] ip,
	input [5:0] arp_rxa, arp_txa, arp_len,
	input [7:0] arp_txd,
	input arp_we, arp_xmit, arp_done,
	output reg arp_ready,
	input [9:0] icmp_rxa, icmp_txa, icmp_len,
	input [7:0] icmp_txd,
	input icmp_we, icmp_xmit, icmp_done,
	output reg icmp_ready,
	input [`pbuf_awidth - 1:0] udp_rxa, udp_txa, udp_len,
	input [7:0] udp_txd,
	input udp_we, udp_xmit, udp_done, udp_xmit_req, udp_space,
	output reg udp_ready, udp_xmit_ok);

	reg [1:0] activeSrc;
	parameter SRC_SELF  =  2'h0;
	parameter SRC_ARP   =  2'h1;
	parameter SRC_ICMP  =  2'h2;
	parameter SRC_UDP   =  2'h3;

	reg [4:0] state;
	parameter ST_IDLE     = 5'h00;
	parameter ST_WAITETH0 = 5'h01;
	parameter ST_ETH0     = 5'h02;
	parameter ST_ETH1     = 5'h03;
	parameter ST_ARP      = 5'h04;
	parameter ST_IP0      = 5'h05;
	parameter ST_IP1      = 5'h06;
	parameter ST_IP2      = 5'h07;
	parameter ST_IP3      = 5'h08;
	parameter ST_IP       = 5'h09;
	parameter ST_ICMP     = 5'h0a;
	parameter ST_UDP      = 5'h0b;
	parameter ST_UDP0     = 5'h0c;
	parameter ST_UDP1     = 5'h0d;
	parameter ST_PREDONE  = 5'h1d;
	parameter ST_DONE     = 5'h1e;
	parameter ST_UDP_XMIT = 5'h1f;

	parameter UDP_PORT_CTL = 16'hc351;    // Original JM definition d791;
	
	reg [`pbuf_awidth - 1:0] self_rxa=`pbuf_awidth'b0;
	reg [7:0] eth0;

	always @(posedge clk) 
		if (reset) begin
			state<=ST_IDLE;
			activeSrc<=SRC_SELF;		
			rx_done<=0;
			self_rxa<=`pbuf_awidth'b0;
		end
		else case (state)
			ST_IDLE: begin
				activeSrc<=SRC_SELF;
				if (rx_ready) begin
					self_rxa<=`pbuf_awidth'd12; // get ethtype0
					state<=ST_WAITETH0;
				end else if (udp_xmit_req) begin
					state<=ST_UDP_XMIT;
				end else begin
					state<=ST_IDLE;
				end
			end
			ST_WAITETH0: begin
				self_rxa<=`pbuf_awidth'd13; // get ethtype1
				state<=ST_ETH0;
			end
			ST_ETH0: begin
				eth0<=rxd;
				self_rxa<=`pbuf_awidth'd30; // get dest ip addr 0
				state<=ST_ETH1;
			end
			ST_ETH1: begin
				self_rxa<=`pbuf_awidth'd31; // get dest ip addr 1
				if (rxd==8'h06 && eth0==8'h08) state<=ST_ARP;
				else if (rxd==8'h00 && eth0==8'h08) state<=ST_IP0;
				else state<=ST_PREDONE;
			end
			ST_IP0: begin
				self_rxa<=`pbuf_awidth'd32; // get dest ip addr 2
				if (rxd==ip[31:24]) state<=ST_IP1;
				else state<=ST_PREDONE;
			end
			ST_IP1: begin		
				self_rxa<=`pbuf_awidth'd33; // get dest ip addr 3
				if (rxd==ip[23:16]) state<=ST_IP2;
				else state<=ST_PREDONE;
			end
			ST_IP2: begin
				self_rxa<=`pbuf_awidth'd23; // get the ip type (if valid)
				if (rxd==ip[15:8]) state<=ST_IP3;
				else state<=ST_PREDONE;
			end
			ST_IP3: begin
				self_rxa<=`pbuf_awidth'h24; // get the udp port (MSB) (if needed)
				if (rxd==ip[7:0]) state<=ST_IP;
				else state<=ST_PREDONE;
			end
			ST_IP: begin
				self_rxa<=`pbuf_awidth'h25; // get the udp port (LSB) (if needed)
				if (rxd==8'h01) state<=ST_ICMP;
				else if (rxd==8'd17 && udp_space) state<=ST_UDP0;
				else state<=ST_PREDONE;
			end
			ST_ARP: begin
				activeSrc<=SRC_ARP;
				if (arp_done) begin
					state<=ST_PREDONE;
				end else
					state<=ST_ARP;
			end
			ST_ICMP: begin
				activeSrc<=SRC_ICMP;
				if (icmp_done) begin
					state<=ST_PREDONE;
				end else
					state<=ST_ICMP;
			end
			ST_UDP0: begin
				if (rxd==UDP_PORT_CTL[15:8]) state<=ST_UDP1;
				else state<=ST_PREDONE;
			end
			ST_UDP1: begin
				if (rxd==UDP_PORT_CTL[7:0]) state<=ST_UDP;
				else state<=ST_PREDONE;
			end
			ST_UDP: begin
				activeSrc<=SRC_UDP;
				if (udp_done) begin
					state<=ST_PREDONE;
				end else
					state<=ST_UDP;
			end
			ST_PREDONE: begin
				rx_done<=1;
				if (rx_done==1) state<=ST_DONE;
				else state<=ST_PREDONE;
			end
			ST_DONE: begin
				activeSrc<=SRC_SELF;
				rx_done<=0;
				if (rx_done==0) state<=ST_IDLE;
				else state<=ST_DONE;
			end
			ST_UDP_XMIT: 
				if (!udp_xmit_req) begin 
					state<=ST_IDLE;
					activeSrc<=SRC_SELF;
				end else begin
					state<=ST_UDP_XMIT;
					activeSrc<=SRC_UDP;
				end
		endcase

	assign rxa=(activeSrc==SRC_SELF)?(self_rxa):
		(activeSrc==SRC_ARP)?({5'h0,arp_rxa}):
		(activeSrc==SRC_ICMP)?(icmp_rxa):
		(activeSrc==SRC_UDP)?(udp_rxa):0;

	assign txa=(activeSrc==SRC_ARP)?({5'h0,arp_txa}):
		(activeSrc==SRC_ICMP)?(icmp_txa):
		(activeSrc==SRC_UDP)?(udp_txa):0;

	assign txd=(activeSrc==SRC_ARP)?(arp_txd):
		(activeSrc==SRC_ICMP)?(icmp_txd):
		(activeSrc==SRC_UDP)?(udp_txd):0;

	assign tx_we=(activeSrc==SRC_ARP)?(arp_we):
		(activeSrc==SRC_ICMP)?(icmp_we):
		(activeSrc==SRC_UDP)?(udp_we):0;

	assign tx_done=(activeSrc==SRC_ARP)?(arp_xmit):
		(activeSrc==SRC_ICMP)?(icmp_xmit):
		(activeSrc==SRC_UDP)?(udp_xmit):0;

	assign tx_len=(activeSrc==SRC_ARP)?(arp_len):
		(activeSrc==SRC_ICMP)?(icmp_len):
		(activeSrc==SRC_UDP)?(udp_len):0;

	always @(posedge clk) arp_ready<=(state==ST_ARP);
	always @(posedge clk) icmp_ready<=(state==ST_ICMP);
	always @(posedge clk) udp_ready<=(state==ST_UDP);
	always @(posedge clk) udp_xmit_ok<=(state==ST_UDP_XMIT);

endmodule
