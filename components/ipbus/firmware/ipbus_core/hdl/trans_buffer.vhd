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

use work.ipbus_trans_decl.all;

entity trans_buffer is
	port(
		clk_m: in std_logic;
		rst_m: in std_logic;
		m_wdata: in std_logic_vector(7 downto 0);
		m_we: in std_logic;
		m_rdata: out std_logic_vector(7 downto 0);
		m_re: in std_logic;
		m_req: in std_logic;
		m_done: out std_logic;
		clk_ipb: in std_logic;
		t_out: out ipbus_trans_in;
		t_in: in ipbus_trans_out
	);

end trans_buffer;

architecture rtl of trans_buffer is

begin

	m_done <= '0';
	m_rdata <= (others => '0');
	
	t_out.pkt_rdy <= '0';
	t_out.rdata <= (others => '0');
	t_out.busy <= '0';

end rtl;
