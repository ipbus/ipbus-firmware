-- Behavioural model of clocks for ipbus testing
--
-- The clock edges are *not* delta cycle accurate
-- Do not assume any phase relationship between clocks
--
-- Dave Newbold, March 2011

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_sim_7s is
	port(
		clko_125: out std_logic;
		clko_ipb: out std_logic;
		clko_p40: out std_logic;
		locked: out std_logic;
		nuke: in std_logic;
		soft_rst: in std_logic;
		rsto_125: out std_logic;
		rsto_ipb: out std_logic;
		rsto_ipb_ctrl: out std_logic;
		rsto_p40: out std_logic;
	);

end clock_sim_7s;

architecture behavioural of clock_sim_7s is

	signal clk125, clk_ipb, clk40, nuke_del, srst: std_logic := '0';
	signal reset_vec: std_logic_vector(3 downto 0) := X"f";
	signal rctr: unsigned(3 downto 0) := "0000";

begin

	clk125 <= not clk125 after 4 ns;
	clk_ipb <= not clk_ipb after 16 ns;
	clk40 <= not clk40 after 12.5 ns;
	
	clko_125 <= clk125;
	clko_ipb <= clk25;
	clko_p40 <= clk40;
	
	srst <= '1' when rctr /= "0000" else '0';
	
	process(clk_ipb)
	begin
		if rising_edge(clk_ipb) then
			reset_vec <= '0' & reset_vec(3 downto 1);
			if srst = '1' or soft_rst = '1' then
				rctr <= rctr + 1;
			end if;
		end if;
	end process;

	nuke_del <= nuke after 50 us;
	
	process(clk_ipb)
	begin
		if rising_edge(clk_ipb) then
			rsto_ipb_ctrl <= reset_vec(0) or nuke_del;
			rsto <= reset_vec(0) or nuke_del or srst;
		end if;
	end process;
	
	process(clk125)
	begin
		if rising_edge(clk125) then
			rsto_125 <= reset_vec(0) or nuke_del;
		end if;
	end process;
	
	process(clk40)
	begin
		if rising_edge(clk40) then
			rsto_p40 <= reset_vec(0) or nuke_del;
		end if;
	end process;
	
end behavioural;