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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ipbus_v3_trans_decl.all;

entity ipbus_transactor_if is
	port(
		clk: in std_logic; 
		rst: in std_logic;
		trans_in: in ipbus_trans_in;
		trans_out: out ipbus_trans_out;
		ipb_req: out std_logic; -- Bus request
		ipb_grant: in std_logic; -- Bus grant
		rx_ready: out std_logic_vector(1 downto 0); -- New data is available
		rx_next: in std_logic_vector(1 downto 0); -- Request for new data from transactor
		rx_data: out std_logic_vector(63 downto 0); -- Packet data to transactor
		tx_data: in std_logic_vector(63 downto 0); -- Packet data from transactor
		tx_we: in std_logic_vector(1 downto 0); -- Transactor data valid
		tx_hdr: in std_logic; -- Header word flag from transactor
		tx_err: in std_logic
	);
 
end ipbus_transactor_if;

architecture rtl of ipbus_transactor_if is

	type state_type is (ST_IDLE, ST_FIRST, ST_HDR, ST_PREBODY, ST_BODY, ST_DONE, ST_GAP);
	signal state: state_type;
	
	signal dinit: std_logic;
	signal dnext: std_logic_vector(1 downto 0);
	signal rxd: std_logic_vector(63 downto 0);
	signal raddr, raddr_incr, raddr_d, waddr, haddr, waddrh: unsigned(addr_width - 1 downto 0);
	signal hlen, blen, rctr, wctr: unsigned(15 downto 0);
	signal idata: std_logic_vector(31 downto 0);
	signal first, start, start_d: std_logic;

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if dinit = '1' then
				raddr_d <= (others => '0');
			else
				raddr_d <= raddr;
			end if;
		end if;
	end process;

	raddr_incr <= raddr_d + 2 when dnext(1) = '1' else raddr_d + 1;
	raddr <= raddr_incr when dnext(0) = '1' else raddr_d;

	trans_out.raddr <= std_logic_vector(raddr);
	rxd <= trans_in.rdata;


	process(clk)
	begin
		if rising_edge(clk) then
		
			if rst = '1' then
				state <= ST_IDLE;
			else
				case state is

				when ST_IDLE =>  -- Starting state
					if start = '1' and start_d = '1' then
						state <= ST_FIRST;
					end if;
				
				when ST_FIRST => -- Get packet length
					if rxd(31 downto 16) = X"0000" then
						if rxd(15 downto 0) = X"0000" then
							state <= ST_DONE;
						else
							state <= ST_PREBODY;
						end if;
					else
						state <= ST_HDR;
					end if;

				when ST_HDR => -- Transfer packet info
					if rctr = hlen then
						if blen = X"0000" then
							state <= ST_DONE;
						else
							state <= ST_PREBODY;
						end if;
					end if;

				when ST_PREBODY =>
					if ipb_grant = '1' then
						state <= ST_BODY;
					end if;

				when ST_BODY => -- Transfer body
					if (rctr > blen and tx_hdr = '1') or tx_err = '1' then
						state <= ST_DONE;
					end if;

				when ST_DONE => -- Write buffer header
					state <= ST_GAP;
					
				when ST_GAP =>
					state <= ST_IDLE;

				end case;
			end if;

		end if;
	end process;

	start <= trans_in.pkt_rdy and not trans_in.busy;
	dinit <= not start;
	-- dnext <= "01" when (state = ST_FIRST or state = ST_HDR) else (rx_next when state = ST_BODY else "00");
	dnext(0) <= '1' when (state = ST_FIRST or state = ST_HDR or (state = ST_BODY and rx_next(0) = '1')) else '0';
	dnext(1) <= rx_next(1) when (state = ST_BODY) else '0';

	process(clk)
	begin
		if rising_edge(clk) then
		
			start_d <= start;
			
			if state = ST_IDLE and start = '1' then
				hlen <= unsigned(rxd(31 downto 16));
				blen <= unsigned(rxd(15 downto 0));
			end if;
			
			if state = ST_HDR or (state = ST_BODY and tx_we = "01") then
				waddr <= waddr + 1;
			elsif state = ST_BODY and tx_we = "11" then
				waddr <= waddr + 2;
			elsif state = ST_DONE or rst = '1' then
				waddr <= to_unsigned(1, addr_width);
			end if;

			if state = ST_IDLE or state = ST_PREBODY then
				rctr <= X"0001";
			elsif state = ST_HDR or (state = ST_BODY and rx_next = "01") then
				rctr <= rctr + 1;
			elsif state = ST_BODY and rx_next = "11" then
				rctr <= rctr + 2;
			end if;

			if state = ST_PREBODY then
				wctr <= X"0000";
			elsif state = ST_BODY and tx_we(0) = '1' and first = '0' then
				if tx_we(1) = '0' then
					wctr <= wctr + 1;
				else
					wctr <= wctr + 2;
				end if;
			end if;
			
			if tx_hdr = '1' then
				haddr <= waddr;
			end if;
			
			if state = ST_PREBODY then
				first <= '1';
			elsif tx_we(0) = '1' then
				first <= '0';
			end if;
						
		end if;
	end process;
	
	ipb_req <= '1' when state = ST_PREBODY or state = ST_BODY else '0';

	rx_data <= rxd;
	rx_ready(0) <= '1' when state = ST_BODY and not (rctr > blen) else '0';
	rx_ready(1) <= '1' when state = ST_BODY and not ((rctr + 1) > blen) else '0';
		
	idata <= std_logic_vector(hlen) & std_logic_vector(wctr) when state = ST_DONE
		else rxd(31 downto 0);
		
	waddrh <= (others => '0') when state = ST_DONE else waddr;
	
	trans_out.pkt_done <= '1' when state = ST_DONE else '0';
	trans_out.we <= "01" when state = ST_HDR or state = ST_DONE else ((tx_we(1) and not first) & (tx_we(0) and not first));
	trans_out.waddr <= std_logic_vector(haddr) when (state = ST_BODY and tx_hdr = '1') else std_logic_vector(waddrh);
	trans_out.wdata(31 downto 0) <= tx_data(31 downto 0) when state = ST_BODY else idata;
	trans_out.wdata(63 downto 32) <= tx_data(63 downto 32) when state = ST_BODY else X"00000000";
			
end rtl;
