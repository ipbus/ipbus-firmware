-- ipbus_roreg_v
--
-- Read-only static register block for version numbers, etc
--
-- Dave Newbold, April 2017

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_roreg_v is
	generic(
		N_REG: positive := 1;
		DATA: std_logic_vector
	);
	port(
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus
	);
	
end ipbus_roreg_v;

architecture rtl of ipbus_roreg_v is

	constant ADDR_WIDTH: integer := calc_width(N_REG);
	signal sel: integer range 0 to 2 ** ADDR_WIDTH - 1 := 0;
	signal valid: std_logic;

begin

	sel <= to_integer(unsigned(ipb_in.ipb_addr(ADDR_WIDTH - 1 downto 0))) when ADDR_WIDTH > 0 else 0;
	valid <= '1' when sel < N_REG else '0';
	
	ipb_out.ipb_rdata <= DATA(32 * (sel+ 1) - 1 downto 32 * sel) when valid = '1' else (others => '0');
	ipb_out.ipb_ack <= ipb_in.ipb_strobe and not ipb_in.ipb_write and valid;
	ipb_out.ipb_err <= ipb_in.ipb_strobe and (ipb_in.ipb_write or not valid);
	
end rtl;

