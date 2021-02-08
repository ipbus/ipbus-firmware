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


-- Handles source of MAC and IP address...
-- Parses incoming RARP response to capture real MAC and IP address
--
-- Dave Sankey, July 2012 and September 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_ipaddr_ipam is
  generic(
-- Switch between using DHCP or RARP as the protocol for external IP address management
-- '0' => RARP, '1' => DHCP
  	DHCP_RARP: std_logic := '0'
  );
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
    rx_reset: in std_logic;
    enable_125: in std_logic;
    ipam_125: in std_logic;
    MAC_addr: in std_logic_vector(47 DOWNTO 0);
    IP_addr: in std_logic_vector(31 downto 0);
    my_rx_data: in std_logic_vector(7 downto 0);
    my_rx_error: in std_logic;
    my_rx_last: in std_logic;
    my_rx_valid: in std_logic;
    pkt_drop_ipam: in std_logic;
    My_MAC_addr: out std_logic_vector(47 downto 0);
    My_IP_addr: out std_logic_vector(31 downto 0);
    Server_IP_addr: out std_logic_vector(31 downto 0);
    ipam_running: out std_logic
  );
end udp_ipaddr_ipam;

architecture rtl of udp_ipaddr_ipam is

  signal MAC_IP_addr_rx_vld: std_logic;
  signal MAC_IP_addr_rx: std_logic_vector(79 downto 0);
  signal Server_IP_addr_rx: std_logic_vector(31 downto 0);

begin

MAC_IP_addr_rx_vld_block:  process (mac_clk)
  begin
    if rising_edge(mac_clk) then
-- Valid RARP response received.
      if my_rx_last = '1' and pkt_drop_ipam = '0' and 
      my_rx_error = '0' then
        MAC_IP_addr_rx_vld <= '1'
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      else
        MAC_IP_addr_rx_vld <= '0'
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
    end if;
  end process;

rarp_reply: if DHCP_RARP = '0' generate
Server_IP_addr_rx <= (Others => '0');

MAC_IP_addr_rx_rarp: process(mac_clk)
  variable pkt_mask: std_logic_vector(41 downto 0);
  variable MAC_IP_addr_rx_int: std_logic_vector(79 downto 0);
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "111111" & "111111" & "11" &
        "11" & "11" & "11" & "11" & "111111" &
        "1111" & "000000" & "0000";
	MAC_IP_addr_rx_int := (Others => '0');
      elsif my_rx_valid = '1' then
        if pkt_drop_ipam = '1' then
	  MAC_IP_addr_rx_int := (Others => '0');
        elsif pkt_mask(41) = '0' then
          MAC_IP_addr_rx_int := MAC_IP_addr_rx_int(71 downto 0) & my_rx_data;
        end if;
        pkt_mask := pkt_mask(40 downto 0) & '1';
      end if;
      MAC_IP_addr_rx <= MAC_IP_addr_rx_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;
end generate rarp_reply;

dhcp_offer: if DHCP_RARP = '1' generate
MAC_IP_addr_rx_dhcp: process(mac_clk)
  variable pkt_mask: std_logic_vector(75 downto 0);
  variable MAC_IP_addr_rx_int: std_logic_vector(79 downto 0);
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
         pkt_mask := "111111" & "111111" & "1111" & "1111" & "1111" &
		"11" & "1111" & "1111" & "1111" & "1111" & "1111" &
		"11111111" & "1111" & "0000" & "1111" & "1111" & "000000";
	MAC_IP_addr_rx_int := (Others => '0');
      elsif my_rx_valid = '1' then
        if pkt_drop_ipam = '1' then
	  MAC_IP_addr_rx_int := (Others => '0');
        elsif pkt_mask(75) = '0' then
          MAC_IP_addr_rx_int := MAC_IP_addr_rx_int(71 downto 0) & my_rx_data;
        end if;
        pkt_mask := pkt_mask(74 downto 0) & '1';
      end if;
      MAC_IP_addr_rx <= MAC_IP_addr_rx_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      Server_IP_addr_rx <= x"c0a801dd"
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;
end generate dhcp_offer;

My_MAC_IP_addr_block:  process (mac_clk)
  variable Got_MAC_IP_addr_rx, last_enable_125: std_logic;
  variable My_MAC_IP_addr_int: std_logic_vector(79 downto 0);
  begin
    if rising_edge(mac_clk) then
-- Sample MAC_addr & IP_addr on reset or enable going high...
      if (rst_macclk = '1') or
      (enable_125 = '1' and last_enable_125 = '0') then
        Got_MAC_IP_addr_rx := '0';
	My_MAC_IP_addr_int := IP_addr & MAC_addr;
      elsif MAC_IP_addr_rx_vld = '1' and ipam_125 = '1' then
        Got_MAC_IP_addr_rx := '1';
        if DHCP_RARP = '0'  then
-- IP address and MAC address are swapped compared to DHCP...
		  My_MAC_IP_addr_int := MAC_IP_addr_rx(31 downto 0) & MAC_IP_addr_rx(79 downto 32);
		else
		  My_MAC_IP_addr_int := MAC_IP_addr_rx;
		end if;
      end if;
      last_enable_125 := enable_125;
      My_IP_addr <= My_MAC_IP_addr_int(79 downto 48)
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      My_MAC_addr <= My_MAC_IP_addr_int(47 downto 0)
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      Server_IP_addr <= Server_IP_addr_rx
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      ipam_running <= enable_125 and ipam_125 and not Got_MAC_IP_addr_rx
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

end rtl;
