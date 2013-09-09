-- ipbus_ctrlreg_v
--
-- Generic control / status register bank
--
-- Provides N_CTRL control registers (32b each), rw
-- Provides N_STAT status registers (32b each), ro
--
-- Bottom part of read address space is control, top is status
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

	constant ADDR_WIDTH: integer := integer_max(calc_width(N_CTRL), calc_width(N_STAT));

	signal sel: integer := 0;
	signal reg: ipb_reg_v(N_CTRL - 1 downto 0);
	signal ctrl_out, stat_out: std_logic_vector(31 downto 0);
	signal valid, ctrl_valid, stat_valid, stat_cyc: std_logic;
	signal ack: std_logic;

begin

	sel <= to_integer(unsigned(ipbus_in.ipb_addr(ADDR_WIDTH - 1 downto 0))) when ADDR_WIDTH > 0 else 0;
	stat_cyc <= ipbus_in.ipb_addr(ADDR_WIDTH);

	ctrl_valid <= '1' when sel < N_CTRL else '0';
	stat_valid <= '1' when sel < N_STAT else '0';
	valid <= (ctrl_valid and not stat_cyc) or (stat_valid and stat_cyc and not ipbus_in.ipb_write);
	
	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg <= (others => (others => '0'));
			elsif ipbus_in.ipb_strobe = '1' and ipbus_in.ipb_write = '1' and ctrl_valid = '1' then
				reg(sel) <= ipbus_in.ipb_wdata;
			end if;
		end if;
	end process;
	
	ctrl_out <= reg(sel) when ctrl_valid = '1' else (others => '0');
	stat_out <= d(sel) when stat_valid = '1' else (others => '0');
	
	ipbus_out.ipb_rdata <= ctrl_out when stat_cyc = '0' else stat_out;	
	ipbus_out.ipb_ack <= ipbus_in.ipb_strobe and valid;
	ipbus_out.ipb_err <= ipbus_in.ipb_strobe and not valid;

	q <= reg;
	
end rtl;
