-- ipbus_dpram
--
-- Generic 36b wide dual-port memory with ipbus access on one port
-- Note that this takes up *twice* the ipbus address space indicated by ADDR_WIDTH,
--	with the bottom 18 bits of each location in the lower half, and vice versa
--
-- Should lead to an inferred block RAM in Xilinx parts with modern tools
--
-- Note the wait state on ipbus access - full speed access is not possible
-- Can combine with peephole_ram access method for full speed access.
--
-- Dave Newbold, July 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_dpram36 is
	generic(
		ADDR_WIDTH: natural
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		rclk: in std_logic;
		we: in std_logic := '0';
		d: in std_logic_vector(35 downto 0) := (others => '0');
		q: out std_logic_vector(35 downto 0);
		addr: in std_logic_vector(ADDR_WIDTH - 1 downto 0)
	);
	
end ipbus_dpram36;

architecture rtl of ipbus_dpram36 is

	type ram_array is array(2 ** ADDR_WIDTH - 1 downto 0) of std_logic_vector(17 downto 0);
	shared variable ram_bh, ram_th: ram_array;
	signal sel, rsel: integer;
	signal ack: std_logic;

begin

	sel <= to_integer(unsigned(ipb_in.ipb_addr(ADDR_WIDTH - 1 downto 0)));

	process(clk)
	begin
		if rising_edge(clk) then
			if ipb_in.ipb_addr(ADDR_WIDTH) = '0' then
				ipb_out.ipb_rdata <= X"000" & "00" & ram_bh(sel); -- Order of statements is important to infer read-first RAM!
			else
				ipb_out.ipb_rdata <= X"000" & "00" & ram_th(sel); -- Order of statements is important to infer read-first RAM!
			end if;				
			if ipb_in.ipb_strobe='1' and ipb_in.ipb_write='1' then
				if ipb_in.ipb_addr(ADDR_WIDTH) = '0' then
					ram_bh(sel) := ipb_in.ipb_wdata(17 downto 0);
				else
					ram_th(sel) := ipb_in.ipb_wdata(17 downto 0);
				end if;
			end if;
			ack <= ipb_in.ipb_strobe and not ack;
		end if;
	end process;
	
	ipb_out.ipb_ack <= ack;
	ipb_out.ipb_err <= '0';
	
	rsel <= to_integer(unsigned(addr));
	
	process(rclk)
	begin
		if rising_edge(rclk) then
			q <= ram_th(rsel) & ram_bh(rsel); -- Order of statements is important to infer read-first RAM!
			if we = '1' then
				ram_bh(rsel) := d(17 downto 0);
				ram_th(rsel) := d(35 downto 18);
			end if;
		end if;
	end process;

end rtl;
