-- Handles source of MAC and IP address...
-- Parses incoming RARP response to capture real MAC and IP address
--
-- Dave Sankey, July 2012 and September 2015

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_ipaddr_block is
  port (
    mac_clk: in std_logic;
    rst_macclk_reg: in std_logic;
    rx_reset: in std_logic;
    enable_125: in std_logic;
    rarp_125: in std_logic;
    MAC_addr: in std_logic_vector(47 DOWNTO 0);
    IP_addr: in std_logic_vector(31 downto 0);
    my_rx_data: in std_logic_vector(7 downto 0);
    my_rx_error: in std_logic;
    my_rx_last: in std_logic;
    my_rx_valid: in std_logic;
    pkt_drop_rarp: in std_logic;
    My_MAC_addr: out std_logic_vector(47 downto 0);
    My_IP_addr: out std_logic_vector(31 downto 0);
    rarp_mode: out std_logic
  );
end udp_ipaddr_block;

architecture rtl of udp_ipaddr_block is

  signal MAC_IP_addr_rx_vld: std_logic;
  signal MAC_IP_addr_rx: std_logic_vector(79 downto 0);

begin

MAC_IP_addr_rx_vld_block:  process (mac_clk)
  begin
    if rising_edge(mac_clk) then
-- Valid RARP response received.
      if my_rx_last = '1' and pkt_drop_rarp = '0' and 
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

MAC_IP_addr_rx_block: process(mac_clk)
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
        if pkt_drop_rarp = '1' then
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

My_MAC_IP_addr_block:  process (mac_clk)
  variable Got_MAC_IP_addr_rx, last_enable_125: std_logic;
  variable My_MAC_IP_addr_int: std_logic_vector(79 downto 0);
  begin
    if rising_edge(mac_clk) then
-- Sample MAC_addr & IP_addr on reset or enable going high...
      if (rst_macclk_reg = '1') or
      (enable_125 = '1' and last_enable_125 = '0') then
        Got_MAC_IP_addr_rx := '0';
	My_MAC_IP_addr_int := MAC_addr & IP_addr;
      elsif MAC_IP_addr_rx_vld = '1' and rarp_125 = '1' then
        Got_MAC_IP_addr_rx := '1';
	My_MAC_IP_addr_int := MAC_IP_addr_rx;
      end if;
      last_enable_125 := enable_125;
      My_MAC_addr <= My_MAC_IP_addr_int(79 downto 32)
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      My_IP_addr <= My_MAC_IP_addr_int(31 downto 0)
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
      rarp_mode <= enable_125 and rarp_125 and not Got_MAC_IP_addr_rx
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

end rtl;
