-- payload_sim
--
-- Testbench design for ipbus_clk_bridge blocks
--
-- Dave Newbold, October 2022

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.ipbus.all;
use work.ipbus_decode_ipbus_axi_tb_sim.all;

entity payload is
	generic(
		CARRIER_TYPE: std_logic_vector(7 downto 0) := x"00"
	);
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clk: in std_logic;
		rst: in std_logic;
		nuke: out std_logic;
		soft_rst: out std_logic;
		userled: out std_logic
	);

end payload;

architecture rtl of payload is

	constant DESIGN_TYPE: std_logic_vector := X"00";

	signal ipbw: ipb_wbus_array(N_SLAVES - 1 downto 0);
	signal ipbr: ipb_rbus_array(N_SLAVES - 1 downto 0);
	signal afclk, asclk, rfclk, rsclk: std_logic := '0';
	
begin

	nuke <= '0';
	soft_rst <= '0';
	userled <= '0';

-- ipbus address decode
		
	fabric: entity work.ipbus_fabric_sel
		generic map(
    		NSLV => N_SLAVES,
    		SEL_WIDTH => IPBUS_SEL_WIDTH
    	)
		port map(
			ipb_in => ipb_in,
			ipb_out => ipb_out,
			sel => ipbus_sel_ipbus_axi_tb_sim(ipb_in.ipb_addr),
			ipb_to_slaves => ipbw,
			ipb_from_slaves => ipbr
		);



end rtl;
