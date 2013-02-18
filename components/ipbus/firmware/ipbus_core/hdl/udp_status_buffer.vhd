-- Accumulates status info and passes dollops to udp_build_status
--
-- Dave Sankey, Jan 2013

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_status_buffer is
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
    rx_reset: in std_logic;
    pkt_done_125: in std_logic;
    next_pkt_id: in std_logic_vector(15 downto 0);
    status_request: in std_logic;
    status_block: out std_logic_vector(127 downto 0)
  );
end udp_status_buffer;

architecture rtl of udp_status_buffer is

  signal header, history, ipbus_in, ipbus_out: std_logic_vector(127 downto 0);
  signal tick: integer range 0 to 3;

begin

With tick select status_block <=
  history when 1,
  ipbus_in when 2,
  ipbus_out when 3,
  header when Others;

select_block:  process (mac_clk)
  begin
    if rising_edge(mac_clk) then
      if rx_reset = '1' then
        tick <= 0
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      elsif status_request = '1' then
        tick <= tick + 1
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
    end if;
  end process;

header_block:  process (mac_clk)
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
        header <= x"200000FF" & x"00001FF8" & x"00000001" & x"200001F0"
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      elsif pkt_done_125 = '1' then
        header(31 downto 0) <= x"20" & next_pkt_id & x"F0"
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
    end if;
  end process;

history_block:  process (mac_clk)
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
        history <= (Others => '0')
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
    end if;
  end process;

ipbus_in_block:  process (mac_clk)
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
        ipbus_in <= (Others => '0')
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
    end if;
  end process;

ipbus_out_block:  process (mac_clk)
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
        ipbus_out <= (Others => '0')
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
    end if;
  end process;

end rtl;
