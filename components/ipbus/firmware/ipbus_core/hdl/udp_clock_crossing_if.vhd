-- Signals crossing clock domain...
--
-- Dave Sankey, January 2013

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_clock_crossing_if is
  generic(
    BUFWIDTH: natural := 0
  );
  port (
    mac_clk: in std_logic;
--
    pkt_rdy_125: in std_logic;
    busy_125: in std_logic;
    rx_read_buffer_125: in std_logic_vector(BUFWIDTH - 1 downto 0);
    tx_write_buffer_125: in std_logic_vector(BUFWIDTH - 1 downto 0);
    pkt_done_read_125: out std_logic;
    rx_ram_sent: out std_logic;
    tx_ram_written: out std_logic;
    we_125: out std_logic;
    rst_ipb_125: out std_logic;
--
    ipb_clk: in std_logic; 
    rst_ipb: in std_logic;
--
    pkt_done_read: in std_logic;
    pkt_done_write: in std_logic;
    we: in std_logic;
    busy: out std_logic;
    pkt_rdy: out std_logic;
    rx_read_buffer: out std_logic_vector(BUFWIDTH - 1 downto 0);
    tx_write_buffer: out std_logic_vector(BUFWIDTH - 1 downto 0)
  );
end udp_clock_crossing_if;

architecture rtl of udp_clock_crossing_if is

  signal pkt_rdy_buf, busy_buf, we_buf, rst_ipb_buf: std_logic;
  signal pkt_done_read_buf, pkt_done_write_buf: std_logic_vector(2 downto 0);
  signal rx_read_buf_buf, tx_write_buf_buf: std_logic_vector(BUFWIDTH - 1 downto 0);

  attribute KEEP: string;
  attribute KEEP of pkt_done_read_buf: signal is "TRUE";
  attribute KEEP of pkt_done_write_buf: signal is "TRUE";
  attribute KEEP of pkt_rdy_buf: signal is "TRUE";
  attribute KEEP of busy_buf: signal is "TRUE";
  attribute KEEP of we_buf: signal is "TRUE";
  attribute KEEP of rst_ipb_buf: signal is "TRUE";
  attribute KEEP of rx_read_buf_buf: signal is "TRUE";
  attribute KEEP of tx_write_buf_buf: signal is "TRUE";

begin

-- rx_ram_sent and tx_ram_written only high for 1 tick (at end...)
  pkt_done_read_125 <= pkt_done_read_buf(1);
  rx_ram_sent <= pkt_done_read_buf(2) and not pkt_done_read_buf(1);
  tx_ram_written <= pkt_done_write_buf(2) and not pkt_done_write_buf(1);

pkt_done_mac_clk: process(mac_clk)
  begin
    if rising_edge(mac_clk) then
      pkt_done_read_buf <= pkt_done_read_buf(1 downto 0) & pkt_done_read
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      pkt_done_write_buf <= pkt_done_write_buf(1 downto 0) & pkt_done_write
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;      

pkt_rdy_ipb_clk: process(ipb_clk)
  begin
    if rising_edge(ipb_clk) then
-- ensure that pkt_done is still immediately reflected...
      pkt_rdy_buf <= pkt_rdy_125 and not pkt_done_read
-- pragma translate_off
      after 15 ns
-- pragma translate_on
      ;
-- ensure that pkt_done is immediately reflected...
      pkt_rdy <= pkt_rdy_buf and not pkt_done_read
-- pragma translate_off
      after 15 ns
-- pragma translate_on
      ;
    end if;
  end process;      

we_mac_clk: process(mac_clk)
  begin
    if rising_edge(mac_clk) then
      we_buf <= we
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      we_125 <= we_buf
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;      

rst_ipb_clk: process(mac_clk)
  begin
    if rising_edge(mac_clk) then
      rst_ipb_buf <= rst_ipb
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      rst_ipb_125 <= rst_ipb_buf
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;      

busy_ipb_clk: process(ipb_clk)
  variable busy_stretch: std_logic_vector(3 downto 0);
  begin
    if rising_edge(ipb_clk) then
-- ensure that pkt_done is still immediately reflected...
      busy_buf <= busy_125 or pkt_done_write
-- pragma translate_off
      after 15 ns
-- pragma translate_on
      ;
-- ensure that pkt_done is immediately reflected...
      if busy_buf = '1' or pkt_done_write = '1' then
        busy_stretch := (Others => '1');
      else
        busy_stretch := busy_stretch(2 downto 0) & '0';
      end if;
      busy <= busy_stretch(3)
-- pragma translate_off
      after 15 ns
-- pragma translate_on
      ;
    end if;
  end process;    

rx_read_buffer_ipb_clk: process(ipb_clk)
  begin
    if rising_edge(ipb_clk) then
      rx_read_buf_buf <= rx_read_buffer_125
-- pragma translate_off
      after 15 ns
-- pragma translate_on
      ;
      rx_read_buffer <= rx_read_buf_buf
-- pragma translate_off
      after 15 ns
-- pragma translate_on
      ;
    end if;
  end process;    

tx_write_buffer_ipb_clk: process(ipb_clk)
  begin
    if rising_edge(ipb_clk) then
      tx_write_buf_buf <= tx_write_buffer_125
-- pragma translate_off
      after 15 ns
-- pragma translate_on
      ;
      tx_write_buffer <= tx_write_buf_buf
-- pragma translate_off
      after 15 ns
-- pragma translate_on
      ;
    end if;
  end process;    

end rtl;