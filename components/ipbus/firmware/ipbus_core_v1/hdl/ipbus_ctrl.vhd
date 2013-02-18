-- Dave Newbold, May 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use work.ipbus.all;
use work.ipbus_ctrl_decl.all;
use work.ipbus_bus_decl.all;

entity ipbus_ctrl is 
  port(
		mac_clk: in std_logic;
		rst_macclk: in std_logic;
		ipb_clk: in std_logic;
		rst_ipb: in std_logic;
		mac_rx_data: in std_logic_vector(7 downto 0);
		mac_rx_valid: in std_logic;
		mac_rx_last: in std_logic;
		mac_rx_error: in std_logic;
		mac_tx_data: out std_logic_vector(7 downto 0);
		mac_tx_valid: out std_logic;
		mac_tx_last: out std_logic;
		mac_tx_error: out std_logic;
		mac_tx_ready: in std_logic;
		ipb_out: out ipb_wbus;
		ipb_in: in ipb_rbus;
		mac_addr: in std_logic_vector(47 downto 0);
		ip_addr: in std_logic_vector(31 downto 0);
		pkt_rx_led: out std_logic;
		pkt_tx_led: out std_logic
	);

end ipbus_ctrl;

architecture rtl of ipbus_ctrl is

  signal packet_txd, packet_rxd: std_logic_vector(7 downto 0);
  signal packet_txa, packet_txlen, packet_rxa, packet_rxl: pbuf_a;
  signal packet_txwe, packet_txdone, packet_rxready, packet_rxdone: std_logic;
  signal arp_rxa, arp_txa: std_logic_vector(5 downto 0);
  signal arp_txd: std_logic_vector(7 downto 0);
  signal arp_we, arp_xmit, arp_done, arp_ready: std_logic;

  signal icmp_rxa, icmp_txa, icmp_len: std_logic_vector(9 downto 0);
  signal icmp_txd: std_logic_vector(7 downto 0);
  signal icmp_we, icmp_xmit, icmp_done, icmp_ready: std_logic;

  signal udp_rxa, udp_txa, udp_len: pbuf_a;
  signal udp_txd: std_logic_vector(7 downto 0);
  signal udp_we, udp_xmit, udp_done, udp_ready, udp_space, udp_xmit_req, udp_xmit_ok: std_logic;

  signal packet_req_addr,packet_req_len: rbuf_a;
  signal packet_resp_addr,packet_resp_len: wbuf_a;
  signal packet_req_data,packet_resp_data: std_logic_vector(31 downto 0);
  signal resp_we, req_avail, resp_done: std_logic;
  
  signal moti: trans_moti;
  signal tomi: trans_tomi;

