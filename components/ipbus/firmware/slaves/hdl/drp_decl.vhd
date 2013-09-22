-- drp_decl
--
-- Defines the array types for the ports of the drp_mux entity
--
-- Dave Newbold, September 2013

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package drp_decl is
  
-- The signals going from master to slaves
	type drp_wbus is
  		record
  			addr: std_logic_vector(8 downto 0);
      	data: std_logic_vector(15 downto 0);
      	en: std_logic;
      	we: std_logic;
    	end record;

	type drp_wbus_array is array(natural range <>) of drp_wbus;
	 
-- The signals going from slaves to master	 
	type drp_rbus is
    record
			data: std_logic_vector(15 downto 0);
			rdy: std_logic;
    end record;

	type drp_rbus_array is array(natural range <>) of drp_rbus;
	
	constant DRP_RBUS_NULL: drp_rbus := ((others => '0'), '0');

end drp_decl;

