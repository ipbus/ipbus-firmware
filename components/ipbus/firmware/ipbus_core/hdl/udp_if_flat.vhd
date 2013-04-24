-- UDP_if created from
-- VHDL Entity ipbus_v2_lib.UDP_if.symbol and
-- VHDL Entity ipbus_v2_lib.rxblock.symbol
--  Dave Sankey Sep 2012

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY UDP_if IS
   PORT( 
      mac_clk: IN std_logic;
      rst_macclk: IN std_logic;
      ipb_clk: IN std_logic;
      rst_ipb: IN std_logic;
      IP_addr: IN std_logic_vector(31 DOWNTO 0);
      MAC_addr: IN std_logic_vector(47 DOWNTO 0);
      mac_rx_data: IN std_logic_vector(7 DOWNTO 0);
      mac_rx_error: IN std_logic;
      mac_rx_last: IN std_logic;
      mac_rx_valid: IN std_logic;
      mac_tx_ready: IN std_logic;
      pkt_done: IN std_logic;
      raddr: IN std_logic_vector(11 DOWNTO 0);
      waddr: IN std_logic_vector(11 DOWNTO 0);
      wdata: IN std_logic_vector(31 DOWNTO 0);
      we: IN std_logic;
      busy: OUT std_logic;
      mac_tx_data: OUT std_logic_vector(7 DOWNTO 0);
      mac_tx_error: OUT std_logic;
      mac_tx_last: OUT std_logic;
      mac_tx_valid: OUT std_logic;
      pkt_rdy: OUT std_logic;
      rdata: OUT std_logic_vector(31 DOWNTO 0);
      rxpayload_dropped: OUT std_logic;
      rxram_dropped: OUT std_logic
   );

END UDP_if ;

ARCHITECTURE flat OF UDP_if IS

   SIGNAL addra: std_logic_vector(12 DOWNTO 0);
   SIGNAL addrb: std_logic_vector(12 DOWNTO 0);
   SIGNAL cksum: std_logic;
   SIGNAL clr_sum: std_logic;
   SIGNAL dia: std_logic_vector(7 DOWNTO 0);
   SIGNAL do_sum: std_logic;
   SIGNAL dob: std_logic_vector(7 DOWNTO 0);
   SIGNAL int_data: std_logic_vector(7 DOWNTO 0);
   SIGNAL int_valid: std_logic;
   SIGNAL outbyte: std_logic_vector(7 DOWNTO 0);
   SIGNAL payload_addr: std_logic_vector(12 DOWNTO 0);
   SIGNAL payload_data: std_logic_vector(7 DOWNTO 0);
   SIGNAL payload_send: std_logic;
   SIGNAL payload_we: std_logic;
   SIGNAL req_resend: std_logic;
   SIGNAL rx_addra: std_logic_vector(12 DOWNTO 0);
   SIGNAL rx_addrb: std_logic_vector(10 DOWNTO 0);
   SIGNAL rx_dia: std_logic_vector(7 DOWNTO 0);
   SIGNAL rx_dob: std_logic_vector(31 DOWNTO 0);
   SIGNAL rx_reset: std_logic;
   SIGNAL rx_wea: std_logic;
   SIGNAL rxram_busy: std_logic;
   SIGNAL rxram_end_addr: std_logic_vector(12 DOWNTO 0);
   SIGNAL rxram_send: std_logic;
   SIGNAL tx_addra: std_logic_vector(10 DOWNTO 0);
   SIGNAL tx_addrb: std_logic_vector(12 DOWNTO 0);
   SIGNAL tx_dia: std_logic_vector(31 DOWNTO 0);
   SIGNAL tx_dob: std_logic_vector(7 DOWNTO 0);
   SIGNAL tx_wea: std_logic;
   SIGNAL udpaddrb: std_logic_vector(12 DOWNTO 0);
   SIGNAL udpdob: std_logic_vector(7 DOWNTO 0);
   SIGNAL udpram_busy: std_logic;
   SIGNAL udpram_send: std_logic;
   SIGNAL wea: std_logic;
