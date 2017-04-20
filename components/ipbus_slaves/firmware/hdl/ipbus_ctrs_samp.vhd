-- ipbus_ctrs_samp
--
-- Access to block of external wide counters
-- Counters are sampled when first address is read
--
-- Dave Newbold, March 2017

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_ctrs_samp is
	generic(
		N_CTRS: positive := 1;
		CTR_WDS: positive := 1
	);
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clk: in std_logic;
		d: in std_logic_vector(N_CTRS * CTR_WDS * 32 - 1 downto 0)
	);
	
end ipbus_ctrs_samp;

architecture rtl of ipbus_ctrs_samp is

	signal di: ipb_reg_v(N_CTRS * CTR_WDS - 1 downto 0);
	signal rstb: std_logic_vector(N_CTRS * CTR_WDS - 1 downto 0);

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if rstb(0) = '1' then
				for i in N_CTRS - 1 downto 0 loop
					for j in CTR_WDS - 1 downto 0 loop
						di(i * CTR_WDS + j) <= std_logic_vector(d(32 * (CTR_WDS * i + (j + 1) - 1) downto 32 * (CTR_WDS * i + j)));
					end loop;
				end loop;
			end if;
		end if;
	end process;
	
	sreg: entity work.ipbus_syncreg_v
		generic map(
			N_CTRL => 0,
			N_STAT => N_CTRS * CTR_WDS
		)
		port map(
			clk => ipb_clk,
			rst => ipb_rst,
			ipb_in => ipb_in,
			ipb_out => ipb_out,
			slv_clk => clk,
			d => di,
			rstb => rstb
		);
			
end rtl;
