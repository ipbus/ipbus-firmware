`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:19:33 01/15/2010 
// Design Name: 
// Module Name:    icmp 
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
module icmp(
    input mac_clk, reset,
    input packet_ready,
	output reg done_with_packet,
    input [7:0] packet_data,
    output reg [9:0] packet_read_addr,
    output reg [7:0] packet_out,
    output reg [9:0] packet_out_len,
	output reg [9:0] packet_out_addr,
    output reg packet_out_we, packet_xmit,
	output reg [31:0] reset_reg_out
    );

// Check for ping and resets.  

	reg [3:0] state;
parameter STATE_IDLE                 = 4'h0;
parameter STATE_CHECK0WAIT           = 4'h1;
parameter STATE_CHECK0               = 4'h2;
parameter STATE_RESP_READSET         = 4'h3;
parameter STATE_RESP_READWAIT        = 4'h4;
parameter STATE_RESP_READWAIT2       = 4'h5;
parameter STATE_RESP_WE              = 4'h6;
parameter STATE_RESP_NEXT            = 4'h7;
parameter STATE_ADDCHECKSUM0         = 4'h8;
parameter STATE_ADDCHECKSUM1         = 4'h9;
parameter STATE_ADDCHECKSUMDONE      = 4'ha;
parameter STATE_PREIDLE              = 4'hd;
parameter STATE_DONEOK               = 4'he;
parameter STATE_DONEFAIL             = 4'hf;

// to be worth responding to, HARDWARE = 0x0 0x1, PROTOCOL = 0x8 0x0,
//                            HLEN = 0x6, PLEN=0x4, OPERATION = 0x0 0x1
//                            TARGET IA = my IP 

	// wire [9:0] resp_read_addr;
	// wire [7:0] resp_data;
	reg [9:0] resp_read_addr;
	reg [7:0] resp_data;
  
	reg [7:0] ICMP_type;
	reg [31:0] reset_reg_int;

	reg checksum_toggle;
  
	wire [15:0] icmp_checksum;
	wire in_icmp_addresses;
	wire icmp_csum_cond;

	
assign in_icmp_addresses=(packet_out_addr>=10'd34);

//always @(posedge mac_clk)
	assign icmp_csum_cond=(state==STATE_RESP_NEXT && in_icmp_addresses);
	
ip_checksum_8bit csum_icmp( .clk( mac_clk ), .reset( state==STATE_IDLE ),
	.data(packet_out),
	.dv_even(icmp_csum_cond && !packet_out_addr[0]),
	.dv_odd(icmp_csum_cond && packet_out_addr[0]),
	.checksum(icmp_checksum));
	
always @(posedge mac_clk)
	if (reset) begin 
		state<=STATE_IDLE;
		checksum_toggle<=0;
		packet_out_we<=0;
		packet_xmit<=0;
		done_with_packet<=0;
		ICMP_type<=0;
		reset_reg_out<=0;
		reset_reg_int<=0;
	end else case (state)
	
	STATE_IDLE: if (packet_ready) begin
		packet_read_addr<=10'd34; // check the type - 14(ethernet header length) + 20(IPv4 header assumed length)
		packet_out_addr<=0;
		checksum_toggle<=0;
		packet_out_we<=0;
		packet_xmit<=0;
		packet_out_len<=10'h3ff;
		done_with_packet<=0;
 		reset_reg_out<=0;
 		reset_reg_int<=0;
		state<=STATE_CHECK0WAIT;
	end
	
	STATE_CHECK0WAIT : 
		state<=STATE_CHECK0; // one wait state
		
	STATE_CHECK0 : begin
		ICMP_type<=packet_data;
		if (packet_data == 8'd08) begin // only handle ping!
			state<=STATE_RESP_READSET; 
		end else if (packet_data == 8'd42) begin // and the "unused" #42!
			state<=STATE_RESP_READSET;
		end else state<=STATE_DONEFAIL;
	end
	
	STATE_RESP_READSET : begin // handle ping and the "unused" #42!
		checksum_toggle<=0;
		packet_read_addr<=resp_read_addr;
		state<=STATE_RESP_READWAIT;
	end
	
	STATE_RESP_READWAIT : begin
		state<=STATE_RESP_READWAIT2;
	end
	
	STATE_RESP_READWAIT2 : begin
		state<=STATE_RESP_WE;
	end
	
	STATE_RESP_WE : begin
		packet_out<=resp_data;
		packet_out_we<=1;
		if (packet_out_addr==10'd16) packet_out_len[9:8]<=packet_data[1:0];
		else if (packet_out_addr==10'd17) packet_out_len[7:0]<=packet_data;	
		else if (packet_out_addr==10'd18) packet_out_len<=packet_out_len+14; // for the ethernet header

		state<=STATE_RESP_NEXT;
		
		if ( ICMP_type==8'd42 ) begin
			if (packet_out_addr==10'd18)
				if (packet_out_len!=10'd32)
					state<=STATE_DONEFAIL;
			else if (packet_out_addr==10'd42) reset_reg_int[31:24]<=packet_data;
			else if (packet_out_addr==10'd43) reset_reg_int[23:16]<=packet_data;	
			else if (packet_out_addr==10'd44) reset_reg_int[15:8]<=packet_data;
			else if (packet_out_addr==10'd45) reset_reg_int[7:0]<=packet_data;
		end
	end
	
	STATE_RESP_NEXT : begin
		packet_out_we<=0;
		checksum_toggle<=1;
		if (packet_out_addr>10'd18 && packet_out_addr==packet_out_len ) 
			state<=STATE_ADDCHECKSUM0;
		else begin
			if (packet_out_addr==10'd35) packet_out_addr <= 10'd38;
			else packet_out_addr<=packet_out_addr+1;
			state<=STATE_RESP_READSET;
		end
	end
	
	STATE_ADDCHECKSUM0 : begin
		packet_out_addr<=10'd36;
		packet_out<=icmp_checksum[15:8];
		checksum_toggle<=0;
		packet_out_we<=1;
		state<=STATE_ADDCHECKSUM1;
	end
	
	STATE_ADDCHECKSUM1 : begin
		packet_out_addr<=10'd37;
		packet_out<=icmp_checksum[7:0];
		packet_out_we<=1;
		state<=STATE_ADDCHECKSUMDONE;
	end
	
	STATE_ADDCHECKSUMDONE : begin
		packet_out_we<=0;
		state<=STATE_DONEOK;
	end
	
	STATE_DONEFAIL : begin
		done_with_packet<=1;
		if (done_with_packet==0) state<=STATE_DONEFAIL;
		else state<=STATE_PREIDLE;
	end
	
	STATE_DONEOK : begin
		reset_reg_out<=reset_reg_int;
		done_with_packet<=1;
		packet_xmit<=1;
		if (done_with_packet==0) state<=STATE_DONEOK;
		else state<=STATE_PREIDLE;
	end
	
	STATE_PREIDLE : begin
		done_with_packet<=0;
		packet_xmit<=0;
		if (done_with_packet==1) state<=STATE_PREIDLE;
		else state<=STATE_IDLE;
	end
	
	endcase

// this section sets the address of the input pointer, according to the address of the output pointer, in order to fill the ETHERNET and IPv4 headers
// it does this by simply swapping the transmit/receive MAC addresses, copies the rest of the header and swaps the transmit/receive IP addresses
// assign resp_read_addr = (packet_out_addr==10'd00)?(10'd06):// packet out 0 (MAC destination 0) <- packet in 6 (MAC source 0)
						// (packet_out_addr==10'd01)?(10'd07):// packet out 1 (MAC destination 1) <- packet in 7 (MAC source 1)
						// (packet_out_addr==10'd02)?(10'd08):// packet out 2 (MAC destination 2) <- packet in 8 (MAC source 2)
						// (packet_out_addr==10'd03)?(10'd09):// packet out 3 (MAC destination 3) <- packet in 9 (MAC source 3)
						// (packet_out_addr==10'd04)?(10'd10):// packet out 4 (MAC destination 4) <- packet in 10 (MAC source 4)
						// (packet_out_addr==10'd05)?(10'd11):// packet out 5 (MAC destination 5) <- packet in 11 (MAC source 5)
						// (packet_out_addr==10'd06)?(10'd00):// packet out 6 (MAC source 0) <- packet in 0 (MAC destination 0)
						// (packet_out_addr==10'd07)?(10'd01):// packet out 7 (MAC source 1) <- packet in 1 (MAC destination 1)
						// (packet_out_addr==10'd08)?(10'd02):// packet out 8 (MAC source 2) <- packet in 2 (MAC destination 2)
						// (packet_out_addr==10'd09)?(10'd03):// packet out 9 (MAC source 3) <- packet in 3 (MAC destination 3)
						// (packet_out_addr==10'd10)?(10'd04):// packet out 10 (MAC source 4) <- packet in 4 (MAC destination 4)
						// (packet_out_addr==10'd11)?(10'd05):// packet out 11 (MAC source 5) <- packet in 5 (MAC destination 5)
		// // . 	
		// // . 12 through 25 are "default" making packet out 12 <- packet in	12
		// // .
		// // . these are:
		// // . 12,13 = length		
		// // . 14 = IP version + header length		
		// // . 15 = IP type of service		
		// // . 16,17 = IP total length in bytes 
		// // . 18,19 = identification
		// // . 20,21 = flags + fragment offset
		// // . 22 = time to live
		// // . 23 = protocol
		// // . 24,25 = header checksum 
		// // .
		// // . 12 through 25 are "default" making packet out 25 <- packet in	25
		// // .								
						// (packet_out_addr==10'd26)?(10'd30):// packet out 26 (IPv4 destination 0) <- packet in 30 (IPv4 source 0)
						// (packet_out_addr==10'd27)?(10'd31):// packet out 27 (IPv4 destination 1) <- packet in 31 (IPv4 source 1)
						// (packet_out_addr==10'd28)?(10'd32):// packet out 28 (IPv4 destination 2) <- packet in 32 (IPv4 source 2)
						// (packet_out_addr==10'd29)?(10'd33):// packet out 29 (IPv4 destination 3) <- packet in 33 (IPv4 source 3)
						// (packet_out_addr==10'd30)?(10'd26):// packet out 30 (IPv4 source 0) <- packet in 26 (IPv4 destination 0)
						// (packet_out_addr==10'd31)?(10'd27):// packet out 31 (IPv4 source 1) <- packet in 27 (IPv4 destination 1)
						// (packet_out_addr==10'd32)?(10'd28):// packet out 32 (IPv4 source 2) <- packet in 28 (IPv4 destination 2)
						// (packet_out_addr==10'd33)?(10'd29):// packet out 33 (IPv4 source 3) <- packet in 29 (IPv4 destination 3)
						// (packet_out_addr); // for 34 and 35, this is irrelevant since the value is fixed, rather than using the location pointed to by the read pointer
	
	

// this section sets the address of the input pointer, according to the address of the output pointer, in order to fill the ETHERNET and IPv4 headers
// it does this by simply swapping the transmit/receive MAC addresses, copies the rest of the header and swaps the transmit/receive IP addresses
always @ (packet_out_addr) 
	case (packet_out_addr) 
		10'd00 :
			// packet out 0 (MAC destination 0) <- packet in 6 (MAC source 0)
			resp_read_addr = 10'd06;
		10'd01 :
			// packet out 1 (MAC destination 1) <- packet in 7 (MAC source 1)
			resp_read_addr = 10'd07;
		10'd02 :
			// packet out 2 (MAC destination 2) <- packet in 8 (MAC source 2)
			resp_read_addr = 10'd08;
		10'd03 :
			// packet out 3 (MAC destination 3) <- packet in 9 (MAC source 3)
			resp_read_addr = 10'd09;
		10'd04 :
			// packet out 4 (MAC destination 4) <- packet in 10 (MAC source 4)
			resp_read_addr = 10'd10;
		10'd05 :
			// packet out 5 (MAC destination 5) <- packet in 11 (MAC source 5)
			resp_read_addr = 10'd11;
		10'd06 :
			// packet out 6 (MAC source 0) <- packet in 0 (MAC destination 0)
			resp_read_addr = 10'd00;
		10'd07 :
			// packet out 7 (MAC source 1) <- packet in 1 (MAC destination 1)
			resp_read_addr = 10'd01;
		10'd08 :
			// packet out 8 (MAC source 2) <- packet in 2 (MAC destination 2)
			resp_read_addr = 10'd02;
		10'd09 :
			// packet out 9 (MAC source 3) <- packet in 3 (MAC destination 3)
			resp_read_addr = 10'd03;
		10'd10 :
			// packet out 10 (MAC source 4) <- packet in 4 (MAC destination 4)
			resp_read_addr = 10'd04;
		10'd11 :
			// packet out 11 (MAC source 5) <- packet in 5 (MAC destination 5)
			resp_read_addr = 10'd05;
		// . 	
		// . 12 through 25 are "default" making packet out 12 <- packet in	12
		// .
		// . these are:
		// . 12,13 = length		
		// . 14 = IP version + header length		
		// . 15 = IP type of service		
		// . 16,17 = IP total length in bytes 
		// . 18,19 = identification
		// . 20,21 = flags + fragment offset
		// . 22 = time to live
		// . 23 = protocol
		// . 24,25 = header checksum 
		// .
		// . 12 through 25 are "default" making packet out 25 <- packet in	25
		// .		
		10'd26 :
			// packet out 26 (IPv4 destination 0) <- packet in 30 (IPv4 source 0)
			resp_read_addr = 10'd30; 
		10'd27 :
			// packet out 27 (IPv4 destination 1) <- packet in 31 (IPv4 source 1)
			resp_read_addr = 10'd31;
		10'd28 :
			// packet out 28 (IPv4 destination 2) <- packet in 32 (IPv4 source 2)
			resp_read_addr = 10'd32;
		10'd29 :
			// packet out 29 (IPv4 destination 3) <- packet in 33 (IPv4 source 3)
			resp_read_addr = 10'd33;
		10'd30 :
			// packet out 30 (IPv4 source 0) <- packet in 26 (IPv4 destination 0)
			resp_read_addr = 10'd26;
		10'd31 :
			// packet out 31 (IPv4 source 1) <- packet in 27 (IPv4 destination 1)
			resp_read_addr = 10'd27;
		10'd32 :
			// packet out 32 (IPv4 source 2) <- packet in 28 (IPv4 destination 2)
			resp_read_addr = 10'd28;
		10'd33 :
			// packet out 33 (IPv4 source 3) <- packet in 29 (IPv4 destination 3)
			resp_read_addr = 10'd29;
		default :
			// for 34 and 35, this is irrelevant since the value is fixed, rather than using the location pointed to by the read pointer
			resp_read_addr = packet_out_addr;	  
	endcase							
	
	
	
	
// // this section sets the data to be written to the location indicaterd by the output pointer
// // if it is in the ICMP packet, it sets the type/code to 0 (ping reply)
// // else, set the output value to the value of the location pointed to by the input pointer
// assign resp_data =		(packet_out_addr==10'd34)?(8'h0):// packet out 34 (ICMP type) <- 0 (ping reply)
						// (packet_out_addr==10'd35)?(8'h0):// packet out 35 (ICMP code) <- 0 (ping reply)
						// (packet_out_addr==10'd36)?(8'h0):// packet out 36 (checksum 0) <- 0 
						// (packet_out_addr==10'd37)?(8'h0):// packet out 37 (checksum 1) <- 0						
						// packet_data;

			
			
			
// this section sets the data to be written to the location indicaterd by the output pointer
// if it is in the ICMP packet, it sets the type/code to 0 (ping reply)
// else, set the output value to the value of the location pointed to by the input pointer			
always @ (packet_out_addr , packet_data) 
	case (packet_out_addr) 
		10'd34 :
			// packet out 34 (ICMP type) <- 0 (ping reply)
			resp_data = 8'h0;
		10'd35 :
			// packet out 35 (ICMP code) <- 0 (ping reply)
			resp_data = 8'h0;
		10'd36 :
			// packet out 36 (checksum 0) <- 0 
			resp_data = 8'h0;
		10'd37 :
			// packet out 37 (checksum 1) <- 0
			resp_data = 8'h0;
		default :
			resp_data = packet_data;	  
	endcase						




endmodule
