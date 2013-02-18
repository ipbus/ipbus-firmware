-- trans_buffer
--
-- Generic packet buffer for access to ipbus transactor by
-- non-ethernet master.
--
-- Dave Newbold, February 2013
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus_trans_decl.all;

entity trans_buffer is
	port(
		clk_m: in std_logic;
		rst_m: in std_logic;
		m_wdata: in std_logic_vector(15 downto 0);
		m_we: in std_logic;
		m_rdata: out std_logic_vector(15 downto 0);
		m_re: in std_logic;
		m_req: in std_logic;
		m_done: out std_logic;
		clk_ipb: in std_logic;
		t_out: out ipbus_trans_in;
		t_in: in ipbus_trans_out
	);

end trans_buffer;

architecture rtl of trans_buffer is
	
	COMPONENT sdpram_16x10_32x9
		PORT (
			clka : IN STD_LOGIC;
			wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			clkb : IN STD_LOGIC;
			addrb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
			doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT sdpram_32x9_16x10
		PORT (
			clka : IN STD_LOGIC;
			wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
			dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			clkb : IN STD_LOGIC;
			addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	END COMPONENT;

	signal req_d, mode, done_m, done_m_s: std_logic;
	signal mode_ipb, mode_ipb_s, mode_ipb_d, rdy, done: std_logic;
	signal addr: unsigned(9 downto 0);
	
	attribute KEEP: string;
	attribute KEEP of done_m_s: signal is "TRUE"; -- Synchroniser not to be optimised into shreg
	attribute KEEP of mode_ipb_s: signal is "TRUE"; -- Synchroniser not to be optimised into shreg


begin
	
	process(clk_m)
	begin
		if rising_edge(clk_m) then
			mode <= (mode or (m_req and not req_d)) and not (done_m or rst_m);
			req_d <= m_req;
		end if;
	end process;
	
	m_done <= not mode;
	
	process(clk_ipb) -- Synchroniser clk_m -> clk_ipb
	begin
		if rising_edge(clk_ipb) then
			mode_ipb_s <= mode;
			mode_ipb <= mode_ipb_s;
			mode_ipb_d <= mode_ipb;
		end if;
	end process;
	
	process(clk_m) -- Synchroniser clk_ipb -> clk_m
	begin
		if rising_edge(clk_m) then
			done_m_s <= done;
			done_m <= done_m_s;
		end if;
	end process;
	
	process(clk_ipb)
	begin
		if rising_edge(clk_ipb) then
			rdy <= (rdy or (mode_ipb and not mode_ipb_d)) and not t_in.pkt_done;
			done <= (done or t_in.pkt_done) and not mode_ipb;
		end if;
	end process;
	
	t_out.pkt_rdy <= rdy;
	t_out.busy <= '0';
	
	process(clk_m)
	begin
		if rising_edge(clk_m) then
			if rst_m = '1' or mode = '1' or (req_d and not m_req) = '1' then
				addr <= (others => '0');
			elsif m_re = '1' or m_we = '1' then
				addr <= addr + 1;
			end if;
		end if;
	end process;
	
	ram_in: sdpram_16x10_32x9
		port map(
			clka => clk_m,
			wea => m_we,
			addra => addr,
			dina => m_wdata,
			clkb => clk_ipb,
			addrb => t_in.raddr,
			doutb => t_out.rdata
		);
		
	ram_out: sdpram_32x9_16x10
		port map(
			clka => clk_ipb,
			wea => t_in.we,
			addra => t_in.waddr,
			dina => t_in.wdata,
			clkb => clk_m,
			addrb => addr,
			doutb => m_rdata
		);

end rtl;
