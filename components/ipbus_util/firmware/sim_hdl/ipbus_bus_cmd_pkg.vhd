library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library udp_core_lib;
use udp_core_lib.udp_core_pkg.all;

library ipbus;
use ipbus.ipbus.all;
use ipbus.ipbus_reg_types.all;

package ipbus_bus_cmd_pkg is

constant C_WR_TIMEOUT_LIMIT         : integer := 100;
constant C_RD_TIMEOUT_LIMIT         : integer := 100;

    --------------------------------------------------------------------------------
    -- Procedure Declarations:
    --------------------------------------------------------------------------------
    procedure ipbus_init(
        signal clk          : in std_logic;
        signal rst          : in std_logic;
        signal ipb_w_mosi   : out ipb_wbus
    );
    
    procedure ipbus_rd(
        signal clk          : in std_logic;
        signal ipb_r_miso   : in ipb_rbus;
        signal ipb_w_mosi   : out ipb_wbus;
        constant addr       : in std_logic_vector(31 downto 0);
        signal data         : out std_logic_vector(31 downto 0)
    );
    
    procedure ipbus_wr(
        signal clk          : in std_logic;
        signal ipb_r_miso   : in ipb_rbus;
        signal ipb_w_mosi   : out ipb_wbus;
        constant addr       : in std_logic_vector(31 downto 0);
        constant data       : in std_logic_vector(31 downto 0)
    );

end package ipbus_bus_cmd_pkg;

package body ipbus_bus_cmd_pkg is

--------------------------------------------------------------------------------
-- Procedures:
--------------------------------------------------------------------------------
    procedure ipbus_init(
        signal clk          : in std_logic;
        signal rst          : in std_logic;
        signal ipb_w_mosi   : out ipb_wbus
    ) is
    constant C_WAIT_CYCLES  : integer := 3;
    
    begin
        ipb_w_mosi.ipb_addr     <= (others=>'0');
        ipb_w_mosi.ipb_wdata    <= (others=>'0');
        ipb_w_mosi.ipb_strobe   <= '0';
        ipb_w_mosi.ipb_write    <= '0';
         
        wait until rst = not('0') and rising_edge(clk);
        for i in 0 to C_WAIT_CYCLES-1 loop
            wait until rising_edge(clk);
        end loop;
        
        assert false report "IPbus Initialised" severity note;
    end procedure ipbus_init;
    
--------------------------------------------------------------------------------
    procedure ipbus_rd(
        signal clk          : in std_logic;
        signal ipb_r_miso   : in ipb_rbus;
        signal ipb_w_mosi   : out ipb_wbus;
        constant addr       : in std_logic_vector(31 downto 0);
        signal data         : out std_logic_vector(31 downto 0)
    )is
    variable timeout_counter    : integer := 0;
    begin
        ipb_w_mosi.ipb_addr     <= addr;
        ipb_w_mosi.ipb_strobe   <= '1';
        ipb_w_mosi.ipb_wdata    <= (others=>'0');
        ipb_w_mosi.ipb_write    <= '0';
        
        ack_wait_loop : loop
            wait until rising_edge(clk); 
            if (timeout_counter = C_RD_TIMEOUT_LIMIT) then
                ipb_w_mosi.ipb_addr     <= (others=>'0');
                ipb_w_mosi.ipb_strobe   <= '0';
                assert false report "IPbus Read Operation Timeout" severity warning;
                exit ack_wait_loop;
                
            elsif(ipb_r_miso.ipb_ack ='1') then
                data <= ipb_r_miso.ipb_rdata;
                ipb_w_mosi.ipb_addr     <= (others=>'0');
                ipb_w_mosi.ipb_strobe   <= '0';
                assert false report "IPbus Read Operation Complete" severity note;
                exit ack_wait_loop;
                
            elsif(ipb_r_miso.ipb_err = '1') then
                ipb_w_mosi.ipb_addr     <= (others=>'0');
                ipb_w_mosi.ipb_strobe   <= '0';
                assert false report "IPbus Read Operation Failed" severity error;
                exit ack_wait_loop;
                
            else
                timeout_counter := timeout_counter + 1;
                
            end if;
        end loop ack_wait_loop;
        wait until rising_edge(clk);
    end procedure ipbus_rd;
    
--------------------------------------------------------------------------------
--! Allows addr to be populated with X"xxxx_xxxx" Literal String (constant)
    procedure ipbus_wr(
        signal clk          : in  std_logic;
        signal ipb_r_miso   : in  ipb_rbus;
        signal ipb_w_mosi   : out ipb_wbus;
        constant addr       : in  std_logic_vector(31 downto 0);
        constant data       : in  std_logic_vector(31 downto 0)
    ) is
    
    variable timeout_counter                : integer := 0;
    
    begin
        ipb_w_mosi.ipb_addr     <= addr;
        ipb_w_mosi.ipb_wdata    <= data;
        ipb_w_mosi.ipb_write    <= '1';
        ipb_w_mosi.ipb_strobe   <= '1';
        
        wait until rising_edge(clk);
        
        ack_wait_loop : loop
            wait until rising_edge(clk); 
            if (timeout_counter = C_WR_TIMEOUT_LIMIT) then
                ipb_w_mosi.ipb_addr     <= (others=>'0');
                ipb_w_mosi.ipb_wdata    <= (others=>'0');
                ipb_w_mosi.ipb_write    <= '0';
                ipb_w_mosi.ipb_strobe   <= '0';
                assert false report "IPbus Write Operation Timeout" severity warning;
                exit ack_wait_loop;
                
            elsif(ipb_r_miso.ipb_ack ='1') then
                ipb_w_mosi.ipb_addr     <= (others=>'0');
                ipb_w_mosi.ipb_wdata    <= (others=>'0');
                ipb_w_mosi.ipb_write    <= '0';
                ipb_w_mosi.ipb_strobe   <= '0';
                assert false report "IPbus Write Operation Complete" severity note;
                exit ack_wait_loop;
                
            elsif(ipb_r_miso.ipb_err = '1') then
                ipb_w_mosi.ipb_addr     <= (others=>'0');
                ipb_w_mosi.ipb_wdata    <= (others=>'0');
                ipb_w_mosi.ipb_write    <= '0';
                ipb_w_mosi.ipb_strobe   <= '0';
                assert false report "IPbus Write Operation Failed" severity error;
                exit ack_wait_loop;
                
            else
                timeout_counter := timeout_counter + 1;
            end if;
        end loop ack_wait_loop;
        
        wait until rising_edge(clk);

    end procedure ipbus_wr;

end package body ipbus_bus_cmd_pkg;
