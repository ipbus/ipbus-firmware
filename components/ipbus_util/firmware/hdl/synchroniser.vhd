
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.VComponents.all;

entity synchroniser is
	port(
		clk: in std_logic; 
		d: in std_logic; 
		q: out std_logic
	);
end synchroniser;

architecture rtl of synchroniser is
	
	signal q_int: std_logic;

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of fd1 : label is "TRUE";

    attribute MP7_FALSE_PATH_DEST_CELL : boolean;
    attribute MP7_FALSE_PATH_DEST_CELL of fd1  : label is TRUE;

    attribute SHREG_EXTRACT : string;
    attribute SHREG_EXTRACT of fd1, fd2 : label is "no";

	
begin
	
	fd1: FD
    port map (
      C    => clk,
      D    => d,
      Q    => q_int);

	fd2: FD
    port map (
      C    => clk,
      D    => q_int,
      Q    => q);
		
		
end rtl;
