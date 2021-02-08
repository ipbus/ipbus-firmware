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


-- Builds outbound rarp or dhcp discover at random intervals...
-- Sends dhcp request once valid dhcp offer received
--
-- Dave Sankey, June 2013
-- Gareth Bird, December 2020

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_ipam_block is
  generic(
-- Switch between using DHCP or RARP as the protocol for external IP address management
-- '0' => RARP, '1' => DHCP
  	DHCP_RARP: std_logic := '0'
  );
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
    enable_125: in std_logic;
    MAC_addr: in std_logic_vector(47 downto 0);
    My_IP_addr: in std_logic_vector(31 downto 0);
    ipam_mode: in std_logic; 
    ipam_addr: out std_logic_vector(12 downto 0); --! ethernet RAM location write to 
    ipam_data: out std_logic_vector(7 downto 0); --! Data to ethernet RAM address
    ipam_end_addr: out std_logic_vector(12 downto 0); --! End of packet
    ipam_send: out std_logic; --! Trigger to send ethernet packet
    ipam_we: out std_logic --! write enable
  );
end udp_ipam_block;

architecture rtl of udp_ipam_block is

  signal ipam_we_sig: std_logic;
  signal address: unsigned(11 downto 0);
  signal ipam_req, tick: std_logic;
  signal rndm: std_logic_vector(4 downto 0);
  signal secs_elapsed: unsigned(15 downto 0) := (others=> '0');
  
begin

  ipam_we <= ipam_we_sig;
  ipam_addr <= std_logic_vector("0" & address);

dhcp_discover: if DHCP_RARP = '1' generate
-- dhcp packet structure:
-- ETHERNET
    -- Ethernet DST_MAC(6) discover -> broadcast (FFFFFFFFFFFF) , 
    -- SRC_MAC(6) = MAC_addr
    -- Ether_Type IPv4 = x"0800" 
    -- IP header length = x"45"
