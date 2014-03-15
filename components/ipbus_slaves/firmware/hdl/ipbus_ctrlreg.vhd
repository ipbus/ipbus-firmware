-- Generic control / status register block
--
-- THIS DESIGN IS OBSOLETE - USE IPBUS_CTRLREG_V INSTEAD
--
-- Provides 2**n control registers (32b each), rw
-- Provides 2**m status registers (32b each), ro
--
-- Bottom part of read address space is control, top is status
--
-- Useful for misc control of firmware block
-- Unused registers should be optimised away
--
-- Dave Newbold, July 2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_ctrlreg is
	generic(
		CTRL_ADDR_WIDTH: natural := 0;
		STAT_ADDR_WIDTH: natural := 0
	);
	port(
		clk: in std_logic;
		reset: in std_logic;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		d: in std_logic_vector(2 ** stat_addr_width * 32 - 1 downto 0);
		q: out std_logic_vector(2 ** ctrl_addr_width * 32 - 1 downto 0)
	);
	
end ipbus_ctrlreg;

architecture rtl of ipbus_ctrlreg is

	constant ADDR_WIDTH: integer := integer_max(CTRL_ADDR_WIDTH, STAT_ADDR_WIDTH);

	type reg_array is array(2 ** CTRL_ADDR_WIDTH - 1 downto 0) of std_logic_vector(31 downto 0);
	signal reg: reg_array;
	signal ctrl_sel, stat_sel: integer range 0 to 2 ** ADDR_WIDTH - 1 := 0;
	signal ack: std_logic;

begin

	ctrl_sel <= to_integer(unsigned(ipbus_in.ipb_addr(CTRL_ADDR_WIDTH - 1 downto 0))) when CTRL_ADDR_WIDTH > 0 else 0;
	stat_sel <= to_integer(unsigned(ipbus_in.ipb_addr(STAT_ADDR_WIDTH - 1 downto 0))) when STAT_ADDR_WIDTH > 0 else 0;

	process(clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				reg <= (others=>(others=>'0'));
			elsif ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
				reg(ctrl_sel) <= ipbus_in.ipb_wdata;
			end if;

			if ipbus_in.ipb_addr(ADDR_WIDTH) = '0' then
				ipbus_out.ipb_rdata <= reg(ctrl_sel);
			else
				ipbus_out.ipb_rdata <= d(32 * (stat_sel + 1) - 1 downto 32 * stat_sel); 
			end if;
			
			ack <= ipbus_in.ipb_strobe and not ack;

		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';

	q_gen: for i in 2 ** ctrl_addr_width - 1 downto 0 generate
		q((i+1)*32-1 downto i*32) <= reg(i);
	end generate;
	
end rtl;
