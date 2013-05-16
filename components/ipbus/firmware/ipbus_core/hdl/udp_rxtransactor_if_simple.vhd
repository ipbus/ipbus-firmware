-- Interface to rx side of transactor...
-- Even simpler, but now multi-buffer RAM!
--
-- Dave Sankey, September 2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_rxtransactor_if is
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
    rx_reset: in std_logic;
    payload_send: in std_logic;
    payload_we: in std_logic;
    pkt_done_read_125: in std_logic;
    rx_ram_busy: in std_logic;
    rx_req_send: in std_logic;
    pkt_rcvd: out std_logic;
    pkt_rdy_125: out std_logic;
    rx_wea : out std_logic;
    rxpayload_dropped: out std_logic
  );
end udp_rxtransactor_if;

architecture simple of udp_rxtransactor_if is

  signal ram_ok : std_logic;

begin

  rx_wea <= payload_we and ram_ok;

ram_status: process (mac_clk)
  variable pkt_rcvd_i, ram_ok_i, rxpayload_dropped_i: std_logic;
  begin
    if rising_edge(mac_clk) then
      rxpayload_dropped_i := '0';
      pkt_rcvd_i := '0';
      if rx_reset = '1' then
        ram_ok_i := '1';
      else
-- catch next packet arriving before we've disposed of this one...
        if payload_we = '1' and rx_ram_busy = '1' then
          ram_ok_i := '0';
        end if;
        if payload_send = '1' then
          if ram_ok_i = '1' then
            pkt_rcvd_i := '1';
	  else
            rxpayload_dropped_i := '1';
	  end if;
	  ram_ok_i := '1';
        end if;
      end if;
      ram_ok <= ram_ok_i
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      pkt_rcvd <= pkt_rcvd_i
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      rxpayload_dropped <= rxpayload_dropped_i
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

pkt_rdy_status: process (mac_clk)
-- delay change in pkt_rdy going high to allow rx_read_buffer to settle...
  variable pkt_rdy_buf: std_logic_vector(15 downto 0);
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
        pkt_rdy_buf := (Others => '0');
      else
        if rx_req_send = '1' then
          pkt_rdy_buf := pkt_rdy_buf(14 downto 0) & '1';
        elsif pkt_done_read_125 = '1' then
          pkt_rdy_buf := (Others => '0');
        else
          pkt_rdy_buf := pkt_rdy_buf(14 downto 0) & pkt_rdy_buf(0);
        end if;
      end if;
      pkt_rdy_125 <= pkt_rdy_buf(15)
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

end simple;