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

-- Interface to the Ultrascale system monitor

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.drp_decl.all;

use work.ipbus_decode_ipbus_sysmon_us.all;

entity ipbus_sysmon_us is
  generic (
    -- FPGAs in the UltraScale and UltraScale+ families can contain up
    -- to four SLRs.
    G_NUM_SLRS : positive range 1 to 4
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    ipb_in  : in ipb_wbus;
    ipb_out : out ipb_rbus;
    i2c_scl : inout std_logic;
    i2c_sda : inout std_logic
  );
end ipbus_sysmon_us;

architecture rtl of ipbus_sysmon_us is

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
      sel             => ipbus_sel_ipbus_sysmon_us(ipb_in.ipb_addr),
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

    sysmon_inst : SYSMONE1
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
        i2c_sda_ts  => i2c_sda_ts(i)
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

  -- DRP mux.
  gen_drp_den : for i in 0 to G_NUM_SLRS - 1 generate

    drp_den(i) <=
      drp_m2s.en when sysmon_select = std_logic_vector(to_unsigned(i, 2))
      else '0';

  end generate;

  drp_s2m.rdy  <= or_reduce(drp_drdy);
  drp_s2m.data <= drp_do(to_integer(unsigned(sysmon_select)));

end rtl;
