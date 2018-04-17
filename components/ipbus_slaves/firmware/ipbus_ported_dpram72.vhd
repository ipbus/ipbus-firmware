---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory, University of Bristol, CERN
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


-- ipbus_dpram
--
-- Generic 72b wide dual-port memory with ported ipbus access on one side
-- Only the bottom 18b of the data port are meaningful
-- Note that this takes up *four times* the internal address space indicated by ADDR_WIDTH
-- In theory, one could use only three times the address space since 3*32 = 96 > 72, but 
-- that would make the decoding of the address more complex
--
-- Should lead to an inferred block RAM in Xilinx parts with modern tools
--
-- Giovanni Petrucciani (April 2018) based on ipbus_ported_dpram36 (Dave Newbold, October 2013)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_ported_dpram72 is
	generic(
		ADDR_WIDTH: positive
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		rclk: in std_logic;
		we: in std_logic := '0';
		d: in std_logic_vector(71 downto 0);
		q: out std_logic_vector(71 downto 0);
		addr: in std_logic_vector(ADDR_WIDTH - 1 downto 0)
	);
	
end ipbus_ported_dpram72;

architecture rtl of ipbus_ported_dpram72 is
	type ram_array is array(2 ** ADDR_WIDTH - 1 downto 0) of std_logic_vector(17 downto 0);
	shared variable ram_ll, ram_lh, ram_hl, ram_hh: ram_array := (others => (others => '0'));
	signal sel, rsel: integer range 0 to 2 ** ADDR_WIDTH - 1 := 0;
	signal wcyc, wcyc_d: std_logic;
	signal dsel: unsigned(1 downto 0);
	signal ptr: unsigned(ADDR_WIDTH downto 0);
	signal data: std_logic_vector(71 downto 0);
	signal data_o: std_logic_vector(31 downto 0);
	signal wea_ll, wea_lh, wea_hl, wea_hh: std_logic;

begin

	wcyc <= ipb_in.ipb_strobe and ipb_in.ipb_write;

	process(clk)
	begin
		if falling_edge(clk) then
			if rst = '1' then
				ptr <= (others => '0');				
			elsif ipb_in.ipb_addr(0) = '0' and wcyc = '1' then
				ptr <= unsigned(ipb_in.ipb_wdata(ADDR_WIDTH downto 0));
			elsif (ipb_in.ipb_strobe = '1' and ipb_in.ipb_write = '0' and ipb_in.ipb_addr(0) = '1') or wcyc_d = '1' then
				ptr <= ptr + 1;
			end if;
		end if;
	end process;
	
	sel <= to_integer(ptr(ADDR_WIDTH downto 2));
	wea_ll <= wcyc and ipb_in.ipb_addr(0) and not ptr(0) and not ptr(1);
	wea_hl <= wcyc and ipb_in.ipb_addr(0) and ptr(0)     and not ptr(1);
	wea_lh <= wcyc and ipb_in.ipb_addr(0) and not ptr(0) and ptr(1);
	wea_hh <= wcyc and ipb_in.ipb_addr(0) and ptr(0)     and ptr(1);
	
	process(clk)
	begin
		if rising_edge(clk) then

			data <= ram_hh(sel) & ram_hl(sel) & ram_lh(sel) & ram_ll(sel);
			dsel <= ptr(1 downto 0);
				
			if wea_ll = '1' then
				ram_ll(sel) := ipb_in.ipb_wdata(17 downto 0);
			end if;
			if wea_lh = '1' then
				ram_lh(sel) := ipb_in.ipb_wdata(17 downto 0);
			end if;
			if wea_hl = '1' then
				ram_hl(sel) := ipb_in.ipb_wdata(17 downto 0);
			end if;	
                        if wea_hh = '1' then
				ram_hh(sel) := ipb_in.ipb_wdata(17 downto 0);
			end if;
			
			wcyc_d <= wcyc and ipb_in.ipb_addr(0);
		
		end if;
	end process;
	
	data_o(17 downto 0) <= data(17 downto 0 ) when dsel = "00" else 
                               data(35 downto 18) when dsel = "01" else
                               data(53 downto 36) when dsel = "10" else
                               data(71 downto 54) when dsel = "11";
	data_o(31 downto 18) <= (others => '0');
	
	ipb_out.ipb_ack <= ipb_in.ipb_strobe;
	ipb_out.ipb_err <= '0';
	ipb_out.ipb_rdata <= std_logic_vector(to_unsigned(0, 32 - ADDR_WIDTH - 1)) & std_logic_vector(ptr)
		when ipb_in.ipb_addr(0)='0' else data_o;
	
	rsel <= to_integer(unsigned(addr));
	
	process(rclk)
	begin
		if rising_edge(rclk) then
			q <= ram_hh(rsel) & ram_hl(rsel) & ram_lh(rsel) & ram_ll(rsel); -- Order of statements is important to infer read-first RAM!
			if we = '1' then
				ram_ll(rsel) := d(17 downto 0);
				ram_lh(rsel) := d(35 downto 18);
				ram_hl(rsel) := d(53 downto 36);
				ram_hh(rsel) := d(71 downto 54);
			end if;
		end if;
	end process;

end rtl;
