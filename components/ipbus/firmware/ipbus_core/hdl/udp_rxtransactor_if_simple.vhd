-- Simple interface to rx side of transactor...
-- single RAM
--
-- Dave Sankey, September 2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_rxtransactor_if is
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
--
    payload_data: in std_logic_vector(7 downto 0);
    payload_addr: in std_logic_vector(12 downto 0);
    payload_we: in std_logic;
    payload_send: in std_logic;
    pkt_done_125: in std_logic;
    rx_reset: in std_logic;
    pkt_rdy_125: out std_logic;
--
    ipb_clk: in std_logic; 
    rst_ipb: in std_logic;
--
    pkt_done: in std_logic;
    raddr: in std_logic_vector(11 downto 0);
    rdata: out std_logic_vector(31 downto 0);
--
    rx_wea : out std_logic;
    rx_addra : out std_logic_vector(12 downto 0);
    rx_addrb : out std_logic_vector(10 downto 0);
    rx_dia : out std_logic_vector(7 downto 0);
    rx_dob : in std_logic_vector(31 downto 0);
    rxpayload_dropped: out std_logic
  );
end udp_rxtransactor_if;

architecture simple of udp_rxtransactor_if is

  signal pkt_rdy_125_sig, ram_ok : std_logic;

begin

-- mac_clk clock domain
  rx_wea <= payload_we and ram_ok and not pkt_rdy_125_sig;
  rx_addra <= payload_addr;
  rx_dia <= payload_data;
  pkt_rdy_125 <= pkt_rdy_125_sig;

-- IPBus clock domain
  rx_addrb <= raddr(10 downto 0);
  rdata <= rx_dob;

ram_status: process (mac_clk)
  variable pkt_rdy_125_i, ram_ok_i, rxpayload_dropped_i : std_logic;
  begin
    if rising_edge(mac_clk) then
      rxpayload_dropped_i := '0';
-- catch next packet arriving before we've disposed of this one...
      if payload_we = '1' and pkt_rdy_125_i = '1' then
        ram_ok_i := '0';
      end if;
      if payload_send = '1' then
        if ram_ok_i = '1' then
          pkt_rdy_125_i := '1';
	else
          rxpayload_dropped_i := '1';
	end if;
      end if;
      if pkt_done_125 = '1' then
        pkt_rdy_125_i := '0';
      end if;        
      if rx_reset = '1' then
        ram_ok_i := '1';
      end if;
      if rst_macclk = '1' then
	pkt_rdy_125_i := '0';
      end if;
      ram_ok <= ram_ok_i
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      pkt_rdy_125_sig <= pkt_rdy_125_i
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

end simple;