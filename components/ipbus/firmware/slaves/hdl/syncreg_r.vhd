-- syncreg_r
--
-- Clock domain crossing register with full handshaking
-- 	Data are transferred from slave to master when re is asserted
-- 	New requests are ignored while busy is high
-- 	Ack signals completed transfer
--
-- Dave Newbold, June 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity syncreg_r is
	generic(
		size: positive := 32
	);
	port(
		m_clk: in std_logic;
		m_rst: in std_logic;
		m_re: in std_logic;
		m_busy: out std_logic;
		m_ack: out std_logic;
		m_q: out std_logic_vector(size - 1 downto 0);
		s_clk: in std_logic;
		s_d: in std_logic_vector(size - 1 downto 0);
		s_stb: out std_logic
	);
	
end syncreg_r;

architecture rtl of syncreg_r is
		
	signal we, busy, ack, s1, s2, s3, m1, m2, m3: std_logic;
	
	attribute KEEP: string;
	attribute KEEP of s1: signal is "TRUE"; -- Synchroniser not to be optimised into shreg
	attribute KEEP of m1: signal is "TRUE"; -- Synchroniser not to be optimised into shreg
	
begin

	process(s_clk)
	begin
		if rising_edge(s_clk) then
			if we = '1' then
				m_q <= s_d;
			end if;
		end if;
	end process;
	
	process(m_clk)
	begin
		if rising_edge(m_clk) then
			m1 <= s3; -- Clock domain crossing for ack handshake
			m2 <= m1;
			m3 <= m2;
			busy <= (busy or m_re) and not (ack or m_rst);
		end if;
	end process;
	
	ack <= m2 and not m3;
	
	process(s_clk)
	begin
		if rising_edge(s_clk) then
			s1 <= busy; -- Clock domain crossing for we handshake
			s2 <= s1;
			s3 <= s2;
		end if;
	end process;
	
	we <= s2 and not s3;
	s_stb <= we;
	
	m_busy <= busy;
	m_ack <= ack;

end rtl;

