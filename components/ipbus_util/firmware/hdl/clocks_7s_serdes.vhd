-- clocks_7s_serdes
--
-- Input is a free-running 125MHz clock (taken straight from MGT clock buffer)
--
-- Dave Newbold, April 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.VComponents.all;

entity clocks_7s_serdes is
	port(
		clki_fr: in std_logic; -- Input free-running clock (125MHz)
		clki_125: in std_logic; -- Ethernet domain clk125
		clko_ipb: out std_logic; -- ipbus domain clock (31MHz)
		clko_p40: out std_logic; -- pseudo-40MHz clock
		clko_200: out std_logic; -- 200MHz clock for idelayctrl
		eth_locked: in std_logic; -- ethernet locked signal
		locked: out std_logic; -- global locked signal
		nuke: in std_logic; -- hard reset input
		soft_rst: in std_logic;
		rsto_125: out std_logic; -- clk125 domain reset (held until ethernet locked)
		rsto_ipb: out std_logic; -- ipbus domain reset
		rsto_eth: out std_logic; -- ethernet startup reset (required!)
		rsto_ipb_ctrl: out std_logic; -- ipbus domain reset for controller
		rsto_fr: out std_logic; -- clk40 domain reset
		onehz: out std_logic -- blinkenlights output
	);

end clocks_7s_serdes;

architecture rtl of clocks_7s_serdes is
	
	signal dcm_locked, sysclk, sysclk_ub, clk_ipb_i, clk_ipb_b, clkfb: std_logic;
	signal clk_p40_i, clk_p40_b: std_logic;
	signal d17, d17_d: std_logic;
	signal nuke_i, nuke_d, nuke_d2, eth_done: std_logic := '0';
	signal rst, srst, rst_ipb, rst_125, rst_ipb_ctrl: std_logic := '1';
	signal rst_ipb_int: std_logic := '1';
	signal rctr: unsigned(3 downto 0) := "0000";
	signal rst_125_int: std_logic;
	
	-- Allow some register duplication for ipb reset.  
    -- Not sure if it will propagate down through hierarchy
	attribute MAX_FANOUT : integer;
	attribute MAX_FANOUT of rst_ipb : signal is 10; 
	
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
			clkin1_period => 8.0,
			clkfbout_mult_f => 8.0, -- VCO freq 1000MHz
			clkout1_divide => 32,
			clkout2_divide => 25,
			clkout3_divide => 5
		)
		port map(
			clkin1 => sysclk,
			clkfbin => clkfb,
			clkfbout => clkfb,
			clkout1 => clk_ipb_i,
			clkout2 => clk_p40_i,
			clkout3 => clko_200, -- No BUFG needed here, goes to idelayctrl on local routing
			locked => dcm_locked,
			rst => '0',
			pwrdwn => '0'
		);
	
	clkdiv: entity work.ipbus_clock_div port map(
		clk => sysclk,
		d17 => d17,
		d28 => onehz
	);
	
	process(sysclk)
	begin
		if rising_edge(sysclk) then
			d17_d <= d17;
			if d17='1' and d17_d='0' then
				rst <= nuke_d2 or not dcm_locked;
				nuke_d <= nuke_i; -- ~1ms time bomb (allows return packet to be sent)
				nuke_d2 <= nuke_d;
				eth_done <= (eth_done or eth_locked) and not rst;
				rsto_eth <= rst; -- delayed reset for ethernet block to avoid startup issues
			end if;
		end if;
	end process;
	
	locked <= dcm_locked;
	srst <= '1' when rctr /= "0000" else '0';
	
	
	-- Large skew between incoming sysclk and clk_ipb_b leads to hold violations on rsto_ipb & rsto_ipb_ctrl.
	-- First move reset to ipb_clk domain via async path and then generate resets.
	
    sync_rst_to_clk_ipb: entity work.synchroniser 
    port map(
        clk => clk_ipb_b,
        d => rst,
        q => rst_ipb_ctrl);
        
	process(clk_ipb_b)
	begin
		if rising_edge(clk_ipb_b) then
			rst_ipb_int <= rst_ipb_ctrl or srst;
			rst_ipb <= rst_ipb_int;
			nuke_i <= nuke;
			if srst = '1' or soft_rst = '1' then
				rctr <= rctr + 1;
			end if;
		end if;
	end process;
	
	rsto_ipb_ctrl <= rst_ipb_ctrl;

	rsto_ipb <= rst_ipb;	
	
	-- clki_125 derived from txoutclk from transceiver driven by oscillator that also drives sysclk.
	-- Vivado probably treats clocks as async.  Play it safe and also add sync unit here.
	-- First derive rst_125_int in sysclk domain (i.e. that of rst & eth_done)
	
	process(sysclk)
    begin
        if rising_edge(sysclk) then
			rst_125_int <= rst or not eth_done;
        end if;
    end process;	
	
    sync_rst_to_clk_125: entity work.synchroniser 
    port map(
        clk => clki_125,
        d => rst_125_int,
        q => rst_125);	
	
	
	rsto_125 <= rst_125;
	
	rsto_fr <= rst;
		
end rtl;
