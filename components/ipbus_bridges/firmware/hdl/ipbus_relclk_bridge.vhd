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
-- Transfers ipbus signals between related clock domains. For crossing between asynchronous clocks, use ipbus_clk_bridge.
-- Note that one clock must be a strict multiple of the other.
--
-- Dave Newbold, October 2022

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;

entity ipbus_relclk_bridge is
	generic(
		S_CLK_FASTER: boolean := true
	);
	port(
		s_clk: in std_logic;
		s_rst: in std_logic;
		s_ipb_in: in ipb_wbus;
		s_ipb_out: out ipb_rbus;
		d_clk: in std_logic;
		d_rsto: out std_logic;
		d_ipb_out: out ipb_wbus;
		d_ipb_in: in ipb_rbus
	);

end ipbus_relclk_bridge;

architecture rtl of ipbus_relclk_bridge is

	signal s_t, d_t: std_logic;
	signal s_c, s_c_d, s_cyc, d_c, d_c_d, d_cyc: std_logic;

	signal s_stb, s_ack, s_ack_d, d_rst_i, d_stb, ack, err, d_ack: std_logic;
	signal rdata: std_logic_vector(31 downto 0);

begin

-- Non-handshake signals

	d_ipb_out.ipb_addr <= s_ipb_in.ipb_addr when rising_edge(d_clk); -- Resample onto the dest clock; these signals are stable during bus cycle
	d_ipb_out.ipb_wdata <= s_ipb_in.ipb_wdata when rising_edge(d_clk);
	d_ipb_out.ipb_write <= s_ipb_in.ipb_write when rising_edge(d_clk);
	d_rst_i <= s_rst when rising_edge(d_clk);
	d_rsto <= d_rst_i;

-- Clock edge detection

	s_t <= s_rst or not s_t when rising_edge(s_clk); -- Toggle in source clock domain
	d_c <= s_t when rising_edge(d_clk);
	d_c_d <= d_c when rising_edge(d_clk);
	d_cyc <= d_c xor d_c_d when not S_CLK_FASTER else '1'; -- Detection of new cycle on slower source clock
	
	d_t <= d_rst_i or not d_t when rising_edge(d_clk); -- Toggle in dest clock domain
	s_c <= d_t when rising_edge(s_clk);
	s_c_d <= s_c when rising_edge(s_clk);
	s_cyc <= s_c xor s_c_d when S_CLK_FASTER else '1'; -- Detection of new cycle on slower dest clock

-- Handshaking in dest clock domain

	process(d_clk)
	begin
		if rising_edge(d_clk) then
			if d_rst_i = '1' then
				d_stb <= '0';
			elsif d_cyc = '1' then
				d_stb <= s_ipb_in.ipb_strobe;
			elsif d_ipb_in.ipb_ack = '1' or d_ipb_in.ipb_err = '1' then
				d_stb <= '0';
			end if;
		end if;
	end process;

	d_ipb_out.ipb_strobe <= d_stb;

	ack <= ((ack and not d_cyc) or d_ipb_in.ipb_ack) and not d_rst_i when rising_edge(d_clk);
	err <= ((err and not d_cyc) or d_ipb_in.ipb_err) and not d_rst_i when rising_edge(d_clk);
	rdata <= d_ipb_in.ipb_rdata when (d_ipb_in.ipb_ack = '1' or d_ipb_in.ipb_err = '1') and rising_edge(d_clk);

	d_ack <= ack or err;

-- Handshaking in source clock domain

	process(s_clk)
	begin
		if rising_edge(s_clk) then
			if s_rst = '1' then
				s_ack <= '0';
			elsif s_cyc = '1' then
				s_ack <= d_ack;
			else
				s_ack <= '0';
			end if;
		end if;
	end process;

	s_ipb_out.ipb_ack <= s_ack and ack;
	s_ipb_out.ipb_err <= s_ack and err;
	s_ipb_out.ipb_rdata <= rdata;

end rtl;
