library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_statreg_bank is
    generic(
        N_REG: natural := 1
    );
    port(
        clk         : in std_logic;
        reset       : in std_logic;
        ipbus_in    : in ipb_wbus;
        ipbus_out   : out ipb_rbus;
        d           : in ipb_reg_v(N_REG-1 downto 0)
    );
end ipbus_statreg_bank;

architecture rtl of ipbus_statreg_bank is
    -- ADDR_WIDTH is num of bits required to represent N_REG num of addrs.
    constant ADDR_WIDTH: integer := calc_width(N_REG);
    -- sel has range from zero to N_REG-1, set to zero by default.
    signal sel    : integer range 0 to N_REG-1 := 0;
    signal reg    : ipb_reg_v(2 ** ADDR_WIDTH - 1 downto 0);
    
begin
    sel <= to_integer(unsigned(ipbus_in.ipb_addr(ADDR_WIDTH - 1 downto 0))) when ADDR_WIDTH > 0 else 0;
    reg(2**ADDR_WIDTH-1 downto N_REG) <= (others=>(others=>'0'));
    
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reg(N_REG-1 downto 0) <= (others=>(others=>'0'));
            elsif (ipbus_in.ipb_strobe ='1') and (ipbus_in.ipb_write = '0') then
                ipbus_out.ipb_rdata <= reg(sel);
                ipbus_out.ipb_ack <= ipbus_in.ipb_strobe;
                ipbus_out.ipb_err <= '0';
            else
                reg(N_REG-1 downto 0) <= d;
            end if;
        end if;
    end process;
    
end rtl;