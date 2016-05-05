-- Signals crossing clock domain...
--
-- Dave Sankey, January 2013

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udp_clock_crossing_if is
  generic(
    BUFWIDTH: natural := 0
  );
  port (
    mac_clk: in std_logic;
    rst_macclk_reg: in std_logic;
--
    rx_read_buffer_125: in std_logic_vector(BUFWIDTH - 1 downto 0);
    rx_req_send_125: in std_logic;
    tx_write_buffer_125: in std_logic_vector(BUFWIDTH - 1 downto 0);
    enable_125: out std_logic;
    rarp_125: out std_logic;
    rst_ipb_125: out std_logic;
    rx_ram_sent: out std_logic;
    tx_ram_written: out std_logic;
    we_125: out std_logic;
--
    ipb_clk: in std_logic; 
    rst_ipb: in std_logic;
--
    enable: in std_logic;
    pkt_done: in std_logic;
    RARP: in std_logic;
    we: in std_logic;
    pkt_rdy: out std_logic;
    rx_read_buffer: out std_logic_vector(BUFWIDTH - 1 downto 0);
    tx_write_buffer: out std_logic_vector(BUFWIDTH - 1 downto 0)
  );
end udp_clock_crossing_if;

architecture rtl of udp_clock_crossing_if is

  signal req_send_tff, we_latch : std_logic;
  signal enable_buf, rarp_buf, we_buf, rst_ipb_buf, pkt_done_tff: std_logic_vector(1 downto 0);
  signal req_send_buf, pkt_done_buf: std_logic_vector(2 downto 0);
  signal rx_read_buf_buf, tx_write_buf_buf: std_logic_vector(BUFWIDTH - 1 downto 0);

-- Synthesis attribute for Vivado 2015 and later:
  attribute ASYNC_REG: string;
  attribute ASYNC_REG of enable_buf: signal is "TRUE";
  attribute ASYNC_REG of pkt_done_buf: signal is "TRUE";
  attribute ASYNC_REG of rarp_buf: signal is "TRUE";
  attribute ASYNC_REG of req_send_buf: signal is "TRUE";
  attribute ASYNC_REG of rst_ipb_buf: signal is "TRUE";
  attribute ASYNC_REG of rx_read_buf_buf: signal is "TRUE";
  attribute ASYNC_REG of tx_write_buf_buf: signal is "TRUE";
  attribute ASYNC_REG of we_buf: signal is "TRUE";

-- Synthesis attribute for ISE:
  attribute KEEP: string;
  attribute KEEP of enable_buf: signal is "TRUE";
  attribute KEEP of pkt_done_buf: signal is "TRUE";
  attribute KEEP of rarp_buf: signal is "TRUE";
  attribute KEEP of req_send_buf: signal is "TRUE";
  attribute KEEP of rst_ipb_buf: signal is "TRUE";
  attribute KEEP of rx_read_buf_buf: signal is "TRUE";
  attribute KEEP of tx_write_buf_buf: signal is "TRUE";
  attribute KEEP of we_buf: signal is "TRUE";

begin

-- clock domain crossing logic based on
-- http://sc.morganisms.net/2010/06/rtl-for-passing-pulse-across-clock-domains-in-vhdl/
-- toggle flip flops used on control signals

  enable_125 <= enable_buf(1);
  rarp_125 <= rarp_buf(1);
  we_125 <= we_buf(1);
  rst_ipb_125 <= rst_ipb_buf(1);

transactor_if_ipb_clk: process(ipb_clk)
-- Signals to and from transactor are pkt_rdy and pkt_done:
--
-- This block clears pkt_rdy on start up.
-- It asserts it when it has a new packet ready to be processed by the transactor.
--
-- It clears it when it sees transactor starting to take packet (pkt_done goes low).
-- It then waits for pkt_done to go high again, at which point it closes current packet.
--
-- It moves on to next packet, asserting pkt_rdy when the next packet is ready to be processed by the transactor.
--
-- I.e. pkt_rdy is only high if there is a new packet ready to be processed.
--
-- Signals to and from MAC domain are toggle flipflops req_send_buf and pkt_done_tff
--
-- Toggle of req_send_buf signifies packet ready for transactor,
-- we toggle pkt_done_tff when processing complete.
--
  variable pkt_rdy_var, pkt_pending: std_logic;
  begin
    if rising_edge(ipb_clk) then
      if rst_ipb = '1' then
        pkt_rdy_var := '0';
        pkt_pending := '0';
      else
        if pkt_done = '0' then
          pkt_rdy_var := '0';
	elsif pkt_pending = '1' then
          pkt_rdy_var := '1';
	  pkt_pending := '0';
	end if;
        if (req_send_buf(2) xor req_send_buf(1)) = '1' then
