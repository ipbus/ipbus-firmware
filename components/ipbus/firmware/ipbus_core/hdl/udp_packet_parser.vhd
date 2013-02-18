-- Parses first 42 bytes of incoming ethernet packet for supported protocols
--
-- Dave Sankey, June 2012

library ieee;
use ieee.std_logic_1164.all;

entity udp_packet_parser is
  port (
    mac_clk: in std_logic;
    rx_reset: in std_logic;
    mac_rx_data: in std_logic_vector(7 downto 0);
    mac_rx_valid: in std_logic;
    MAC_addr: in std_logic_vector(47 downto 0);
    IP_addr: in std_logic_vector(31 downto 0);
    pkt_drop_arp: out std_logic;
    pkt_drop_ping: out std_logic;
    pkt_drop_payload: out std_logic;
    pkt_drop_resend: out std_logic;
    pkt_drop_status: out std_logic
  );
end udp_packet_parser;

architecture v2 of udp_packet_parser is

begin


-- ARP:
-- Ethernet DST_MAC(6), SRC_MAC(6), Ether_Type = x"0806"
-- HTYPE = x"0001"
-- PTYPE = x"0800"
-- HLEN = x"06", PLEN = x"04"
-- OPER = x"0001"
-- SHA(6)
-- SPA(4)
-- THA(6)
-- TPA(4) = MY_IP(4)
arp:  process (mac_clk)
  variable pkt_data: std_logic_vector(111 downto 0);
  variable pkt_mask: std_logic_vector(41 downto 0);
  variable pkt_drop: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "111111" & "111111" & "00" &
        "00" & "00" & "00" & "00" & "111111" &
        "1111" & "111111" & "0000";
        pkt_data := x"0806" & x"0001" & x"0800" & x"0604" & x"0001" & IP_addr;
        pkt_drop := '0';
      elsif mac_rx_valid = '1' then
        if pkt_mask(41) = '0' then
          if pkt_data(111 downto 104) /= mac_rx_data then
            pkt_drop := '1';
          end if;
          pkt_data := pkt_data(103 downto 0) & x"00";
        end if;
        pkt_mask := pkt_mask(40 downto 0) & '1';
      end if;
      pkt_drop_arp <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;


-- Ping:
-- Ethernet DST_MAC(6), SRC_MAC(6), Ether_Type = x"0800"
-- IP VERS = x"4", HL = x"5", TOS = x"00"
-- IP LEN
-- IP ID
-- IP FLAG-FRAG = x"4000"
-- IP TTL, PROTO = x"01"
-- IP CKSUM
-- IP SPA(4)
-- IP DPA(4)
-- ICMP TYPE = "08", CODE = "00"
-- ICMP CKSUM
-- ICMP data...
ping:  process (mac_clk)
  variable pkt_data: std_logic_vector(151 downto 0);
  variable pkt_mask: std_logic_vector(41 downto 0);
  variable pkt_drop: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "000000" & "111111" & "00" &
        "00" & "11" & "11" & "00" & "1" & "0" & "11" &
        "1111" & "0000" & "00" & "11" & "1111";
        pkt_data := MAC_addr & x"0800" & x"4500" & x"4000" & x"01" &
        IP_addr & x"0800";
        pkt_drop := '0';
      elsif mac_rx_valid = '1' then
        if pkt_mask(41) = '0' then
          if pkt_data(151 downto 144) /= mac_rx_data then
            pkt_drop := '1';
          end if;
          pkt_data := pkt_data(143 downto 0) & x"00";
        end if;
        pkt_mask := pkt_mask(40 downto 0) & '1';
      end if;
      pkt_drop_ping <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- UDP payload:
