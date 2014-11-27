-- sysmon_v6
--
-- Interface to the virtex 6 system monitor
--
-- Dave Newbold, November 2014

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.VComponents.all;

use work.ipbus.all;
use work.drp_decl.all;

entity sysmon_v6 is
	port(
		clk: in std_logic;
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus
	);

end sysmon_v6;

architecture rtl of sysmon_v6 is
	
	signal drp_m2s: drp_wbus;
	signal drp_s2m: drp_rbus;

begin
	
	drp: entity work.ipbus_drp_bridge
		port map(
			clk => clk,
			rst => rst,
			ipb_in => ipb_in,
			ipb_out => ipb_out,
			drp_out => drp_m2s,
			drp_in => drp_s2m
		);
	
	sysm: SYSMON
		port map(
			convst => '0',
			convstclk => '0',
			daddr => drp_m2s.addr(6 downto 0),
			dclk => clk,
			den => drp_m2s.en,
			di => drp_m2s.data,
			do => drp_s2m.data,
			drdy => drp_s2m.rdy,
			dwe => drp_m2s.we,
			reset => rst,
			vauxp => X"0000",
			vauxn => X"0000",
			vn => '0',
			vp => '0'
		);
	
end rtl;
