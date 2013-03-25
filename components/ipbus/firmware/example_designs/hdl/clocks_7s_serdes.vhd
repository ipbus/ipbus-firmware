-- clocks_v6_serdes
--
-- Generates a ~32MHz ipbus clock from an external 200MHz reference
-- Includes reset logic for ipbus
--
-- Dave Newbold, April 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.VComponents.all;

entity clocks_7s_serdes is port(
	sysclk_p: in std_logic;
	sysclk_n: in std_logic;
	clki_125: in std_logic;
	clko_ipb: out std_logic;
	sysclk_o: out std_logic;
	locked: out std_logic;
	nuke: in std_logic;
	rsto_125: out std_logic;
	rsto_ipb: out std_logic;
	onehz: out std_logic
	);

end clocks_7s_serdes;

architecture rtl of clocks_7s_serdes is
	
	signal dcm_locked, sysclk, sysclk_ub, clk_ipb_i, clk_ipb_b, clkfb: std_logic;
	signal d25, d25_d: std_logic;
	signal nuke_i, nuke_d, nuke_d2: std_logic := '0';
	signal rst, rst_ipb, rst_125: std_logic := '1';

begin
	
	ibufgds0: IBUFGDS port map(
		i => sysclk_p,
		ib => sysclk_n,
		o => sysclk_ub
	);

	bufg_sys: BUFG port map(
		i => sysclk_ub,
		o => sysclk
	);

	sysclk_o <= sysclk;

	bufgipb: BUFG port map(
		i => clk_ipb_i,
		o => clk_ipb_b
	);
	
	clko_ipb <= clk_ipb_b;
	
	mmcm: MMCME2_BASE
		generic map(
			clkfbout_mult_f => 10.0,
			clkout1_divide => 32,
			clkin1_period => 10.0
		)
		port map(
			clkin1 => sysclk,
			clkfbin => clkfb,
			clkfbout => clkfb,
			clkout1 => clk_ipb_i,
			locked => dcm_locked,
			rst => '0',
			pwrdwn => '0'
		);
	
	clkdiv: entity work.clock_div port map(
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
