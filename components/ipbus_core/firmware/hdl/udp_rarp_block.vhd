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


-- Builds outbound rarp request at random intervals...
--
-- Dave Sankey, June 2013

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_rarp_block is
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
    enable_125: in std_logic;
    MAC_addr: in std_logic_vector(47 downto 0);
    rarp_mode: in std_logic;
    rarp_addr: out std_logic_vector(12 downto 0);
    rarp_data: out std_logic_vector(7 downto 0);
    rarp_end_addr: out std_logic_vector(12 downto 0);
    rarp_send: out std_logic;
    rarp_we: out std_logic
  );
end udp_rarp_block;

architecture rtl of udp_rarp_block is

  signal rarp_we_sig: std_logic;
  signal address: unsigned(5 downto 0);
  signal rarp_req, tick: std_logic;
  signal rndm: std_logic_vector(4 downto 0);

begin

  rarp_we <= rarp_we_sig;
  rarp_addr <= std_logic_vector("0000000" & address);

send_packet:  process (mac_clk)
  variable last_we, send_i: std_logic;
  variable end_addr_i: std_logic_vector(12 downto 0);
  begin
    if rising_edge(mac_clk) then
      if rarp_we_sig = '0' and last_we = '1' then
        end_addr_i := std_logic_vector(to_unsigned(41, 13));
	send_i := '1';
      else
        end_addr_i := (Others => '0');
	send_i := '0';
      end if;
      last_we := rarp_we_sig;
      rarp_end_addr <= end_addr_i
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      rarp_send <= send_i
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

-- rarp:
-- Ethernet DST_MAC(6), SRC_MAC(6), Ether_Type = x"8035"
-- HTYPE = x"0001"
-- PTYPE = x"0800"
-- HLEN = x"06", PLEN = x"04"
-- OPER = x"0003"
-- SHA(6)
-- SPA(4)
-- THA(6)
-- TPA(4)
data_block:  process(mac_clk)
  variable data_buffer: std_logic_vector(335 downto 0);
  variable we_buffer: std_logic_vector(41 downto 0);
  begin
    if rising_edge(mac_clk) then
      if (rst_macclk = '1') then
	we_buffer := (Others => '0');
      elsif rarp_req = '1' then
        data_buffer := x"FFFFFFFFFFFF" & MAC_addr & x"8035" & x"0001" &
	x"0800" & x"06" & x"04" & x"0003" & MAC_addr & x"00000000" &
	MAC_addr & x"00000000";
	we_buffer := (Others => '1');
      end if;
      rarp_data <= data_buffer(335 downto 328)
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      rarp_we_sig <= we_buffer(41)
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      data_buffer := data_buffer(327 downto 0) & x"00";
      we_buffer := we_buffer(40 downto 0) & '0';
    end if;
  end process;

addr_block:  process(mac_clk)
  variable addr_int, next_addr: unsigned(5 downto 0);
  variable counting: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
	next_addr := (Others => '0');
	counting := '0';
      elsif rarp_req = '1' then
        counting := '1';
      elsif rarp_we_sig = '0' then
	next_addr := (Others => '0');
        counting := '0';
      end if;
      addr_int := next_addr;
      address <= addr_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      if counting = '1' then
        next_addr := addr_int + 1;
      end if;
    end if;
  end process;

tick_counter:  process(mac_clk)
  variable counter_int: unsigned(23 downto 0);
  variable tick_int: std_logic;
  begin
    if rising_edge(mac_clk) then
      if (rst_macclk = '1') or (enable_125 = '0') then
        counter_int := (Others => '0');
	tick_int := '0';
-- tick goes at 8 Hz
      elsif counter_int = x"FFFFFF" then
-- pragma translate_off
-- kludge for simulation in finite number of ticks!
      elsif counter_int = x"00003F" then
-- pragma translate_on
	counter_int := (Others => '0');
	tick_int := '1';
      else
        counter_int := counter_int + 1;
	tick_int := '0';
      end if;
      tick <= tick_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

random: process(mac_clk)
-- xorshift rng based on http://b2d-f9r.blogspot.co.uk/2010/08/16-bit-xorshift-rng-now-with-more.html
-- using triplet 5, 3, 1 (next 5, 7, 4)
  variable x, y, t : std_logic_vector(15 downto 0);
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
        x := MAC_addr(31 downto 16);
        y := MAC_addr(15 downto 0);
      elsif tick = '1' then
        t := x xor (x(10 downto 0) & "00000");
	x := y;
	y := (y xor ("0" & y(15 downto 1))) xor (t xor ("000" & t(15 downto 3)));
      end if;
      rndm <= y(4 downto 0)
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

rarp_req_block: process(mac_clk)
  variable req_count, req_end: unsigned(5 downto 0);
  variable rarp_req_int: std_logic;
  begin
    if rising_edge(mac_clk) then
      if (rst_macclk = '1') or (enable_125 = '0') then
        req_count := (Others => '0');
-- initial delay from bottom of MAC address...
	req_end := unsigned("000" & MAC_addr(1 downto 0) & "1");
-- pragma translate_off
-- kludge for simulation in finite number of ticks!
	req_end := to_unsigned(1, 6);
-- pragma translate_on
	rarp_req_int := '0';
      elsif req_count = req_end then
        req_count := (Others => '0');
	req_end := unsigned(rndm & "1");
	rarp_req_int := RARP_mode;
      elsif tick = '1' then
        req_count := req_count + 1;
	rarp_req_int := '0';
      else
	rarp_req_int := '0';
      end if;
      rarp_req <= rarp_req_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

end rtl;
