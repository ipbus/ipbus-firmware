-- Adds latency to any slave, for testing purposes
--
-- NB: Delays ack only, not err
--
-- Dave Newbold, May 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_latency_test is
	generic(
		latency: natural := 1
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		slv_ipbus_out: out ipb_wbus;
		slv_ipbus_in: in ipb_rbus
	);
	
end ipbus_latency_test;

architecture rtl of ipbus_latency_test is

	signal ack_del: std_logic_vector(latency downto 0);
	signal got_ack: std_logic;

begin

	slv_ipbus_out.ipb_addr <= ipbus_in.ipb_addr;
	slv_ipbus_out.ipb_wdata <= ipbus_in.ipb_wdata;
	slv_ipbus_out.ipb_write	 <= ipbus_in.ipb_write;
	
	ipbus_out.ipb_rdata <= slv_ipbus_in.ipb_rdata;
	ipbus_out.ipb_err <= slv_ipbus_in.ipb_err;
	
	ack_del(0) <= slv_ipbus_in.ipb_ack;
	
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' or ipbus_in.ipb_strobe = '0' then
				ack_del(latency downto 1) <= (others => '0');
				got_ack <= '0';
			else
				ack_del(latency downto 1) <= ack_del(latency - 1 downto 0);
				got_ack <= (got_ack or ack_del(0)) and not ack_del(latency);
			end if;
		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack_del(latency);
	slv_ipbus_out.ipb_strobe <= ipbus_in.ipb_strobe and not got_ack;
	
end rtl;
