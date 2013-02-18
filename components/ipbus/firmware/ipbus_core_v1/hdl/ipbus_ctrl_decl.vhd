-- Contains the component declarations for the remaining verilog
-- modules required for the ipbus controller design.
--
-- Dave Newbold, May 2011
--
-- $Id$

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus_bus_decl.all;

package ipbus_ctrl_decl is

  component gbe_txpacketbuffer port(
    mac_clk: in std_logic;
    mac_txd: out std_logic_vector(7 downto 0);
    mac_txdv: out std_logic;
    mac_txack: in std_logic;
    reset: in std_logic;
    packet_txd: in std_logic_vector(7 downto 0);
    packet_addr: in pbuf_a;
    packet_we: in std_logic;
    packet_done: in std_logic;
    packet_len: in pbuf_a);
  end component;

  component gbe_rxpacketbuffer port(
    clk: in std_logic;
    mac_clk: in std_logic;
    mac_rxd: in std_logic_vector(7 downto 0);
    mac_rxdv: in std_logic;
    mac_rxpacketok: in std_logic;
    mac_rxpacketbad: in std_logic;
    reset: in std_logic;
    packet_rxd: out std_logic_vector(7 downto 0);
    packet_rxa: in pbuf_a;
    packet_rxready: out std_logic;
    packet_rxdone: in std_logic;
    packet_len: out pbuf_a);
  end component;

  component packet_handler port(
    clk: in std_logic;
    reset: in std_logic;
    rxa: out pbuf_a;
    rxd: in std_logic_vector(7 downto 0);
    txa: out pbuf_a;
    txd: out std_logic_vector(7 downto 0);
    rx_ready: in std_logic;
    rx_done: out std_logic;
    tx_we: out std_logic;
    tx_done: out std_logic;
    tx_len: out pbuf_a;
    ip: in std_logic_vector(31 downto 0);
    arp_rxa: in std_logic_vector(5 downto 0);
    arp_txa: in std_logic_vector(5 downto 0);
    arp_len: in std_logic_vector(5 downto 0);
    arp_txd: in std_logic_vector(7 downto 0);
    arp_we: in std_logic;
    arp_xmit: in std_logic;
    arp_done: in std_logic;
    arp_ready: out std_logic;
    icmp_rxa: in std_logic_vector(9 downto 0);
    icmp_txa: in std_logic_vector(9 downto 0);
    icmp_len: in std_logic_vector(9 downto 0);
    icmp_txd: in std_logic_vector(7 downto 0);
    icmp_we: in std_logic;
    icmp_xmit: in std_logic;
    icmp_done: in std_logic;
    icmp_ready: out std_logic;
    udp_rxa: in pbuf_a;
    udp_txa: in pbuf_a;
    udp_len: in pbuf_a;
    udp_txd: in std_logic_vector(7 downto 0);
    udp_we: in std_logic;
    udp_xmit: in std_logic;
    udp_done: in std_logic;
    udp_ready: out std_logic;
    udp_space: in std_logic;
    udp_xmit_req: in std_logic;
    udp_xmit_ok: out std_logic);
  end component;

  component arp port(
    mac_clk: in std_logic;
    reset: in std_logic;
    packet_ready: in std_logic;
    myMAC: in std_logic_vector(47 downto 0);
    myIP: in std_logic_vector(31 downto 0);
    packet_data: in std_logic_vector(7 downto 0);
    packet_read_addr: out std_logic_vector(5 downto 0);
    done_with_packet: out std_logic;
    packet_out: out std_logic_vector(7 downto 0);
    packet_out_addr: out std_logic_vector(5 downto 0);
    packet_out_we: out std_logic;
    packet_xmit: out std_logic);
  end component;
    
  component icmp port(
    mac_clk: in std_logic;
    reset: in std_logic;
    packet_ready: in std_logic;
    packet_data: in std_logic_vector(7 downto 0);
    packet_read_addr: out std_logic_vector(9 downto 0);
    done_with_packet: out std_logic;
    packet_out: out std_logic_vector(7 downto 0);
    packet_out_addr: out std_logic_vector(9 downto 0);
    packet_out_we: out std_logic;
    packet_xmit: out std_logic;
    packet_out_len: out std_logic_vector(9 downto 0);
    reset_reg_out: out std_logic_vector(31 downto 0));
  end component;

  component sub_packetbuffer port(
    ipb_clk: in std_logic;
    mac_clk: in std_logic;
    reset: in std_logic;
    incoming_ready: in std_logic;
    done_with_incoming: out std_logic;
    incoming_space: out std_logic;
    rxa: out pbuf_a;
    rxd: in std_logic_vector(7 downto 0);
    rxl: in pbuf_a;
    txa: out pbuf_a;
    txd: out std_logic_vector(7 downto 0);
    tx_we: out std_logic;
    txl: out pbuf_a;
    tx_send: out std_logic;
    tx_req: out std_logic;
    tx_ok: in std_logic;
    req_addr: in rbuf_a;
    req_data: out std_logic_vector(31 downto 0);
    req_len: out rbuf_a;
    resp_addr: in wbuf_a;
    resp_data: in std_logic_vector(31 downto 0);
    resp_len: in wbuf_a;
    resp_we: in std_logic;
    req_avail: out std_logic;
    resp_done: in std_logic);
  end component;

end ipbus_ctrl_decl;

