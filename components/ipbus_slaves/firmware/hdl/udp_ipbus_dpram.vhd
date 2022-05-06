
-- udp_ipbus_dpram
--
-- Generic 32b (or less) wide dual-port memory with ipbus access on one port
-- This is a 'flat memory' mapping the RAM directly into ipbus address space
-- Note that 1 wait state is required due to design of Xilinx block RAM
--
-- Should lead to an inferred block RAM in Xilinx parts with modern tools
--
-- Adam Barcock, March 2022. 
-- Based on work by Dave Newbold, July 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity udp_ipbus_dpram is
    generic(
        ADDR_WIDTH     : positive;
        DATA_WIDTH      : positive := 32;
        LATENCY         : integer range 1 to 2 := 1;
        USER_LATENCY    : integer range 1 to 2 := 1
    );
    port(
        clk     : in std_logic;
        rst     : in std_logic;
        ipb_in  : in ipb_wbus;
        ipb_out : out ipb_rbus;
        
        q_mask  : in std_logic_vector(DATA_WIDTH-1 downto 0);
        rclk    : in std_logic;
        we      : in std_logic := '0';
        en      : in std_logic := '0';
        d       : in std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
        addr    : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        q       : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end udp_ipbus_dpram;
architecture rtl of udp_ipbus_dpram is
    
    type ram_array is array(2 ** ADDR_WIDTH - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    type data_out_arr is array (0 to 1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    
    shared variable ram : ram_array  := (others => (others => '0'));
    signal sel, rsel: integer range 0 to 2 ** ADDR_WIDTH - 1 := 0;
    signal ipb_rdata, q_rdata : data_out_arr;
    signal ack: std_logic_vector(1 downto 0);
    
begin
    sel <= to_integer(unsigned(ipb_in.ipb_addr(ADDR_WIDTH - 1 downto 0)));
    process(clk)
    begin
        if rising_edge(clk) then
            if ipb_in.ipb_strobe='1' then
                if ipb_in.ipb_write='1' then
                    ram(sel) := ipb_in.ipb_wdata(DATA_WIDTH - 1 downto 0);
                end if;
                ipb_rdata(0)    <= std_logic_vector(ram(sel));
            end if;
            ipb_rdata(1)    <= ipb_rdata(0);
            ack(0)      <= ipb_in.ipb_strobe and not ack(0);
            ack(1)      <= ack(0);
        end if;
    end process;
    ipb_out.ipb_rdata   <= ipb_rdata(LATENCY-1) and q_mask;
    ipb_out.ipb_ack     <= ack(LATENCY-1);
    ipb_out.ipb_err     <= '0';
    
    rsel <= to_integer(unsigned(addr));
    process(rclk)
    begin
        if rising_edge(rclk) then
            if en = '1' then
                if we = '1' then
                    ram(rsel) := d;
                end if;
                q_rdata(0) <= std_logic_vector(ram(rsel));
            end if;
            q_rdata(1) <= q_rdata(0);
        end if;
    end process;
    q <= q_rdata(USER_LATENCY-1) and q_mask;

end rtl;