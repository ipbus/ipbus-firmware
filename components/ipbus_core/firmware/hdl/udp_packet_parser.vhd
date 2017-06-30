---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------


-- Parses first 42 bytes of incoming ethernet packet for supported protocols
--
-- Dave Sankey, June 2012, March 2013

library ieee;
use ieee.std_logic_1164.all;

entity udp_packet_parser is
  generic(
    IPBUSPORT: std_logic_vector(15 DOWNTO 0) := x"C351";
    SECONDARYPORT: std_logic := '0'
  );
  port (
    mac_clk: in std_logic;
    rx_reset: in std_logic;
    enable_125: std_logic;
    mac_rx_data: in std_logic_vector(7 downto 0);
    mac_rx_valid: in std_logic;
    MAC_addr: in std_logic_vector(47 downto 0);
    My_IP_addr: in std_logic_vector(31 downto 0);
    next_pkt_id: in std_logic_vector(15 downto 0);
    pkt_broadcast: out std_logic;
    pkt_byteswap: out std_logic;
    pkt_drop_arp: out std_logic;
    pkt_drop_ipbus: out std_logic;
    pkt_drop_payload: out std_logic;
    pkt_drop_ping: out std_logic;
    pkt_drop_rarp: out std_logic;
    pkt_drop_reliable: out std_logic;
    pkt_drop_resend: out std_logic;
    pkt_drop_status: out std_logic
  );
end udp_packet_parser;

architecture v3 of udp_packet_parser is

  signal pkt_drop_arp_sig, pkt_drop_rarp_sig, pkt_drop_ping_sig: std_logic;
  signal pkt_drop_ip_sig, pkt_drop_ipbus_sig: std_logic;
  signal pkt_drop_payload_sig, pkt_payload_drop_sig: std_logic;
  signal pkt_drop_reliable_sig, pkt_reliable_drop_sig: std_logic;
  signal ipbus_status_mask, ipbus_hdr_mask: std_logic;

begin

  pkt_drop_arp <= pkt_drop_arp_sig or SECONDARYPORT;
  pkt_drop_rarp <= pkt_drop_rarp_sig or SECONDARYPORT;
  pkt_drop_ping <= pkt_drop_ping_sig or SECONDARYPORT;
  pkt_drop_ipbus <= pkt_drop_ipbus_sig;
  pkt_drop_payload <= pkt_drop_payload_sig and pkt_payload_drop_sig;
  pkt_drop_reliable <= pkt_drop_reliable_sig and pkt_reliable_drop_sig;
  pkt_byteswap <= pkt_drop_payload_sig;

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
        pkt_data := x"0806" & x"0001" & x"0800" & x"0604" & x"0001" & My_IP_addr;
        pkt_drop := not enable_125;
      elsif mac_rx_valid = '1' then
        if pkt_mask(41) = '0' then
          if pkt_data(111 downto 104) /= mac_rx_data then
            pkt_drop := '1';
          end if;
          pkt_data := pkt_data(103 downto 0) & x"00";
        end if;
        pkt_mask := pkt_mask(40 downto 0) & '1';
      end if;
      pkt_drop_arp_sig <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- RARP:
-- Ethernet DST_MAC(6), SRC_MAC(6), Ether_Type = x"8035"
-- HTYPE = x"0001"
-- PTYPE = x"0800"
-- HLEN = x"06", PLEN = x"04"
-- OPER = x"0004"
-- SHA(6)
-- SPA(4)
-- THA(6) = MAC_addr
-- TPA(4) = MY_IP(4)
rarp:  process (mac_clk)
  variable pkt_data: std_logic_vector(127 downto 0);
  variable pkt_mask: std_logic_vector(37 downto 0);
  variable pkt_drop: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "111111" & "111111" & "00" &
        "00" & "00" & "00" & "00" & "111111" &
        "1111" & "000000";
        pkt_data := x"8035" & x"0001" & x"0800" & x"0604" & x"0004" & MAC_addr;
        pkt_drop := not enable_125;
      elsif mac_rx_valid = '1' then
        if pkt_mask(37) = '0' then
          if pkt_data(127 downto 120) /= mac_rx_data then
            pkt_drop := '1';
          end if;
          pkt_data := pkt_data(119 downto 0) & x"00";
        end if;
        pkt_mask := pkt_mask(36 downto 0) & '1';
      end if;
      pkt_drop_rarp_sig <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- IP packet:
