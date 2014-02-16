-- Generic 'peephole' RAM
--
-- generic addr_width defines number of significant address bits
--
-- This design implements a RAM block, with correct behaviour to allow
-- inference of a Xilinx block RAM. Block RAM cannot normally be used 
-- without bus wait states. This design overcomes this. It uses two
-- ipbus addresses:
--
-- loc 0: pointer register
-- loc 1: data register
--
-- Upon read or write, the pointer register is automatically incremented.
-- When used with non-incrementing read or write ipbus transactions, this allows
-- full bus utilisation for block transfers with no wait states. Real designs
-- will probably want to replace the inferred block RAM with an instantiated
-- DPRAM, and use the other port for some purpose.
--
-- Dave Newbold, April 2011
--
-- $Id: ipbus_peephole_ram.vhd 1202 2012-09-28 08:53:07Z phdmn $

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_peephole_ram is
	generic(addr_width : positive);
	port(
		clk: in STD_LOGIC;
		reset: in STD_LOGIC;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus
	);
	
end ipbus_peephole_ram;

architecture rtl of ipbus_peephole_ram is

	type reg_array is array(2**addr_width-1 downto 0) of std_logic_vector(31 downto 0);
	signal reg: reg_array;
	signal sel: integer;
	signal ptr: unsigned(addr_width-1 downto 0);
	signal data: std_logic_vector(31 downto 0);
	
begin

	sel <= to_integer(ptr);

	process(clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				ptr <= (others=>'0');
			elsif ipbus_in.ipb_strobe='1' then
				if ipbus_in.ipb_addr(0)='0' and ipbus_in.ipb_write='1' then
					ptr <= unsigned(ipbus_in.ipb_wdata(addr_width-1 downto 0));
				elsif ipbus_in.ipb_addr(0)='1' then
					if ipbus_in.ipb_write='1' then
						reg(sel) <= ipbus_in.ipb_wdata;
					end if;
					ptr <= ptr + 1;
				end if;
			end if;

			data <= reg(sel);
						
		end if;
	end process;
	
	ipbus_out.ipb_ack <= ipbus_in.ipb_strobe;
	ipbus_out.ipb_err <= '0';
	ipbus_out.ipb_rdata <= std_logic_vector(to_unsigned(0, 32 - addr_width)) & std_logic_vector(ptr)
		when ipbus_in.ipb_addr(0)='0' else data;

end rtl;
