-- ipbus_dpram
--
-- Generic 32b (or less) wide dual-port memory with ported ipbus access on one side
-- This is a 'ported ram' taking two ipbus addresses:
-- word 0: r/w RAM pointer
-- word 1: r/w data
--
-- Note that RAM access does not require a wait state, and the address auto-increments
-- allowing efficient block transfers.
--
-- Should lead to an inferred block RAM in Xilinx parts with modern tools
--
-- Dave Newbold, October 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_ported_dpram is
	generic(
		ADDR_WIDTH: positive;
		DATA_WIDTH: positive := 32
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		rclk: in std_logic;
		we: in std_logic := '0';
		d: in std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
		q: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		addr: in std_logic_vector(ADDR_WIDTH - 1 downto 0)
	);
	
end ipbus_ported_dpram;

architecture rtl of ipbus_ported_dpram is

	type ram_array is array(2 ** ADDR_WIDTH - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	shared variable ram: ram_array;
	signal sel, rsel: integer range 0 to 2 ** ADDR_WIDTH - 1 := 0;
	signal wcyc, wcyc_d: std_logic;
	signal ptr: unsigned(ADDR_WIDTH - 1 downto 0);
	signal data: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal wea_l, wea_h: std_logic;

begin

	wcyc <= ipb_in.ipb_strobe and ipb_in.ipb_write;

	process(clk)
	begin
		if falling_edge(clk) then
			if rst = '1' then
				ptr <= (others => '0');				
			elsif ipb_in.ipb_addr(0) = '0' then
				if wcyc = '1' then
					ptr <= unsigned(ipb_in.ipb_wdata(ADDR_WIDTH - 1 downto 0));
				end if;
			else
				if (ipb_in.ipb_strobe = '1' and ipb_in.ipb_write = '0') or (wcyc_d = '1') then
					ptr <= ptr + 1;
				end if;
			end if;
		end if;
	end process;
	
	sel <= to_integer(ptr);
	
	process(clk)
	begin
		if rising_edge(clk) then
			data <= ram(sel);
			if wcyc = '1' and ipb_in.ipb_addr(0) = '1' then
				ram(sel) := ipb_in.ipb_wdata(DATA_WIDTH - 1 downto 0);
			end if;
			wcyc_d <= wcyc and ipb_in.ipb_addr(0);
		end if;
	end process;
		
	ipb_out.ipb_ack <= ipb_in.ipb_strobe;
	ipb_out.ipb_err <= '0';
	ipb_out.ipb_rdata <= (32 - ADDR_WIDTH downto 0 => '0') & std_logic_vector(ptr) when ipb_in.ipb_addr(0)='0'
		else (31 - DATA_WIDTH downto 0 => '0') & data;
	
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
