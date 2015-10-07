-- Generates RARP response targetted to 0:0:0:0:0:0 to pass MAC and IP 
-- address to slaves
--
-- Dave Sankey, September 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_master_rarp is
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
    actual_mac_addr: in std_logic_vector(47 downto 0);
    actual_ip_addr: in std_logic_vector(31 downto 0);
    Master_got_IP_addr: in std_logic;
    Slaves_got_IP_addr: in std_logic;
    rarp_rx_data: out std_logic_vector(7 downto 0);
    rarp_rx_last: out std_logic;
    rarp_rx_valid: out std_logic
  );
end udp_master_rarp;

architecture rtl of udp_master_rarp is

  signal address: unsigned(5 downto 0);
  signal rarp_req: std_logic;
  signal rst_macclk_sig: std_logic;

begin

-- register reset...
	rst_macclk_block: process(mac_clk)
	begin
		if rising_edge(mac_clk) then
			rst_macclk_sig <= rst_macclk
-- pragma translate_off
			after 4 ns
-- pragma translate_on
			;
		end if;
	end process;

-- address is continually cycling 0-63.
-- each time it passes through 63 rarp_req_block checks if a rarp stuffing packet is needed
-- i.e. master has IP but one or more slaves don't
-- if so, data_block sends the rarp packet.

-- rarp response:
-- Ethernet DST_MAC(6), SRC_MAC(6), Ether_Type = x"8035"
-- HTYPE = x"0001"
-- PTYPE = x"0800"
-- HLEN = x"06", PLEN = x"04"
-- OPER = x"0004"
-- SHA(6)
-- SPA(4)
-- THA(6) = actual_mac_addr
-- TPA(4) = actual_ip_addr
data_block:  process(mac_clk)
  variable pkt_data: std_logic_vector(7 downto 0);
  variable data_buffer: std_logic_vector(39 downto 0);
  variable valid, last: std_logic;
  begin
    If rising_edge(mac_clk) then
      If rst_macclk_sig = '1' then
	valid := '0';
	last := '0';
	data_buffer := (Others => '0');
      ElsIf rarp_req = '1' then
        valid := '1';
      End If;
      Case to_integer(address) is
	When 12 =>
	  data_buffer := x"8035000108";
	When 17 =>
	  data_buffer := x"0006040004";
	When 32 =>
	  data_buffer := actual_mac_addr(47 downto 8);
	When 37 =>
	  data_buffer := actual_mac_addr(7 downto 0) & actual_ip_addr;
	When 41 =>
	  last := valid;
	When 42 =>
	  valid := '0';
	  last := '0';
	When Others =>
      End Case;
      pkt_data := data_buffer(39 downto 32);
      data_buffer := data_buffer(31 downto 0) & x"00";
      rarp_rx_data <= pkt_data
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      rarp_rx_valid <= valid
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      rarp_rx_last <= last
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process data_block;

addr_block:  process(mac_clk)
  variable addr_int, next_addr: unsigned(5 downto 0);
  variable counting: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rst_macclk_sig = '1' then
	next_addr := (Others => '0');
      end if;
      addr_int := next_addr;
      if next_addr = "111111" then
        next_addr := (Others => '0');
      else
        next_addr := addr_int + 1;
      end if;
      address <= addr_int
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

rarp_req_block: process(mac_clk)
  variable rarp_req_int: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rst_macclk_sig = '1' then
	rarp_req_int := '0';
      elsif (address = "111111") and (Slaves_got_IP_addr = '0') then
	rarp_req_int := Master_got_IP_addr;
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
