-- trans_buffer_test
--
-- Slave for testing of trans_buffer out of band access to transactor
--
-- Loc 0 (15 downto 0): data to be written to buffer
-- Loc 0 (18 downto 16): request; read enable; write enable
-- Loc 1 (15 downto 0): data read from buffer
-- Loc 1 (16): done flag
--
-- Dave Newbold, March 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity trans_buffer_test is
	port(
		clk: in std_logic;
		rst: in std_logic;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		clk_t: in std_logic;
		t_wdata: out std_logic_vector(15 downto 0);
		t_we: out std_logic;
		t_rdata: in std_logic_vector(15 downto 0);
		t_re: out std_logic;
		t_req: out std_logic;
		t_done: in std_logic
	);
	
end trans_buffer_test;

architecture rtl of trans_buffer_test is

	signal ctrl, stat: ipb_reg_v(0 downto 0);
	signal stb: std_logic_vector(0 downto 0);

begin

	reg: entity work.ipbus_syncreg_v
		generic map(
			N_CTRL => 1,
			N_STAT => 1
		)
		port map(
			clk => clk,
			rst => rst,
			ipb_in => ipbus_in,
			ipb_out => ipbus_out,
			slv_clk => clk_t,
			d => stat,
			q => ctrl,
			stb => stb
		);
		
	t_wdata <= ctrl(0)(15 downto 0);
	t_we <= ctrl(0)(16) and stb(0);
	stat(0) <= X"000" & "000" & t_done & t_rdata;
	t_re <= ctrl(0)(17) and stb(0);
	t_req <= ctrl(0)(18) and stb(0);

end rtl;

