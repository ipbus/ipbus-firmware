-- stretcher
--
-- Stretches a single clock pulse so it's visible on an LED
--
-- Dave Newbold, January 2013
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;

entity led_stretcher is
	generic(
		WIDTH: positive := 1
	);
	port(
		clk: in std_logic; -- Assumed to be 125MHz ipbus clock
		d: in std_logic_vector(WIDTH - 1 downto 0); -- Input (edge detected)
		q: out std_logic_vector(WIDTH - 1 downto 0) -- LED output, ~250ms pulse
	);

end led_stretcher;

architecture rtl of led_stretcher is

	signal d25, d25_d: std_logic;
	
begin
	
	clkdiv: entity work.ipbus_clock_div
		port map(
			clk => clk,
			d25 => d25,
			d28 => open
		);

	process(clk)
	begin
		if rising_edge(clk) then
			d25_d <= d25;
		end if;
	end process;
	
	lgen: for i in WIDTH - 1 downto 0 generate
	
		signal s, sd, e, q_i, q_i_d: std_logic;
	
	begin
	
		process(clk)
		begin
			if rising_edge(clk) then
				s <= d(i); -- Possible clock domain crossing from slower clock (sync not important)
				sd <= s;
				e <= (e or (s and not sd)) and not (q_i and not q_i_d);
				q_i_d <= q_i;
				if d25 = '1' and d25_d = '0' then
					q_i <= e;
				end if;
			end if;
		end process;

		q(i) <= q_i;
		
	end generate;
	
end rtl;
