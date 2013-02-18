-- Top level for the ipbus transactor module
-- This module handles the decoding of ipbus packets and the transactions on the bus itself
--
-- Dave Newbold, April 2011
-- Rewritten from Andy Rose's version of January 2011
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

library work;
use work.ipbus.all;
use work.ipbus_bus_decl.all;

entity transactor is
	port(
		clk: in std_logic; 
		reset: in std_logic;
		ipb_out: out ipb_wbus;
		ipb_in: in ipb_rbus;
		moti: in trans_moti;
		tomi: out trans_tomi);
		
end transactor;

architecture rtl of transactor is

  signal rx_data, tx_data, ipb_data: std_logic_vector(31 downto 0);
  signal rx_ready, rx_next, tx_done, byte_order, start: std_logic;
  signal ipb_out_int: ipb_wbus;
  signal tx_func: std_logic_vector(3 downto 0);

begin

  rx: entity work.transactor_rx
    port map(
        clk => clk,
        reset => reset,
        pkt_ready => moti.ready,
        pkt_addr_rst => moti.addr_rst,
        pkt_raddr => tomi.raddr,
        pkt_rdata => moti.rdata,
        rx_ready => rx_ready,
        rx_next => rx_next,
        start => start
    );

  rx_data <= moti.rdata when byte_order='0' else
    moti.rdata(7 downto 0) & moti.rdata(15 downto 8) & moti.rdata(23 downto 16) & moti.rdata(31 downto 24);

  sm: entity work.transactor_sm
    port map(
        clk => clk,
        reset => reset,
        rx_data => rx_data,
        rx_ready => rx_ready,
        rx_next => rx_next,
		  tx_func => tx_func,
        byte_order => byte_order,
        ipb_out => ipb_out_int,
        ipb_in => ipb_in
    );

  ipb_data <= ipb_in.ipb_rdata when ipb_out_int.ipb_write='0' else ipb_out_int.ipb_wdata;

  tx: entity work.transactor_tx
    port map(
      clk => clk,
      reset => reset,
      pkt_addr => tomi.waddr,
      pkt_we => tomi.we,
      pkt_done => tx_done,
		tx_func => tx_func,
      tx_data => tx_data,
      ipb_data => ipb_data,
      rx_data => rx_data,
      start => start
    );
  
  tomi.done <= tx_done;
  
  tomi.wdata <= tx_data when byte_order='0' else 
    tx_data(7 downto 0) & tx_data(15 downto 8) & tx_data(23 downto 16) & tx_data(31 downto 24);
  
  ipb_out <= ipb_out_int;
  
end rtl;
