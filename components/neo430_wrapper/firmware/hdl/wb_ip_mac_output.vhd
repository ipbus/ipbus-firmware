--
-- Output 32 bit IP address and 48 bit MAC address. Wishbone input
--
-- David Cussans, 28 Oct 2020

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Memory map ( 32 bit words)
-- 0 = IP address
-- 1 = MAC address(31:0)
-- 2 = MAC address(47:32)
-- 3 = bit-0 is the IPBus reset line.
-- 4 = bit-0 is the use RARP line.

entity wb_ip_mac_output is
generic (
    dat_sz  : natural := 32
);
port (
    clk_i  : in  std_logic;
    rst_i  : in  std_logic;
    --
    -- Wishbone Interface
    --
    dat_i  : in  std_logic_vector((dat_sz - 1) downto 0);
    dat_o  : out std_logic_vector((dat_sz - 1) downto 0);
    adr_i  : in  std_logic_vector(2 downto 0);
    we_i   : in  std_logic;
    ack_o  : out std_logic;
    err_o  : out std_logic;
    stb_i  : in  std_logic;
    --
    -- MAC, IP address , RARP flag output
    --
    --
    use_rarp_o : out STD_LOGIC; -- set high to indicate that IPBus core should use RARP 
    mac_addr_o : out std_logic_vector(47 downto 0);
    ip_addr_o : out  std_logic_vector(31 downto 0);
    ipbus_rst_o : out std_logic -- set high to reset IPBus core
);
end wb_ip_mac_output;

architecture Behavioral of wb_ip_mac_output is

    signal s_mac_addr: std_logic_vector(47 downto 0) := ( others => '0');
    signal s_ip_addr:  std_logic_vector(31 downto 0) := ( others => '0');
    signal s_use_rarp: std_logic;
    signal s_ipbus_rst : std_logic := '1' ;    
    signal s_ack : std_logic := '0';
    
begin

    err_o   <= '0';
 
    sync : process(clk_i)
    begin
        if rising_edge(clk_i) then

        if (stb_i = '1') then
            
            if (we_i = '1') then
                case adr_i is
                when "000" =>
                    s_ip_addr                   <= dat_i;
                when "001" =>
                    s_mac_addr(31 downto 0)     <= dat_i;
                when "010" =>
                    s_mac_addr(47 downto 32)    <= dat_i(15 downto 0);
                when "011" =>
                    s_ipbus_rst                 <= dat_i(0);
                when "100" =>
                    s_use_rarp                  <= dat_i(0);
                when others =>
                    dat_o   <= (others => '-');
                end case;
            else
                case adr_i is
                when "000" =>
                    dat_o   <= s_ip_addr; 
                when "001" =>
                    dat_o   <= s_mac_addr(31 downto 0) ;
                when "010" =>
                    dat_o   <= x"0000" & s_mac_addr(47 downto 32) ;
                when "011" =>
                    dat_o   <= x"0000000" & "000" & s_ipbus_rst ;
                when "100" =>
                    dat_o   <= x"0000000" & "000" & s_use_rarp;
                when others =>
                    dat_o   <= (others => '-');
                end case;
            end if;
        else
        
        end if;
        s_ack <= stb_i and not s_ack;
        end if;
        
    end process sync;

    ack_o <= s_ack;
    mac_addr_o  <= s_mac_addr;
    ip_addr_o   <= s_ip_addr;
    ipbus_rst_o <= s_ipbus_rst;

end Behavioral;
