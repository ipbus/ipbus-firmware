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


-- Width adaptor for master - transactor interface to native data width
--
-- Dave Newbold, April 2019

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus_trans_decl.all;

entity ipbus_transactor_sr is
	port(
		clk: in std_logic; 
		rst: in std_logic;
		rdata: in std_logic_vector(IPB_TRANS_DATA_WDS * 32 - 1 downto 0);
		raddr: out std_logic_vector(IPB_RAM_ADDR_WIDTH - 1 downto 0);
		rx_data: out std_logic_vector(IPB_DATA_WDS * 32 - 1 downto 0); -- Packet data to transactor
		rx_len: out std_logic_vector(IPB_DW_BITS - 1 downto 0); -- Size of new data available
		rx_ack: in std_logic_vector(IPB_DW_BITS - 1 downto 0); -- Size of data just read
		tx_data: in std_logic_vector(IPB_DATA_WDS * 32 - 1 downto 0);
		tx_len: in std_logic_vector(IPB_DW_BITS - 1 downto 0);
		tx_hdr: in std_logic; -- Flags that this word is a post-facto transaction header
		tx_phdr: in std_logic; -- Flags that this word is a post-facto packet header
		tx_ack: out std_logic;
		wdata: out std_logic_vector(IPB_TRANS_DATA_WDS * 32 - 1 downto 0);
		waddr: out std_logic_vector(IPB_RAM_ADDR_WIDTH - 1 downto 0);
		we: out std_logic_vector(IPB_TRANS_DATA_WDS - 1 downto 0)
	);
 
end ipbus_transactor_sr;

architecture rtl of ipbus_transactor_sr is

	constant NR: integer := IPB_DATA_WDS + IPB_TRANS_DATA_WDS - 1;
	
	signal ra, wa, wha: unsigned(IPB_RAM_ADDR_WIDTH - 1 downto 0);
	signal cnt, ptr: unsigned(ipb_bit_width(NR) - 1 downto 0);
	type r_t is array(NR - 1 downto 0) of std_logic_vector(31 downto 0);
	signal r: r_t;
	signal rc: std_logic_vector(IPB_TRANS_DATA_WDS * 32 - 1 downto 0);
  
begin

-- RAM read address generation

	raddr <= (others => '0');
	
-- RAM read-ahead

-- Output registers

-- Read side IO

-- 

	rx_data <= (others => '0');
	rx_len <= (others => '0');
	tx_ack => '0';
	wdata => (others => '0');
	waddr => (others => '0');
	we => (others => '0');

end rtl;
