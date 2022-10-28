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
-- Transfers ipbus signals between asynchronous clock domains Performance will be very low due to four-way handshaking on every transfer.
-- For crossing between related clocks, with higher performance, use ipbus_relclk_bridge.
-- For full performance, consider using a transactor with an ipbus-to-ipbus transport
--
-- Dave Newbold, October 2022

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;

entity ipbus_clk_bridge is
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

end ipbus_clk_bridge;

architecture rtl of ipbus_clk_bridge is

	signal s_stb, s_ack, s_ack_d, d_rst_i, d_stb, stb, ack, err, d_ack: std_logic;
	signal err: std_logic;
	signal rdata: std_logic_vector(31 downto 0);

begin

	d_ipb_out.ipb_addr <= s_ipb_in.ipb_addr when rising_edge(d_clk); -- These signals are stable by the time stb goes high, no need for full CDC
	d_ipb_out.ipb_wdata <= s_ipb_in.ipb_wdata when rising_edge(d_clk);
	d_ipb_out.ipb_write <= s_ipb_in.ipb_write when rising_edge(d_clk);

	s_stb <= s_ipb_in.ipb_strobe and not s_ack; -- Strobe to dest side held high until ack sent back, then cleared to reset dest side

	cdc_sd: entity work.ipbus_cdc
        generic map(
            N => 2
        )
		port map(
			dclk => s_clk,
			d(0) => s_stb,
            d(1) => s_rst,
			qclk => d_clk,
			q(0) => d_stb,
            q(1) => d_rst_i
		);

	d_rst <= d_rst_i;

    stb <= d_stb and not (ack or err); -- Strobe to bus driven by source side strobe until ack from bus
	d_ipb_out.ipb_strobe <= stb;

	ack <= (ack or d_ipb_in.ipb_ack) and d_stb and not d_rst_i when rising_edge(d_clk); -- Ack captured from bus, cleared when source side drops strobe
	err <= (err or d_ipb_in.ipb_err) and d_stb and not d_rst_i when rising_edge(d_clk); -- Err captured from bus, cleared when source side drops strobe
	rdata <= d_ipb_in.ipb_rdata when stb = '1' and (d_ipb_in.ipb_ack = '1' or d_ipb_in.ipb_err = '1') and rising_edge(d_clk); -- Return data captured from bus on ack or err

	d_ack <= ack or err or s_ipb_in.ipb_ack or s_ipb_i.ipb_err; -- Ack back to source side driven until ack or err is cleared by strobe drop

	cdc_ds: entity work.ipbus_cdc
		port map(
			dclk => d_clk,
			d(0) => d_ack,
			qclk => s_clk,
			q(0) => s_ack
		);

	s_ack_d <= s_ack when rising_edge(m_clk);

	s_ipb_out.ipb_ack <= s_ack and not s_ack_d and ack; -- Ack set by rising edge of ack from strobe, qualified by (stable) dest side ack
	s_ipb_out.ipb_err <= s_ack and not s_ack_d and err; -- Err set by rising edge of ack from strobe, qualified by (stable) dest side err
	s_ipb_out.ipb_rdata <= rdata when rising_edge(s_clk); -- rdata from dest side is stable by the time s_ack goes high, no need for full CDC

end rtl;
