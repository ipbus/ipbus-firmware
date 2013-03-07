-- clock_div
--
-- Dave Newbold, March 2013
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.VComponents.all;

entity clock_div is
	port(
		clk: in std_logic;
		d25: out std_logic;
		d28: out std_logic
	);

end clock_div;

architecture rtl of clock_div is

	

	signal q, qr: std_logic_vector(5 downto 0);
	signal ctr: unsigned(2 downto 0) := "000";
	signal ce: std_logic;
	
begin

	q(0) <= '1';
	qr(0) <= '0';
	
	gen: for i in 5 downto 1 generate
		
		ce <= q(i-1) and not qr(i-1);
	
		sr: srlc32e
			generic map(
				INIT => X"80000000"
			)
			port map(
				q => q(i),
				a => "11111",
				ce => ce,
				clk => clk,
				d => q(i)
			);
			
	end generate;
	
	process(clk)
	begin
		if rising_edge(clk) then
			qr(5 downto 1) <= q(5 downto 1);
		end if;
	end process;
	
	d25 <= q(5);
	
	process(clk)
	begin
		if rising_edge(clk) then
			if q(5) and not qr(5) then
				ctr <= ctr + 1;
			end if;
		end if;
	end process;
	
	d28 <= ctr(2);

end rtl;
