-- syncreg_w
--
-- Clock domain crossing register with full handshaking
-- 	Data are moved from master to slave when we is asserted
-- 	New requests are ignored while busy is high
-- 	Ack signals a completed transfer
-- On slave side, stb indicates that a new word is available on that cycle
--
-- Dave Newbold, June 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity syncreg_w is
	generic(
		size: positive := 32
	);
	port(
		m_clk: in std_logic;
		m_rst: in std_logic;
		m_we: in std_logic;
		m_busy: out std_logic;
		m_ack: out std_logic;
		m_d: in std_logic_vector(size - 1 downto 0);
		m_q: out std_logic_vector(size - 1 downto 0);
		s_clk: in std_logic;
		s_q: out std_logic_vector(size - 1 downto 0);
		s_stb: out std_logic
	);
	
end syncreg_w;

architecture rtl of syncreg_w is
		
	signal q: std_logic_vector(size - 1 downto 0);
	signal we_v, busy, ack, s1, s2, s3, m1, m2, m3: std_logic;
	
	attribute KEEP: string;
	attribute KEEP of s1: signal is "TRUE"; -- Synchroniser not to be optimised into shreg
	attribute KEEP of m1: signal is "TRUE"; -- Synchroniser not to be optimised into shreg
	
begin
	
	we_v <= m_we and not busy;
	
	process(m_clk)
	begin
		if rising_edge(m_clk) then
			m1 <= s3; -- Clock domain crossing for ack handshake
			m2 <= m1;
			m3 <= m2;
			busy <= (busy or we_v) and not (ack or m_rst);
		end if;
	end process;
	
	ack <= m2 and not m3;
	
	process(s_clk)
	begin
		if rising_edge(s_clk) then
			s1 <= busy; -- Clock domain crossing for we handshake
			s2 <= s1;
			s3 <= s2;
			if m_rst = '1' then -- Assume long pulse on rst
				q <= (others => '0');
			elsif s2 = '1' and s3 = '0' then
				q <= m_d;
			end if;
			s_stb <= s2 and not s3;
		end if;
	end process;
	
	m_q <= q;
	s_q <= q;
	
	m_busy <= busy;
	m_ack <= ack;

end rtl;

