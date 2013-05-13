-- ipbus_trans_decl
--
-- Defines the types for interface between ipbus transactor and
-- the memory buffers which hold input and output packets
--
-- Dave Newbold, September 2012


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ipbus_trans_decl is

	constant addr_width: positive := 12;

	-- Signals from buffer to transactor
	
	type ipbus_trans_in is
		record
			pkt_rdy: std_logic;
			rdata: std_logic_vector(31 downto 0);
			busy: std_logic;
		end record;

	type ipbus_trans_in_array is array(natural range <>) of ipbus_trans_in;
		
	-- Signals from transactor to buffer
	
	type ipbus_trans_out is
		record
			raddr: std_logic_vector(addr_width - 1 downto 0);
			pkt_done: std_logic;
			we: std_logic;
			waddr: std_logic_vector(addr_width - 1 downto 0);
			wdata: std_logic_vector(31 downto 0);
		end record;
  
	type ipbus_trans_out_array is array(natural range <>) of ipbus_trans_out;  

end ipbus_trans_decl;
