-- Generic ipbus slave config register for testing
--
-- generic addr_width defines number of significant address bits
--
-- We use one cycle of read / write latency to ease timing (probably not necessary)
-- The q outputs change immediately on write (no latency).
--
-- Dave Newbold, March 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_reg is
	generic(addr_width: natural := 0);
	port(
		clk: in std_logic;
		reset: in std_logic;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		q: out STD_LOGIC_VECTOR(2**addr_width*32-1 downto 0)
	);
	
end ipbus_reg;

architecture rtl of ipbus_reg is

	type reg_array is array(2**addr_width-1 downto 0) of std_logic_vector(31 downto 0);
	signal reg: reg_array;
	signal sel: integer;
	signal ack: std_logic;

begin

	sel <= to_integer(unsigned(ipbus_in.ipb_addr(addr_width - 1 downto 0))) when addr_width > 0 else 0;

	process(clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				reg <= (others=>(others=>'0'));
			elsif ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
				reg(sel) <= ipbus_in.ipb_wdata;
			end if;

			ipbus_out.ipb_rdata <= reg(sel);
			ack <= ipbus_in.ipb_strobe and not ack;

		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';

	q_gen: for i in 2**addr_width-1 downto 0 generate
		q((i+1)*32-1 downto i*32) <= reg(i);
	end generate;

end rtl;
