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

  signal m_axi_awready_gpio : std_logic;
  signal m_axi_awvalid_gpio : std_logic;
  signal m_axi_awaddr_gpio  : std_logic_vector(31 downto 0);
  signal m_axi_wready_gpio  : std_logic;
  signal m_axi_wvalid_gpio  : std_logic;
  signal m_axi_wdata_gpio   : std_logic_vector(31 downto 0);
  signal m_axi_wstrb_gpio   : std_logic_vector(3 downto 0);
  signal m_axi_bready_gpio  : std_logic;
  signal m_axi_bvalid_gpio  : std_logic;
  signal m_axi_bresp_gpio   : std_logic_vector(1 downto 0);
  signal s_axi_arready_gpio : std_logic;
  signal s_axi_arvalid_gpio : std_logic;
  signal s_axi_araddr_gpio  : std_logic_vector(31 downto 0);
  signal s_axi_rready_gpio  : std_logic;
  signal s_axi_rvalid_gpio  : std_logic;
  signal s_axi_rdata_gpio   : std_logic_vector(31 downto 0);
  signal s_axi_rresp_gpio   : std_logic_vector(1 downto 0);

  signal axi_stat_gpio           : ipb_reg_v(0 downto 0);
  signal axi_traffic_done_gpio   : std_logic;
  signal axi_traffic_status_gpio : std_logic_vector(31 downto 0);
  signal axi_bridged_data_gpio   : std_logic_vector(31 downto 0);

  signal m_axi_awready_mem32 : std_logic;
  signal m_axi_awvalid_mem32 : std_logic;
  signal m_axi_awaddr_mem32  : std_logic_vector(31 downto 0);
  signal m_axi_wready_mem32  : std_logic;
  signal m_axi_wvalid_mem32  : std_logic;
  signal m_axi_wdata_mem32   : std_logic_vector(31 downto 0);
  signal m_axi_wstrb_mem32   : std_logic_vector(3 downto 0);
  signal m_axi_bready_mem32  : std_logic;
  signal m_axi_bvalid_mem32  : std_logic;
  signal m_axi_bresp_mem32   : std_logic_vector(1 downto 0);
  signal s_axi_arready_mem32 : std_logic;
  signal s_axi_arvalid_mem32 : std_logic;
  signal s_axi_araddr_mem32  : std_logic_vector(31 downto 0);
  signal s_axi_rready_mem32  : std_logic;
  signal s_axi_rvalid_mem32  : std_logic;
  signal s_axi_rdata_mem32   : std_logic_vector(31 downto 0);
  signal s_axi_rresp_mem32   : std_logic_vector(1 downto 0);

  signal m_axi_awready_mem64 : std_logic;
  signal m_axi_awvalid_mem64 : std_logic;
  signal m_axi_awaddr_mem64  : std_logic_vector(31 downto 0);
  signal m_axi_wready_mem64  : std_logic;
  signal m_axi_wvalid_mem64  : std_logic;
  signal m_axi_wdata_mem64   : std_logic_vector(63 downto 0);
  signal m_axi_wstrb_mem64   : std_logic_vector(7 downto 0);
  signal m_axi_bready_mem64  : std_logic;
  signal m_axi_bvalid_mem64  : std_logic;
  signal m_axi_bresp_mem64   : std_logic_vector(1 downto 0);
  signal s_axi_arready_mem64 : std_logic;
  signal s_axi_arvalid_mem64 : std_logic;
  signal s_axi_araddr_mem64  : std_logic_vector(31 downto 0);
  signal s_axi_rready_mem64  : std_logic;
  signal s_axi_rvalid_mem64  : std_logic;
  signal s_axi_rdata_mem64   : std_logic_vector(63 downto 0);
  signal s_axi_rresp_mem64   : std_logic_vector(1 downto 0);

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

  --==========

  sysmon : entity work.ipbus_sysmon_x7
    port map (
      clk     => ipb_clk,
      rst     => ipb_rst,
      ipb_in  => ipbw(N_SLV_SYSMON),
      ipb_out => ipbr(N_SLV_SYSMON)
    );

  --==========

  icap : entity work.ipbus_icap_x7
    port map (
      clk     => ipb_clk,
      rst     => ipb_rst,
      ipb_in  => ipbw(N_SLV_ICAP),
      ipb_out => ipbr(N_SLV_ICAP)
    );

  --==========

  iprog : entity work.ipbus_iprog_x7
    port map (
      clk     => ipb_clk,
      rst     => ipb_rst,
      ipb_in  => ipbw(N_SLV_IPROG),
      ipb_out => ipbr(N_SLV_IPROG)
    );

  --==========

  -- First AXI4Lite bridge example. Bridges into nowhere, really. Uses
  -- an AXI GPIO as endpoint, and an IPBus register to read back the
  -- data from the GPIO.

  axi_bridge_gpio : entity work.ipbus_axi4lite_master
    port map (
      clk     => ipb_clk,
      rst     => ipb_rst,
      ipb_in  => ipbw(N_SLV_AXI4LITE_GPIO),
      ipb_out => ipbr(N_SLV_AXI4LITE_GPIO),

      m_axi_clock   => ipb_clk,
      m_axi_awaddr  => m_axi_awaddr_gpio,
      m_axi_awvalid => m_axi_awvalid_gpio,
      m_axi_awready => m_axi_awready_gpio,
      m_axi_wdata   => m_axi_wdata_gpio,
      m_axi_wstrb   => m_axi_wstrb_gpio,
      m_axi_wvalid  => m_axi_wvalid_gpio,
      m_axi_wready  => m_axi_wready_gpio,
      m_axi_bresp   => m_axi_bresp_gpio,
      m_axi_bvalid  => m_axi_bvalid_gpio,
      m_axi_bready  => m_axi_bready_gpio,
      m_axi_araddr  => s_axi_araddr_gpio,
      m_axi_arvalid => s_axi_arvalid_gpio,
      m_axi_arready => s_axi_arready_gpio,
      m_axi_rdata   => s_axi_rdata_gpio,
      m_axi_rvalid  => s_axi_rvalid_gpio,
      m_axi_rready  => s_axi_rready_gpio,
      m_axi_rresp   => s_axi_rresp_gpio
    );

  -- We (ab)use an AXI GPIO interface to extract the results of our
  -- AXI transaction in the form of a register for verification.
  axi_gpio : entity work.axi_gpio_example
    port map (
      s_axi_aclk    => ipb_clk,
      s_axi_aresetn => not ipb_rst,
      s_axi_awaddr  => m_axi_awaddr_gpio(8 downto 0),
      s_axi_awvalid => m_axi_awvalid_gpio,
      s_axi_awready => m_axi_awready_gpio,
      s_axi_wdata   => m_axi_wdata_gpio,
      s_axi_wstrb   => m_axi_wstrb_gpio,
      s_axi_wvalid  => m_axi_wvalid_gpio,
      s_axi_wready  => m_axi_wready_gpio,
      s_axi_bresp   => m_axi_bresp_gpio,
      s_axi_bvalid  => m_axi_bvalid_gpio,
      s_axi_bready  => m_axi_bready_gpio,
      s_axi_araddr  => s_axi_araddr_gpio(8 downto 0),
      s_axi_arvalid => s_axi_arvalid_gpio,
      s_axi_arready => s_axi_arready_gpio,
      s_axi_rdata   => s_axi_rdata_gpio,
      s_axi_rresp   => s_axi_rresp_gpio,
      s_axi_rvalid  => s_axi_rvalid_gpio,
      s_axi_rready  => s_axi_rready_gpio,
      gpio_io_o     => axi_bridged_data_gpio
    );

  axi_gpio_readback_register : entity work.ipbus_ctrlreg_v
    generic map (
      N_CTRL => 0,
      N_STAT => 1
    )
    port map (
      clk   => ipb_clk,
      reset => ipb_rst,
      ipbus_in  => ipbw(N_SLV_AXI4LITE_GPIO_READBACK_REG),
      ipbus_out => ipbr(N_SLV_AXI4LITE_GPIO_READBACK_REG),
      d => axi_stat_gpio,
      q => open
    );

  axi_stat_gpio(0) <= axi_bridged_data_gpio;

  --==========

  -- Second AXI4Lite bridge example. Bridges into a dual-port block
  -- RAM of 32 bits wide.

  axi_bridge_mem32 : entity work.ipbus_axi4lite_master
    generic map (
      NUM_BYTES_PER_AXI_WORD => 4
    )
    port map (
      clk     => ipb_clk,
      rst     => ipb_rst,
      ipb_in  => ipbw(N_SLV_AXI4LITE_MEM_32BIT),
      ipb_out => ipbr(N_SLV_AXI4LITE_MEM_32BIT),

      m_axi_clock   => ipb_clk,
      m_axi_awaddr  => m_axi_awaddr_mem32,
      m_axi_awvalid => m_axi_awvalid_mem32,
      m_axi_awready => m_axi_awready_mem32,
      m_axi_wdata   => m_axi_wdata_mem32,
      m_axi_wstrb   => m_axi_wstrb_mem32,
      m_axi_wvalid  => m_axi_wvalid_mem32,
      m_axi_wready  => m_axi_wready_mem32,
      m_axi_bresp   => m_axi_bresp_mem32,
      m_axi_bvalid  => m_axi_bvalid_mem32,
      m_axi_bready  => m_axi_bready_mem32,
      m_axi_araddr  => s_axi_araddr_mem32,
      m_axi_arvalid => s_axi_arvalid_mem32,
      m_axi_arready => s_axi_arready_mem32,
      m_axi_rdata   => s_axi_rdata_mem32,
      m_axi_rvalid  => s_axi_rvalid_mem32,
      m_axi_rready  => s_axi_rready_mem32,
      m_axi_rresp   => s_axi_rresp_mem32
    );

  axi_mem32 : entity work.axi_mem_example_32bit
    port map (
      s_aclk        => ipb_clk,
      s_aresetn     => not ipb_rst,
      s_axi_awaddr  => m_axi_awaddr_mem32,
      s_axi_awvalid => m_axi_awvalid_mem32,
      s_axi_awready => m_axi_awready_mem32,
      s_axi_wdata   => m_axi_wdata_mem32,
      s_axi_wstrb   => m_axi_wstrb_mem32,
      s_axi_wvalid  => m_axi_wvalid_mem32,
      s_axi_wready  => m_axi_wready_mem32,
      s_axi_bresp   => m_axi_bresp_mem32,
      s_axi_bvalid  => m_axi_bvalid_mem32,
      s_axi_bready  => m_axi_bready_mem32,
      s_axi_araddr  => s_axi_araddr_mem32,
      s_axi_arvalid => s_axi_arvalid_mem32,
      s_axi_arready => s_axi_arready_mem32,
      s_axi_rdata   => s_axi_rdata_mem32,
      s_axi_rresp   => s_axi_rresp_mem32,
      s_axi_rvalid  => s_axi_rvalid_mem32,
      s_axi_rready  => s_axi_rready_mem32,
      rsta_busy     => open,
      rstb_busy     => open
    );

  --==========

  -- Third AXI4Lite bridge example. Bridges into a dual-port block RAM
  -- of 64 bits wide (i.e., wider than an IPBus word).

  axi_bridge_mem64 : entity work.ipbus_axi4lite_master
    generic map (
      NUM_BYTES_PER_AXI_WORD => 8
    )
    port map (
      clk     => ipb_clk,
      rst     => ipb_rst,
      ipb_in  => ipbw(N_SLV_AXI4LITE_MEM_64BIT),
      ipb_out => ipbr(N_SLV_AXI4LITE_MEM_64BIT),

      m_axi_clock   => ipb_clk,
      m_axi_awaddr  => m_axi_awaddr_mem64,
      m_axi_awvalid => m_axi_awvalid_mem64,
      m_axi_awready => m_axi_awready_mem64,
      m_axi_wdata   => m_axi_wdata_mem64,
      m_axi_wstrb   => m_axi_wstrb_mem64,
      m_axi_wvalid  => m_axi_wvalid_mem64,
      m_axi_wready  => m_axi_wready_mem64,
      m_axi_bresp   => m_axi_bresp_mem64,
      m_axi_bvalid  => m_axi_bvalid_mem64,
      m_axi_bready  => m_axi_bready_mem64,
      m_axi_araddr  => s_axi_araddr_mem64,
      m_axi_arvalid => s_axi_arvalid_mem64,
      m_axi_arready => s_axi_arready_mem64,
      m_axi_rdata   => s_axi_rdata_mem64,
      m_axi_rvalid  => s_axi_rvalid_mem64,
      m_axi_rready  => s_axi_rready_mem64,
      m_axi_rresp   => s_axi_rresp_mem64
    );

  axi_mem64 : entity work.axi_mem_example_64bit
    port map (
      s_aclk        => ipb_clk,
      s_aresetn     => not ipb_rst,
      s_axi_awaddr  => m_axi_awaddr_mem64,
      s_axi_awvalid => m_axi_awvalid_mem64,
      s_axi_awready => m_axi_awready_mem64,
      s_axi_wdata   => m_axi_wdata_mem64,
      s_axi_wstrb   => m_axi_wstrb_mem64,
      s_axi_wvalid  => m_axi_wvalid_mem64,
      s_axi_wready  => m_axi_wready_mem64,
      s_axi_bresp   => m_axi_bresp_mem64,
      s_axi_bvalid  => m_axi_bvalid_mem64,
      s_axi_bready  => m_axi_bready_mem64,
      s_axi_araddr  => s_axi_araddr_mem64,
      s_axi_arvalid => s_axi_arvalid_mem64,
      s_axi_arready => s_axi_arready_mem64,
      s_axi_rdata   => s_axi_rdata_mem64,
      s_axi_rresp   => s_axi_rresp_mem64,
      s_axi_rvalid  => s_axi_rvalid_mem64,
      s_axi_rready  => s_axi_rready_mem64,
      rsta_busy     => open,
      rstb_busy     => open
    );

  --==========

  nuke       <= '0';
  soft_rst   <= '0';
  userled    <= '0';

end rtl;
