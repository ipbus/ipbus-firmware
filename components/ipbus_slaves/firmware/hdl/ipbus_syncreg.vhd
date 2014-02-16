-- ipbus_syncreg
--
-- Generic control / status register block
--
-- Provides 2**n control registers (32b each), rw
-- Provides 2**m status registers (32b each), ro
-- Bottom part of read address space is control, top is status
--
-- Both control and status are moved across clock domains with full handshaking
-- This may be overkill for some applications
--
-- Useful for misc control of firmware block
-- Unused registers should be optimised away
--
-- Dave Newbold, June 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_syncreg is
	generic(
		ctrl_addr_width : natural := 0;
		stat_addr_width : natural := 0
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		slv_clk: in std_logic;
		d: in std_logic_vector(2 ** stat_addr_width * 32 - 1 downto 0);
		q: out std_logic_vector(2 ** ctrl_addr_width * 32 - 1 downto 0);
		stb: out std_logic_vector(2 ** ctrl_addr_width - 1 downto 0)
	);
	
end ipbus_syncreg;

architecture rtl of ipbus_syncreg is

	signal ctrl_sel, stat_sel: integer := 0;
	signal addr_width_max: natural;
	signal ctrl_cyc_w, ctrl_cyc_r, stat_cyc: std_logic;
	type carray is array(2 ** ctrl_addr_width - 1 downto 0) of std_logic_vector(31 downto 0); 
	signal cq: carray;
	type sarray is array(2 ** stat_addr_width - 1 downto 0) of std_logic_vector(31 downto 0); 
	signal sq: sarray;
	signal cp: std_logic;
	signal cwe, cbusy, cack: std_logic_vector(2 ** ctrl_addr_width - 1 downto 0);
	signal sp: std_logic;
	signal sre, sbusy, sack: std_logic_vector(2 ** stat_addr_width - 1 downto 0);

begin

	addr_width_max <= ctrl_addr_width when ctrl_addr_width > stat_addr_width else stat_addr_width;
	ctrl_sel <= to_integer(unsigned(ipb_in.ipb_addr(ctrl_addr_width - 1 downto 0))) when ctrl_addr_width > 0 else 0;
	stat_sel <= to_integer(unsigned(ipb_in.ipb_addr(stat_addr_width - 1 downto 0))) when stat_addr_width > 0 else 0;

	ctrl_cyc_w <= ipb_in.ipb_strobe and ipb_in.ipb_write and not ipb_in.ipb_addr(addr_width_max);
	ctrl_cyc_r <= ipb_in.ipb_strobe and not ipb_in.ipb_write and not ipb_in.ipb_addr(addr_width_max);
	stat_cyc <= ipb_in.ipb_strobe and not ipb_in.ipb_write and ipb_in.ipb_addr(addr_width_max);
		
	w_gen: for i in 2 ** ctrl_addr_width - 1 downto 0 generate
	
		cwe(i) <= '1' when ctrl_cyc_w = '1' and ctrl_sel = i else '0';
		
		wsync: entity work.syncreg_w
			port map(
				m_clk => clk,
				m_rst => rst,
				m_we => cwe(i),
				m_busy => cbusy(i),
				m_ack => cack(i),
				m_d => ipb_in.ipb_wdata,
				m_q => cq(i),
				s_clk => slv_clk,
				s_q => q((i+1)*32-1 downto i*32),
				s_stb => stb(i)
			);

	end generate;
	
	process(clk)
	begin
		if rising_edge(clk) then
			cp <= (cp or (ctrl_cyc_w and not cbusy(ctrl_sel))) and ctrl_cyc_w and not cack(ctrl_sel);
			sp <= (sp or (stat_cyc and not sbusy(stat_sel))) and stat_cyc and not sack(stat_sel);
		end if;
	end process;
	
	r_gen: for i in 2 ** stat_addr_width - 1 downto 0 generate

		sre(i) <= '1' when stat_cyc = '1' and stat_sel = i else '0';
	
		rsync: entity work.syncreg_r
			port map(
				m_clk => clk,
				m_rst => rst,
				m_re => sre(i),
				m_busy => sbusy(i),
				m_ack => sack(i),
				m_q => sq(i),
				s_clk => slv_clk,
				s_d => d((i+1)*32-1 downto i*32)
			);
	
	end generate;
			
	ipb_out.ipb_rdata <= cq(ctrl_sel) when ctrl_cyc_r = '1' else sq(stat_sel);
	
	ipb_out.ipb_ack <= (ctrl_cyc_w and cack(ctrl_sel) and cp) or ctrl_cyc_r or (stat_cyc and sack(stat_sel) and sp);
	ipb_out.ipb_err <= '0';
	
end rtl;

