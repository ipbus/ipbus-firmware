---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------

-- Interface to the UltraScale+ system monitor.
-- For recommended/limit values, please refer to Xilinx DS890.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.drp_decl.all;

use work.ipbus_decode_ipbus_sysmon_usp.all;

entity ipbus_sysmon_usp is
  generic (
    -- FPGAs in the UltraScale and UltraScale+ families can contain up
    -- to four SLRs.
    G_NUM_SLRS : positive range 1 to 4;

    -- The following are all generics that are passed straight to the
    -- SYSMON instances. Refer to UG580 for their values.
    -- G_INIT_40 - G_INIT_44: SYSMON configuration registers
    G_INIT_40 : std_logic_vector(15 downto 0);
    G_INIT_41 : std_logic_vector(15 downto 0);
    G_INIT_42 : std_logic_vector(15 downto 0);
    G_INIT_43 : std_logic_vector(15 downto 0);
    G_INIT_44 : std_logic_vector(15 downto 0);
    -- G_INIT_45: SYSMON analog bus register.
    G_INIT_45 : std_logic_vector(15 downto 0);
    -- G_INIT_46 - G_INIT_4F: SYSMON sequence registers.
    G_INIT_46 : std_logic_vector(15 downto 0);
    G_INIT_47 : std_logic_vector(15 downto 0);
    G_INIT_48 : std_logic_vector(15 downto 0);
    G_INIT_49 : std_logic_vector(15 downto 0);
    G_INIT_4A : std_logic_vector(15 downto 0);
    G_INIT_4B : std_logic_vector(15 downto 0);
    G_INIT_4C : std_logic_vector(15 downto 0);
    G_INIT_4D : std_logic_vector(15 downto 0);
    G_INIT_4E : std_logic_vector(15 downto 0);
    G_INIT_4F : std_logic_vector(15 downto 0);
    -- G_INIT_50 - G_INIT_5F: SYSMON alarm limit registers.
    G_INIT_50 : std_logic_vector(15 downto 0);
    G_INIT_51 : std_logic_vector(15 downto 0);
    G_INIT_52 : std_logic_vector(15 downto 0);
    G_INIT_53 : std_logic_vector(15 downto 0);
    G_INIT_54 : std_logic_vector(15 downto 0);
    G_INIT_55 : std_logic_vector(15 downto 0);
    G_INIT_56 : std_logic_vector(15 downto 0);
    G_INIT_57 : std_logic_vector(15 downto 0);
    G_INIT_58 : std_logic_vector(15 downto 0);
    G_INIT_59 : std_logic_vector(15 downto 0);
    G_INIT_5A : std_logic_vector(15 downto 0);
    G_INIT_5B : std_logic_vector(15 downto 0);
    G_INIT_5C : std_logic_vector(15 downto 0);
    G_INIT_5D : std_logic_vector(15 downto 0);
    G_INIT_5E : std_logic_vector(15 downto 0);
    G_INIT_5F : std_logic_vector(15 downto 0);
    -- G_INIT_60 - G_INIT_6F: SYSMON user supply alarms.
    G_INIT_60 : std_logic_vector(15 downto 0);
    G_INIT_61 : std_logic_vector(15 downto 0);
    G_INIT_62 : std_logic_vector(15 downto 0);
    G_INIT_63 : std_logic_vector(15 downto 0);
    G_INIT_64 : std_logic_vector(15 downto 0);
    G_INIT_65 : std_logic_vector(15 downto 0);
    G_INIT_66 : std_logic_vector(15 downto 0);
    G_INIT_67 : std_logic_vector(15 downto 0);
    G_INIT_68 : std_logic_vector(15 downto 0);
    G_INIT_69 : std_logic_vector(15 downto 0);
    G_INIT_6A : std_logic_vector(15 downto 0);
    G_INIT_6B : std_logic_vector(15 downto 0);
    G_INIT_6C : std_logic_vector(15 downto 0);
    G_INIT_6D : std_logic_vector(15 downto 0);
    G_INIT_6E : std_logic_vector(15 downto 0);
    G_INIT_6F : std_logic_vector(15 downto 0);
    -- SYSMON primitive attributes.
    G_COMMON_N_SOURCE       : std_logic_vector(15 downto 0);
    G_IS_CONVSTCLK_INVERTED : bit;
    G_IS_DCLK_INVERTED      : bit;
    -- SYSMON user voltage monitor attributes.
    G_SYSMON_VUSER0_BANK    : natural range 0 to 999;
    G_SYSMON_VUSER0_MONITOR : string;
    G_SYSMON_VUSER1_BANK    : natural range 0 to 999;
    G_SYSMON_VUSER1_MONITOR : string;
    G_SYSMON_VUSER2_BANK    : natural range 0 to 999;
    G_SYSMON_VUSER2_MONITOR : string;
    G_SYSMON_VUSER3_BANK    : natural range 0 to 999;
    G_SYSMON_VUSER3_MONITOR : string
  );
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- IPBus interface.
    ipb_in  : in ipb_wbus;
    ipb_out : out ipb_rbus;

    -- I2C interface.
    i2c_scl : inout std_logic;
    i2c_sda : inout std_logic;

    -- ADC activity signals.
    -- NOTE: These refer to the selected SYSMON.
    adc_busy    : out std_logic;
    adc_channel : out std_logic_vector(5 downto 0);
    adc_eoc     : out std_logic;
    adc_eos     : out std_logic;

    -- Summary alarm signal. This is the logical OR of all the ones
    -- below. (Technically: with the exception of the top over
    -- temperature alarm.)
    alarm_any : out std_logic;

    -- Over temperature alarm signals.
    -- NOTE: These are the logical ORs of all SYSMONs.
    alarm_over_temp : out std_logic;
    alarm_user_temp : out std_logic;

    -- Voltage monitoring alarm signals.
    -- NOTE: These are the logical ORs of all SYSMONs.
    alarm_vccint  : out std_logic;
    alarm_vccaux  : out std_logic;
    alarm_vccbram : out std_logic
  );
