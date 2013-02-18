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
		trans_in: in ipbus_trans_in; -- Interface to packet buffers
		trans_out: out ipbus_trans_out;
		next_pkt_id: out std_logic_vector(15 downto 0);
		cfg_vector_in: in std_logic_vector(127 downto 0);
		cfg_vector_out: out std_logic_vector(127 downto 0);
		pkt_rx: out std_logic; -- 'Activity LED' lines (need stretching externally)
		pkt_tx: out std_logic
	);
		
end transactor;

architecture rtl of transactor is

  signal rx_data, tx_data, tx_data_sm: std_logic_vector(31 downto 0);
  signal rx_ready, rx_next, byte_order, tx_we, tx_hdr, tx_err: std_logic;
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
			rx_ready => rx_ready,
			rx_next => rx_next,
			tx_data => tx_data,
			tx_we => tx_we,
			tx_hdr => tx_hdr,
			tx_err => tx_err,
			byte_order => byte_order,
			next_pkt_id => next_pkt_id,
			pkt_rx => pkt_rx,
			pkt_tx => pkt_tx
		);

  rx_data <= trans_in.rdata when byte_order='0' else
    trans_in.rdata(7 downto 0) & trans_in.rdata(15 downto 8) & trans_in.rdata(23 downto 16) & trans_in.rdata(31 downto 24);

  tx_data <= tx_data_sm when byte_order='0' else 
    tx_data_sm(7 downto 0) & tx_data_sm(15 downto 8) & tx_data_sm(23 downto 16) & tx_data_sm(31 downto 24);
    
  sm: entity work.transactor_sm
    port map(
    	clk => clk,
      rst => rst,
      rx_data => rx_data,
      rx_ready => rx_ready,
      rx_next => rx_next,
      tx_data => tx_data_sm,
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
