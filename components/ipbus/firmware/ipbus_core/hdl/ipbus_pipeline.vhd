-- ipbus_pipeline
--
-- Introduces pipeline stages into any ipbus connection
--
-- This will add latency to slaves, decreasing bus throughput, but helping
-- with timing due to breaking the stb-ack loop, e.g. in the case of large
-- address decoders
--
-- Dave Newbold, July 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;

entity ipbus_pipeline is
	generic(
		latency: natural := 1
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		m_ipb_in: in ipb_wbus;
		m_ipb_out: out ipb_rbus;
		s_ipb_out: out ipb_wbus;
		s_ipb_in: in ipb_rbus
	);
	
end ipbus_pipeline;

architecture rtl of ipbus_pipeline is

	signal ack_del, err_del: std_logic_vector(latency downto 0);
	signal got_resp: std_logic;

begin

	s_ipb_out.ipb_addr <= m_ipb_in.ipb_addr;
	s_ipb_out.ipb_wdata <= m_ipb_in.ipb_wdata;
	s_ipb_out.ipb_write	 <= m_ipb_in.ipb_write;
	
	m_ipb_out.ipb_rdata <= s_ipb_in.ipb_rdata;
	
	ack_del(0) <= s_ipb_in.ipb_ack;
	err_del(0) <= s_ipb_in.ipb_err;
	
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' or m_ipb_in.ipb_strobe = '0' then
				ack_del(latency downto 1) <= (others => '0');
				err_del(latency downto 1) <= (others => '0');				
				got_resp <= '0';
			else
				ack_del(latency downto 1) <= ack_del(latency - 1 downto 0);
				err_del(latency downto 1) <= err_del(latency - 1 downto 0);
				got_resp <= (got_resp or ack_del(0) or err_del(0)) and
					not (ack_del(latency) or err_del(latency));
			end if;
		end if;
	end process;
	
	m_ipb_out.ipb_ack <= ack_del(latency);
	m_ipb_out.ipb_err <= err_del(latency);	
	s_ipb_out.ipb_strobe <= ipbus_in.ipb_strobe and not got_ack;
	
end rtl;
