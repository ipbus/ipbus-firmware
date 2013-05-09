-- Signals crossing clock domain...
--
-- Dave Sankey, January 2013

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_clock_crossing_if is
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
--
    pkt_rdy_125: in std_logic;
    udpram_busy: in std_logic;
    pkt_done_125: out std_logic;
    we_125: out std_logic;
    rst_ipb_125: out std_logic;
--
    ipb_clk: in std_logic; 
    rst_ipb: in std_logic;
--
    pkt_done: in std_logic;
    we: in std_logic;
    busy: out std_logic;
    pkt_rdy: out std_logic;
--
		rst_ipb_sync: out std_logic
  );
end udp_clock_crossing_if;

architecture rtl of udp_clock_crossing_if is

  signal pkt_done_buf, pkt_rdy_buf, busy_buf, we_buf, rst_ipb_buf : std_logic;
  signal rst_ipb_buf: std_logic;

  attribute KEEP: string;
  attribute KEEP of pkt_done_buf: signal is "TRUE";
  attribute KEEP of pkt_rdy_buf: signal is "TRUE";
  attribute KEEP of busy_buf: signal is "TRUE";
  attribute KEEP of we_buf: signal is "TRUE";
  attribute KEEP of rst_ipb_buf: signal is "TRUE";

begin

pkt_done_mac_clk: process(mac_clk)
  begin
    if rising_edge(mac_clk) then
      pkt_done_buf <= pkt_done
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      pkt_done_125 <= pkt_done_buf
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
      pkt_rdy_buf <= pkt_rdy_125 and not pkt_done
-- pragma translate_off
      after 15 ns
-- pragma translate_on
      ;
-- ensure that pkt_done is immediately reflected...
      pkt_rdy <= pkt_rdy_buf and not pkt_done
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
  begin
    if rising_edge(ipb_clk) then
-- ensure that pkt_done is still immediately reflected...
      busy_buf <= udpram_busy or pkt_done
-- pragma translate_off
      after 15 ns
-- pragma translate_on
      ;
-- ensure that pkt_done is immediately reflected...
      busy <= busy_buf or pkt_done
-- pragma translate_off
      after 15 ns
-- pragma translate_on
      ;
    end if;
  end process;    

	ipb_rst_s: process(mac_clk)
	begin
		if rising_edge(mac_clk) then
			rst_ipb_buf <= rst_ipb;
			rst_ipb_sync <= rst_ipb_buf;
		end if;
	end process;

end rtl;