-- IPV4
    -- 'Differentiated services' set to: x"00"
    -- IPv4 Packet Length 285 = x"011D"
    -- Identification: MAC address bits
    -- Flags: x"4000" (Don't fragment)
    -- Time to live ~64s x"40"
    -- UDP protocol = x"11" (17)
    -- Checksum: Fixed by source IP and ID 
    -- Source IP (on discover) 0.0.0.0 =  x 192.168 & NOT MAC addr
    -- Dest IP (broadcast on discover) 255.255.255.255 = x"FFFFFFFF"
-- UDP
    -- Ports (68->67) x"00440043"
    -- UDP Packet Length 265 =x"0109"
    -- Checksum empty =x"0000"
-- Bootstrap Discover Packet
    -- Boot request x"01"
    -- Ethernet x"01"
    -- (HW) Address length x"06" (in octets/bytes)
    -- hops x"00"
    -- trans ID  MAC_addr(31 downto 0) fudge as only 1 XID
    -- secs elapsed sec_count defined through sec_counter
    -- bootpflag  x"8000" broadcast
    -- 4 empty IPs  x"00000000" * 4
    -- MAC address
    -- 192 empty bytes (!)
-- DHCP magic cookie (x"63825363")
-- Options
    -- Discover option x"350101"
    -- Max size (opt 57) opt size 2 msg size 576 x"39020240" 
    -- Large Parameter list:
        --Option: (55) Parameter Request List x"37077D014206034396"
        --   Length: 7
        --    Parameter Request List Item: (125) V-I Vendor-specific Information
        --    Parameter Request List Item: (1) Subnet Mask
        --    Parameter Request List Item: (66) TFTP Server Name
        --    Parameter Request List Item: (6) Domain Name Server
        --    Parameter Request List Item: (3) Router
        --    Parameter Request List Item: (67) Bootfile name
        --    Parameter Request List Item: (150) TFTP Server Address
-- end x"FF"
dhcp_block:  process(mac_clk)
  variable data_buffer: std_logic_vector(2383 downto 0):= (others => '0');
  variable we_buffer: std_logic_vector(297 downto 0) := (others => '0');
  constant zeroes_192: std_logic_vector(1535 downto 0) := (others => '0');
  begin
    if rising_edge(mac_clk) then
      if (rst_macclk = '1') then
		we_buffer := (Others => '0');
      elsif ipam_req = '1' then
      	data_buffer(2383 downto 112)  :=  x"FFFFFFFFFFFF" & MAC_addr & x"0800" &x"45"   -- Ethernet header
        & x"00" & x"0110" & MAC_addr(15 downto 0) & x"4000" & x"40" & x"11" & x"7929" & x"C0A8" & NOT MAC_addr(15 downto 0) & x"FFFFFFFF" -- IPv4 Header
      --  & x"c0a800ef" & x"FFFFFFFF" crosscheck for sniped packetMSB_half_store
        & x"00440043" &  x"0108" & x"0000" &  x"01" & x"01" & x"06" & x"00" & MAC_addr(31 downto 0) & std_logic_vector(secs_elapsed)
        & x"8000" & x"00000000" & x"00000000"& x"00000000"& x"00000000" & MAC_addr & x"00000000000000000000" & zeroes_192  -- Bootstrap
        & x"63825363" -- DHCP Magic Cookie
        & x"3501";
	  	we_buffer := (Others => '1');
	  	if ipam_mode = '1' then -- dhcp discover
	  	  data_buffer(2247 downto 2240) := x"10";  -- IP length
	  	  data_buffer(2183 downto 2176) := x"35";  -- IP checksum
	  	  data_buffer(2079 downto 2064) := x"00fc";  -- UDP length
	  	  data_buffer(111 downto 0) := x"01ff000000000000000000000000";
	  	  we_buffer(11 downto 0) := (Others => '0');
	  	else -- dhcp request
	  	  data_buffer(111 downto 0) := x"033604c0a801dd3204" & My_IP_addr & x"ff";
	  	end if;
      end if;
      ipam_data <= data_buffer(2383 downto 2376)
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      ipam_we_sig <= we_buffer(297)
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      data_buffer := data_buffer(2375 downto 0) & x"00";
      we_buffer := we_buffer(296 downto 0) & '0';
    end if;
  end process;

second_count: process(mac_clk)
    variable tickcount: unsigned(2 to 0) := (others => '0');
    begin
    if (tick = '1') then
        tickcount := tickcount + 1;
    end if;
    if (tickcount = 7) then
        secs_elapsed <= secs_elapsed + 1;
        tickcount := (others => '0');
    end if;
	end process;
end generate dhcp_discover;

rarp_request: if DHCP_RARP = '0' generate
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
  variable pkt_data: std_logic_vector(7 downto 0);
  variable data_buffer: std_logic_vector(55 downto 0);
  variable pkt_mask: std_logic_vector(41 downto 0);
  variable filler: std_logic;
  variable we: std_logic;
  begin
    If rising_edge(mac_clk) then
      If rst_macclk = '1' then
	we := '0';
      ElsIf ipam_req = '1' then
        we := '1';
	pkt_mask := "0000001111111101101101" &
	"11111100001111110000";
	filler := '1';
      End If;
      Case to_integer(address) is
	When 5 | 21 | 31 =>
	  data_buffer := MAC_addr & x"00";
	  filler := '0';
	When 11 =>
	  data_buffer := x"80350108060403";
	When 41 =>
	  we := '0';
	When Others =>
      End Case;
      If pkt_mask(41) = '1' then
        pkt_data := data_buffer(55 downto 48);
	data_buffer := data_buffer(47 downto 0) & x"00";
      Else
        pkt_data := (Others => filler);
      End If;
      pkt_mask := pkt_mask(40 downto 0) & '0';
      ipam_data <= pkt_data
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      ipam_we_sig <= we
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process data_block;
end generate rarp_request;
  
send_packet:  process (mac_clk)
  variable last_we, send_i: std_logic := '0';
  variable end_addr_i: std_logic_vector(12 downto 0);
  begin
    if rising_edge(mac_clk) then
      if ipam_we_sig = '0' and last_we = '1' then
      	if DHCP_RARP = '0' then
      	  end_addr_i := std_logic_vector(to_unsigned(41, 13));
      	elsif ipam_mode = '1' then -- DHCPDISCOVER
      	  end_addr_i := std_logic_vector(to_unsigned(285, 13));
      	else -- DHCPREQUEST
      	  end_addr_i := std_logic_vector(to_unsigned(297, 13));
      	end if;
		send_i := '1';
      else
        end_addr_i := (Others => '0');
		send_i := '0';
      end if;
      last_we := ipam_we_sig;
      ipam_end_addr <= end_addr_i
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      ipam_send <= send_i
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

addr_block:  process(mac_clk)
  variable addr_int, next_addr: unsigned(11 downto 0);
  variable counting: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
	    next_addr := (Others => '0');
	    counting := '0';
      elsif ipam_req = '1' then
        counting := '1';
      elsif ipam_we_sig = '0' then
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

ipam_req_block: process(mac_clk)
  variable req_count, req_end: unsigned(5 downto 0);
  variable ipam_req_int, dhcp_active: std_logic;
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
	    ipam_req_int := '0';
	    dhcp_active := ipam_mode;
      elsif req_count = req_end then
-- time to send RARP/DHCPDISCOVER
        req_count := (Others => '0');
	    req_end := unsigned(rndm & "1");
	    ipam_req_int := ipam_mode;
      elsif (dhcp_active /= ipam_mode) and (ipam_we_sig = '0') then
-- time to send DHCPREQUEST...
        dhcp_active := ipam_mode;
	    ipam_req_int := DHCP_RARP;
      elsif tick = '1' then
        req_count := req_count + 1;
	    ipam_req_int := '0';
      else
	    ipam_req_int := '0';
      end if;
      ipam_req <= ipam_req_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

end rtl;