-- Ethernet DST_MAC(6), SRC_MAC(6), Ether_Type = x"0800"
-- IP VERS = x"4", HL = x"5", TOS = x"00"
-- IP LEN
-- IP ID
-- IP FLAG-FRAG = x"4000" or x"0000"
-- IP TTL, PROTO
-- IP CKSUM
-- IP SPA(4)
-- IP DPA(4)
ip_pkt:  process (mac_clk)
  variable pkt_data: std_logic_vector(127 downto 0);
  variable pkt_mask: std_logic_vector(33 downto 0);
  variable msk_data: std_logic_vector(7 downto 0);
  variable msk_mask: std_logic_vector(9 downto 0);
  variable pkt_drop: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "000000" & "111111" & "00" &
        "00" & "11" & "11" & "00" & "1" & "1" & "11" &
        "1111" & "0000";
        msk_mask := "111111" & "11" & "10";
        pkt_data := MAC_addr & x"0800" & x"4500" & x"0000" & My_IP_addr;
	msk_data := (Others => '1');
        pkt_drop := not enable_125;
      elsif mac_rx_valid = '1' then
        if pkt_mask(33) = '0' then
          if pkt_data(127 downto 120) /= (mac_rx_data and msk_data) then
            pkt_drop := '1';
          end if;
          pkt_data := pkt_data(119 downto 0) & x"00";
	  if msk_mask(9) = '0' then
	    msk_data := "10111111";
	  else
	    msk_data := (Others => '1');
	  end if;
	  msk_mask := msk_mask(8 downto 0) & '1';
        end if;
        pkt_mask := pkt_mask(32 downto 0) & '1';
      end if;
      pkt_drop_ip_sig <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- Ping:
-- Ethernet
-- IP VERS, HL, TOS
-- IP LEN
-- IP ID
-- IP FLAG-FRAG
-- IP TTL, PROTO = x"01"
-- IP CKSUM
-- IP SPA(4)
-- IP DPA(4)
-- ICMP TYPE = "08", CODE = "00"
-- ICMP CKSUM
-- ICMP data...
ping:  process (mac_clk)
  variable pkt_data: std_logic_vector(23 downto 0);
  variable pkt_mask: std_logic_vector(35 downto 0);
  variable pkt_drop: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "111111" & "111111" & "11" &
        "11" & "11" & "11" & "11" & "1" & "0" & "11" &
        "1111" & "1111" & "00";
        pkt_data := x"01" & x"0800";
        pkt_drop := not enable_125;
      elsif mac_rx_valid = '1' then
        if pkt_drop_ip_sig = '1' then
	  pkt_drop := '1';
        elsif pkt_mask(35) = '0' then
          if pkt_data(23 downto 16) /= mac_rx_data then
            pkt_drop := '1';
          end if;
          pkt_data := pkt_data(15 downto 0) & x"00";
        end if;
        pkt_mask := pkt_mask(34 downto 0) & '1';
      end if;
      pkt_drop_ping_sig <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- UDP packet to IPbus port:
-- Ethernet
-- IP VERS, HL, TOS
-- IP LEN
-- IP ID
-- IP FLAG-FRAG
-- IP TTL, PROTO = x"11"
-- IP CKSUM
-- IP SPA(4)
-- IP DPA(4)
-- UDP SRCPORT
-- UDP DSTPORT (50001)
ipbus_pkt:  process (mac_clk)
  variable pkt_data: std_logic_vector(23 downto 0);
  variable pkt_mask: std_logic_vector(37 downto 0);
  variable pkt_drop: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "111111" & "111111" & "11" &
        "11" & "11" & "11" & "11" & "1" & "0" & "11" &
        "1111" & "1111" & "11" & "00";
        pkt_data := x"11" & IPBUSPORT;
        pkt_drop := not enable_125;
      elsif mac_rx_valid = '1' then
        if pkt_drop_ip_sig = '1' then
	  pkt_drop := '1';
        elsif pkt_mask(37) = '0' then
          if pkt_data(23 downto 16) /= mac_rx_data then
            pkt_drop := '1';
          end if;
          pkt_data := pkt_data(15 downto 0) & x"00";
        end if;
        pkt_mask := pkt_mask(36 downto 0) & '1';
      end if;
      pkt_drop_ipbus_sig <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- IPbus header parsers (switch 1 tick earlier...)
