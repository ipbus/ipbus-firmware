-- Builds request for UDP resend...
--
-- Dave Sankey, July 2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_build_resend is
  port (
    mac_clk: in std_logic;
    mac_rx_valid: in std_logic;
    mac_rx_last: in std_logic;
    mac_rx_error: in std_logic;
    pkt_drop_resend: in std_logic;
    req_resend: out std_logic
  );
end udp_build_resend;

architecture rtl of udp_build_resend is

begin

send_packet:  process (mac_clk)
  begin
    if rising_edge(mac_clk) then
      if mac_rx_last = '1' and pkt_drop_resend = '0' and 
      mac_rx_error = '0' then
        req_resend <= '1'
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      else
        req_resend <= '0'
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
    end if;
  end process;

end rtl;