end ipbus_sysmon_usp;

architecture rtl of ipbus_sysmon_usp is

  -- Locations of alarm bits in the 'alm' bit field, according to
  -- UG580.
  constant C_BIT_NUM_USER_TEMP : natural := 0;
  constant C_BIT_NUM_VCCINT  : natural := 1;
  constant C_BIT_NUM_VCCAUX  : natural := 2;
  constant C_BIT_NUM_VCCBRAM : natural := 3;
  constant C_BIT_NUM_ANY : natural := 7;

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  signal ctrl : ipb_reg_v(0 downto 0);
  signal stat : ipb_reg_v(1 downto 0);

  signal sysmon_select : std_logic_vector(1 downto 0);

  signal drp_m2s : drp_wbus;
  signal drp_s2m : drp_rbus;

  signal drp_den  : std_logic_vector(G_NUM_SLRS - 1 downto 0);
  signal drp_drdy : std_logic_vector(G_NUM_SLRS - 1 downto 0);
  type drp_do_array is array (natural range <>) of std_logic_vector(15 downto 0);
  signal drp_do   : drp_do_array(G_NUM_SLRS - 1 downto 0);

  signal i2c_scl_l : std_logic;
  signal i2c_sda_l : std_logic;
  signal i2c_scl_tristate : std_logic;
  signal i2c_sda_tristate : std_logic;
  signal i2c_scl_ts : std_logic_vector(G_NUM_SLRS - 1 downto 0);
  signal i2c_sda_ts : std_logic_vector(G_NUM_SLRS - 1 downto 0);

  signal adc_busy_l : std_logic_vector(G_NUM_SLRS - 1 downto 0);
  subtype channel is std_logic_vector(5 downto 0);
  type channel_array is array (natural range <>) of channel;
  signal adc_channel_l : channel_array(G_NUM_SLRS - 1 downto 0);
  signal adc_eoc_l : std_logic_vector(G_NUM_SLRS - 1 downto 0);
  signal adc_eos_l : std_logic_vector(G_NUM_SLRS - 1 downto 0);

  subtype alarm is std_logic_vector(15 downto 0);
  type alarm_array is array (natural range <>) of alarm;
  signal alarms : alarm_array(G_NUM_SLRS - 1 downto 0);

  signal alarm_any_l : std_logic_vector(G_NUM_SLRS - 1 downto 0);
  signal alarm_over_temp_l : std_logic_vector(G_NUM_SLRS - 1 downto 0);
  signal alarm_user_temp_l : std_logic_vector(G_NUM_SLRS - 1 downto 0);
  signal alarm_vccint_l : std_logic_vector(G_NUM_SLRS - 1 downto 0);
  signal alarm_vccaux_l : std_logic_vector(G_NUM_SLRS - 1 downto 0);
  signal alarm_vccbram_l : std_logic_vector(G_NUM_SLRS - 1 downto 0);

  signal alarm_any_ored : std_logic;
  signal alarm_over_temp_ored : std_logic;
  signal alarm_user_temp_ored : std_logic;
  signal alarm_vccint_ored : std_logic;
  signal alarm_vccaux_ored : std_logic;
  signal alarm_vccbram_ored : std_logic;

