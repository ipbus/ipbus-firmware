-- Version register, returns a fixed value
--
-- To be replaced by a more coherent versioning mechanism later
--
-- Dave Newbold, August 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;

entity ipbus_ver is
	port(
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus
	);
	
end ipbus_ver;

architecture rtl of ipbus_ver is

begin

  ipbus_out.ipb_rdata <= X"a5c7" & X"1008"; -- Lower 16b are ipbus firmware build ID (temporary arrangement).
  ipbus_out.ipb_ack <= ipbus_in.ipb_strobe;
  ipbus_out.ipb_err <= '0';

end rtl;

-- Build log
--
-- build 0x1000 : 22/08/11 : Starting build ID
-- build 0x1001 : 29/08/11 : Version for SPI testing
-- build 0x1002 : 27/09/11 : Bug fixes, new transactor code; v1.3 candidate
-- build 0x1003 : buggy
-- build 0x1004 : 18/10/11 : New mini-t top level, bug fixes, 1.3 codebase
-- build 0x1005 : 20/10/11 : ipbus address config testing in mini-t
-- build 0x1006 : 26/10/11 : trying with jumbo frames
-- build 0x1007 : 27/10/11 : new slaves / address map + rhino frames
-- build 0x1008 : 31/10/11 : rhino frames + multibus demo


