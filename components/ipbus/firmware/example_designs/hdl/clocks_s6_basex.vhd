-- clocks_s6_basex
--
-- Generates a 25MHz ipbus clock from 200MHz xtal reference
-- Includes reset logic for ipbus
--
-- Dave Newbold, April 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.VComponents.all;

entity clocks_s6_basex is port(
		sysclk_p: in std_logic;
		sysclk_n: in std_logic;
		clki_125: in std_logic;
		clko_ipb: out std_logic;
		sysclko: out std_logic;
		locked: out std_logic;
		nuke: in std_logic;
		rsto_125: out std_logic;
		rsto_ipb: out std_logic;
		onehz: out std_logic
	);

end clocks_s6_basex;

architecture rtl of clocks_s6_basex is

	signal clk_ipb_i, clk_ipb_b, d25, d25_d, dcm_locked, sysclk, sysclk_ub: std_logic;
	signal nuke_i, nuke_d, nuke_d2: std_logic := '0';
	signal rst, rst_ipb, rst_125: std_logic := '1';
	
	component clock_divider_s6 port(
		clk: in std_logic;
		d25: out std_logic;
		d28: out std_logic
	);
	end component;
	
begin

	ibufgds0: IBUFGDS port map(
		i => sysclk_p,
		ib => sysclk_n,
		o => sysclk
	);
		
	sysclko <= sysclk;
	clko_ipb <= clk_ipb_b;

	bufg_ipb: BUFG port map(
		i => clk_ipb_i,
		o => clk_ipb_b
	);

	dcm0: DCM_CLKGEN
		generic map(
			CLKIN_PERIOD => 5.0,
			CLKFX_MULTIPLY => 2,
			CLKFX_DIVIDE => 16
		)
		port map(
			clkin => sysclk,
			clkfx => clk_ipb_i,
			locked => dcm_locked,
			rst => '0'
		);
		
	clkdiv: clock_divider_s6 port map(
		clk => sysclk,
		d25 => d25,
		d28 => onehz
	);
	
	process(sysclk)
	begin
		if rising_edge(sysclk) then
			d25_d <= d25;
			if d25='1' and d25_d='0' then
				rst <= nuke_d2 or not dcm_locked;
				nuke_d <= nuke_i; -- Time bomb (allows return packet to be sent)
				nuke_d2 <= nuke_d;
			end if;
		end if;
	end process;
		
	locked <= dcm_locked;
	
	process(clk_ipb_b)
	begin
		if rising_edge(clk_ipb_b) then
			rst_ipb <= rst;
			nuke_i <= nuke;
		end if;
	end process;
	
	rsto_ipb <= rst_ipb;
	
	process(clki_125)
	begin
		if rising_edge(clki_125) then
			rst_125 <= rst;
		end if;
	end process;
	
	rsto_125 <= rst_125;

end rtl;
