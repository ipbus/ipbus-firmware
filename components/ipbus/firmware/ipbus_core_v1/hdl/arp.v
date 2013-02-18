`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:58:54 01/14/2010 
// Design Name: 
// Module Name:    arp 
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
module arp(
    input mac_clk, reset,
    input packet_ready,
	 output reg done_with_packet,
    input [7:0] packet_data,
    output reg [5:0] packet_read_addr,
    input [47:0] myMAC,
    input [31:0] myIP,
    output reg [7:0] packet_out,
	 output reg [5:0] packet_out_addr,
    output reg packet_out_we, packet_xmit
    );

	reg [3:0] state;
parameter ST_IDLE                 = 4'h0;
parameter ST_CHECKCONSTWAIT       = 4'h1;
parameter ST_CHECKCONST           = 4'h2;
parameter ST_CHECKIP_WAIT         = 4'h3;
parameter ST_CHECKIP              = 4'h4;
parameter ST_RESP_READSET         = 4'h5;
parameter ST_RESP_READWAIT        = 4'h6;
parameter ST_RESP_WE              = 4'h7;
parameter ST_RESP_NEXT            = 4'h8;
parameter ST_RESP_READWAIT2       = 4'h9;
parameter ST_PREIDLE              = 4'hd;
parameter ST_DONEOK               = 4'he;
parameter ST_DONEFAIL             = 4'hf;

// to be worth responding to, HARDWARE = 0x0 0x1, PROTOCOL = 0x8 0x0,
//                            HLEN = 0x6, PLEN=0x4, OPERATION = 0x0 0x1
//                            TARGET IA = my IP 

	wire [7:0] compareConst, compareIP;
	wire [4:0] resp_read_addr;
	wire [7:0] resp_data;
	
always @(posedge mac_clk)
	if (reset) begin 
		state<=ST_IDLE;
		packet_out_we<=0;
		packet_xmit<=0;
		done_with_packet<=0;
	end else case (state)
	ST_IDLE: if (packet_ready) begin
		packet_read_addr<=6'd14; // just after the header
		packet_out_addr<=0;
		packet_out_we<=0;
		packet_xmit<=0;
		done_with_packet<=0;
      state<=ST_CHECKCONSTWAIT;
	end
	ST_CHECKCONSTWAIT : state<=ST_CHECKCONST; // one wait state
	ST_CHECKCONST :
		if (packet_data != compareConst) state<=ST_DONEFAIL;
		else if (packet_read_addr==6'd21) begin
			packet_read_addr<=6'd38;
			state<=ST_CHECKIP_WAIT;
		end else begin
			packet_read_addr<=packet_read_addr+1;
			state<=ST_CHECKCONSTWAIT;
		end
	ST_CHECKIP_WAIT : state<=ST_CHECKIP;
	ST_CHECKIP :
		if (packet_data != compareIP) state<=ST_DONEFAIL;
		else if (packet_read_addr==6'd41) state<=ST_RESP_READSET;
		else begin
			packet_read_addr<=packet_read_addr+1;
			state<=ST_CHECKIP_WAIT;
		end
	ST_RESP_READSET : begin
		packet_read_addr<=resp_read_addr;
		state<=ST_RESP_READWAIT;
	end
	ST_RESP_READWAIT : begin
		state<=ST_RESP_READWAIT2;
	end
	ST_RESP_READWAIT2 : begin
		state<=ST_RESP_WE;
	end
	ST_RESP_WE : begin
		packet_out<=resp_data;
		packet_out_we<=1;
		state<=ST_RESP_NEXT;
	end
	ST_RESP_NEXT : begin
		packet_out_we<=0;
		if (packet_out_addr==6'd42) state<=ST_DONEOK;
		else begin
			packet_out_addr<=packet_out_addr+1;
			state<=ST_RESP_READSET;
      end
	end
	ST_DONEFAIL : begin
		done_with_packet<=1;
		if (done_with_packet==0) state<=ST_DONEFAIL;
		else state<=ST_PREIDLE;
	end
	ST_DONEOK : begin
		done_with_packet<=1;
		packet_xmit<=1;
		if (done_with_packet==0) state<=ST_DONEOK;
		else state<=ST_PREIDLE;
	end
	ST_PREIDLE : begin
		done_with_packet<=0;
		packet_xmit<=0;
		if (done_with_packet==1) state<=ST_PREIDLE;
		else state<=ST_IDLE;
	end
	
	endcase


assign compareConst= (packet_read_addr==6'd15)?(8'h1):
							(packet_read_addr==6'd16)?(8'h8):
							(packet_read_addr==6'd18)?(8'h6):
							(packet_read_addr==6'd19)?(8'h4):
							(packet_read_addr==6'd21)?(8'h1):
							8'h0;

assign compareIP=	(packet_read_addr==6'd38)?(myIP[31:24]):
						(packet_read_addr==6'd39)?(myIP[23:16]):
						(packet_read_addr==6'd40)?(myIP[15:8]):
						myIP[7:0];

assign resp_read_addr = (packet_out_addr==6'd00)?(6'd06):
								(packet_out_addr==6'd01)?(6'd07):
								(packet_out_addr==6'd02)?(6'd08):
								(packet_out_addr==6'd03)?(6'd09):
								(packet_out_addr==6'd04)?(6'd10):
								(packet_out_addr==6'd05)?(6'd11):
								(packet_out_addr==6'd32)?(6'd22):
								(packet_out_addr==6'd33)?(6'd23):
								(packet_out_addr==6'd34)?(6'd24):
								(packet_out_addr==6'd35)?(6'd25):
								(packet_out_addr==6'd36)?(6'd26):
								(packet_out_addr==6'd37)?(6'd27):
								(packet_out_addr==6'd38)?(6'd28):
								(packet_out_addr==6'd39)?(6'd29):
								(packet_out_addr==6'd40)?(6'd30):
								(packet_out_addr==6'd41)?(6'd31):
								packet_out_addr;
	
assign resp_data=	(packet_out_addr>=6'd00 && packet_out_addr<=6'd05)?packet_data:
							(packet_out_addr==6'd06)?myMAC[47:40]:
							(packet_out_addr==6'd07)?myMAC[39:32]:
							(packet_out_addr==6'd08)?myMAC[31:24]:
							(packet_out_addr==6'd09)?myMAC[23:16]:
							(packet_out_addr==6'd10)?myMAC[15:8]:
							(packet_out_addr==6'd11)?myMAC[7:0]:
							(packet_out_addr==6'd12)?8'h08:
							(packet_out_addr==6'd13)?8'h06:
							(packet_out_addr==6'd14)?8'h00:
							(packet_out_addr==6'd15)?8'h01:
							(packet_out_addr==6'd16)?8'h08:
							(packet_out_addr==6'd17)?8'h00:
							(packet_out_addr==6'd18)?8'h06:
							(packet_out_addr==6'd19)?8'h04:
							(packet_out_addr==6'd20)?8'h00:
							(packet_out_addr==6'd21)?8'h02:
							(packet_out_addr==6'd22)?myMAC[47:40]:
							(packet_out_addr==6'd23)?myMAC[39:32]:
							(packet_out_addr==6'd24)?myMAC[31:24]:
							(packet_out_addr==6'd25)?myMAC[23:16]:
							(packet_out_addr==6'd26)?myMAC[15:8]:
							(packet_out_addr==6'd27)?myMAC[7:0]:
							(packet_out_addr==6'd28)?myIP[31:24]:
							(packet_out_addr==6'd29)?myIP[23:16]:
							(packet_out_addr==6'd30)?myIP[15:8]:
							(packet_out_addr==6'd31)?myIP[7:0]:
							packet_data;

endmodule
