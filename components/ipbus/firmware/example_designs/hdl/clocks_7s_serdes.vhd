-- clocks_7s_serdes
--
-- Input is a free-running 125MHz clock (taken straight from MGT clock buffer)
--
-- Dave Newbold, April 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.VComponents.all;

entity clocks_7s_serdes is
	port(
		clki_fr: in std_logic; -- Input free-running clock (125MHz)
		clki_125: in std_logic; -- Ethernet domain clk125
		clko_ipb: out std_logic; -- ipbus domain clock (31MHz)
		clko_p40: out std_logic; -- pseudo-40MHz clock
		eth_locked: in std_logic; -- ethernet locked signal
		locked: out std_logic; -- global locked signal
		nuke: in std_logic; -- hard reset input
		rsto_125: out std_logic; -- clk125 domain reset (held until ethernet locked)
		rsto_ipb: out std_logic; -- ipbus domain reset
		rsto_eth: out std_logic; -- ethernet startup reset (required!)
		rsto: out std_logic; -- clk40 domain reset
		onehz: out std_logic -- blinkenlights output
	);

end clocks_7s_serdes;

architecture rtl of clocks_7s_serdes is
	
	signal dcm_locked, sysclk, sysclk_ub, clk_ipb_i, clk_ipb_b, clkfb: std_logic;
	signal clk_p40_i, clk_p40_b: std_logic;
	signal d25, d25_d: std_logic;
	signal nuke_i, nuke_d, nuke_d2: std_logic := '0';
	signal rst, rst_ipb, rst_125, rst_eth: std_logic := '1';

begin
	
	sysclk <= clki_fr;

	bufgipb: BUFG port map(
		i => clk_ipb_i,
		o => clk_ipb_b
	);
	
	clko_ipb <= clk_ipb_b;
	
	bufgp40: BUFG port map(
		i => clk_p40_i,
		o => clk_p40_b
	);
	
	clko_p40 <= clk_p40_b;
	
	mmcm: MMCME2_BASE
		generic map(
			clkin1_period => 8.0
			clkfbout_mult_f => 8.0, -- VCO freq 1000MHz
			clkout1_divide => 32,
			clkout2_divider => 25,
		)
		port map(
			clkin1 => sysclk,
			clkfbin => clkfb,
			clkfbout => clkfb,
			clkout1 => clk_ipb_i,
			clkout2 => clk_p40_i,
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

