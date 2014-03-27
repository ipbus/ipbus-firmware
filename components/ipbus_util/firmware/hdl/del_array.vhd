-- del_array
--
-- Generic delay element (should synthesise to SRL16/32 in Xilinx devices)
--
-- Dave Newbold, March 2014.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.VComponents.all;

entity del_array is
	generic(
		DWIDTH: positive;
		DELAY: integer
	);
	port(
		clk: in std_logic;
		d: in std_logic_vector(DWIDTH - 1 downto 0);
		q: out std_logic_vector(DWIDTH - 1 downto 0)
	);

end del_array;

architecture rtl of del_array is

	type del_array_t is array(DELAY downto 0) of std_logic_vector(DWIDTH - 1 downto 0);
	signal del_array: del_array_t;

begin

	del_array(0) <= d;

	process(clk)
	begin
		if rising_edge(clk) then
			del_array(DELAY downto 1) <= del_array(DELAY - 1 downto 0);
		end if;
	end process;
	
	q <= del_array(DELAY);

end rtl;

