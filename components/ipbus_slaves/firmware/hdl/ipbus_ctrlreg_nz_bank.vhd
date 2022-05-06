library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_ctrlreg_nz_bank is
    generic(
        N_REG: natural := 1
    );
    port(
        clk         : in std_logic; 
        rst         : in std_logic;
        ipbus_in    : in ipb_wbus; 
        ipbus_out   : out ipb_rbus;
        qmask       : in ipb_reg_v(N_REG-1 downto 0);
        rst_value   : in ipb_reg_v(N_REG-1 downto 0);
        q           : out ipb_reg_v(N_REG-1 downto 0)
    );
end ipbus_ctrlreg_nz_bank;

architecture rtl of ipbus_ctrlreg_nz_bank is
    -- ADDR_WIDTH is num of bits required to represent N_REG num of addrs.
    constant ADDR_WIDTH: integer := calc_width(N_REG);
    -- sel has range from zero to N_REG-1, set to zero by default.
    signal sel    : integer range 0 to N_REG-1 := 0;
    signal reg    : ipb_reg_v(2 ** ADDR_WIDTH - 1 downto 0);

begin
    sel <= to_integer(unsigned(ipbus_in.ipb_addr(ADDR_WIDTH - 1 downto 0))) when ADDR_WIDTH > 0 else 0;

    gen_nz_reg: for i in 0 to N_REG-1 generate
        nz_reg: entity work.ipbus_ctrlreg_nz_rst
            generic map(
                REG_ID => i
            )
            port map(
                clk         => clk, 
                rst         => rst,
                sel         => sel,
                ipbus_in    => ipbus_in,
                qmask       => qmask(i),
                rst_value   => rst_value(i),
                q           => reg(i)
            );
    end generate gen_nz_reg;

    reg(2**ADDR_WIDTH-1 downto N_REG) <= (others=>(others=>'0'));
    q <= reg(N_REG-1 downto 0);

    ipbus_out.ipb_rdata <= reg(sel);
    ipbus_out.ipb_ack <= ipbus_in.ipb_strobe;
    ipbus_out.ipb_err <= '0';

end rtl;