--
   SIGNAL arp_addr: std_logic_vector(12 DOWNTO 0);
   SIGNAL arp_data: std_logic_vector(7 DOWNTO 0);
   SIGNAL arp_end_addr: std_logic_vector(12 DOWNTO 0);
   SIGNAL arp_send: std_logic;
   SIGNAL arp_we: std_logic;
   SIGNAL rx_cksum: std_logic;
   SIGNAL rx_clr_sum: std_logic;
   SIGNAL clr_sum_payload: std_logic;
   SIGNAL clr_sum_ping: std_logic;
   SIGNAL rx_do_sum: std_logic;
   SIGNAL do_sum_payload: std_logic;
   SIGNAL do_sum_ping: std_logic;
   SIGNAL rx_int_data: std_logic_vector(7 DOWNTO 0);
   SIGNAL int_data_payload: std_logic_vector(7 DOWNTO 0);
   SIGNAL int_data_ping: std_logic_vector(7 DOWNTO 0);
   SIGNAL rx_int_valid: std_logic;
   SIGNAL int_valid_payload: std_logic;
   SIGNAL int_valid_ping: std_logic;
   SIGNAL rx_outbyte: std_logic_vector(7 DOWNTO 0);
   SIGNAL ping_addr: std_logic_vector(12 DOWNTO 0);
   SIGNAL ping_data: std_logic_vector(7 DOWNTO 0);
   SIGNAL ping_end_addr: std_logic_vector(12 DOWNTO 0);
   SIGNAL ping_send: std_logic;
   SIGNAL ping_we: std_logic;
   SIGNAL status_block: std_logic_vector(127 downto 0);
   SIGNAL status_request: std_logic;
   SIGNAL status_data: std_logic_vector(7 downto 0);
   SIGNAL status_addr: std_logic_vector(12 downto 0);
   SIGNAL status_we: std_logic;
   SIGNAL status_end_addr: std_logic_vector(12 downto 0);
   SIGNAL status_send: std_logic;
   SIGNAL pkt_drop_arp: std_logic;
   SIGNAL pkt_drop_payload: std_logic;
   SIGNAL pkt_drop_ping: std_logic;
   SIGNAL pkt_drop_resend: std_logic;
   SIGNAL pkt_drop_status: std_logic;
   signal last_rx_last: std_logic;
   signal my_rx_last: std_logic;
--
   signal ipbus_in_hdr, ipbus_out_hdr: std_logic_vector(31 downto 0);
   signal pkt_broadcast, ipbus_out_valid: std_logic;
   signal rxram_dropped_sig, rxpayload_dropped_sig: std_logic;
   signal pkt_drop_ipbus, pkt_drop_reliable: std_logic;
   signal next_pkt_id: std_logic_vector(15 downto 0); -- Next expected packet ID

--
   signal pkt_done_125: std_logic;
   signal pkt_rdy_125: std_logic;
   signal we_125: std_logic;
   signal ipb_rst_sync: std_logic;

BEGIN

-- nasty kludge to not rename port, but this is really rxpacket_dropped
   rxram_dropped <= rxram_dropped_sig or rxpayload_dropped_sig;
-- nasty kludge to not rename port, but this is really rxpacket_ignored
   rxpayload_dropped <= my_rx_last and pkt_drop_arp and pkt_drop_ping and
   pkt_drop_payload and pkt_drop_resend and pkt_drop_status;

   rx_do_sum <= do_sum_ping or do_sum_payload;
   rx_clr_sum <= clr_sum_ping or clr_sum_payload;
   rx_int_valid <= int_valid_ping or int_valid_payload;
   rx_int_data <= int_data_payload when int_valid_payload = '1' else int_data_ping;

-- force rx_last to match documentation!
rx_last_kludge: process(mac_clk)
  begin
    if rising_edge(mac_clk) then
      last_rx_last <= mac_rx_last
-- pragma translate_off
      after 4 ns
