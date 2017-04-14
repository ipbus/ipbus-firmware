-- ipbus_ctrs_v
--
-- Block of counters
--
-- Counters are sampled when first address is read
-- LIMIT controls whether counters are allowed to wrap
-- RST_ON_READ controls whether counters are reset on sampling
--
-- Dave Newbold, August 2016

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_ctrs_v is
	generic(
		N_CTRS: positive := 1;
		CTR_WDS: positive := 1;
		LIMIT: boolean := true;
		RST_ON_READ: boolean := false
	);
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clk: in std_logic;
		rst: in std_logic;
		inc: in std_logic_vector(N_CTRS - 1 downto 0) := (others => '0');
		dec: in std_logic_vector(N_CTRS - 1 downto 0) := (others => '0');
		q: out std_logic_vector(N_CTRS * CTR_WDS * 32 - 1 downto 0)
	);
	
end ipbus_ctrs_v;

architecture rtl of ipbus_ctrs_v is

	type ctrs_t is array(N_CTRS - 1 downto 0) of unsigned(CTR_WDS * 32 - 1 downto 0);
	signal ctrs: ctrs_t;
	signal d: ipb_reg_v(N_CTRS * CTR_WDS - 1 downto 0);
	signal rstb: std_logic_vector(N_CTRS * CTR_WDS - 1 downto 0);

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				ctrs <= (others => (others => '0'));
			else
				for i in N_CTRS - 1 downto 0 loop
					if inc(i) = '1' and dec(i) = '0' then
						if ctrs(i) /= (ctrs(i)'range => '1') or not LIMIT then
							if rstb(0) = '1' and RST_ON_READ then
								ctrs(i) <= 1
							else
								ctrs(i) <= ctrs(i) + 1;
							end if;
						end if;
					elsif inc(i) = '0' and dec(i) = '1' then
						if ctrs(i) /= (ctrs(i)'range => '0') or not LIMIT then
							if rstb(0) = '1' and RST_ON_READ then
								ctrs(i) <= 0;
							else
								ctrs(i) <= ctrs(i) - 1;
							end if;
						end if;
					elsif rstb(0) = '1' and RST_ON_READ then
						ctrs(i) <= 0;
					end if;
				end loop;
			end if;
			if rstb(0) = '1' then
				for i in N_CTRS - 1 downto 0 loop
					for j in CTR_WDS - 1 downto 0 loop
						d(i * CTR_WDS + j) <= std_logic_vector(ctrs(i)(32 * (j + 1) - 1 downto 32 * j));
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
			d => d,
			rstb => rstb
		);
	
	process(ctrs)
	begin
		for i in N_CTRS - 1 downto 0 loop
			q(32 * (i + 1) * CTR_WDS - 1 downto 32 * i * CTR_WDS) <= std_logic_vector(ctrs(i));
		end loop;
	end process;
			
end rtl;
