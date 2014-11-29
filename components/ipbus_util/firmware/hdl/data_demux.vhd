-- data_demux
--
-- Demuxes data from fast to slow clock - clocks must be 'related' for timing to work
--
-- Dave Newbold, November 2014

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_demux is
	generic(
		RATIO: positive := 6;
		DWIDTH: positive := 32;
		ALIGN: integer := 0
	);
	port(
		clk_f: in std_logic; -- fast clock
		clk_s: in std_logic; -- slow clock
		rst_s: in std_logic; -- in slow clock domain
		d_f: in std_logic_vector(DWIDTH - 1 downto 0); -- in fast clock domain
		d_s: out std_logic_vector(DWIDTH * RATIO - 1 downto 0) -- in slow clock domain
	);

begin

	assert ALIGN < RATIO
		report "ALIGN generic is not valid; must have ALIGN < RATIO"
		severity failure;
	
end data_demux;

architecture rtl of data_demux is

	signal ctr: integer range RATIO - 1 downto 0 := 0;
	signal d: std_logic_vector(DWIDTH * RATIO - 1 downto 0);

begin
	
	process(clk_f)
	begin
		if rising_edge(clk_f) then

			if rst_s = '1' then
				ctr <= ALIGN;
			elsif ctr = RATIO - 1 then
				ctr <= 0;
			else
				ctr <= ctr + 1;
			end if;
			
			for i in RATIO - 1 downto 0 loop
				if ctr = i then
					d(DWIDTH * (i + i) - 1 downto DWIDTH * i) <= d_f;
				end if;
			end loop;
			
		end if;
	end process;

	process(clk_s)
	begin
		if rising_edge(clk_s) then
			d_s <= d;
		end if;
	end process;
	
end rtl;
