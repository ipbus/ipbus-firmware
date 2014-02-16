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
		q: out ipb_reg_v(N_CTRL - 1 downto 0);
		stb: out std_logic_vector(N_CTRL - 1 downto 0)
	);
	
end ipbus_ctrlreg_v;

architecture rtl of ipbus_ctrlreg_v is

	constant ADDR_WIDTH: integer := integer_max(calc_width(N_CTRL), calc_width(N_STAT));

	signal sel: integer := 0;
	signal reg: ipb_reg_v(N_CTRL - 1 downto 0);
	signal si, ri: ipb_reg_v(2 ** ADDR_WIDTH - 1 downto 0);
	signal stat_cyc, cw_cyc: std_logic;

begin

	sel <= to_integer(unsigned(ipbus_in.ipb_addr(ADDR_WIDTH - 1 downto 0))) when ADDR_WIDTH > 0 else 0;
	stat_cyc <= ipbus_in.ipb_addr(ADDR_WIDTH);
	cw_cyc <= ipbus_in.ipb_strobe and ipbus_in.ipb_write and not stat_cyc;

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				reg <= (others => (others => '0'));
			elsif cw_cyc = '1' and sel < N_CTRL then
				reg(sel) <= ipbus_in.ipb_wdata;
			end if;
		end if;
	end process;
	
	stb_gen: for i in N_CTRL - 1 downto 0 generate
		stb(i) <= '1' when cw_cyc = '1' and sel = i else '0';
	end generate;
	
	si(N_STAT - 1 downto 0) <= d;
	si(2 ** ADDR_WIDTH - 1 downto N_STAT) <= (others => (others => '0'));
	ri(N_CTRL - 1 downto 0) <= reg;
	ri(2 ** ADDR_WIDTH - 1 downto N_CTRL) <= (others => (others => '0'));
	
	ipbus_out.ipb_rdata <= ri(sel) when stat_cyc = '0' else si(sel);	
	ipbus_out.ipb_ack <= ipbus_in.ipb_strobe;
	ipbus_out.ipb_err <= '0';

	q <= reg;
	
end rtl;
