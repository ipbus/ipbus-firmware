-- Arbitrates access to transactor by multiple packet buffers
--
-- Dave Newbold, July 2011
--
-- $Id$

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ipbus_bus_decl.all;

entity bus_arb is
  generic(NSRC: positive);
  port(
    clk: in std_logic; 
    reset: in std_logic;
    moti_bus: in trans_moti_array(NSRC-1 downto 0);
    tomi_bus: out trans_tomi_array(NSRC-1 downto 0);
    moti: out trans_moti;
    tomi: in trans_tomi
  );

end bus_arb;

architecture rtl of bus_arb is
  
 	signal src: unsigned(1 downto 0) := "00"; -- Up to four ports...
	signal sel: integer := 0;
	signal done, new_pkt, pkt, ready_d, act: std_logic_vector(NSRC-1 downto 0);
	signal done_d: std_logic;
  
begin

  sel <= to_integer(src);

  process(clk)
  begin
    if rising_edge(clk) then
      if pkt(sel)='0' then
        if src/=(NSRC-1) then
          src <= src + 1;
        else
          src <= (others=>'0');
        end if;
      end if;
      done_d <= tomi.done;
    end if;
  end process;

  moti.rdata <= moti_bus(sel).rdata;
  moti.addr_rst <= moti_bus(sel).addr_rst;
  moti.ready <= pkt(sel);

  busgen: for i in NSRC-1 downto 0 generate
  begin
    act(i) <= '1' when sel = i else '0';
    tomi_bus(i).done <= done(i);
    tomi_bus(i).wdata <= tomi.wdata;
    tomi_bus(i).waddr <= tomi.waddr;
    tomi_bus(i).raddr <= tomi.raddr;
    tomi_bus(i).we <= tomi.we when sel = i else '0';
    
    process(clk)
    begin
      if rising_edge(clk) then
        ready_d(i) <= moti_bus(i).ready;
        pkt(i) <= ((pkt(i) and not done(i)) or new_pkt(i)) and not reset;
        done(i) <= (done(i) or (tomi.done and not done_d and act(i))) and not (new_pkt(i) or reset);
      end if;
    end process;
    
    new_pkt(i) <= moti_bus(i).ready and not ready_d(i);
      
  end generate;
  
end rtl;