begin

  -- IPBus address decoder.
  fabric : entity work.ipbus_fabric_sel
    generic map (
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
    )
    port map (
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_ipbus_sysmon_usp(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
    );

  -- Control and status registers.
  csr : entity work.ipbus_ctrlreg_v
    generic map (
      N_CTRL => ctrl'length,
      N_STAT => stat'length
    )
    port map (
      clk       => clk,
      reset     => rst,
      ipbus_in  => ipbw(N_SLV_CSR),
      ipbus_out => ipbr(N_SLV_CSR),
      q         => ctrl,
      d         => stat
    );

  -- Control signal to select the sysmon in the desired SLR.
  sysmon_select <= ctrl(0)(1 downto 0);

  -- Make the number of available SLRs accessible in a status
  -- register.
  stat(0)(1 downto 0) <= std_logic_vector(to_unsigned(G_NUM_SLRS, 2));

  -- Make all the alarms available.
  stat(1)(0) <= alarm_any_ored;
  stat(1)(1) <= alarm_over_temp_ored;
  stat(1)(2) <= alarm_user_temp_ored;
  stat(1)(3) <= alarm_vccint_ored;
  stat(1)(4) <= alarm_vccaux_ored;
  stat(1)(5) <= alarm_vccbram_ored;

  -- IPBus to DRP bridge for sysmons.
  drp : entity work.ipbus_drp_bridge
    port map (
      clk => clk,
      rst => rst,
      ipb_in  => ipbw(N_SLV_DRP),
      ipb_out => ipbr(N_SLV_DRP),
      drp_out => drp_m2s,
      drp_in  => drp_s2m
    );

  -- SYSMON number 0 will become (by careful placement constraints)
  -- the primary sysmon instance, located in the primary SLR. The
  -- other instances will cover the other SLRs.
  gen_sysmon : for i in 0 to G_NUM_SLRS - 1 generate

    sysmon_inst : SYSMONE4
      generic map (
        INIT_40 => G_INIT_40,
        INIT_41 => G_INIT_41,
        INIT_42 => G_INIT_42,
        INIT_43 => G_INIT_43,
        INIT_44 => G_INIT_44,
        INIT_45 => G_INIT_45,
        INIT_46 => G_INIT_46,
        INIT_47 => G_INIT_47,
        INIT_48 => G_INIT_48,
        INIT_49 => G_INIT_49,
        INIT_4A => G_INIT_4A,
        INIT_4B => G_INIT_4B,
        INIT_4C => G_INIT_4C,
        INIT_4D => G_INIT_4D,
        INIT_4E => G_INIT_4E,
        INIT_4F => G_INIT_4F,
        INIT_50 => G_INIT_50,
        INIT_51 => G_INIT_51,
        INIT_52 => G_INIT_52,
        INIT_53 => G_INIT_53,
        INIT_54 => G_INIT_54,
        INIT_55 => G_INIT_55,
        INIT_56 => G_INIT_56,
        INIT_57 => G_INIT_57,
        INIT_58 => G_INIT_58,
        INIT_59 => G_INIT_59,
        INIT_5A => G_INIT_5A,
        INIT_5B => G_INIT_5B,
        INIT_5C => G_INIT_5C,
        INIT_5D => G_INIT_5D,
        INIT_5E => G_INIT_5E,
        INIT_5F => G_INIT_5F,
        INIT_60 => G_INIT_60,
        INIT_61 => G_INIT_61,
        INIT_62 => G_INIT_62,
        INIT_63 => G_INIT_63,
        INIT_64 => G_INIT_64,
        INIT_65 => G_INIT_65,
        INIT_66 => G_INIT_66,
        INIT_67 => G_INIT_67,
        INIT_68 => G_INIT_68,
        INIT_69 => G_INIT_69,
        INIT_6A => G_INIT_6A,
        INIT_6B => G_INIT_6B,
        INIT_6C => G_INIT_6C,
        INIT_6D => G_INIT_6D,
        INIT_6E => G_INIT_6E,
        INIT_6F => G_INIT_6F,
        COMMON_N_SOURCE       => G_COMMON_N_SOURCE,
        IS_CONVSTCLK_INVERTED => G_IS_CONVSTCLK_INVERTED,
        IS_DCLK_INVERTED      => G_IS_DCLK_INVERTED,
        SYSMON_VUSER0_BANK    => G_SYSMON_VUSER0_BANK,
        SYSMON_VUSER0_MONITOR => G_SYSMON_VUSER0_MONITOR,
        SYSMON_VUSER1_BANK    => G_SYSMON_VUSER1_BANK,
        SYSMON_VUSER1_MONITOR => G_SYSMON_VUSER1_MONITOR,
        SYSMON_VUSER2_BANK    => G_SYSMON_VUSER2_BANK,
        SYSMON_VUSER2_MONITOR => G_SYSMON_VUSER2_MONITOR,
        SYSMON_VUSER3_BANK    => G_SYSMON_VUSER3_BANK,
        SYSMON_VUSER3_MONITOR => G_SYSMON_VUSER3_MONITOR
      )
      port map (
        -- DRP interface.
        dclk  => clk,
        daddr => drp_m2s.addr(7 downto 0),
        di    => drp_m2s.data,
        dwe   => drp_m2s.we,
        den   => drp_den(i),
        drdy  => drp_drdy(i),
        do    => drp_do(i),

        -- Reset and conversion control.
        reset     => rst,
        convst    => '0',
        convstclk => '0',

        -- External analog inputs (disabled).
        vp => '0',
        vn => '0',
        vauxp => X"0000",
        vauxn => X"0000",

        -- I2C interface.
        i2c_sclk    => i2c_scl_l,
        i2c_sda     => i2c_sda_l,
        i2c_sclk_ts => i2c_scl_ts(i),
        i2c_sda_ts  => i2c_sda_ts(i),

        -- ADC signals.
        busy    => adc_busy_l(i),
        channel => adc_channel_l(i),
        eoc     => adc_eoc_l(i),
        eos     => adc_eos_l(i),

        -- Alarms.
        ot  => alarm_over_temp_l(i),
        alm => alarms(i)
      );

  end generate;

  -- I2C I/O buffers.
  iobuf_i2c_scl : iobuf
    port map (
      io => i2c_scl,
      i  => '0',
      o  => i2c_scl_l,
      t  => i2c_scl_tristate
    );
  iobuf_i2c_sda : iobuf
    port map (
      io => i2c_sda,
      i  => '0',
      o  => i2c_sda_l,
      t  => i2c_sda_tristate
    );

  -- I2C tristating signals.
  i2c_scl_tristate <= and_reduce(i2c_scl_ts);
  i2c_sda_tristate <= and_reduce(i2c_sda_ts);

  -- DRP muxing.
  gen_drp_den : for i in 0 to G_NUM_SLRS - 1 generate

    drp_den(i) <=
      drp_m2s.en when sysmon_select = std_logic_vector(to_unsigned(i, 2))
      else '0';

  end generate;

  drp_s2m.rdy  <= or_reduce(drp_drdy);
  drp_s2m.data <= drp_do(to_integer(unsigned(sysmon_select)));

  -- ADC signals.
  adc_busy    <= adc_busy_l(to_integer(unsigned(sysmon_select)));
  adc_channel <= adc_channel_l(to_integer(unsigned(sysmon_select)));
  adc_eoc     <= adc_eoc_l(to_integer(unsigned(sysmon_select)));
  adc_eos     <= adc_eos_l(to_integer(unsigned(sysmon_select)));

  -- Alarms.
  gen_alarms : for i in 0 to G_NUM_SLRS - 1 generate
    alarm_any_l(i) <= alarms(i)(C_BIT_NUM_ANY);
    alarm_user_temp_l(i) <= alarms(i)(C_BIT_NUM_USER_TEMP);
    alarm_vccint_l(i)  <= alarms(i)(C_BIT_NUM_VCCINT);
    alarm_vccaux_l(i)  <= alarms(i)(C_BIT_NUM_VCCAUX);
    alarm_vccbram_l(i) <= alarms(i)(C_BIT_NUM_VCCBRAM);
  end generate;

  alarm_any_ored <= or_reduce(alarm_any_l);
  alarm_over_temp_ored <= or_reduce(alarm_over_temp_l);
  alarm_user_temp_ored <= or_reduce(alarm_user_temp_l);
  alarm_vccint_ored  <= or_reduce(alarm_vccint_l);
  alarm_vccaux_ored  <= or_reduce(alarm_vccaux_l);
  alarm_vccbram_ored <= or_reduce(alarm_vccbram_l);

  alarm_any <= alarm_any_ored;
  alarm_over_temp <= alarm_over_temp_ored;
  alarm_user_temp <= alarm_user_temp_ored;
  alarm_vccint  <= alarm_vccint_ored;
  alarm_vccaux  <= alarm_vccaux_ored;
  alarm_vccbram <= alarm_vccbram_ored;

end rtl;
