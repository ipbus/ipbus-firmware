--======================================================================
-- Single bit clock-domain crossing. Just the usual two-flop approach,
-- but with an added latch in the source domain.
--======================================================================

library ieee;
use ieee.std_logic_1164.all;

entity cdc_bit is
  port (
    clk_src : in std_logic;
    signal_in : in std_logic;
    clk_dst : in std_logic;
    signal_out : out std_logic
  );
end cdc_bit;

architecture rtl of cdc_bit is

  signal signal_d0 : std_logic;
  signal signal_d1 : std_logic;
  signal signal_d2 : std_logic;

  attribute async_reg : string;
  attribute async_reg of signal_d0 : signal is "true";
  attribute async_reg of signal_d1 : signal is "true";
  attribute async_reg of signal_d2 : signal is "true";

begin

  process(clk_src) is
  begin
    if rising_edge(clk_src) then
      signal_d0 <= signal_in;
    end if;
  end process;

  process(clk_dst) is
  begin
    if rising_edge(clk_dst) then
      signal_d1 <= signal_d0;
      signal_d2 <= signal_d1;
    end if;
  end process;

  signal_out <= signal_d2;

end rtl;

--======================================================================
