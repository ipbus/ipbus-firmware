-- Shim for ipbus.
--
-- Splits back to back transactions apart (i.e. strobe will go low between transactions)
-- Waits for acknowledge to go low before starting anotherv transaction
--
-- Greg Iles, July 2012

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_shim is
	generic(
		ENABLE : boolean := true
	);
	port(
		clk: in std_logic;
		reset: in std_logic;
		ipbus_in: in ipb_wbus;
		ipbus_out: out ipb_rbus;
		ipbus_shim_out: out ipb_wbus;
		ipbus_shim_in: in ipb_rbus
	);
	
end ipbus_shim;

architecture rtl of ipbus_shim is

	type type_shim_state is (idle, wait_for_ack_start, wait_for_ack_stop);
  signal shim_state: type_shim_state := idle;

begin

  -- Would timeout be wise?  Good for robustness, but not debugging.


  shim_en: if (ENABLE = true) generate
    shim_sm: process(clk)
    begin
      if rising_edge(clk) then
        if reset='1' then
          shim_state <= idle;
          ipbus_shim_out <= (ipb_addr =>  x"00000000", ipb_wdata => x"00000000", ipb_strobe => '0', ipb_write => '0');
          ipbus_out <= (ipb_rdata => x"00000000", ipb_ack => '0', ipb_err => '0');
        else
          case shim_state is
          when idle =>
            if ipbus_in.ipb_strobe='1' then   
              shim_state <= wait_for_ack_start;
              ipbus_shim_out <= ipbus_in;
            end if;
          when wait_for_ack_start =>
            if ipbus_shim_in.ipb_ack = '1' then
              -- Send data back to master
              ipbus_out.ipb_ack <= '1';
              ipbus_out.ipb_err <= ipbus_shim_in.ipb_err;
              ipbus_out.ipb_rdata <= ipbus_shim_in.ipb_rdata;
              -- Negate strobe
              ipbus_shim_out.ipb_strobe <= '0';
              shim_state <= wait_for_ack_stop;
            end if;
          when wait_for_ack_stop => 
            ipbus_out.ipb_ack <= '0';
            if ipbus_shim_in.ipb_ack = '0' then
              shim_state <= idle;
            end if;        
          when others =>
            shim_state <= idle;
          end case;
        end if;
      end if;
    end process;
  end generate;
      
  shim_dis: if (enable = false) generate
    ipbus_shim_out <= ipbus_in;
    ipbus_out <= ipbus_shim_in;
  end generate;

end rtl;
