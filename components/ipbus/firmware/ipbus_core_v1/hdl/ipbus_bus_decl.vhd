-- mac_arbiter_decl
--
-- Defines the array types for the ports of the mac_arbiter entity
--
-- Dave Newbold, March 2011
--
-- $Id: mac_arbiter_decl.vhd 326 2011-04-25 20:00:14Z phdmn $

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package ipbus_bus_decl is

	constant rbuf_awidth: positive :=  9;
	constant wbuf_awidth: positive :=  9;
	subtype rbuf_a is std_logic_vector(rbuf_awidth - 1 downto 0);
	subtype wbuf_a is std_logic_vector(rbuf_awidth - 1 downto 0);
	subtype rbuf_a_us is unsigned(rbuf_awidth - 1 downto 0);
	subtype wbuf_a_us is unsigned(rbuf_awidth - 1 downto 0);
	
	constant pbuf_awidth: positive := 11;
	subtype pbuf_a is std_logic_vector(pbuf_awidth - 1 downto 0);
	subtype pbuf_a_us is unsigned(pbuf_awidth - 1 downto 0);
  
  -- The signals going from memory to transactor
  type trans_moti is
    record
      ready: std_logic;
      addr_rst: std_logic;
      rdata : std_logic_vector(31 downto 0);
    end record;
  
    type trans_moti_array is array(natural range <>) of trans_moti;
     
  -- The signals going from transactor to memory	 
  type trans_tomi is
  	record
  		done: std_logic;
  		wdata: std_logic_vector(31 downto 0);
  		raddr: rbuf_a;
  		waddr: wbuf_a;
  		we: std_logic;
  	end record;
  
  type trans_tomi_array is array(natural range <>) of trans_tomi;  

end ipbus_bus_decl;
