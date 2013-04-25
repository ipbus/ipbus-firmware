-- clocks_v5_serdes
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

entity clocks_v5_serdes is port(
	clki_125_fr: in std_logic;
	clki_125: in std_logic;
	clko_ipb: out std_logic;
	eth_locked: in std_logic;
	locked: out std_logic;
	nuke: in std_logic;
	rsto_ipb: out std_logic;
	rsto_125: out std_logic;
	rsto_eth: out std_logic;
	onehz: out std_logic
	);

end clocks_v5_serdes;

architecture rtl of clocks_v5_serdes is
	
	signal dcm_locked, sysclk, sysclk_ub, clk_ipb_i, clk_ipb_b, clkfb: std_logic;
	signal d25, d25_d: std_logic;
	signal nuke_i, nuke_d, nuke_d2: std_logic := '0';
	signal rst, rst_ipb, rst_125, rst_eth: std_logic := '1';

begin
	
	sysclk <= clki_125_fr;
	
	bufgipb: BUFG port map(
		i => clk_ipb_i,
		o => clk_ipb_b
	);
	
	clko_ipb <= clk_ipb_b;
	
	dcm0: DCM_BASE
		generic map(
			CLKIN_PERIOD => 8.0,
			CLKDV_DIVIDE => 4.0,
			CLK_FEEDBACK => "NONE"
		)
		port map(
			clkin => sysclk,
			clk0 => clki_125,
			clkdv => clk_ipb_i,
			clkfb => '0',
			locked => dcm_locked,
			rst => '0'
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
			rst_125 <= rst or not eth_locked;
		end if;
	end process;
	
	rsto_125 <= rst_125;
	
	process(sysclk)
	begin
		if rising_edge(sysclk) then
			rst_eth <= rst;
		end if;
	end process;
	
	rsto_eth <= rst_eth;
		
end rtl;

