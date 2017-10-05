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


-- The ipbus slaves live in this entity - modify according to requirements
--
-- Ports can be added to give ipbus slaves access to the chip top level.
--
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;
use work.flash_package.ALL;

entity glib_slaves is
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		rst_out: out std_logic;
		eth_err_ctrl: out std_logic_vector(35 downto 0);
		eth_err_stat: in std_logic_vector(47 downto 0) := X"000000000000";
		pkt_rx: in std_logic := '0';
		pkt_tx: in std_logic := '0'
	);

end glib_slaves;

architecture rtl of glib_slaves is

	constant NSLV: positive := 3;
	signal ipbw: ipb_wbus_array(NSLV-1 downto 0);
	signal ipbr, ipbr_d: ipb_rbus_array(NSLV-1 downto 0);
	signal ctrl_reg: std_logic_vector(31 downto 0);
	signal icap_conf_trigg: std_logic;
	signal icap_conf_page: std_logic_vector(1 downto 0);
	signal flash_r: rflashr;
	signal flash_w: wflashr;
	
begin

  fabric: entity work.ipbus_fabric
    generic map(NSLV => NSLV)
    port map(
      ipb_in => ipb_in,
      ipb_out => ipb_out,
      ipb_to_slaves => ipbw,
      ipb_from_slaves => ipbr
    );

-- Slave 0: overall infrastructure control register

	slave0: entity work.ipbus_ctrlreg
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(0),
			ipbus_out => ipbr(0),
			d => X"abcdfedc",
			q => ctrl_reg
		);
		
		icap_conf_trigg <= ctrl_reg(0);
		icap_conf_page <= ctrl_reg(2 downto 1);

-- Slave 1: icap register for firmware switching

	slave1: entity work.icap_interface_wrapper
		port map(
			reset_i => ipb_rst,
			conf_trigg_i => icap_conf_trigg,
			fsm_conf_page_i => icap_conf_page,
			ipbus_clk_i => ipb_clk,
			ipbus_inv_clk_i => not ipb_clk, -- CHECK!
			ipbus_i => ipbw(1),
			ipbus_o => ipbr(1)
		);

-- Slave 2: flash interface for firmware upload

	slave2: entity work.flash_interface_wrapper
		port map(
			reset_i => ipb_rst,
			ipbus_clk_i => ipb_clk,
			ipbus_i => ipbw(2),
			ipbus_o => ipbr(2),
			flash_i => flash_r,
			flash_o => flash_w
		);

end rtl;
