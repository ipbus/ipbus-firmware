
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_trans_decl.all;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

entity uc_pipe_interface is
  port(
    clk: in std_logic;
    rst: in std_logic;
    ipbus_in: in ipb_wbus;
    ipbus_out: out ipb_rbus;
    clk200: in std_logic;
    uc_pipe_nrd: in std_logic;
    uc_pipe_nwe: in std_logic;
    uc_pipe: inout std_logic_vector(15 downto 0)
  );
  
end uc_pipe_interface;

architecture rtl of uc_pipe_interface is

SIGNAL samp_nwe : std_logic_vector(1 DOWNTO 0) := (OTHERS => '1');
SIGNAL samp_nrd : std_logic_vector(1 DOWNTO 0) := (OTHERS => '1');

  signal ack: std_logic;
  signal clk200buf: std_logic;

      signal we_pipe : std_logic_vector(0 downto 0);
      signal w_addr_pipe : unsigned(9 downto 0) := (others=>'1');
      signal w_data_pipe : std_logic_vector(15 downto 0);
      signal r_addr_ipbus : unsigned(8 downto 0) := (others=>'0');
      signal r_data_ipbus : std_logic_vector(31 downto 0);
      signal we_ipbus : std_logic_vector(0 downto 0);
      signal w_addr_ipbus : unsigned(8 downto 0) := (others=>'1');
      signal w_data_ipbus : std_logic_vector(31 downto 0);
      signal r_addr_pipe : unsigned(9 downto 0) := (others=>'0');
      signal r_data_pipe : std_logic_vector(15 downto 0);

--       signal pipe_to_ipbus_reset , ipbus_to_pipe_reset : std_logic;


  COMPONENT sdpram_16x10_32x9
    PORT (
      clka : IN STD_LOGIC;
      wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
      dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      clkb : IN STD_LOGIC;
      addrb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
      doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
  END COMPONENT;
  
  COMPONENT sdpram_32x9_16x10
    PORT (
      clka : IN STD_LOGIC;
      wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
      dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      clkb : IN STD_LOGIC;
      addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
      doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;

begin



  buf200: BUFG port map(
    i => clk200,
    o => clk200buf
  );


--   w_data_pipe <= uc_pipe;
--   uc_pipe <= r_data_pipe when uc_pipe_nwe = '1' else (OTHERS => 'Z');


  process( clk200buf , ipbus_to_pipe_reset , pipe_to_ipbus_reset )
  begin
--     if( ipbus_to_pipe_reset = '1' ) then
--       r_addr_pipe <= (others=>'0');
--     elsif( pipe_to_ipbus_reset = '1' ) then
--       w_addr_pipe <= (others=>'1');
--     els
    if  rising_edge( clk200buf ) then

      samp_nwe( 1 downto 0 ) <= samp_nwe(0) & uc_pipe_nwe;
      samp_nrd( 1 downto 0 ) <= samp_nrd(0) & uc_pipe_nrd;

      we_pipe <= "0";

      if( uc_pipe_nwe = '1' ) then
        uc_pipe <= r_data_pipe;
      else
        uc_pipe <= (OTHERS => 'Z');
      end if;

      if( samp_nrd = "10" ) then
        r_addr_pipe <= r_addr_pipe + 1;
      end if;

      if( samp_nwe = "10" ) then
        w_addr_pipe <= w_addr_pipe + 1;
        we_pipe <= "1";
      end if;

     end if;
  end process;

  


  ipbus_out.ipb_err <= '0'; 
  ipbus_out.ipb_ack <= ack;

  process(clk )
  begin

    if rising_edge( clk ) then 

--       if( ipbus_to_pipe_reset = '1' ) then
--         ipbus_to_pipe_reset <= '0';  
--         w_addr_ipbus <= (others=>'1');
--       elsif( pipe_to_ipbus_reset = '1' ) then
--         pipe_to_ipbus_reset <= '0';
--         r_addr_ipbus <= (others=>'0');
--       else
  
        ack <= ipbus_in.ipb_strobe and not ack;
  
        --STATUS/CONFIGURATION REGISTER
        if ipbus_in.ipb_strobe='1' and ack='0' then
          if ipbus_in.ipb_write='0' then 
            if ipbus_in.ipb_addr(1 downto 0)="00" then
              ipbus_out.ipb_rdata <= "0000000" & std_logic_vector( w_addr_ipbus ) & "000000" & std_logic_vector( r_addr_pipe );
            elsif ipbus_in.ipb_addr(1 downto 0)="01" then
              ipbus_out.ipb_rdata <= "0000000" & std_logic_vector( r_addr_ipbus ) & "000000" & std_logic_vector( w_addr_pipe );
            end if;
--           else
--             if ipbus_in.ipb_addr(1 downto 0)="00" then
--               ipbus_to_pipe_reset <= '1';          
--             elsif ipbus_in.ipb_addr(1 downto 0)="01" then
--               pipe_to_ipbus_reset <= '1';          
--             end if;
          end if;
        end if;
  
  
        we_ipbus <= "0";
        
        --FIFO
        if ipbus_in.ipb_strobe='1' and ack='0' and ipbus_in.ipb_addr(1 downto 0)="10" then
        
          if ipbus_in.ipb_write='1' then
            w_data_ipbus <= ipbus_in.ipb_wdata( 15 downto 0 ) & ipbus_in.ipb_wdata( 31 downto 16 );
            w_addr_ipbus <= w_addr_ipbus + 1;
            we_ipbus <= "1";
          else
            ipbus_out.ipb_rdata <= r_data_ipbus( 15 downto 0 ) & r_data_ipbus( 31 downto 16 ) ;
            r_addr_ipbus <= r_addr_ipbus + 1;
          end if;

        end if;

--       end if;
    end if; --if rising_edge( clk )
  end process;




  ram_pipe_to_ipbus: sdpram_16x10_32x9
    port map(
      clka => clk200buf,
      wea => we_pipe,
      addra => std_logic_vector( w_addr_pipe ),
      dina => uc_pipe, --w_data_pipe,
      clkb => clk,
      addrb => std_logic_vector( r_addr_ipbus ),
      doutb => r_data_ipbus
    );


   ram_ipbus_to_pipe: sdpram_32x9_16x10
    port map(
      clka => clk,
      wea => we_ipbus,
      addra => std_logic_vector( w_addr_ipbus ),
      dina => w_data_ipbus,
      clkb => clk200buf,
      addrb => std_logic_vector( r_addr_pipe ),
      doutb => r_data_pipe
    );

end rtl;
