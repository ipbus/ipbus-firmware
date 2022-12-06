--------------------------------------------------------------------------------

-- ipbus_freq_ctr
--
-- General clock frequency monitor (slightly advanced version).
--
-- Just like the original ipbus_freq_ctr, but with a dedicated reference clock
-- for the counters, instead of relying on the IPBus clock.

--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

library unisim;
use unisim.VComponents.all;

entity ipbus_freq_ctr is
	generic(
		N_CLK: natural := 1
	);
	port(
		clk_ref: in std_logic;
		clk: in std_logic;
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clkdiv: in std_logic_vector(N_CLK - 1 downto 0)
	);

begin
	
	assert N_CLK <= 16
		report "Too many clocks for freq_ctr"
		severity failure;
	
end ipbus_freq_ctr;

architecture rtl of ipbus_freq_ctr is

	constant ADDR_WIDTH: integer := calc_width(N_CLK);
	signal sel: integer range 0 to 2 ** ADDR_WIDTH - 1 := 0;
	signal ctr, tctr, sctr: unsigned(23 downto 0) := X"000000";
	signal stat, ctrl: ipb_reg_v(0 downto 0);
	signal cd: std_logic_vector(2 ** ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal t_in, t, t_d, valid, svalid, cyc: std_logic;
	
	attribute SHREG_EXTRACT: string;
	attribute SHREG_EXTRACT of t_in: signal is "no"; -- Synchroniser not to be optimised into shreg

begin

	reg: entity work.ipbus_ctrlreg_v
		generic map(
			N_CTRL => 1,
			N_STAT => 1
		)
		port map(
			clk => clk,
			reset => rst,
			ipbus_in => ipb_in,
			ipbus_out => ipb_out,
			d => stat,
			q => ctrl
		);
		
	cyc <= ipb_in.ipb_strobe and ipb_in.ipb_write and not ipb_in.ipb_addr(0);
	sel <= to_integer(unsigned(ctrl(0)(ADDR_WIDTH - 1 downto 0))) when ADDR_WIDTH > 0 else 0;
	
	cd(N_CLK - 1 downto 0) <= clkdiv;
	cd(2 ** ADDR_WIDTH - 1 downto N_CLK) <= (others => '0');
	
	process(clk_ref) -- Synchroniser
	begin
		if rising_edge(clk_ref) then
			t_in <= cd(sel);
			t <= t_in;
			t_d <= t;
		end if;
	end process;
	
	process(clk_ref) -- Counters
	begin
		if rising_edge(clk_ref) then
		
			ctr <= ctr + 1;

			if ctr = X"000000" or (ctr(15 downto 0) = X"0000" and ctrl(0)(4) = '1') then
				sctr <= tctr;
				tctr <= X"000000";
			elsif t = '1' and t_d = '0' then
				tctr <= tctr + 1;
			end if;

			if ctr = X"000000" then
				svalid <= valid;
				valid <= '1';
			elsif cyc = '1' then
				svalid <= '0';
				valid <= '0';
			end if;
				
		end if;
	end process;
	
	stat(0) <= "0000000" & svalid & std_logic_vector(sctr) when ctrl(0)(4) = '0' else
		"0000000" & svalid & std_logic_vector(sctr(15 downto 0)) & X"00";
	
end rtl;

--------------------------------------------------------------------------------
