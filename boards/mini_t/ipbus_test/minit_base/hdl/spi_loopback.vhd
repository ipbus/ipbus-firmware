-- spi_loopback
--
-- Copies req data back to resp buffer for SPI test
--
-- Dave Newbold, July 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bus_arb_decl.all;

entity spi_loopback is port(
	clk: in std_logic;	-- Clock
	rst: in std_logic;	-- Sync reset
  moti: in trans_moti;
  tomi: out trans_tomi
	);

end spi_loopback;

architecture rtl of spi_loopback is

	signal addr, len: std_logic_vector(9 downto 0);
	signal active, ready_d, last, last_d, new_req: std_logic;

begin

	process(clk)
	begin

		if rising_edge(clk) then
			ready_d <= moti.ready;
			last_d <= last;
			active <= ((active and not last_d) or new_req) and not rst;
			if active='0' then
				len <= moti.rdata(9 downto 0);
			end if;
			tomi.waddr <= addr;
		end if;

		if falling_edge(clk) then
			if active = '0' then
				addr <= (others => '0');
			else
				addr <= std_logic_vector(unsigned(addr) + 1);
			end if;
		end if;

	end process;
	
	new_req <= '1' when moti.ready = '1' and ready_d = '0' else '0';
	last <= '1' when addr = len else '0';
			
	tomi.raddr <= addr;
	tomi.wdata <= moti.rdata;
	tomi.we <= active;
	tomi.done <= not active;
				
end rtl;
