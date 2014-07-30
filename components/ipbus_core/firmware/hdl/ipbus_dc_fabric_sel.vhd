-- The ipbus bus fabric, address select logic, data multiplexers
--
-- This version designed to address the ipbus slaves daisy-chain style
-- rather than via a simple fanout.
--
-- This version selects the addressed slave depending on the state
-- of incoming control lines
--
-- Dave Newbold, July 2014

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.ALL;

entity ipbus_dc_fabric_sel is
  generic(
    NSLV: positive;
    STROBE_GAP: boolean := false;
    SEL_WIDTH: positive
   );
  port(
  	clk: in std_logic;
  	rst: in std_logic;
  	sel: in std_logic_vector(SEL_WIDTH - 1 downto 0);
    ipb_in: in ipb_wbus;
    ipb_out: out ipb_rbus;
    ipbdc_to_slave: out ipbdc_bus;
    ipbdc_from_slaves: in ipbdc_bus
   );

end ipbus_dc_fabric_sel;

architecture rtl of ipbus_dc_fabric_sel is

begin

	ipb_out <= IPB_WBUS_NULL;
	ipbdc_out <= IPBDC_BUS_NULL;
  
end rtl;