begin

  txbuf: entity work.tx_buffer port map(
    clk => mac_clk,
    rst => rst_macclk,
    tx_data => mac_tx_data,
    tx_valid => mac_tx_valid,
    tx_last => mac_tx_last,
    tx_error => mac_tx_error,
    tx_ready => mac_tx_ready,
    packet_txd => packet_txd,
    packet_addr => packet_txa,
    packet_we => packet_txwe,
    packet_done => packet_txdone,
    packet_len => packet_txlen
  );

	rxbuf: entity work.rx_buffer port map(
		clk => mac_clk,
		rst => rst_macclk,
		rx_data => mac_rx_data,
		rx_valid => mac_rx_valid,
		rx_last => mac_rx_last,
		rx_error => mac_rx_error,
		packet_rxd => packet_rxd,
		packet_rxa => packet_rxa,
		packet_len => packet_rxl,
		packet_rxready => packet_rxready,
		packet_rxdone => packet_rxdone
	);
  
  handler: packet_handler port map(
    clk => mac_clk,
    reset => rst_macclk,
    rxa => packet_rxa,
    rxd => packet_rxd,
    txa => packet_txa,
    txd => packet_txd,
    rx_ready => packet_rxready,
    rx_done => packet_rxdone,
    tx_we => packet_txwe,
    tx_done => packet_txdone,
    tx_len => packet_txlen,
    ip => ip_addr,
    arp_rxa => arp_rxa,
    arp_txa => arp_txa,
    arp_len => "101010",
    arp_txd => arp_txd,
    arp_we => arp_we,
    arp_xmit => arp_xmit,
    arp_done => arp_done,
    arp_ready => arp_ready,
    icmp_rxa => icmp_rxa,
    icmp_txa => icmp_txa,
    icmp_len => icmp_len,
    icmp_txd => icmp_txd,
    icmp_we => icmp_we,
    icmp_xmit => icmp_xmit,
    icmp_done => icmp_done,
    icmp_ready => icmp_ready,
    udp_rxa => udp_rxa,
    udp_txa => udp_txa,
    udp_len => udp_len,
    udp_txd => udp_txd,
    udp_we => udp_we,
    udp_xmit => udp_xmit,
    udp_done => udp_done,
    udp_ready => udp_ready,
    udp_space => udp_space,
    udp_xmit_req => udp_xmit_req,
    udp_xmit_ok => udp_xmit_ok
  );

  arp_block: arp port map(
    mac_clk => mac_clk,
    reset => rst_macclk,
    packet_ready => arp_ready,
    myMAC => mac_addr,
    myIP => ip_addr,
    packet_data => packet_rxd,
    packet_read_addr => arp_rxa,
    done_with_packet => arp_done,
    packet_out => arp_txd,
    packet_out_addr => arp_txa,
    packet_out_we => arp_we,
    packet_xmit => arp_xmit
  );
  
  icmp_block: icmp port map(
    mac_clk => mac_clk,
    reset => rst_macclk,
    packet_ready => icmp_ready,
    packet_data => packet_rxd,
    packet_read_addr => icmp_rxa,
    done_with_packet => icmp_done,
    packet_out => icmp_txd,
    packet_out_addr => icmp_txa,
    packet_out_we => icmp_we,
    packet_xmit => icmp_xmit,
    packet_out_len => icmp_len,
    reset_reg_out => open
  );

  packet_buffer: sub_packetbuffer port map(
    ipb_clk => ipb_clk,
    mac_clk => mac_clk,
    reset => rst_macclk,
    incoming_ready => udp_ready,
    done_with_incoming => udp_done,
    incoming_space => udp_space,
    rxa => udp_rxa,
    rxd => packet_rxd,
    rxl => packet_rxl,
    txa => udp_txa,
    txd => udp_txd,
    tx_we => udp_we,
    txl => udp_len,
    tx_send => udp_xmit,
    tx_req => udp_xmit_req,
    tx_ok => udp_xmit_ok,
    req_addr => packet_req_addr,
    req_data => packet_req_data,
    req_len => packet_req_len,
    resp_addr => packet_resp_addr,
    resp_data => packet_resp_data,
    resp_len => packet_resp_len,
    resp_we => resp_we,
    req_avail => req_avail,
    resp_done => resp_done
  );

  shim: entity work.udp_shim port map(
    clk => ipb_clk,
    reset => rst_ipb,
    packet_data_i => packet_req_data,
    packet_len_i => packet_req_len,
    packet_addr_i => packet_req_addr,
    packet_data_o => packet_resp_data,
    packet_addr_o => packet_resp_addr,
    packet_len_o => packet_resp_len,
    packet_we_o => resp_we,
    new_packet => req_avail,
    done => resp_done,
    moti => moti,
    tomi => tomi
  );

  trans: entity work.transactor port map(
   	clk => ipb_clk, 
    reset => rst_ipb,
    ipb_out => ipb_out,
    ipb_in => ipb_in,
    moti => moti,
    tomi => tomi
  );
  
  pkt_rx_led <= '0';
  pkt_tx_led <= '1';

end rtl;
