-- Generic control / status register block
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

entity ipbus_ctrlreg_v is
	generic(
		N_CTRL: positive := 1;
		N_STAT: positive := 1
	);
	port(
		clk: in std_logic;
		reset: in std_logic;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		d: in ipb_reg_v(N_STAT - 1 downto 0);
		q: out ipb_reg_v(N_CTRL - 1 downto 0)
	);
	
end ipbus_ctrlreg_v;

architecture rtl of ipbus_ctrlreg_v is

	constant CTRL_WIDTH: integer := calc_width(N_CTRL);
	constant STAT_WIDTH: integer := calc_width(N_STAT);
	constant ADDR_WIDTH: integer := max(CTRL_WIDTH, STAT_WIDTH);

	signal reg: ipb_reg_v(CTRL_WIDTH - 1 downto 0);
	signal ctrl_out, stat_out: std_logic_vector(31 downto 0);
	signal ctrl_sel, stat_sel: integer;
	signal addr_width_max: natural;
	signal ack: std_logic;

begin

	sel <= to_integer(unsigned(ipbus_in.ipb_addr(ADDR_WIDTH - 1 downto 0)));
	ctrl_valid <= '1' when sel < N_CTRL else '0';
	stat_valid <= '1' when sel < N_STAT else '0';
	
	process(clk)
	begin
		if rising_edge(clk) then
			if reset='1' then
				reg <= (others=>(others=>'0'));
			elsif ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
				reg(ctrl_sel) <= ipbus_in.ipb_wdata;
			end if;

			ctrl_valid <= '1' when sel < N_CTRL else '0';
			stat_valid <= '1' when sel < N_STAT else '0';
			ack <= ipbus_in.ipb_strobe and not ack;

		end if;
	end process;
	
	ctrl_out <= reg(sel) when ctrl_valid = '1' else (others => '0');
	stat_out <= reg(sel) when stat_valid = '1' else (others => '0');

	ipbus_out.ipb_rdata <= ctrl_out when ipbus_in.ipb_addr(ADDR_WIDTH) = '0' else
		stat_out;	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';

	q <= reg;
	
end rtl;