-- pragma translate_on
      ;
    end if;
  end process;

   my_rx_last <= mac_rx_last and not last_rx_last;

   -- Instance port mappings.
   ARP: entity work.udp_build_arp
      PORT MAP (
         mac_clk => mac_clk,
         rx_reset => rx_reset,
         mac_rx_data => mac_rx_data,
         mac_rx_valid => mac_rx_valid,
         mac_rx_last => my_rx_last,
         mac_rx_error => mac_rx_error,
         pkt_drop_arp => pkt_drop_arp,
         MAC_addr => MAC_addr,
         IP_addr => IP_addr,
         arp_data => arp_data,
         arp_addr => arp_addr,
         arp_we => arp_we,
         arp_end_addr => arp_end_addr,
         arp_send => arp_send
      );
      
    payload: entity work.udp_build_payload
      PORT MAP (
         mac_clk => mac_clk,
         rx_reset => rx_reset,
         mac_rx_data => mac_rx_data,
         mac_rx_valid => mac_rx_valid,
         mac_rx_last => my_rx_last,
         mac_rx_error => mac_rx_error,
         pkt_drop_payload => pkt_drop_payload,
         outbyte => rx_outbyte,
         payload_data => payload_data,
         payload_addr => payload_addr,
         payload_we => payload_we,
         payload_send => payload_send,
         do_sum_payload => do_sum_payload,
         clr_sum_payload => clr_sum_payload,
         int_data_payload => int_data_payload,
         int_valid_payload => int_valid_payload,
         cksum => rx_cksum,
         ipbus_in_hdr => ipbus_in_hdr
      );
      
   ping: entity work.udp_build_ping
      PORT MAP (
         mac_clk => mac_clk,
         rx_reset => rx_reset,
         mac_rx_data => mac_rx_data,
         mac_rx_valid => mac_rx_valid,
         mac_rx_last => my_rx_last,
         mac_rx_error => mac_rx_error,
         pkt_drop_ping => pkt_drop_ping,
         outbyte => rx_outbyte,
         ping_data => ping_data,
         ping_addr => ping_addr,
         ping_we => ping_we,
         ping_end_addr => ping_end_addr,
         ping_send => ping_send,
         do_sum_ping => do_sum_ping,
         clr_sum_ping => clr_sum_ping,
         int_data_ping => int_data_ping,
         int_valid_ping => int_valid_ping
      );
   resend: entity work.udp_build_resend
      PORT MAP (
         mac_clk => mac_clk,
         mac_rx_valid => mac_rx_valid,
         mac_rx_last => my_rx_last,
         mac_rx_error => mac_rx_error,
         pkt_drop_resend => pkt_drop_resend,
         req_resend => req_resend
      );
   status: entity work.udp_build_status
      PORT MAP (
         mac_clk => mac_clk,
	 rx_reset => rx_reset,
	 mac_rx_data => mac_rx_data,
	 mac_rx_valid => mac_rx_valid,
	 mac_rx_last => my_rx_last,
	 mac_rx_error => mac_rx_error,
	 pkt_drop_status => pkt_drop_status,
	 status_block => status_block,
	 status_request => status_request,
	 status_data => status_data,
	 status_addr => status_addr,
	 status_we => status_we,
	 status_end_addr => status_end_addr,
	 status_send => status_send
      );
   status_buffer: entity work.udp_status_buffer
      PORT MAP (
         mac_clk => mac_clk,
	 rst_macclk => rst_macclk,
	 rst_ipb_sync => rst_ipb_sync,
	 rx_reset => rx_reset,
	 mac_rx_error => mac_rx_error,
	 mac_rx_last => my_rx_last,
	 ipbus_in_hdr => ipbus_in_hdr,
	 ipbus_out_hdr => ipbus_out_hdr,
	 ipbus_out_valid => ipbus_out_valid,
	 pkt_broadcast => pkt_broadcast,
	 pkt_drop_arp => pkt_drop_arp,
	 pkt_drop_ipbus => pkt_drop_ipbus,
	 pkt_drop_payload => pkt_drop_payload,
	 pkt_drop_ping => pkt_drop_ping,
	 pkt_drop_reliable => pkt_drop_reliable,
	 pkt_drop_resend => pkt_drop_resend,
	 pkt_drop_status => pkt_drop_status,
	 pkt_rdy_125 => pkt_rdy_125,
	 rxpayload_dropped => rxpayload_dropped_sig,
	 rxram_dropped => rxram_dropped_sig,
	 status_request => status_request,
	 next_pkt_id => next_pkt_id,
	 status_block => status_block
      );
   rx_byte_sum: entity work.udp_byte_sum
      PORT MAP (
         mac_clk => mac_clk,
         do_sum => rx_do_sum,
         clr_sum => rx_clr_sum,
         mac_rx_data => mac_rx_data,
         mac_rx_valid => mac_rx_valid,
         int_data => rx_int_data,
         int_valid => rx_int_valid,
	 run_byte_sum => '0',
         cksum => rx_cksum,
         outbyte => rx_outbyte
      );
   rx_reset_block: entity work.udp_do_rx_reset
      PORT MAP (
         mac_clk => mac_clk,
         rst_macclk => rst_macclk,
         mac_rx_last => my_rx_last,
	 mac_rx_valid => mac_rx_valid,
         rx_reset => rx_reset
      );
   rx_packet_parser: entity work.udp_packet_parser
      PORT MAP (
         mac_clk => mac_clk,
	 rx_reset => rx_reset,
	 mac_rx_data => mac_rx_data,
	 mac_rx_valid => mac_rx_valid,
	 MAC_addr => MAC_addr,
	 IP_addr => IP_addr,
	 next_pkt_id => next_pkt_id,
	 pkt_broadcast => pkt_broadcast,
	 pkt_drop_arp => pkt_drop_arp,
	 pkt_drop_ipbus => pkt_drop_ipbus,
	 pkt_drop_payload => pkt_drop_payload,
	 pkt_drop_ping => pkt_drop_ping,
	 pkt_drop_reliable => pkt_drop_reliable,
	 pkt_drop_resend => pkt_drop_resend,
	 pkt_drop_status => pkt_drop_status
      );
   rx_ram_mux: entity work.udp_rxram_mux
      PORT MAP (
         mac_clk => mac_clk,
         rx_reset => rx_reset,
         pkt_drop_arp => pkt_drop_arp,
         arp_data => arp_data,
         arp_addr => arp_addr,
         arp_we => arp_we,
         arp_end_addr => arp_end_addr,
         arp_send => arp_send,
         pkt_drop_ping => pkt_drop_ping,
         ping_data => ping_data,
         ping_addr => ping_addr,
         ping_we => ping_we,
         ping_end_addr => ping_end_addr,
         ping_send => ping_send,
	 pkt_drop_status => pkt_drop_status,
	 status_data => status_data,
	 status_addr => status_addr,
	 status_we => status_we,
	 status_end_addr => status_end_addr,
	 status_send => status_send,
	 mac_rx_valid => mac_rx_valid,
         rxram_busy => rxram_busy,
         dia => dia,
         addra => addra,
         wea => wea,
         rxram_end_addr => rxram_end_addr,
         rxram_send => rxram_send,
         rxram_dropped => rxram_dropped_sig
      );
   internal_ram: entity work.udp_DualPortRAM
      PORT MAP (
         ClkA => mac_clk,
         ClkB => mac_clk,
         wea => wea,
         addra => addra,
         addrb => addrb,
         dia => dia,
         dob => dob
      );
   ipbus_rx_ram: entity work.udp_DualPortRAM_rx
      PORT MAP (
         clk125 => mac_clk,
         clk => ipb_clk,
         rx_wea => rx_wea,
         rx_addra => rx_addra,
         rx_addrb => rx_addrb,
         rx_dia => rx_dia,
         rx_dob => rx_dob
      );
   ipbus_tx_ram: entity work.udp_DualPortRAM_tx
      PORT MAP (
         clk => ipb_clk,
         clk125 => mac_clk,
         tx_wea => tx_wea,
         tx_addra => tx_addra,
         tx_addrb => tx_addrb,
         tx_dia => tx_dia,
         tx_dob => tx_dob
      );
   tx_byte_sum: entity work.udp_byte_sum
      PORT MAP (
         mac_clk => mac_clk,
         do_sum => do_sum,
         clr_sum => clr_sum,
         mac_rx_data => udpdob,
         mac_rx_valid => udpram_busy,
         int_data => int_data,
         int_valid => int_valid,
         run_byte_sum => int_valid,
         cksum => cksum,
         outbyte => outbyte
      );
   rx_transactor: entity work.udp_rxtransactor_if
      PORT MAP (
         mac_clk => mac_clk,
         rst_macclk => rst_macclk,
         payload_data => payload_data,
         payload_addr => payload_addr,
         payload_we => payload_we,
         payload_send => payload_send,
	 pkt_done_125 => pkt_done_125,
         rx_reset => rx_reset,
	 pkt_rdy_125 => pkt_rdy_125,
         ipb_clk => ipb_clk,
         rst_ipb => rst_ipb,
         pkt_done => pkt_done,
         raddr => raddr,
         rdata => rdata,
         rx_wea => rx_wea,
         rx_addra => rx_addra,
         rx_addrb => rx_addrb,
         rx_dia => rx_dia,
         rx_dob => rx_dob,
         rxpayload_dropped => rxpayload_dropped_sig
      );
   tx_main: entity work.udp_tx_mux
      PORT MAP (
         mac_clk => mac_clk,
         rst_macclk => rst_macclk,
         rxram_end_addr => rxram_end_addr,
         rxram_send => rxram_send,
         rxram_busy => rxram_busy,
         addrb => addrb,
         dob => dob,
         udpram_send => udpram_send,
         udpram_busy => udpram_busy,
         udpaddrb => udpaddrb,
         udpdob => udpdob,
         do_sum => do_sum,
         clr_sum => clr_sum,
         int_data => int_data,
         int_valid => int_valid,
         cksum => cksum,
         outbyte => outbyte,
         mac_tx_data => mac_tx_data,
         mac_tx_valid => mac_tx_valid,
         mac_tx_last => mac_tx_last,
         mac_tx_error => mac_tx_error,
         mac_tx_ready => mac_tx_ready,
	 ipbus_out_hdr => ipbus_out_hdr,
	 ipbus_out_valid => ipbus_out_valid
      );
   tx_transactor: entity work.udp_txtransactor_if
      PORT MAP (
         mac_clk => mac_clk,
         rst_macclk => rst_macclk,
         req_resend => req_resend,
	 pkt_done_125 => pkt_done_125,
	 we_125 => we_125,
         udpaddrb => udpaddrb,
         udpram_send => udpram_send,
         udpdob => udpdob,
         ipb_clk => ipb_clk,
         rst_ipb => rst_ipb,
         pkt_done => pkt_done,
         we => we,
         waddr => waddr,
         wdata => wdata,
         tx_wea => tx_wea,
         tx_addra => tx_addra,
         tx_addrb => tx_addrb,
         tx_dia => tx_dia,
         tx_dob => tx_dob
      );
   clock_crossing_if: entity work.udp_clock_crossing_if
      PORT MAP (
         mac_clk => mac_clk,
         rst_macclk => rst_macclk,
	 pkt_rdy_125 => pkt_rdy_125,
         udpram_busy => udpram_busy,
	 pkt_done_125 => pkt_done_125,
	 we_125 => we_125,
         ipb_clk => ipb_clk,
         rst_ipb => rst_ipb,
         pkt_done => pkt_done,
         we => we,
         busy => busy,
	 pkt_rdy => pkt_rdy,
	 	rst_ipb_sync => rst_ipb_sync
      );

END flat;
