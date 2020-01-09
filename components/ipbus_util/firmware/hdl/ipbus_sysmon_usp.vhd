library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

use work.ipbus.all;
use work.drp_decl.all;

entity ipbus_sysmon_usp is

  port (
    clk : in std_logic;
    rst : in std_logic;
    ipb_in : in ipb_wbus;
    ipb_out : out ipb_rbus;
    i2c_scl : in std_logic;
    i2c_sda : in std_logic
  );

end ipbus_sysmon_usp;

architecture rtl of ipbus_sysmon_usp is

  signal drp_m2s : drp_wbus;
  signal drp_s2m : drp_rbus;

begin

  drp : entity work.ipbus_drp_bridge
    port map (
      clk => clk,
      rst => rst,
      ipb_in => ipb_in,
      ipb_out => ipb_out,
      drp_out => drp_m2s,
      drp_in => drp_s2m
    );

  sysm : SYSMONE4
    port map (
      -- DRP interface.
      do => drp_s2m.data,
      di => drp_m2s.data,
      daddr => drp_m2s.addr(7 downto 0),
      den => drp_m2s.en,
      dwe => drp_m2s.we,
      dclk => clk,
      drdy => drp_s2m.rdy,

      -- Clock and control.
      reset => rst,
      convst => '0',
      convstclk => '0',

      -- External analog inputs (disabled).
      vp => '0',
      vn => '0',
      vauxp => X"0000",
      vauxn => X"0000",

      -- I2C interface (disabled).
      i2c_sclk => i2c_scl,
      i2c_sda => i2c_sda
    );

end rtl;
