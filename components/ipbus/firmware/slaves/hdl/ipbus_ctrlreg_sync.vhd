-- Generic control / status register block
--
-- Provides 2**n control registers (32b each), rw
-- Provides 2**m status registers (32b each), ro
--
-- Bottom part of read address space is control, top is status
--
-- Control register is synchronised to a second clock domain
-- Status register is not synchronised (i.e. useful for quasi-static signals only)
--
-- Useful for misc control of firmware block
-- Unused registers should be optimised away
--
-- Dave Newbold, July 2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_ctrlreg_sync is
	generic(
		ctrl_addr_width : natural := 0;
		stat_addr_width : natural := 0
	);
	port(
		clk: in std_logic;
		reset: in std_logic;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		ctrl_clk: in std_logic;
		d: in std_logic_vector(2 ** stat_addr_width * 32 - 1 downto 0);
		q: out std_logic_vector(2 ** ctrl_addr_width * 32 - 1 downto 0)
	);
	
end ipbus_ctrlreg_sync;

architecture rtl of ipbus_ctrlreg_sync is

	type reg_array is array(2 ** ctrl_addr_width - 1 downto 0) of std_logic_vector(31 downto 0);
	signal reg, sreg: reg_array;
	signal ctrl_sel, stat_sel: integer;
	signal addr_width_max: natural;
	signal ack, update, update_s: std_logic;
	
	attribute KEEP: string;
	attribute KEEP of update_s: signal is "TRUE"; -- Synchroniser not to be optimised into shreg

begin

	addr_width_max <= ctrl_addr_width when ctrl_addr_width > stat_addr_width else stat_addr_width;
	ctrl_sel <= to_integer(unsigned(ipbus_in.ipb_addr(ctrl_addr_width - 1 downto 0))) when ctrl_addr_width > 0 else 0;
	stat_sel <= to_integer(unsigned(ipbus_in.ipb_addr(stat_addr_width - 1 downto 0))) when stat_addr_width > 0 else 0;

	wcyc <= '1' when ipbus_in.ipb_strobe = '1' and ipbus_in.ipb_write = '1' else '0';
	
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg <= (others=>(others=>'0'));
			elsif wcyc = '1' then
				reg(ctrl_sel) <= ipbus_in.ipb_wdata;
			end if;

			if ipbus_in.ipb_addr(addr_width_max) = '0' then
				ipbus_out.ipb_rdata <= reg(ctrl_sel);
			else
				ipbus_out.ipb_rdata <= d(32 * (stat_sel + 1) - 1 downto 32 * stat_sel); 
			end if;
			
			ack <= ipbus_in.ipb_strobe and not ack;

		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';

	process(ctrl_clk)
	begin
		if rising_edge(ctrl_clk) then
			update_s <= wcyc or reset; -- Synchroniser reg
			update <= update_s;
			if update_s = '1' then
				sreg <= reg;
			end if;
		end if;
	end process;
	
	q_gen: for i in 2 ** ctrl_addr_width - 1 downto 0 generate
		q((i+1)*32-1 downto i*32) <= sreg(i);
	end generate;

end rtl;