-- Ethernet DST_MAC(6), SRC_MAC(6), Ether_Type = x"0800"
-- IP VERS = x"4", HL = x"5", TOS = x"00"
-- IP LEN
-- IP ID
-- IP FLAG-FRAG = x"4000"
-- IP TTL, PROTO = x"11"
-- IP CKSUM
-- IP SPA(4)
-- IP DPA(4)
-- UDP SRCPORT
-- UDP DSTPORT (50001)
-- UDP LEN
-- UDP CKSUM
-- UDP data...
payload:  process (mac_clk)
  variable pkt_data: std_logic_vector(151 downto 0);
  variable pkt_mask: std_logic_vector(41 downto 0);
  variable pkt_drop: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "000000" & "111111" & "00" &
        "00" & "11" & "11" & "00" & "1" & "0" & "11" &
        "1111" & "0000" & "11" & "00" & "11" & "11";
        pkt_data := MAC_addr & x"0800" & x"4500" & x"4000" & x"11" &
        IP_addr & x"C351";
        pkt_drop := '0';
      elsif mac_rx_valid = '1' then
        if pkt_mask(41) = '0' then
          if pkt_data(151 downto 144) /= mac_rx_data then
            pkt_drop := '1';
          end if;
          pkt_data := pkt_data(143 downto 0) & x"00";
        end if;
        pkt_mask := pkt_mask(40 downto 0) & '1';
      end if;
      pkt_drop_payload <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- UDP status request:
-- Ethernet DST_MAC(6), SRC_MAC(6), Ether_Type = x"0800"
-- IP VERS = x"4", HL = x"5", TOS = x"00"
-- IP LEN
-- IP ID
-- IP FLAG-FRAG = x"4000"
-- IP TTL, PROTO = x"11"
-- IP CKSUM
-- IP SPA(4)
-- IP DPA(4)
-- UDP SRCPORT
-- UDP DSTPORT (50002)
-- UDP LEN
-- UDP CKSUM
-- UDP data...
status_request:  process (mac_clk)
  variable pkt_data: std_logic_vector(151 downto 0);
  variable pkt_mask: std_logic_vector(41 downto 0);
  variable pkt_drop: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "000000" & "111111" & "00" &
        "00" & "11" & "11" & "00" & "1" & "0" & "11" &
        "1111" & "0000" & "11" & "00" & "11" & "11";
        pkt_data := MAC_addr & x"0800" & x"4500" & x"4000" & x"11" &
        IP_addr & x"C352";
        pkt_drop := '0';
      elsif mac_rx_valid = '1' then
        if pkt_mask(41) = '0' then
          if pkt_data(151 downto 144) /= mac_rx_data then
            pkt_drop := '1';
          end if;
          pkt_data := pkt_data(143 downto 0) & x"00";
        end if;
        pkt_mask := pkt_mask(40 downto 0) & '1';
      end if;
      pkt_drop_status <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- UDP resend request:
-- Ethernet DST_MAC(6), SRC_MAC(6), Ether_Type = x"0800"
-- IP VERS = x"4", HL = x"5", TOS = x"00"
-- IP LEN
-- IP ID
-- IP FLAG-FRAG = x"4000"
-- IP TTL, PROTO = x"11"
-- IP CKSUM
-- IP SPA(4)
-- IP DPA(4)
-- UDP SRCPORT
-- UDP DSTPORT (50003)
-- UDP LEN
-- UDP CKSUM
-- UDP data...
request:  process (mac_clk)
  variable pkt_data: std_logic_vector(151 downto 0);
  variable pkt_mask: std_logic_vector(41 downto 0);
  variable pkt_drop: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "000000" & "111111" & "00" &
        "00" & "11" & "11" & "00" & "1" & "0" & "11" &
        "1111" & "0000" & "11" & "00" & "11" & "11";
        pkt_data := MAC_addr & x"0800" & x"4500" & x"4000" & x"11" &
        IP_addr & x"C353";
        pkt_drop := '0';
      elsif mac_rx_valid = '1' then
        if pkt_mask(41) = '0' then
          if pkt_data(151 downto 144) /= mac_rx_data then
            pkt_drop := '1';
          end if;
          pkt_data := pkt_data(143 downto 0) & x"00";
        end if;
        pkt_mask := pkt_mask(40 downto 0) & '1';
      end if;
      pkt_drop_resend <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

end v2;
