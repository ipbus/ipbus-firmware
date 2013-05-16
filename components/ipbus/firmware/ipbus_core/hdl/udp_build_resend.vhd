-- Builds request for UDP resend...
--
-- Dave Sankey, July 2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_build_resend is
  port (
    mac_clk: in std_logic;
    rx_reset: in std_logic;
    mac_rx_data: in std_logic_vector(7 downto 0);
    mac_rx_error: in std_logic;
    mac_rx_last: in std_logic;
    mac_rx_valid: in std_logic;
    pkt_drop_resend: in std_logic;
    pkt_resend: out std_logic;
    resend_pkt_id: out std_logic_vector(15 downto 0)
  );
end udp_build_resend;

architecture rtl of udp_build_resend is

begin

send_packet:  process (mac_clk)
  begin
    if rising_edge(mac_clk) then
      if mac_rx_last = '1' and pkt_drop_resend = '0' and 
      mac_rx_error = '0' then
        pkt_resend <= '1'
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      else
        pkt_resend <= '0'
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
    end if;
  end process;

resend_pkt_id_block: process(mac_clk)
  variable pkt_mask: std_logic_vector(44 downto 0);
  variable resend_pkt_id_int: std_logic_vector(15 downto 0);
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "111111" & "111111" & "11" &
        "11" & "11" & "11" & "11" & "1" & "1" & "11" &
        "1111" & "1111" & "11" & "11" & "11" & "11" & "100";
	resend_pkt_id_int := (Others => '0');
      elsif mac_rx_valid = '1' then
        if pkt_drop_resend = '1' then
	  resend_pkt_id_int := (Others => '0');
        elsif pkt_mask(44) = '0' then
          resend_pkt_id_int := resend_pkt_id_int(7 downto 0) & mac_rx_data;
        end if;
        pkt_mask := pkt_mask(43 downto 0) & '1';
      end if;
      resend_pkt_id <= resend_pkt_id_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;
end rtl;
