-- Top level for the ipbus transactor module
--
-- Handles the decoding of ipbus packets and the transactions
-- on the bus itself,
--
-- This is the new version for ipbus 2.0
--
-- Dave Newbold, October 2012
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

library work;
use work.ipbus.all;
use work.ipbus_trans_decl.all;

entity transactor is
	port(
		clk: in std_logic; -- IPbus clock
		rst: in std_logic; -- Sync reset
		ipb_out: out ipb_wbus; -- IPbus bus signals
		ipb_in: in ipb_rbus;
		ipb_req: out std_logic; -- Bus arbitrator signals
		ipb_grant: in std_logic;
		trans_in: in ipbus_trans_in; -- Interface to packet buffers
		trans_out: out ipbus_trans_out;
		cfg_vector_in: in std_logic_vector(127 downto 0);
		cfg_vector_out: out std_logic_vector(127 downto 0);
		pkt_rx: out std_logic; -- 'Activity LED' lines (need stretching externally)
		pkt_tx: out std_logic
	);
		
end transactor;

architecture rtl of transactor is

	signal rx_data, tx_data: std_logic_vector(31 downto 0);
  signal rx_ready, rx_next, tx_we, tx_hdr, tx_err: std_logic;
  signal cfg_we: std_logic;
  signal cfg_addr: std_logic_vector(1 downto 0);
  signal cfg_din, cfg_dout: std_logic_vector(31 downto 0);

begin

	iface: entity work.transactor_if
		port map(
			clk => clk,
			rst => rst,
			trans_in => trans_in,
			trans_out => trans_out,
			ipb_req => ipb_req,
			ipb_grant => ipb_grant,
			rx_ready => rx_ready,
			rx_next => rx_next,
			rx_data => rx_data,
			tx_data => tx_data,
			tx_we => tx_we,
			tx_hdr => tx_hdr,
			tx_err => tx_err,
			pkt_rx => pkt_rx,
			pkt_tx => pkt_tx
		);
    
	sm: entity work.transactor_sm
    	port map(
			clk => clk,
			rst => rst,
			rx_data => rx_data,
			rx_ready => rx_ready,
			rx_next => rx_next,
			tx_data => tx_data,
			tx_we => tx_we,
			tx_hdr => tx_hdr,
			tx_err => tx_err,
			ipb_out => ipb_out,
			ipb_in => ipb_in,
			cfg_we => cfg_we,
			cfg_addr => cfg_addr,
			cfg_din => cfg_dout,
			cfg_dout => cfg_din
		);

	cfg: entity work.transactor_cfg
		port map(
			clk => clk,
			rst => rst,
			we => cfg_we,
			addr => cfg_addr,
			din => cfg_din,
			dout => cfg_dout,
			vec_in => cfg_vector_in,
			vec_out => cfg_vector_out
		);    

end rtl;
