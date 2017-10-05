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


-- ipbus_clk_bridge
--
-- Bridges ipbus signals between clock domains
-- This version works with fully asynchronous clocks, but you
-- pay a latency penalty. A simpler design could be used for
-- related clocks.
--
-- Dave Newbold, July 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;

entity ipbus_clk_bridge is
	port(
		m_clk: in std_logic;
		m_rst: in std_logic;
		m_ipb_in: in ipb_wbus;
		m_ipb_out: out ipb_rbus;
		s_clk: in std_logic;
		s_rsto: out std_logic;
		s_ipb_out: out ipb_wbus;
		s_ipb_in: in ipb_rbus
	);
	
end ipbus_clk_bridge;

architecture rtl of ipbus_clk_bridge is

begin

	wsync: entity work.syncreg_w
		generic map(
			size => 64
		)
		port map(
			m_clk => m_clk,
			m_rst => m_rst,

	s_ipb_out.ipb_addr <= m_ipb_in.ipb_addr;
	s_ipb_out.ipb_wdata <= m_ipb_in.ipb_wdata;
	s_ipb_out.ipb_write	 <= m_ipb_in.ipb_write;
	
	m_ipb_out.ipb_rdata <= s_ipb_in.ipb_rdata;
	
	ack_del(0) <= s_ipb_in.ipb_ack;
	err_del(0) <= s_ipb_in.ipb_err;
	
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' or m_ipb_in.ipb_strobe = '0' then
				ack_del(latency downto 1) <= (others => '0');
				err_del(latency downto 1) <= (others => '0');				
				got_resp <= '0';
			else
				ack_del(latency downto 1) <= ack_del(latency - 1 downto 0);
				err_del(latency downto 1) <= err_del(latency - 1 downto 0);
				got_resp <= (got_resp or ack_del(0) or err_del(0)) and
					not (ack_del(latency) or err_del(latency));
			end if;
		end if;
	end process;
	
	m_ipb_out.ipb_ack <= ack_del(latency);
	m_ipb_out.ipb_err <= err_del(latency);	
	s_ipb_out.ipb_strobe <= ipbus_in.ipb_strobe and not got_ack;
	
end rtl;
