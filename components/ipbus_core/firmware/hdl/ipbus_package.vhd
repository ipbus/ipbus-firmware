library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ipbus is

-- The signals going from master to slaves
	type ipb_wbus is
  		record
  			ipb_addr: std_logic_vector(31 downto 0);
      	ipb_wdata: std_logic_vector(31 downto 0);
      	ipb_strobe: std_logic;
      	ipb_write: std_logic;
    	end record;

	type ipb_wbus_array is array(natural range <>) of ipb_wbus;
	 
-- The signals going from slaves to master	 
	type ipb_rbus is
    record
			ipb_rdata: std_logic_vector(31 downto 0);
			ipb_ack: std_logic;
			ipb_err: std_logic;
    end record;

	type ipb_rbus_array is array(natural range <>) of ipb_rbus;
	
	constant IPB_RBUS_NULL: ipb_rbus := ((others => '0'), '0', '0');
	constant IPB_WBUS_NULL: ipb_wbus := ((others => '0'), (others => '0'), '0', '0');

-- For top-level generics
	
	type ipb_mac_cfg is (EXTERNAL, INTERNAL);
	type ipb_ip_cfg is (EXTERNAL, INTERNAL);

end ipbus;

