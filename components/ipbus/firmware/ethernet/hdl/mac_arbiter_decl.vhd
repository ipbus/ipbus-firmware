-- mac_arbiter_decl
--
-- Defines the array types for the ports of the mac_arbiter entity
--
-- Dave Newbold, March 2011
--
-- $Id: mac_arbiter_decl.vhd 326 2011-04-25 20:00:14Z phdmn $

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package mac_arbiter_decl is
  
	type mac_arbiter_slv_array is array(natural range <>) of std_logic_vector(7 downto 0);
	type mac_arbiter_sl_array is array(natural range <>) of std_logic; 

end mac_arbiter_decl;
