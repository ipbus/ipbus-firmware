-- stretcher
--
-- Stretches a single clock pulse so it's visible on an LED
--
-- Dave Newbold, January 2013
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;

entity stretcher is
	port(
		clk: in std_logic; -- Assumed to be 125MHz ipbus clock
		d: in std_logic; -- Input (edge detected)
		q: out std_logic -- LED output, ~0.25s pulse
	);

end stretcher;

architecture rtl of stretcher is

	signal d_sync, d_sync_d, d_edge, d25, d25_d, q_i: std_logic;
	
begin
	
	clkdiv: entity work.clock_div
		port map(
			clk => clk,
			d25 => d25,
			d28 => open
		);

	process(clk)
	begin
		if rising_edge(clk) then
			d_sync <= d; -- Possible clock domain crossing from slower clock (sync not important)
			d_sync_d <= d_sync;
			d_edge <= (d_sync and not d_sync_d) or (d_edge and not q_i); 
			d25_d <= d25;
			if d25='1' and d25_d='0' then
				q_i <= d_edge;
			end if;
		end if;
	end process;

	q <= q_i;
	
end rtl;
