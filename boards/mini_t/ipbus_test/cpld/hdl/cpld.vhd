library ieee;
use ieee.std_logic_1164.all;

entity cpld is
   generic (ports: integer := 3);
   port (
      reset_switch: in std_logic; 
		v5_prog_b: in std_logic; 
		v5_init_b: in std_logic; 
		v5_done: in std_logic; 
      v5_cpld:    out std_logic_vector(9 downto 0);
      uc_cpld:    out std_logic_vector(9 downto 0);
		led:        out std_logic_vector(3 downto 0);
	   dummy:      out std_logic;	
      tcka:       in std_logic;
      tmsa:       in std_logic;
      tdia:       in std_logic;
      tdoa:       out std_logic;
      tckb:       in std_logic;
      tmsb:       in std_logic;
      tdib:       in std_logic;
      tdob:       out std_logic;
      tcko:       out std_logic_vector(ports-1 downto 0);
      tmso:       out std_logic_vector(ports-1 downto 0);
      tdio:       out std_logic_vector(ports-1 downto 0);
      tdoo:       in std_logic_vector(ports-1 downto 0);
      sel:        inout std_logic_vector(7 downto 0));
end cpld;

architecture behave of cpld is

  attribute SCHMITT_TRIGGER: string;
  attribute SCHMITT_TRIGGER of reset_switch: signal is "true";

   signal tcki:   std_logic;
   signal tmsi:   std_logic;
   signal tdii:   std_logic;
   signal tdoi:   std_logic;
   signal xfer:   std_logic_vector(ports-1 downto -1);

begin

  v5_cpld(0) <= reset_switch;
  v5_cpld(9 downto 1) <= (others => '0');

  uc_cpld(0) <= reset_switch;
  uc_cpld(9 downto 1) <= (others => '0');
  
  -- LEDs on when signal gnd (i.e. inverted)
  led(0) <= not reset_switch;
  led(1 downto 1) <= (others => '1');
  
 -- Note sel signal is inverted (i.e. switch ON = '0')
   -- Resistors on board not required.  Should have just had pullup.
   sel(6) <= '1';

   -- select JTAG input based on sel(7)
   tcki <= tckb when sel(7) = '1' else tcka;
   tmsi <= tmsb when sel(7) = '1' else tmsa;
   tdii <= tdib when sel(7) = '1' else tdia;
   tdob <= tdoi when sel(7) = '1' else '0';
   tdoa <= tdoi when sel(7) = '0' else '0';

   -- tck switching
   tcksw: process (tcki, sel) begin
      for i in 0 to ports-1 loop
         if sel(i) = '0' then
            tcko(i) <= tcki;
         else
            tcko(i) <= '0';
         end if;
      end loop;
   end process;

   -- tms switching	
   tmssw: process (tmsi, sel) begin
      for i in 0 to ports-1 loop
         if sel(i) = '0' then
            tmso(i) <= tmsi;
         else
            tmso(i) <= '1';
         end if;
      end loop;
   end process;

   -- tdi/tdo routing
	xfer(-1) <= tdii; 
   tdsw: process (tdii, sel, tdoo, xfer) begin
      for i in 0 to ports-1 loop
         if sel(i) = '0' then
            xfer(i) <= tdoo(i); -- loop through chain
            tdio(i)<= xfer(i-1); 
         else
            xfer(i) <= xfer(i-1); -- bypass
            tdio(i)<= '1'; 
         end if;
      end loop;
      tdoi <= xfer(ports-1);
   end process;
	
	dummy <= v5_prog_b or v5_init_b or v5_done;
	
end behave;