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


-- Single port 32b memory
--
-- Dave Newbold, April 2019

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ipbus_udp_ram_buf_rx is
	generic(
		ADDR_WIDTH: positive := 10
	);
	port(
		clk: in std_logic;
		addr: in std_logic_vector(ADDR_WIDTH - 1 downto 0);
		rd: out std_logic_vector(63 downto 0);
		wd: in std_logic_vector(31 downto 0);
		wen: in std_logic
	);

end ipbus_udp_ram_buf_rx;

architecture rtl of ipbus_udp_ram_buf_rx is

	type ram_array is array(2 ** (ADDR_WIDTH - 1) - 1 downto 0) of std_logic_vector(31 downto 0);
	shared variable rama: ram_array  := (others => (others => '0'));
	shared variable ramb: ram_array  := (others => (others => '0'));
	signal sela, selb: integer range 0 to 2 ** (ADDR_WIDTH - 1) + 1 := 0;

begin

	sela <= to_integer(unsigned(addr(ADDR_WIDTH - 1 downto 1)) + 1) when addr(0) = '1' else to_integer(unsigned(addr(ADDR_WIDTH - 1 downto 1)));
	selb <= to_integer(unsigned(addr(ADDR_WIDTH - 1 downto 1)));

	process(clk)
	begin
		if rising_edge(clk) then
			if addr(0) = '0' then
				rd <= ramb(selb) & rama(sela);
			else
				rd <= rama(sela) & ramb(selb);
			end if;

			if wen = '1' and addr(0) = '0' then
				rama(to_integer(unsigned(addr(ADDR_WIDTH - 1 downto 1)))) := wd;
			end if;
			if wen = '1' and addr(0) = '1' then
				ramb(to_integer(unsigned(addr(ADDR_WIDTH - 1 downto 1)))) := wd;
			end if;
		end if;
	end process;

end rtl;
