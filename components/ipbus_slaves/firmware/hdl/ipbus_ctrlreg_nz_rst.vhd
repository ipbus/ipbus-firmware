library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_ctrlreg_nz_rst is
    generic(
        REG_ID: integer := 0
    );
    port(
        clk         : in std_logic; 
        rst         : in std_logic;
        sel         : in integer;
        ipbus_in    : in ipb_wbus;
        qmask       : in std_logic_vector(31 downto 0);
        rst_value   : in std_logic_vector(31 downto 0);
        q           : out std_logic_vector(31 downto 0)
    );
end ipbus_ctrlreg_nz_rst;

architecture rtl of ipbus_ctrlreg_nz_rst is

begin

process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            q <= rst_value;
        elsif sel = REG_ID and ipbus_in.ipb_strobe ='1' and ipbus_in.ipb_write ='1' then
            q <= ipbus_in.ipb_wdata and qmask;
        end if;
    end if;
end process;

end rtl;