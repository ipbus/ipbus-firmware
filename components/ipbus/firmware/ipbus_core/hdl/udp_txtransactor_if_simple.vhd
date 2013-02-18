-- Simple interface to tx side of transactor...
-- single RAM
--
-- Dave Sankey, September 2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_txtransactor_if is
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
--
    req_resend: in std_logic;
--
    pkt_done_125: in std_logic;
    we_125: in std_logic;
    udpaddrb: in std_logic_vector(12 downto 0);
    udpram_send: out std_logic;
    udpdob: out std_logic_vector(7 downto 0);
--
    ipb_clk: in std_logic; 
    rst_ipb: in std_logic;
--
    pkt_done: in std_logic;
    we: in std_logic;
    waddr: in std_logic_vector(11 downto 0);
    wdata: in std_logic_vector(31 downto 0);
--
    tx_wea : out std_logic;
    tx_addra : out std_logic_vector(10 downto 0);
    tx_addrb : out std_logic_vector(12 downto 0);
    tx_dia : out std_logic_vector(31 downto 0);
    tx_dob : in std_logic_vector(7 downto 0)
  );
end udp_txtransactor_if;

architecture simple of udp_txtransactor_if is

  signal ram_written : std_logic;

begin

-- IPBus clock domain
  tx_wea <= we;
  tx_addra <= waddr(10 downto 0);
  tx_dia <= wdata;

-- mac_clk clock domain
  tx_addrb <= udpaddrb;
  udpdob <= tx_dob;

  udpram_send <= pkt_done_125 or (req_resend and ram_written);

ram_status: process (mac_clk)
  variable ram_written_i: std_logic;
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
	ram_written_i := '0';
      elsif pkt_done_125 = '1' then
        ram_written_i := '1';
      elsif we_125 = '1' then 
	ram_written_i := '0';
      end if;
      ram_written <= ram_written_i
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

end simple;