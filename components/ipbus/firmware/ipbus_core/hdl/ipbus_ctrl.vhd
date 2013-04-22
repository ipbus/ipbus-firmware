-- ipbus_ctrl
--
-- Top level of the ipbus bus master
--
-- Bridges ethernet MAC interface and / or out-of-band interfaces
-- to the ipbus.

-- Dave Newbold, Sep 2012

library ieee;
use ieee.std_logic_1164.all;
use work.ipbus.all;
use work.ipbus_trans_decl.all;

entity ipbus_ctrl is 
	generic(
		MAC_CFG: ipb_mac_cfg := STATIC;
		IP_CFG: ipb_ip_cfg := STATIC;
		N_OOB: natural := 0
	);
  port(
		mac_clk: in std_logic; -- Ethernet MAC clock (125MHz)
		rst_macclk: in std_logic; -- MAC clock domain sync reset
		ipb_clk: in std_logic; -- IPbus clock
		rst_ipb: in std_logic; -- IPbus clock domain sync reset
		mac_rx_data: in std_logic_vector(7 downto 0); -- AXI4 style MAC signals
		mac_rx_valid: in std_logic;
		mac_rx_last: in std_logic;
		mac_rx_error: in std_logic;
		mac_tx_data: out std_logic_vector(7 downto 0);
		mac_tx_valid: out std_logic;
		mac_tx_last: out std_logic;
		mac_tx_error: out std_logic;
		mac_tx_ready: in std_logic;
		ipb_out: out ipb_wbus; -- IPbus bus signals
		ipb_in: in ipb_rbus;
		ipb_req: out std_logic;
		ipb_grant: in std_logic := '1';
		mac_addr: in std_logic_vector(47 downto 0) := X"000000000000"; -- Static MAC and IP addresses
		ip_addr: in std_logic_vector(31 downto 0) := X"00000000";
		pkt_rx_led: out std_logic;
		pkt_tx_led: out std_logic;
		oob_in: in ipbus_trans_in_array(N_OOB - 1 downto 0) := (others => ('0', X"0000", '0'));
		oob_out: out ipbus_trans_out_array(N_OOB - 1 downto 0)
	);

end ipbus_ctrl;

architecture rtl of ipbus_ctrl is

  signal trans_in, trans_in_udp: ipbus_trans_in;
  signal trans_out, trans_out_udp: ipbus_trans_out;
  signal udp_rxram_dropped, udp_rxpayload_dropped: std_logic;
  signal cfg, cfg_out: std_logic_vector(127 downto 0);
  signal my_mac_addr: std_logic_vector(47 downto 0);
  signal my_ip_addr: std_logic_vector(31 downto 0);
  signal pkt_rx, pkt_tx: std_logic;
  
begin

	udp_if: entity work.udp_if port map(
		mac_clk => mac_clk,
		rst_macclk => rst_macclk,
		ipb_clk => ipb_clk,
		rst_ipb => rst_ipb,
		IP_addr => my_ip_addr,
		MAC_addr => my_mac_addr,
		mac_rx_data => mac_rx_data,
		mac_rx_error => mac_rx_error,
		mac_rx_last => mac_rx_last,
		mac_rx_valid => mac_rx_valid,
		mac_tx_ready => mac_tx_ready,
		pkt_done => trans_out_udp.pkt_done,
		raddr => trans_out_udp.raddr,
		waddr => trans_out_udp.waddr,
		wdata => trans_out_udp.wdata,
		we => trans_out_udp.we,
		busy => trans_in_udp.busy,
		mac_tx_data => mac_tx_data,
		mac_tx_error => mac_tx_error,
		mac_tx_last => mac_tx_last,
		mac_tx_valid => mac_tx_valid,
		pkt_rdy => trans_in_udp.pkt_rdy,
		rdata => trans_in_udp.rdata,
		rxpayload_dropped => udp_rxpayload_dropped,
		rxram_dropped => udp_rxram_dropped
	);
	
	arb_gen: if N_OOB > 0 generate
		arb: entity work.trans_arb
			generic map(NSRC => N_OOB + 1)
			port map(
				clk => ipb_clk,
				rst => rst_ipb,
				buf_in(0) => trans_in_udp,
				buf_in(N_OOB downto 1) => oob_in,
				buf_out(0) => trans_out_udp,
				buf_out(N_OOB downto 1) => oob_out,
				trans_out => trans_in,
				trans_in => trans_out
			);
	end generate;
	
	n_arb_gen: if N_OOB = 0 generate
		trans_in <= trans_in_udp;
		trans_out_udp <= trans_out;
	end generate;
	
	trans: entity work.transactor port map(
		clk => ipb_clk,
		rst => rst_ipb,
		ipb_out => ipb_out,
		ipb_in => ipb_in,
		ipb_req => ipb_req,
		ipb_grant => ipb_grant,
		trans_in => trans_in,
		trans_out => trans_out,
		cfg_vector_in => cfg_out,
		cfg_vector_out => cfg,
		pkt_rx => pkt_rx,
		pkt_tx => pkt_tx
	);
	
	cfg_out <= my_ip_addr & X"0000" & my_mac_addr & X"00000000";
	
	with MAC_CFG select my_mac_addr <=
		mac_addr when STATIC,
		cfg(79 downto 32) when others;
		
	with IP_CFG select my_ip_addr <=
		ip_addr when STATIC,
		cfg(127 downto 96) when CFG_SPACE,
		X"00000000" when others; -- Fixme when RARP is done

	stretch_rx: entity work.stretcher port map(
		clk => mac_clk,
		d => pkt_rx,
		q => pkt_rx_led
	);
	
	stretch_tx: entity work.stretcher port map(
		clk => mac_clk,
		d => pkt_tx,
		q => pkt_tx_led
	);
			
end rtl;

