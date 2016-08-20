-- ipbus_ctrs_v
--
-- Block of counters
--
-- Full clock handshaking is used, counters should always be valid
-- LIMIT controls whether counters are allowed to wrap
--
-- Dave Newbold, August 2016

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_ctrs_v is
	generic(
		N_CTRS: natural := 1;
		CTR_WIDTH: natural := 32;
		LIMIT: boolean := true
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		slv_clk: in std_logic;
		slv_rst: in std_logic;
		inc: in std_logic_vector(N_CTRS - 1 downto 0) := (others => '0');
		dec: in std_logic_vector(N_CTRS - 1 downto 0) := (others => '0')
	);
	
end ipbus_ctrs_v;

architecture rtl of ipbus_ctrs_v is

	type ctrs_t is array(N_CTRS - 1 downto 0) of unsigned(CTR_WIDTH - 1 downto 0);
	signal ctrs: ctrs_t;
	signal d: ipb_reg_v(N_CTRS - 1 downto 0);

begin

	process(slv_clk)
	begin
		if rising_edge(slv_clk) then
			if slv_rst = '1' then
				ctrs <= (others => (others => '0'));
			else
				for i in N_CTRS - 1 downto 0 loop
					if inc(i) = '1' and dec(i) = '0' then
						if ctrs(i) /= (ctrs(i)'range => '1') or not LIMIT then
							ctrs(i) <= ctrs(i) + 1;
						end if;
					elsif inc(i) = '0' and dec(i) = '1' then
						if ctrs(i) /= (ctrs(i)'range => '0') or not LIMIT then
							ctrs(i) <= ctrs(i) - 1;
						end if;
					end if;
				end loop;
			end if;
		end if;
	end process;
	
	sreg: entity work.ipbus_syncreg_v
		generic map(
			N_CTRL => 0,
			N_STAT => N_CTRS
		)
		port map(
			clk => clk,
			rst => rst,
			ipb_in => ipb_in,
			ipb_out => ipb_out,
			slv_clk => slv_clk,
			d => d
		);
	
	dgen: for i in N_CTRS - 1 downto 0 generate
		d(i) <= (31 downto CTR_WIDTH => '0') & std_logic_vector(ctrs(i));
	end generate;
			
end rtl;
