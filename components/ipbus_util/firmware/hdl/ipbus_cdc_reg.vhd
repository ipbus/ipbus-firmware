-- ipbus_cdc_reg
--
-- Utility synchroniser register for Xilinx
-- Note that synchronising buses this way is unsafe - use proper techniques
--
-- Dave Newbold, October 2016

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ipbus_cdc_reg is
	generic(
		N: natural := 1
	);
	port(
		clk: in std_logic;
		clks: in std_logic;
		d: in std_logic_vector(N - 1 downto 0);
		q: out std_logic_vector(N - 1 downto 0)
	);

end ipbus_cdc_reg;

architecture rtl of ipbus_cdc_reg is

	signal da, db: std_logic_vector(N - 1 downto 0);
	attribute ASYNC_REG: string;
	attribute ASYNC_REG of db: signal is "yes";
	attribute ASYNC_REG of q: signal is "yes";
	attribute SHREG_EXTRACT: string;
	attribute SHREG_EXTRACT of db: signal is "no";

begin

	da <= d when rising_edge(clk);
	db <= da when rising_edge(clks);
	q <= db when rising_edge(clks);
	
end rtl;
