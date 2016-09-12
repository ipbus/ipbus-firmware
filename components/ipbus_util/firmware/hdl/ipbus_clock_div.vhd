-- ipbus_clock_div
--
-- Various divided clocks for reset logic, flashing lights, etc
--
-- Dave Newbold, March 2013. Rewritten by Paschalis Vichoudis, June 2013

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.VComponents.all;

entity ipbus_clock_div is
	port(
		clk: in std_logic;
		d17: out std_logic;
		d25: out std_logic;
		d28: out std_logic
	);

end ipbus_clock_div;

architecture rtl of ipbus_clock_div is

	signal rst_b: std_logic;
	signal cnt: unsigned(27 downto 0);

begin

	reset_gen: component SRL16
		port map(
			a0 	=> '1',
			a1 	=> '1',
			a2 	=> '1',
			a3 	=> '1',
			clk => clk,
			d => '1',
			q => rst_b
		);	

	process(rst_b, clk)
	begin
		if rising_edge(clk) then
			if rst_b = '0' then
				cnt <= (others => '0');
			else
				cnt <= cnt + 1;
			end if;
		end if;
	end process;
	
	d28 <= cnt(27);
	d25 <= cnt(24);
	d17 <= cnt(16);

end rtl;
