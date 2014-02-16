-- clock_div_v6
--
-- Dave Newbold, March 2013. Rewritten by Paschalis Vichoudis, June 2013
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.VComponents.all;

entity clock_div is
	port(
		clk: in std_logic;
		d17: out std_logic;
		d25: out std_logic;
		d28: out std_logic
	);

end clock_div;

architecture rtl of clock_div is

	signal rst_b: std_logic;

begin

	reset_gen : component srl16
   port map 
	(				
		 a0 	=> '1'  ,
		 a1 	=> '1'  ,
		 a2 	=> '1'  ,
		 a3 	=> '1'  ,
		 clk 	=> clk  ,
		 d 	=> '1'  ,
		 q 	=> rst_b
	);	


	process(rst_b, clk)
		variable cnt : std_logic_vector(27 downto 0);
	begin
	if rst_b = '0' then
		cnt:=(others => '0');
	elsif rising_edge(clk) then
		d28 <= cnt(27);
		d25 <= cnt(24);
		d17 <= cnt(16);
		cnt:=cnt+1;
	end if;
	end process;

end rtl;
