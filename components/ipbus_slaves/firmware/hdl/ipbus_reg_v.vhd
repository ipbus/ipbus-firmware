-- ipbus_reg_v
--
-- Generic ipbus register bank
--
-- Dave Newbold, March 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_reg_v is
	generic(
		N_REG: positive := 1
	);
	port(
		clk: in std_logic;
		reset: in std_logic;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		q: out ipb_reg_v(N_REG - 1 downto 0)
	);
	
end ipbus_reg_v;

architecture rtl of ipbus_reg_v is

	constant ADDR_WIDTH: integer := calc_width(N_REG);

	signal reg: ipb_reg_v(N_REG - 1 downto 0);
	signal ri: ipb_reg_v(2 ** ADDR_WIDTH - 1 downto 0);
	signal sel: integer := 0;

begin

	sel <= to_integer(unsigned(ipbus_in.ipb_addr(ADDR_WIDTH - 1 downto 0))) when ADDR_WIDTH > 0 else 0;
	
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg <= (others => (others => '0'));
			elsif ipbus_in.ipb_strobe = '1' and ipbus_in.ipb_write = '1' and sel < N_REG then
				reg(sel) <= ipbus_in.ipb_wdata;
			end if;
		end if;
	end process;
	
	ri(N_REG - 1 downto 0) <= reg;
	ri(2 ** ADDR_WIDTH - 1 downto N_REG) <= (others => (others => '0'));
	
	ipbus_out.ipb_rdata <= ri(sel);
	ipbus_out.ipb_ack <= ipbus_in.ipb_strobe;
	ipbus_out.ipb_err <= '0';

	q <= reg;

end rtl;
