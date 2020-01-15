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

entity payload is
  port(
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

  -- Yeah.... Not pretty, but it makes it easier to create
  -- a simple piece of example code.
  signal nuke_i : std_logic;
  signal soft_rst_i : std_logic;

  attribute keep : string;
  attribute keep of nuke_i : signal is "true";
  attribute keep of soft_rst_i : signal is "true";

begin

  example : entity work.ipbus_sysmon_x7
    port map (
      clk     => ipb_clk,
      rst     => ipb_rst,
      ipb_in  => ipb_in,
      ipb_out => ipb_out
    );

  nuke_i     <= '0';
  nuke       <= nuke_i;
  soft_rst_i <= '0';
  soft_rst   <= soft_rst_i;
  userled    <= '0';

end rtl;
