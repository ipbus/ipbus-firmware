-- Packet counter for monitoring packet loss
--
-- Counters are reset by any write
--
-- Dave Newbold, May 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_pkt_ctr is
	port(
		clk: in STD_LOGIC;
		reset: in STD_LOGIC;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		pkt_rx: in std_logic;
		pkt_tx: in std_logic
	);
	
end ipbus_pkt_ctr;

architecture rtl of ipbus_pkt_ctr is

	signal r_ctr, w_ctr: unsigned(31 downto 0);
	signal ack: std_logic;

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' or (ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write = '1') then
				w_ctr <= (others => '0');
				r_ctr <= (others => '0');
			else
				if pkt_rx = '1' then
					r_ctr <= r_ctr + 1;
				end if;
				if pkt_tx = '1' then
					w_ctr <= w_ctr + 1;
				end if;
			end if;
			ack <= ipbus_in.ipb_strobe and not ack;
		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';
	ipbus_out.ipb_rdata <= std_logic_vector(r_ctr) when ipbus_in.ipb_addr(0) = '0' else
		std_logic_vector(w_ctr);

end rtl;
