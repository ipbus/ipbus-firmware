-- ipbus_dpram
--
-- Generic 36b wide dual-port memory with ported ipbus access on one side
-- Only the bottom 18b of the data port are meaningful
-- Note that this takes up *twice* the internal address space indicated by ADDR_WIDTH
--
-- Should lead to an inferred block RAM in Xilinx parts with modern tools
--
-- Dave Newbold, October 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_ported_dpram36 is
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
		d: in std_logic_vector(35 downto 0);
		q: out std_logic_vector(35 downto 0);
		addr: in std_logic_vector(ADDR_WIDTH - 1 downto 0)
	);
	
end ipbus_ported_dpram36;

architecture rtl of ipbus_ported_dpram36 is

	type ram_array is array(2 ** ADDR_WIDTH - 1 downto 0) of std_logic_vector(35 downto 0);
	shared variable ram: ram_array;
	signal sel, rsel: integer;
	signal wcyc, wcyc_d: std_logic;
	signal ptr: unsigned(ADDR_WIDTH downto 0);
	signal data: std_logic_vector(17 downto 0);

begin

	wcyc <= ipb_in.ipb_strobe and ipb_in.ipb_write;

	process(clk)
	begin
		if falling_edge(clk) then
			if rst = '1' then
				ptr <= (others => '0');				
			elsif ipb_in.ipb_addr(0) = '0' then
				if wcyc = '1' then
					ptr <= unsigned(ipb_in.ipb_wdata(ADDR_WIDTH downto 0));
				end if;
			else
				if (ipb_in.ipb_strobe = '1' and ipb_in.ipb_write = '0') or (wcyc_d = '1') then
					ptr <= ptr + 1;
				end if;
			end if;
		end if;
	end process;
	
	sel <= to_integer(ptr(ADDR_WIDTH downto 1));
	
	process(clk)
	begin
		if rising_edge(clk) then

			if ptr(0) = '0' then
				data <= ram(sel)(17 downto 0);
			else
				data <= ram(sel)(35 downto 18);
			end if;
				
			if wcyc = '1' then
				if ptr(0) = '0' then
					ram(sel)(17 downto 0) := ipb_in.ipb_wdata(17 downto 0);
				else
					ram(sel)(35 downto 18) := ipb_in.ipb_wdata(17 downto 0);
				end if;
			end if;
			
			wcyc_d <= wcyc and ipb_in.ipb_addr(0);
		
		end if;
	end process;
	
	ipb_out.ipb_ack <= ipb_in.ipb_strobe;
	ipb_out.ipb_err <= '0';
	ipb_out.ipb_rdata <= std_logic_vector(to_unsigned(0, 32 - ADDR_WIDTH - 1)) & std_logic_vector(ptr)
		when ipb_in.ipb_addr(0)='0' else X"000" & "00" & data;
	
	rsel <= to_integer(unsigned(addr));
	
	process(rclk)
	begin
		if rising_edge(rclk) then
			q <= ram(rsel); -- Order of statements is important to infer read-first RAM!
			if we = '1' then
				ram(rsel) := d;
			end if;
		end if;
	end process;

end rtl;
