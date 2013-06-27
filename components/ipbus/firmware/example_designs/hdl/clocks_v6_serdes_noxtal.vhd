-- clocks_v6_serdes
--
-- Generates a ~32MHz ipbus clock from 125MHz reference
-- Includes reset logic for ipbus
--
-- Dave Newbold, April 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.VComponents.all;

entity clocks_v6_serdes_noxtal is port(
	clki_125_fr: in std_logic;
	clki_125: in std_logic;
	clko_ipb: out std_logic;
	clko_p40: out std_logic;
	eth_locked: in std_logic;
	locked: out std_logic;
	nuke: in std_logic;
	rsto_ipb: out std_logic;
	rsto_125: out std_logic;
	rsto_eth: out std_logic;
	rsto: out std_logic;
	onehz: out std_logic
	);

end clocks_v6_serdes_noxtal;

architecture rtl of clocks_v6_serdes_noxtal is
	
	signal dcm_locked, sysclk, sysclk_ub, clk_ipb_i, clk_ipb_b, clkfb: std_logic;
	signal clk_p40_i, clk_p40_b: std_logic;
	signal d25, d25_d: std_logic;
	signal dcm_rst, nuke_i, nuke_d, nuke_d2: std_logic := '0';
	signal rst, rst_ipb, rst_125, rst_eth: std_logic := '1';

begin

	bufgipb: BUFG port map(
		i => clk_ipb_i,
		o => clk_ipb_b
	);
	
	clko_ipb <= clk_ipb_b;
	
	sysclk <= clki_125_fr;
	
	bufgp40: BUFG port map(
		i => clk_p40_i,
		o => clk_p40_b
	);
	
	clko_p40 <= clk_p40_b;
	
	mmcm: MMCM_BASE
		generic map(
			clkin1_period => 8.0,
			clkfbout_mult_f => 8.0,
			clkout1_divide => 32,
			clkout2_divide => 25
		)
		port map(
			clkin1 => sysclk,
			clkfbin => clkfb,
			clkfbout => clkfb,
			clkout1 => clk_ipb_i,
			clkout2 => clk_p40_i,
			locked => dcm_locked,
			rst => dcm_rst,
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
				dcm_rst <= not (dcm_locked or dcm_rst);
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
	
	rsto <= rst;
		
end rtl;

