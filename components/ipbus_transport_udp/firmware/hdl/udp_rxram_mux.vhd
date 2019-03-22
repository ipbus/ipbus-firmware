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


-- Multiplex into transport dual-port RAM/interface
--
-- Dave Sankey, July 2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_rxram_mux is
  port (
    mac_clk: in std_logic;
    rx_reset: in std_logic;
--
    rarp_mode: in std_logic;
    rarp_addr: in std_logic_vector(12 downto 0);
    rarp_data: in std_logic_vector(7 downto 0);
    rarp_end_addr: in std_logic_vector(12 downto 0);
    rarp_send: in std_logic;
    rarp_we: in std_logic;
--
    pkt_drop_arp: in std_logic;
    arp_data: in std_logic_vector(7 downto 0);
    arp_addr: in std_logic_vector(12 downto 0);
    arp_we: in std_logic;
    arp_end_addr: in std_logic_vector(12 downto 0);
    arp_send: in std_logic;
--
    pkt_drop_ping: in std_logic;
    ping_data: in std_logic_vector(7 downto 0);
    ping_addr: in std_logic_vector(12 downto 0);
    ping_we: in std_logic;
    ping_end_addr: in std_logic_vector(12 downto 0);
    ping_send: in std_logic;
--
    pkt_drop_status: in std_logic;
    status_data: in std_logic_vector(7 downto 0);
    status_addr: in std_logic_vector(12 downto 0);
    status_we: in std_logic;
    status_end_addr: in std_logic_vector(12 downto 0);
    status_send: in std_logic;
--
    mac_rx_valid: in std_logic;
    rxram_busy: in std_logic;
--
    dia: out std_logic_vector(7 downto 0);
    addra: out std_logic_vector(12 downto 0);
    wea: out std_logic;
    rxram_end_addr: out std_logic_vector(12 downto 0);
    rxram_send: out std_logic;
    rxram_dropped: out std_logic
  );
end udp_rxram_mux;

architecture rtl of udp_rxram_mux is

  signal ram_ready, rxram_send_sig: std_logic;

begin

  rxram_send <= rxram_send_sig and ram_ready;

do_ram_ready:  process(mac_clk)
  variable ram_ready_int, rxram_dropped_int: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' or rarp_mode = '1' then
        ram_ready_int := '1';
      elsif mac_rx_valid = '1' and rxram_busy = '1' then 
        ram_ready_int := '0';
      end if;
      if rxram_send_sig = '1' and ram_ready_int = '0' then
        rxram_dropped_int := '1';
      else
        rxram_dropped_int := '0';
      end if;
      ram_ready <= ram_ready_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      rxram_dropped <= rxram_dropped_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

send_packet:  process(mac_clk)
  variable rxram_end_addr_int: std_logic_vector(12 downto 0);
  variable rxram_send_int: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rarp_send = '1' then
        rxram_end_addr_int := rarp_end_addr;
	rxram_send_int := '1';
      elsif arp_send = '1' then
        rxram_end_addr_int := arp_end_addr;
	rxram_send_int := '1';
      elsif ping_send = '1' then
        rxram_end_addr_int := ping_end_addr;
	rxram_send_int := '1';
      elsif status_send = '1' then
        rxram_end_addr_int := status_end_addr;
	rxram_send_int := '1';
      else
        rxram_end_addr_int := (Others => '0');
        rxram_send_int := '0';
      end if;
      rxram_end_addr <= rxram_end_addr_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      rxram_send_sig <= rxram_send_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

build_packet:  process(mac_clk)
  variable dia_int: std_logic_vector(7 downto 0);
  variable addra_int: std_logic_vector(12 downto 0);
  variable wea_int: std_logic;
  begin
    if rising_edge(mac_clk) then
      if ram_ready = '1' then
        if rarp_mode = '1' then
          dia_int := rarp_data;
	  addra_int := rarp_addr;
	  wea_int := rarp_we;
        elsif pkt_drop_arp = '0' then
          dia_int := arp_data;
	  addra_int := arp_addr;
	  wea_int := arp_we;
        elsif pkt_drop_ping = '0' then
          dia_int := ping_data;
	  addra_int := ping_addr;
	  wea_int := ping_we;
        elsif pkt_drop_status = '0' then
          dia_int := status_data;
	  addra_int := status_addr;
	  wea_int := status_we;
        else
          dia_int := (Others => '0');
	  addra_int := (Others => '0');
	  wea_int := '0';
        end if;
      else
        dia_int := (Others => '0');
	addra_int := (Others => '0');
	wea_int := '0';
      end if;
      dia <= dia_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      addra <= addra_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      wea <= wea_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

end rtl;
