-- Behavioural model of clocks for ipbus testing
--
-- The clock edges are *not* delta cycle accurate
-- Do not assume any phase relationship between clk125, clk25
--
-- Dave Newbold, March 2011

library ieee;
use ieee.std_logic_1164.all;

entity clock_sim is
	port(
	  clko125: out std_logic;
	  clko25: out std_logic;
	  clko40: out std_logic;
	  nuke: in std_logic;
	  rsto: out std_logic
  );

end clock_sim;

architecture behavioural of clock_sim is

  signal clk125, clk25, clk40, nuke_del: std_logic := '0';
  signal reset_vec: std_logic_vector(3 downto 0) := X"f";

begin

  clk125 <= not clk125 after 4 ns;
  clk25 <= not clk25 after 20 ns;
  clk40 <= not clk40 after 12.5ns;
  
  clko125 <= clk125;
  clko25 <= clk25;
  clko40 <= clk40;
  
  process(clk25)
  begin
    if rising_edge(clk25) then
      reset_vec <= '0' & reset_vec(3 downto 1);
    end if;
  end process;

  nuke_del <= nuke after 50us;
  rsto <= reset_vec(0) or nuke_del;

end behavioural;