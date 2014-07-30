-- ipbus_dc_node
--
-- Bridge from daisy-chain style ipbus implementation to ipbus slave
--
-- Dave Newbold, July 2014

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.ALL;

entity ipbus_dc_node is
  generic(
  	I_SLV: integer;
   );
  port(
  	clk: in std_logic;
  	rst: in std_logic;
    ipb_out: out ipb_wbus;
    ipb_in: in ipb_rbus;
    ipbdc_in: in ipbdc_bus;
    ipbdc_out: out ipbdc_bus
   );

end ipbus_dc_node;

architecture rtl of ipbus_dc_node is

begin

	ipb_out <= IPB_WBUS_NULL;
	ipbdc_out <= IPBDC_BUS_NULL;
  
end rtl;

