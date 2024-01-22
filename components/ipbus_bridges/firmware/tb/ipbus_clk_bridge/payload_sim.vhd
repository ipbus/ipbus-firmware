-- payload_sim
--
-- Testbench design for ipbus_clk_bridge blocks
--
-- Dave Newbold, October 2022

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.ipbus.all;
use work.ipbus_decode_ipbus_clk_bridge_tb_sim.all;

entity payload is
	generic(
		CARRIER_TYPE: std_logic_vector(7 downto 0) := x"00"
	);
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clk: in std_logic;
		rst: in std_logic;
		nuke: out std_logic;
		soft_rst: out std_logic;
		userled: out std_logic
	);

end payload;

architecture rtl of payload is

	constant DESIGN_TYPE: std_logic_vector := X"00";

	signal ipbw: ipb_wbus_array(N_SLAVES - 1 downto 0);
	signal ipbr: ipb_rbus_array(N_SLAVES - 1 downto 0);
	signal afclk, asclk, rfclk, rsclk: std_logic := '0';
	signal ipbw_af, ipbw_as, ipbw_rf, ipbw_rs, ipbw_c_af, ipbw_c_as, ipbw_c_rf, ipbw_c_rs: ipb_wbus;
	signal ipbr_af, ipbr_as, ipbr_rf, ipbr_rs, ipbr_c_af, ipbr_c_as, ipbr_c_rf, ipbr_c_rs: ipb_rbus;
	signal rst_af, rst_as, rst_rf, rst_rs, rst_c_af, rst_c_as, rst_c_rf, rst_c_rs: std_logic;
	
begin

	nuke <= '0';
	soft_rst <= '0';
	userled <= '0';

-- ipbus address decode
		
	fabric: entity work.ipbus_fabric_sel
		generic map(
    		NSLV => N_SLAVES,
    		SEL_WIDTH => IPBUS_SEL_WIDTH
    	)
		port map(
			ipb_in => ipb_in,
			ipb_out => ipb_out,
			sel => ipbus_sel_ipbus_clk_bridge_tb_sim(ipb_in.ipb_addr),
			ipb_to_slaves => ipbw,
			ipb_from_slaves => ipbr
		);

-- Clock generation

	afclk <= not afclk after 7 ns; -- Faster 'async' clock
	asclk <= not asclk after 61 ns; -- Slower 'async' clock
	rfclk <= not rfclk after 5 ns; -- Faster sync clock (4x)
	rsclk <= not rsclk after 80 ns; -- Slower sync clock (4x)

-- Direct register

	reg: entity work.ipbus_reg_v
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_REG),
			ipbus_out => ipbr(N_SLV_REG)
		);

-- Faster async clock register

	af_b: entity work.ipbus_clk_bridge
		port map(
			s_clk => ipb_clk,
			s_rst => ipb_rst,
			s_ipb_in => ipbw(N_SLV_AF_REG),
			s_ipb_out => ipbr(N_SLV_AF_REG),
			d_clk => afclk,
			d_rsto => rst_af,
			d_ipb_out => ipbw_af,
			d_ipb_in => ipbr_af
		);

	af_reg: entity work.ipbus_reg_v
		port map(
			clk => afclk,
			reset => rst_af,
			ipbus_in => ipbw_af,
			ipbus_out => ipbr_af
		);

-- Slower async clock register

	as_b: entity work.ipbus_clk_bridge
		port map(
			s_clk => ipb_clk,
			s_rst => ipb_rst,
			s_ipb_in => ipbw(N_SLV_AS_REG),
			s_ipb_out => ipbr(N_SLV_AS_REG),
			d_clk => asclk,
			d_rsto => rst_as,
			d_ipb_out => ipbw_as,
			d_ipb_in => ipbr_as
		);

	as_reg: entity work.ipbus_reg_v
		port map(
			clk => asclk,
			reset => rst_as,
			ipbus_in => ipbw_as,
			ipbus_out => ipbr_as
		);

-- Faster related clock register

	rf_b: entity work.ipbus_relclk_bridge
		generic map(
			S_CLK_FASTER => false
		)
		port map(
			s_clk => ipb_clk,
			s_rst => ipb_rst,
			s_ipb_in => ipbw(N_SLV_RF_REG),
			s_ipb_out => ipbr(N_SLV_RF_REG),
			d_clk => rfclk,
			d_rsto => rst_rf,
			d_ipb_out => ipbw_rf,
			d_ipb_in => ipbr_rf
		);

	rf_reg: entity work.ipbus_reg_v
		port map(
			clk => rfclk,
			reset => rst_rf,
			ipbus_in => ipbw_rf,
			ipbus_out => ipbr_rf
		);

-- Slower related clock register

	rs_b: entity work.ipbus_relclk_bridge
		port map(
			s_clk => ipb_clk,
			s_rst => ipb_rst,
			s_ipb_in => ipbw(N_SLV_RS_REG),
			s_ipb_out => ipbr(N_SLV_RS_REG),
			d_clk => rsclk,
			d_rsto => rst_rs,
			d_ipb_out => ipbw_rs,
			d_ipb_in => ipbr_rs
		);

	rs_reg: entity work.ipbus_reg_v
		port map(
			clk => rsclk,
			reset => rst_rs,
			ipbus_in => ipbw_rs,
			ipbus_out => ipbr_rs
		);

-- Torture test through four clock domains

	as_c: entity work.ipbus_clk_bridge
		port map(
			s_clk => ipb_clk,
			s_rst => ipb_rst,
			s_ipb_in => ipbw(N_SLV_C_REG),
			s_ipb_out => ipbr(N_SLV_C_REG),
			d_clk => asclk,
			d_rsto => rst_c_as,
			d_ipb_out => ipbw_c_as,
			d_ipb_in => ipbr_c_as
		);

	rf_c: entity work.ipbus_relclk_bridge
		generic map(
			S_CLK_FASTER => false
		)
		port map(
			s_clk => asclk,
			s_rst => rst_c_as,
			s_ipb_in => ipbw_c_as,
			s_ipb_out => ipbr_c_as,
			d_clk => rfclk,
			d_rsto => rst_c_rf,
			d_ipb_out => ipbw_c_rf,
			d_ipb_in => ipbr_c_rf
		);

	af_c: entity work.ipbus_clk_bridge
		port map(
			s_clk => rfclk,
			s_rst => rst_c_rf,
			s_ipb_in => ipbw_c_rf,
			s_ipb_out => ipbr_c_rf,
			d_clk => afclk,
			d_rsto => rst_c_af,
			d_ipb_out => ipbw_c_af,
			d_ipb_in => ipbr_c_af
		);

	rs_c: entity work.ipbus_relclk_bridge
		port map(
			s_clk => afclk,
			s_rst => rst_c_af,
			s_ipb_in => ipbw_c_af,
			s_ipb_out => ipbr_c_af,
			d_clk => rsclk,
			d_rsto => rst_c_rs,
			d_ipb_out => ipbw_c_rs,
			d_ipb_in => ipbr_c_rs
		);

	c_reg: entity work.ipbus_reg_v
		port map(
			clk => rsclk,
			reset => rst_c_rs,
			ipbus_in => ipbw_c_rs,
			ipbus_out => ipbr_c_rs
		);	

end rtl;
