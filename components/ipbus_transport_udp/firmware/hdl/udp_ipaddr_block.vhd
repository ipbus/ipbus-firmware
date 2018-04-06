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


-- Handles source of IP address...
-- Parses incoming RARP response
--
-- Dave Sankey, July 2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_ipaddr_block is
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
    rx_reset: in std_logic;
    enable_125: in std_logic;
    rarp_125: in std_logic;
    IP_addr: in std_logic_vector(31 downto 0);
    mac_rx_data: in std_logic_vector(7 downto 0);
    mac_rx_error: in std_logic;
    mac_rx_last: in std_logic;
    mac_rx_valid: in std_logic;
    pkt_drop_rarp: in std_logic;
    My_IP_addr: out std_logic_vector(31 downto 0);
    rarp_mode: out std_logic
  );
end udp_ipaddr_block;

architecture rtl of udp_ipaddr_block is

  signal IP_addr_rx_vld: std_logic;
  signal IP_addr_rx: std_logic_vector(31 downto 0);

begin

IP_addr_rx_vld_block:  process (mac_clk)
  begin
    if rising_edge(mac_clk) then
-- Valid RARP response received.
      if mac_rx_last = '1' and pkt_drop_rarp = '0' and 
      mac_rx_error = '0' then
        IP_addr_rx_vld <= '1'
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      else
        IP_addr_rx_vld <= '0'
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
    end if;
  end process;

IP_addr_rx_block: process(mac_clk)
  variable pkt_mask: std_logic_vector(41 downto 0);
  variable IP_addr_rx_int: std_logic_vector(31 downto 0);
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        pkt_mask := "111111" & "111111" & "11" &
        "11" & "11" & "11" & "11" & "111111" &
        "1111" & "111111" & "0000";
	IP_addr_rx_int := (Others => '0');
      elsif mac_rx_valid = '1' then
        if pkt_drop_rarp = '1' then
	  IP_addr_rx_int := (Others => '0');
        elsif pkt_mask(41) = '0' then
          IP_addr_rx_int := IP_addr_rx_int(23 downto 0) & mac_rx_data;
        end if;
        pkt_mask := pkt_mask(40 downto 0) & '1';
      end if;
      IP_addr_rx <= IP_addr_rx_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

My_IP_addr_block:  process (mac_clk)
  variable Got_IP_addr_rx: std_logic;
  variable My_IP_addr_int: std_logic_vector(31 downto 0);
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
        Got_IP_addr_rx := '0';
	My_IP_addr_int := (Others => '0');
      elsif IP_addr_rx_vld = '1' then
        Got_IP_addr_rx := '1';
	My_IP_addr_int := IP_addr_rx;
      end if;
-- Predefined (Non-RARP) mode...
      if rarp_125 = '0' then
        My_IP_addr <= IP_addr
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      else
        My_IP_addr <= My_IP_addr_int
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
      rarp_mode <= enable_125 and rarp_125 and not Got_IP_addr_rx
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

end rtl;
