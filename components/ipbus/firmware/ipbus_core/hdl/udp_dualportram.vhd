LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY udp_DualPortRAM IS
generic(
  BUFWIDTH: natural := 0;
  ADDRWIDTH: natural := 0
);
port (
  ClkA : in std_logic;
  ClkB : in std_logic;
  wea : in std_logic;
  addra : in std_logic_vector(BUFWIDTH + ADDRWIDTH - 1 downto 0);
  addrb : in std_logic_vector(BUFWIDTH + ADDRWIDTH - 1 downto 0);
  dia : in std_logic_vector(7 downto 0);
  dob : out std_logic_vector(7 downto 0)
  );
END ENTITY udp_DualPortRAM;

--
ARCHITECTURE initial OF udp_DualPortRAM IS
type ram_type is array (2**(BUFWIDTH + ADDRWIDTH) - 1 downto 0) of std_logic_vector (7 downto 0);
signal ram : ram_type;
attribute block_ram : boolean;
attribute block_ram of RAM : signal is TRUE;
BEGIN

write: process (ClkA)
begin
  if (rising_edge(ClkA)) then
    if (wea = '1') then
      ram(to_integer(unsigned(addra))) <= dia
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end if;
end process write;

read: process (ClkB)
begin
  if (rising_edge(ClkB)) then
    dob <= ram(to_integer(unsigned(addrb)))
-- pragma translate_off
    after 4 ns
-- pragma translate_on
    ;
  end if;
end process read;
END ARCHITECTURE initial;
