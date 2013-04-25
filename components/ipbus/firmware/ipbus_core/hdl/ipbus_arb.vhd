-- ipbus_arb
--
-- Arbitrator for multiple ipbus masters
--
-- Dave Newbold, April 2013

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_arb is 
	generic(
		N_BUS: positive := 2
	);
  port(
  	clk: in std_logic;
  	rst: in std_logic;
  	ipb_m_out: in ipb_wbus_array(N_BUS - 1 downto 0);
  	ipb_m_in: out ipb_rbus_array(N_BUS - 1 downto 0);
  	ipb_req: in std_logic_vector(N_BUS - 1 downto 0);
  	ipb_grant: out std_logic_vector(N_BUS - 1 downto 0);
		ipb_out: out ipb_wbus;
		ipb_in: in ipb_rbus
	);

end ipbus_arb;

architecture rtl of ipbus_arb is

 	signal src: unsigned(1 downto 0); -- Up to four ports...
	signal sel: integer;
	signal busy: std_logic;

begin

	sel <= to_integer(src);

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				busy <= '0';
				src <= (others => '0');
			elsif busy = '0' then
				if ipb_req(sel) = '0' then
					if src /= (N_BUS - 1) then
						src <= src + 1;
					else
						src <= (others=>'0');
					end if;
				else
					busy <= '1';
				end if;
			elsif ipb_req(sel) = '0' then
				busy <= '0';
			end if;
		end if;
	end process;

	busgen: for i in N_BUS - 1 downto 0 generate
	begin
		ipb_grant(i) <= '1' when sel = i and busy = '1' else '0';
		ipb_m_in(i) <= ipb_in;
	end generate;
	
	ipb_out <= ipb_m_out(sel);

end rtl;