-- Latch arrival of new packet
	  pkt_pending := '1';
	end if;
      end if;
      pkt_rdy <= pkt_rdy_var;
    end if;
  end process;      

pkt_done_ipb_clk: process(ipb_clk)
  variable last_pkt_done, pkt_done_var : std_logic;
  begin
    if rising_edge(ipb_clk) then
      if rst_ipb = '1' then
	last_pkt_done := '1';
	pkt_done_var := '0';
      else
        if (pkt_done = '1') and (last_pkt_done = '0') then
-- Transactor has finished with packet,
-- infer a toggle flip flop in source domain
	  pkt_done_var := not pkt_done_var;
	end if;
	last_pkt_done := pkt_done;
      end if;
      pkt_done_tff <= pkt_done_tff(0) & pkt_done_var;
    end if;
  end process;      

pkt_done_mac_clk: process(mac_clk)
  begin
    if rising_edge(mac_clk) then
-- pick up tff from ipbus domain
      pkt_done_buf <= pkt_done_buf(1 downto 0) & pkt_done_tff(1);
-- rx_ram_sent and tx_ram_written only high for 1 tick...
      rx_ram_sent <= pkt_done_buf(2) xor pkt_done_buf(1);
      tx_ram_written <= pkt_done_buf(2) xor pkt_done_buf(1);
    end if;
  end process;      

req_send_mac_clk: process(mac_clk)
  begin
    if rising_edge(mac_clk) then
      if rst_macclk_reg = '1' then
        req_send_tff <= '0';
      else
-- infer a toggle flip flop in source domain
        req_send_tff <= req_send_tff xor rx_req_send_125;
      end if;
    end if;
  end process;      

req_send_buf_ipb_clk: process(ipb_clk)
  begin
    if rising_edge(ipb_clk) then
      req_send_buf <= req_send_buf(1 downto 0) & req_send_tff;
    end if;
  end process;

enable_mac_clk: process(mac_clk)
  begin
    if rising_edge(mac_clk) then
      enable_buf <= enable_buf(0) & enable;
    end if;
  end process;      

rarp_mac_clk: process(mac_clk)
  begin
    if rising_edge(mac_clk) then
      rarp_buf <= rarp_buf(0) & RARP;
    end if;
  end process;      

we_ipb_clk: process(ipb_clk)
-- catch any we signal during packet
  variable we_latch_v : std_logic;
  begin
    if rising_edge(ipb_clk) then
      if pkt_done = '1' then
        we_latch_v := '0';
      elsif we = '1' then
        we_latch_v := '1';
      end if;
      we_latch <= we_latch_v;
    end if;
  end process;      

we_mac_clk: process(mac_clk)
  begin
    if rising_edge(mac_clk) then
      we_buf <= we_buf(0) & we_latch;
    end if;
  end process;      

rst_ipb_mac_clk: process(mac_clk)
  begin
    if rising_edge(mac_clk) then
      rst_ipb_buf <= rst_ipb_buf(0) & rst_ipb;
    end if;
  end process;      

rx_read_buffer_ipb_clk: process(ipb_clk)
  begin
    if rising_edge(ipb_clk) then
      rx_read_buf_buf <= rx_read_buffer_125;
      rx_read_buffer <= rx_read_buf_buf;
    end if;
  end process;    

tx_write_buffer_ipb_clk: process(ipb_clk)
  begin
    if rising_edge(ipb_clk) then
      tx_write_buf_buf <= tx_write_buffer_125;
      tx_write_buffer <= tx_write_buf_buf;
    end if;
  end process;    

end rtl;
