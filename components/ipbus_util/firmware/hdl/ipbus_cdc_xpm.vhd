-- ipbus_cdc_xpm.vhd
--
-- Array of single-bit clock crossing synchronisers
-- This version is a wrapper around the Xilinx XPM library
--
-- Dave Newbold, October 2022

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library xpm;
use xpm.vcomponents.all;

entity ipbus_cdc is
	generic(
		N: positive := 1
	);
	port(
        dclk: in std_logic;
        d: in std_logic_vector(N - 1 downto 0);
        qclk: out std_logic;
        q: out std_logic_vector(N - 1 downto 0)
	);
	
end ipbus_cdc;

architecture rtl of ipbus_cdc is
	
begin

    cdc: xpm_cdc_array_single
        generic map(
            DEST_SYNC_FF => 2,
            SIM_ASSERT_CHK => 1,
            WIDTH => N
        )
        port map(
            dest_out => q,
            dest_clk => qclk,
            src_clk => dclk,
            src_in => d
        );

end rtl;