ipbus_mask: process(mac_clk)
  variable pkt_mask: std_logic_vector(44 downto 0);
  variable last_mask, header_sel: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "111111" & "111111" & "11" &
        "11" & "11" & "11" & "11" & "1" & "1" & "11" &
        "1111" & "1111" & "11" & "1" & "00" & "11" & "0000";
        last_mask := '1';
	header_sel := '1';
      elsif mac_rx_valid = '1' then
        if pkt_mask(44) = '1' and last_mask = '0' then
          header_sel := '0';
        end if;
	last_mask := pkt_mask(44);
        pkt_mask := pkt_mask(43 downto 0) & '1';
      end if;
      ipbus_status_mask <= last_mask
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      ipbus_hdr_mask <= last_mask or header_sel
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- UDP payload:
-- IPBus packet header x"20nnnnF0" or x"200000F0"
-- IPBus data...
bigendian:  process (mac_clk)
  variable reliable_data: std_logic_vector(31 downto 0);
  variable unreliable_data: std_logic_vector(31 downto 0);
  variable pkt_drop_reliable_i, pkt_drop_unreliable: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        reliable_data := x"20" & next_pkt_id & x"F0";
        unreliable_data := x"200000F0";
        pkt_drop_reliable_i := not enable_125;
        pkt_drop_unreliable := not enable_125;
      elsif mac_rx_valid = '1' then
        if pkt_drop_ipbus_sig = '1' then
	  pkt_drop_reliable_i := '1';
	  pkt_drop_unreliable := '1';
        elsif ipbus_hdr_mask = '0' then
          if reliable_data(31 downto 24) /= mac_rx_data then
            pkt_drop_reliable_i := '1';
          end if;
          if unreliable_data(31 downto 24) /= mac_rx_data then
            pkt_drop_unreliable := '1';
          end if;
          reliable_data := reliable_data(23 downto 0) & x"00";
          unreliable_data := unreliable_data(23 downto 0) & x"00";
        end if;
      end if;
      pkt_drop_reliable_sig <= pkt_drop_reliable_i
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      pkt_drop_payload_sig <= pkt_drop_reliable_i and pkt_drop_unreliable
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- UDP payload:
-- IPBus packet header x"F0nnnn20" or x"F0000020"
-- IPBus data...
littleendian:  process (mac_clk)
  variable reliable_data: std_logic_vector(31 downto 0);
  variable unreliable_data: std_logic_vector(31 downto 0);
  variable pkt_drop_reliable_i, pkt_drop_unreliable: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        reliable_data := x"F0" & next_pkt_id(7 downto 0) &
	next_pkt_id(15 downto 8)  & x"20";
        unreliable_data := x"F0000020";
        pkt_drop_reliable_i := not enable_125;
        pkt_drop_unreliable := not enable_125;
      elsif mac_rx_valid = '1' then
        if pkt_drop_ipbus_sig = '1' then
	  pkt_drop_reliable_i := '1';
	  pkt_drop_unreliable := '1';
        elsif ipbus_hdr_mask = '0' then
          if reliable_data(31 downto 24) /= mac_rx_data then
            pkt_drop_reliable_i := '1';
          end if;
          if unreliable_data(31 downto 24) /= mac_rx_data then
            pkt_drop_unreliable := '1';
          end if;
          reliable_data := reliable_data(23 downto 0) & x"00";
          unreliable_data := unreliable_data(23 downto 0) & x"00";
        end if;
      end if;
      pkt_reliable_drop_sig <= pkt_drop_reliable_i
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      pkt_payload_drop_sig <= pkt_drop_reliable_i and pkt_drop_unreliable
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- UDP status request:
-- UDP LEN (72 = x"48")
-- IPBus packet header x"200000F1"
status_request:  process (mac_clk)
  variable pkt_data: std_logic_vector(47 downto 0);
  variable pkt_drop: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_data := x"0048200000F1";
        pkt_drop := not enable_125;
      elsif mac_rx_valid = '1' then
        if pkt_drop_ipbus_sig = '1' then
	  pkt_drop := '1';
        elsif ipbus_status_mask = '0' then
          if pkt_data(47 downto 40) /= mac_rx_data then
            pkt_drop := '1';
          end if;
          pkt_data := pkt_data(39 downto 0) & x"00";
        end if;
      end if;
      pkt_drop_status <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- UDP resend request:
-- IPBus packet header x"20XXXXF2"
resend:  process (mac_clk)
  variable pkt_data: std_logic_vector(15 downto 0);
  variable pkt_mask: std_logic_vector(3 downto 0);
  variable pkt_drop: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_data := x"20F2";
	pkt_mask := "0110";
        pkt_drop := not enable_125;
      elsif mac_rx_valid = '1' then
        if pkt_drop_ipbus_sig = '1' then
	  pkt_drop := '1';
        elsif ipbus_hdr_mask = '0' then
	  if pkt_mask(3) = '0' then
	    if pkt_data(15 downto 8) /= mac_rx_data then
              pkt_drop := '1';
            end if;
            pkt_data := pkt_data(7 downto 0) & x"00";
	  end if;
	  pkt_mask := pkt_mask(2 downto 0) & '1';
        end if;
      end if;
      pkt_drop_resend <= pkt_drop
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

broadcast:  process (mac_clk)
  variable pkt_mask: std_logic_vector(5 downto 0);
  variable broadcast_int: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
	pkt_mask := (Others => '0');
        broadcast_int := '1';
      elsif mac_rx_valid = '1' and pkt_mask(5) = '0' then
        if mac_rx_data /= x"FF" then
          broadcast_int := '0';
        end if;
        pkt_mask := pkt_mask(4 downto 0) & '1';
      end if;
      pkt_broadcast <= broadcast_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

end v3;
