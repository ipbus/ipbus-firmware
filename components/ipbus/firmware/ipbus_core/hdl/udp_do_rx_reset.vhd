-- Generates reset for Ethernet RX logic
--
-- Dave Sankey, July 2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_do_rx_reset is
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
    mac_rx_last: in std_logic;
    mac_rx_valid: in std_logic;
    rx_reset: out std_logic
  );
end udp_do_rx_reset;

architecture rtl of udp_do_rx_reset is

  signal rx_reset_sig: std_logic;

begin

rx_reset <= rx_reset_sig and not mac_rx_valid;

rx_reset_buf:  process (mac_clk)
  variable reset_buf: std_logic_vector(11 downto 0);
  variable reset_latch: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
        reset_buf := x"800";
      else
-- NB we qualify the real mac_rx_last with mac_rx_valid in udp_if_flat!
        reset_buf := reset_buf(10 downto 0) & mac_rx_last;
      end if;
      if reset_buf(11) = '1' then
        reset_latch := '1';
      elsif mac_rx_valid = '1' then
        reset_latch := '0';
      end if;
      rx_reset_sig <= reset_latch
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process rx_reset_buf;

end architecture rtl;
