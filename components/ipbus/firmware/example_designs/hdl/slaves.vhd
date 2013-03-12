-- The ipbus slaves live in this entity - modify according to requirements
--
-- Ports can be added to give ipbus slaves access to the chip top level.
--
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.ALL;
use work.emac_hostbus_decl.all;

entity slaves is
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		hostbus_out: out emac_hostbus_in;
		hostbus_in: in emac_hostbus_out;
		rst_out: out std_logic
	);

end slaves;

architecture rtl of slaves is

	constant NSLV: positive := 3;
	signal ipbw: ipb_wbus_array(NSLV-1 downto 0);
	signal ipbr, ipbr_d: ipb_rbus_array(NSLV-1 downto 0);

begin

  fabric: entity work.ipbus_fabric
    generic map(NSLV => NSLV)
    port map(
      ipb_clk => ipb_clk,
      rst => ipb_rst,
      ipb_in => ipb_in,
      ipb_out => ipb_out,
      ipb_to_slaves => ipbw,
      ipb_from_slaves => ipbr
    );

-- Slave 0: fixed pattern

	slave0: entity work.ipbus_ctrlreg
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(0),
			ipbus_out => ipbr(0),
			d => X"abcdfedc",
			q(0) => rst_out,
			q(31 downto 1) => open
		);

-- Slave 1: register

	slave1: entity work.ipbus_reg
		generic map(addr_width => 0)
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(1),
			ipbus_out => ipbr(1),
			q => open);
			
-- Slave 2: 1kword RAM

	slave2: entity work.ipbus_ram
		generic map(addr_width => 10)
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(2),
			ipbus_out => ipbr(2));

-- Dummy ethernet MAC control signals

	hostbus_out.hostclk <= '0';
	hostbus_out.hostopcode <= (others => '0');
	hostbus_out.hostaddr <= (others => '0');
	hostbus_out.hostwrdata <= (others => '0');
	hostbus_out.hostmiimsel <= '0';
	hostbus_out.hostreq <= '0';
	hostbus_out.hostemac1sel <= '0';
			
end rtl;
