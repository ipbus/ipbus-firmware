---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------


-- Top level for the ipbus transactor module
--
-- Handles the decoding of ipbus packets and the transactions
-- on the bus itself.
--
-- This version is for ipbus v3
--
-- Dave Newbold, April 2019
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

library work;
use work.ipbus_trans_decl.all;

entity ipbus_transactor is
	port(
		clk: in std_logic; -- IPbus clock
		rst: in std_logic; -- Sync reset
		ipb_out: out ipb_wbus; -- IPbus bus signals
		ipb_in: in ipb_rbus;
		ipb_req: out std_logic; -- Bus arbitrator signals
		ipb_grant: in std_logic := '1';
		trans_in: in ipbus_trans_in; -- Interface to packet buffers
		trans_out: out ipbus_trans_out
	);
		
end ipbus_transactor;

architecture rtl of ipbus_transactor is

	signal rx_data, tx_data, sm_tx_data: std_logic_vector(IPB_DATA_WDS * 32 - 1 downto 0);
	signal rx_len, rx_ack, tx_len, sm_rx_len, sm_rx_ack, sm_tx_len: std_logic_vector(IPB_DW_BITS - 1 downto 0);
	signal tx_ack, sm_tx_ack, tx_hdr, tx_phdr, sm_tx_hdr, sm_tx_err: std_logic;
	
begin

	sr: entity work.ipbus_transactor_sr
		port map(
			clk => clk,
			rst => rst,
			rdata => trans_in.rdata,
			addr => trans_out.raddr,
			rx_data => rx_data,
			rx_len => rx_len,
			rx_ack => rx_ack,
			tx_data => tx_data,
			tx_len => tx_len,
			tx_hdr => tx_hdr,
			tx_phdr => tx_phdr,
			tx_ack => tx_ack,
			wdata => trans_out.wdata,
			waddr => trans_out.waddr,
			we => trans_out.we
		);

	iface: entity work.ipbus_transactor_if
		port map(
			clk => clk,
			rst => rst,
			pkt_rdy => trans_in.pkt_rdy,
			busy => trans_in.busy,
			pkt_done => trans_out.pkt_done,
			ipb_req => ipb_req,
			ipb_grant => ipb_grant,
			rx_data => rx_data,
			rx_len => rx_len,
			rx_ack => rx_ack,
			sm_rx_len => sm_rx_len,
			sm_rx_ack => sm_rx_ack,
			sm_tx_data => sm_tx_data,
			sm_tx_len => sm_tx_len,
			sm_tx_hdr => sm_tx_hdr,
			sm_tx_ack => sm_tx_ack,
			sm_tx_err => sm_tx_err,			
			tx_data => tx_data,
			tx_len => tx_len,
			tx_hdr => tx_hdr,
			tx_phdr => tx_phdr,
			tx_ack => tx_ack
		);
    
	sm: entity work.ipbus_transactor_sm
    	port map(
			clk => clk,
			rst => rst,
			rx_data => rx_data,
			rx_len => sm_rx_len,
			rx_ack => sm_rx_ack,
			tx_data => tx_data,
			tx_len => tx_len,
			tx_hdr => tx_hdr,
			tx_ack => tx_ack,
			tx_err => tx_err,
			ipb_out => ipb_out,
			ipb_in => ipb_in
		);

end rtl;
