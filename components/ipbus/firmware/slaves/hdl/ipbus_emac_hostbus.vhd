-- Generic ipbus slave config register for testing
--
-- generic addr_width defines number of significant address bits
--
-- We use one cycle of read / write latency to ease timing (probably not necessary)
-- The q outputs change immediately on write (no latency).
--
-- Dave Newbold, March 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.emac_hostbus_decl.all;

entity ipbus_emac_hostbus is
	port(
		clk: in std_logic;
		reset: in std_logic;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		hostbus_out: out emac_hostbus_in;
		hostbus_in: in emac_hostbus_out
	);
	
end ipbus_emac_hostbus;

architecture rtl of ipbus_emac_hostbus is

	signal emac1sel, mdiocyc, acyc, dcyc, dcyc_d: std_logic;
	signal addr: std_logic_vector(9 downto 0);

begin
	
	ipbus_out.ipb_rdata <= hostbus_in.hostrddata when ipbus_in.ipb_addr(0) = '0'
		else X"0000" & "000" & emac1sel & mdiocyc & '0' & addr;
	
	acyc <= ipbus_in.ipb_strobe and ipbus_in.ipb_addr(0);
	dcyc <= ipbus_in.ipb_strobe and not ipbus_in.ipb_addr(0);
	
	process(clk)
	begin
		if rising_edge(clk) then
			if acyc = '1' and ipbus_in.ipb_write = '1' then
				emac1sel <= ipbus_in.ipb_wdata(12);
				mdiocyc <= ipbus_in.ipb_wdata(11);
				addr <= ipbus_in.ipb_wdata(9 downto 0);
			end if;
			dcyc_d <= dcyc;
		end if;
	end process;
	
	hostbus_out.hostwrdata <= ipbus_in.ipb_wdata;
	hostbus_out.hostaddr <= addr;
	hostbus_out.hostemac1sel <= emac1sel;
	hostbus_out.hostclk <= clk;
	
	hostbus_out.hostmiimsel <= not (dcyc or (dcyc_d and ipbus_in.ipb_write)) or mdiocyc; 
	hostbus_out.hostopcode(1) <= not ipbus_in.ipb_write;
	hostbus_out.hostopcode(0) <= ipbus_in.ipb_write;
	hostbus_out.hostreq <= dcyc and mdiocyc and hostbus_in.hostmiimrdy;
	
	ipbus_out.ipb_ack <= acyc or (dcyc and dcyc_d and (hostbus_in.hostmiimrdy or not mdiocyc));
	ipbus_out.ipb_err <= '0';
	
end rtl;
