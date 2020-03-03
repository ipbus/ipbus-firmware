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


-- Jeroen Hegeman, December 2019

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;
use work.ipbus_reg_types.all;
use work.ipbus_decode_ipbus_example_xilinx_x7.all;

entity payload is
  port (
    ipb_clk : in std_logic;
    ipb_rst : in std_logic;
    ipb_in : in ipb_wbus;
    ipb_out : out ipb_rbus;
    clk : in std_logic;
    rst : in std_logic;
    nuke : out std_logic;
    soft_rst : out std_logic;
    userled : out std_logic
  );

end payload;

architecture rtl of payload is

  signal ipbw : ipb_wbus_array(N_SLAVES - 1 downto 0);
  signal ipbr : ipb_rbus_array(N_SLAVES - 1 downto 0);

  -- Yeah.... Not pretty, but it makes it easier to create
  -- a simple piece of example code.
  signal nuke_i : std_logic;
  signal soft_rst_i : std_logic;

  attribute keep : string;
  attribute keep of nuke_i : signal is "true";
  attribute keep of soft_rst_i : signal is "true";

begin

  fabric : entity work.ipbus_fabric_sel
    generic map (
      NSLV      => N_SLAVES,
      SEL_WIDTH => IPBUS_SEL_WIDTH
    )
    port map (
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      sel             => ipbus_sel_ipbus_example_xilinx_x7(ipb_in.ipb_addr),
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
    );

  sysmon : entity work.ipbus_sysmon_x7
    port map (
      clk     => ipb_clk,
      rst     => ipb_rst,
      ipb_in  => ipbw(N_SLV_SYSMON),
      ipb_out => ipbr(N_SLV_SYSMON)
    );

  icap : entity work.ipbus_icap_x7
    port map (
      clk     => ipb_clk,
      rst     => ipb_rst,
      ipb_in  => ipbw(N_SLV_ICAP),
      ipb_out => ipbr(N_SLV_ICAP)
    );

 iprog : entity work.ipbus_iprog_x7
   port map (
     clk     => ipb_clk,
     rst     => ipb_rst,
     ipb_in  => ipbw(N_SLV_IPROG),
     ipb_out => ipbr(N_SLV_IPROG)
   );

  nuke_i     <= '0';
  nuke       <= nuke_i;
  soft_rst_i <= '0';
  soft_rst   <= soft_rst_i;
  userled    <= '0';

end rtl;
