`timescale 1ns / 1ps
`include "ipbus_v_defs.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:55:45 01/26/2010 
// Design Name: 
// Module Name:    sub_packetbuffer 
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
module sub_packetbuffer(
	input ipb_clk, mac_clk, reset,
	input incoming_ready,
	output done_with_incoming,
	output [`pbuf_awidth - 1:0] rxa,
	input [7:0] rxd,
	input [`pbuf_awidth - 1:0] rxl,
	output [`pbuf_awidth - 1:0] txa,
	output [7:0] txd,
	output tx_we, tx_req, tx_send,
	input tx_ok,
	output [`pbuf_awidth - 1:0] txl,
	output incoming_space,
	input [`pbuf_awidth - 3:0] req_addr,
	output [31:0] req_data,
	output [`pbuf_awidth - 3:0] req_len,
	input [`pbuf_awidth - 3:0] resp_addr,
	input [31:0] resp_data,
	input [`pbuf_awidth - 3:0] resp_len,
	input resp_we,
	output reg req_avail,
	input resp_done);	
	
// incoming side
	wire [`pbuf_awidth - 3:0] reqAddr, respAddr;
	wire [31:0] reqData, respData;

	wire inbusy, packet_avail, respWE;
	assign incoming_space=~inbusy;
	wire send_resp;

	sub_packetreq inbuf(.ipb_clk(ipb_clk),.mac_clk(mac_clk),.reset(reset),
		.rxl(rxl),.rxa(rxa),.rxd(rxd),.done_with_packet(send_resp),
		.incoming_ready(incoming_ready),.busy(inbusy),.copydone(done_with_incoming),
		.packet_avail(packet_avail),.len(req_len),
		.readData(reqData),.readAddr(reqAddr));

// outgoing side (also calculates the UDP checksum and swaps XMIT/RECV Ethernet Addresses)
	sub_packetresp outbuf(.ipb_clk(ipb_clk),.mac_clk(mac_clk),.reset(reset),
		.txa(txa),.txd(txd),.txl(txl),.we(tx_we),.tx_req(tx_req),.tx_ok(tx_ok),.tx_send(tx_send),
		.done(send_resp),.len(resp_len),
		.respData(respData),.respAddr(respAddr),.respWE(respWE));


	reg [`pbuf_awidth - 3:0] addra;
	reg [2:0] state;
	wire [`pbuf_awidth - 3:0] addrb;

	initial
		begin
			state = 3'b0;
			addra = `pbuf_awidth_32'b0; 
		end	
	
	parameter ST_IDLE             = 3'h0;
	parameter ST_COPYHEADER       = 3'h1;
	parameter ST_COPYHEADER2      = 3'h2;
	parameter ST_WAIT_FOR_ENGINE  = 3'h3;
	parameter ST_DONE             = 3'h6;
	parameter ST_RESP             = 3'h7;

	reg send_rp;
	assign send_resp=send_rp;
	reg we;

	initial
		begin
			send_rp = 0;
			we = 0; 
		end		
	
	always @(posedge ipb_clk)
		if (reset) begin
			state<=ST_IDLE;
			we<=0;
			send_rp<=0;
		end else case (state)
			ST_IDLE: begin
				send_rp<=0;
				if (packet_avail) begin
					addra<=0;
					we<=1;
					state<=ST_COPYHEADER2;
				end else state<=ST_IDLE;
			end
			ST_COPYHEADER : 
				if (addra==`pbuf_awidth_32'd12) begin
					we<=0;
					state<=ST_WAIT_FOR_ENGINE;
				end else begin
					we<=1;
					addra<=addra+1;
					state<=ST_COPYHEADER2;
				end
			ST_COPYHEADER2 : state<=ST_COPYHEADER;
			ST_WAIT_FOR_ENGINE :
				if (resp_done) state<=ST_RESP;
				else state<=ST_WAIT_FOR_ENGINE;
			ST_RESP: begin 
				send_rp<=1;
				if (send_rp==1) state<=ST_DONE;
				else state<=ST_RESP;
			end
			ST_DONE: begin
				send_rp<=0;
				if (send_rp==0) state<=ST_IDLE;
				else state<=ST_DONE;		
			end
		endcase

	assign addrb=	(addra==`pbuf_awidth_32'd7)?(`pbuf_awidth_32'h8):
		(addra==`pbuf_awidth_32'd8)?(`pbuf_awidth_32'h7):
		addra;

	assign respAddr=(req_avail)?(resp_addr+`pbuf_awidth_32'd11):addra;
	assign reqAddr=(req_avail)?(req_addr+`pbuf_awidth_32'd11):addrb;

	assign respData=(req_avail)?(resp_data):
		(addra==`pbuf_awidth_32'd9)?{reqData[15:0],reqData[31:16]}: // swap UDP ports...
		reqData;

	assign respWE=(req_avail)?resp_we:we;

	assign req_data=reqData;

	always @(posedge ipb_clk)
		req_avail<=(state==ST_WAIT_FOR_ENGINE);

endmodule

