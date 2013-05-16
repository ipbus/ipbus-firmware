-- Accumulates status info and passes dollops to udp_build_status
--
-- Dave Sankey, Jan 2013

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_status_buffer is
  generic(
    BUFWIDTH: natural := 0;
    ADDRWIDTH: natural := 0
  );
  port (
    mac_clk: in std_logic;
    rst_macclk: in std_logic;
    rst_ipb_125: in std_logic;
    rx_reset: in std_logic;
    mac_rx_error: in std_logic;
    mac_rx_last: in std_logic;
    ipbus_in_hdr: in std_logic_vector(31 downto 0);
    ipbus_out_hdr: in std_logic_vector(31 downto 0);
    ipbus_out_valid: in std_logic;
    pkt_broadcast: in std_logic;
    pkt_drop_arp: in std_logic;
    pkt_drop_ipbus: in std_logic;
    pkt_drop_payload: in std_logic;
    pkt_drop_ping: in std_logic;
    pkt_drop_reliable: in std_logic;
    pkt_drop_resend: in std_logic;
    pkt_drop_status: in std_logic;
    pkt_rcvd: in std_logic;
    rxpayload_dropped: in std_logic;
    rxram_dropped: in std_logic;
    status_request: in std_logic;
    next_pkt_id: out std_logic_vector(15 downto 0);
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
  variable next_pkt_id_int, bufsize, nbuf: unsigned(15 downto 0);
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
        bufsize := to_unsigned((2**ADDRWIDTH) - 8, 16);
        nbuf := to_unsigned(2**BUFWIDTH, 16);
        next_pkt_id_int := to_unsigned(1, 16);
        header <= x"200000F1" & x"0000" & 
	std_logic_vector(bufsize) & x"0000" &
	std_logic_vector(nbuf) & x"200001F0"
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      elsif pkt_rcvd = '1' and pkt_drop_reliable = '0' then
        if next_pkt_id_int = x"FFFF" then
	  next_pkt_id_int := to_unsigned(1, 16);
	else
	  next_pkt_id_int := next_pkt_id_int + 1;
	end if;
        header(31 downto 0) <= x"20" & std_logic_vector(next_pkt_id_int) & x"F0"
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
      next_pkt_id <= std_logic_vector(next_pkt_id_int)
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

history_block:  process (mac_clk)
  variable last_rst_ipb, new_event, event_pending: std_logic;
  variable event_data: std_logic_vector(7 downto 0);
  variable arp_ping_ipbus, payload_status_resend: std_logic_vector(2 downto 0);
  begin
    if rising_edge(mac_clk) then
      if rst_macclk = '1' then
	event_pending := '0';
        history <= (Others => '0')
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
      new_event := '0';
      if rst_ipb_125 = '1' and not last_rst_ipb = '1' then
        new_event := '1';
	event_data := x"01";
      end if;
      if mac_rx_last = '1' then
        arp_ping_ipbus := pkt_drop_arp & pkt_drop_ping & pkt_drop_ipbus;
	payload_status_resend := pkt_drop_payload & pkt_drop_status & 
	pkt_drop_resend;
        case arp_ping_ipbus is
	  when "011" =>
	    event_data := x"07";
	  when "101" =>
	    event_data := x"06";
	  when "110" =>
	    case payload_status_resend is
	      when "011" =>
	        event_data := x"02";
	      when "101" =>
	        event_data := x"03";
	      when "110" =>
	        event_data := x"04";
	      when Others =>
	        event_data := x"05";
	    end case;
	  when Others =>
	    if pkt_broadcast = '0' then
	      event_data := x"0F";
	    end if;
        end case;
        if mac_rx_error = '1' then
	  event_data(7 downto 4) := x"8";
	end if;
	event_pending := '1';
      end if;
      if event_pending = '1' then
        if rxpayload_dropped = '1' or rxram_dropped = '1' then
	  event_data(7 downto 4) := x"4";
	elsif rx_reset = '1' then
	  new_event := '1';
	end if;
      end if;
      if new_event = '1' then
        event_pending := '0';
        history <= history(119 downto 0) & event_data
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
      last_rst_ipb := rst_ipb_125;
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
      if pkt_rcvd = '1' then
        ipbus_in <= ipbus_in(95 downto 0) & ipbus_in_hdr
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
      elsif ipbus_out_valid = '1' then
        ipbus_out <= ipbus_out(95 downto 0) & ipbus_out_hdr
-- pragma translate_off
        after 4 ns
-- pragma translate_on
        ;
      end if;
    end if;
  end process;

end rtl;
