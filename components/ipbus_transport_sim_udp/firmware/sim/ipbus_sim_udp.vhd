---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------


-- Uses the FLI mechanism to send / receive UDP packets from uHAL.
--
-- There are two modes of operation:
--
-- If MULTI_PACKET = false, there is a 'one-in, one-out' assumption, i.e.
-- multiple packets cannot be processed simultaneously. This allows the
-- simulator to be paused while waiting for a new packet, reducing the
-- number of cycles to be simulated. A timeout applies in case the firmware
-- decides not to reply to a packet.
--
-- If MULTI_PACKET = true, the simulator runs continuously, can receive
-- and transmit simultaneously, and can queue multiple input packets. This
-- will cause a large number of cycles to be simulated.
--
-- Dave Newbold, July 2012
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus_trans_decl.all;

entity ipbus_sim_udp is
	generic(
		MULTI_PACKET: boolean := false
	);
	port(
		clk_ipb: in std_logic;
  		rst_ipb: in std_logic;
		trans_out: out ipbus_trans_in;
		trans_in: in ipbus_trans_out
	);  
  
end ipbus_sim_udp;

architecture behavioural of ipbus_sim_udp is

	attribute FOREIGN: string;
	
	procedure get_pkt_data(
	variable del_return: in integer;
	variable mac_data_out, mac_data_valid: out integer)
	is begin
	report "ERROR: get_pkt_data can't get here";
	end;
	
	attribute FOREIGN of get_pkt_data : procedure is "get_pkt_data sim_udp_fli.so";
	
	procedure store_pkt_data(
	variable mac_data_in: in integer)
	is begin
	report "ERROR: store_pkt_data can't get here";
	end;
	
	attribute FOREIGN of store_pkt_data : procedure is "store_pkt_data sim_udp_fli.so";
	
	procedure send_pkt
	is begin
	report "ERROR: send_pkt can't get here";
	end;
	
	attribute FOREIGN of send_pkt : procedure is "send_pkt sim_udp_fli.so";
	
	constant TIMEOUT_VAL: integer := 32768;
	
	signal rxbuf_addr, txbuf_addr, rx_addr, tx_addr: unsigned(9 downto 0);
	signal rxbuf_data, txbuf_data: std_logic_vector(31 downto 0);
	signal timer: integer;
	signal rx_valid, tx_done: std_logic;
	signal tx_len: unsigned(15 downto 0);
	
	type state_type is (ST_IDLE, ST_RXPKT, ST_WAIT, ST_TXPKT);
	signal state: state_type;

begin

-- Buffers

	rxbuf: entity work.ipbus_udp_ram_buf
		port map(
			clk => clk_ipb,
			addr => rxbuf_addr,
			rda => trans_out.rdata,
			wd => rxbuf_data,
			wen => rx_valid
		);
	
	txbuf: entity work.ipbus_udp_ram_buf
		port map(
			clk => clk_ipb,
			addr => txbuf_addr,
			rda => txbuf_data,
			wd => trans_in.wdata,
			wen => trans_in.we
		);
		
-- Address lines

	rxbuf_addr <= trans_in.raddr(9 downto 0) when state = WAIT else rx_addr;
	txbuf_addr <= trans_in.waddr(9 downto 0) when state = WAIT else tx_addr;
	
	process(clk_ipb)
	begin
		if rising_edge(clk_ipb) then
			if state = ST_IDLE then
				rx_addr <= (others => '0');
				tx_addr <= (others => '0');
			else
				if rx_valid = '1' then
					rx_addr <= std_logic_vector(unsigned(rx_addr) + 1);
				end if;
				if state = ST_TXPKT then
					tx_addr <= std_logic_vector(unsigned(tx_addr) + 1);
				end if;
			end if;
		end if;
	end process;
		
-- State machine

	process(clk_ipb)
	begin
		if rising_edge(clk_ipb) then
			if rst_ipb = '1' then
				state <= ST_IDLE;
			else		
				case state is
-- Starting state
				when ST_IDLE =>
					if rx_valid = '1' then
						state <= ST_RXPKT;
					end if;
-- Receiving packet			
				when ST_RXPKT =>
					if rx_valid = '0' then
						state <= ST_WAIT;
					end if;
-- Waiting for transactor
				when ST_WAIT =>
					if timeout = '1' then
						state <= ST_IDLE;
					elsif trans_in.pkt_done = '1' then
						state <= ST_TXPKT;
					end if;
-- Transmitting packet
				when ST_TXPKT =>
					if tx_done = '1' then
						state <= ST_IDLE;
					end if;
				end case;
			end if;
			
		end if;
	end process;
	
-- Handshaking
	
	trans_out.pkt_rdy <= '1' when state = ST_WAIT else '0';
	trans_out.busy <= '0';

-- Packet rx	

	packet_rx: process(clk_ipb)
		variable del, data, datav: integer;
	begin
		if MULTI_PACKET then
			del := 0;
		else
			del := 1;
		end if;
		if rising_edge(clk_ipb) then
			get_mac_data(del_return => del, mac_data_out => data, mac_data_valid => datav);
			rxbuf_data <= std_logic_vector(to_unsigned(data, 32));
			if datav = 1 then
				rx_valid <= '1';
			else
				rx_valid <= '0';
			end if;
		end if;
	end process;

-- Packet tx

	packet_tx: process(clk_ipb)
		variable data: integer;
	begin
		if rising_edge(clk_ipb) then
			if trans_in.waddr = (others => '0') and trans_in.we = '1' then
				tx_len <= unsigned(trans_in.wdata(15 downto 0)) + unsigned(trans_in.wdata(15 downto 0)) + 1;
			end if;
			if state = ST_TXPKT then
				if tx_done = '0' or txbuf_addr = (others => '0') then
					data := to_integer(unsigned(txbuf_data));
					store_mac_data(mac_data_in => data);
				else
					put_packet;
				end if;
			end if;
		end if;
	end process;
	
	tx_done = '1' when tx_addr = tx_len else '0';
	
-- Timeout

	process(clk_ipb)
	begin
		if rising_edge(clk_ipb) then
			if state /= ST_WAIT then
				timer <= 0;
				timeout <= '0';
			elsif timeout = '0' then
				timer <= timer + 1;
				if timer = TIMEOUT_VAL then
					timeout <= '1';
				end if;
			end if;
		end if;
	end process;	
	
end behavioural;
