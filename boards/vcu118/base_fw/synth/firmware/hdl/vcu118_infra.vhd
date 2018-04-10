-- vcu118_infra: Clocks & control I/O module for HTG K800 (KU115 framework firmware)
--
-- Raghunandan Shukla (TIFR), Kristian Harder (RAL), Tom Williams (RAL)
-- based on code from Dave Newbold

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_trans_decl.all;
use work.ipbus_axi_decl.all;

library UNISIM;
use UNISIM.VComponents.all;


entity vcu118_infra is
  port (
      -- PCIe clock and reset (active low)
      pcie_sys_clk_p : in std_logic;
      pcie_sys_clk_n : in std_logic;
      pcie_sys_rst_n : in std_logic;
      -- PCIe lanes
      pcie_rx_p : in std_logic_vector(0 downto 0);
      pcie_rx_n : in std_logic_vector(0 downto 0);
      pcie_tx_p : out std_logic_vector(0 downto 0);
      pcie_tx_n : out std_logic_vector(0 downto 0);
      -- IPbus clock and reset
      ipb_clk : out std_logic;
      ipb_rst : out std_logic;
      -- The signals of doom and lesser doom
      nuke: in std_logic;
      soft_rst: in std_logic;
      -- status LEDs
      leds: out std_logic_vector(1 downto 0);
      -- IPbus (from / to slaves)
      ipb_in  : in ipb_rbus;
      ipb_out : out ipb_wbus
  );
end vcu118_infra;


architecture rtl of vcu118_infra is

  signal clk_ipb, clk_ipb_i : std_logic;
  signal locked, clk_locked, pcie_user_lnk_up, rst125, rst_ipb, rst_ipb_ctrl, rst_axi, onehz : std_logic;

  signal pcie_sys_rst_n_i : std_logic;

  signal axi_ms: axi4mm_ms(araddr(12 downto 0), awaddr(12 downto 0), wdata(63 downto 0));
  signal axi_sm: axi4mm_sm(rdata(63 downto 0));

  signal ipb_pkt_done : std_logic;
  signal trans_in : ipbus_trans_in;
  signal trans_out : ipbus_trans_out;

begin

  sys_rst_n_ibuf: IBUF
    port map (
      O => pcie_sys_rst_n_i,
      I => pcie_sys_rst_n
    );


  --  DCM clock generation for internal bus, ethernet
  -- TODO : Replace use of AXI clock here with external oscillator
  clocks: entity work.clocks_usp_serdes
    port map(
      clki_fr => axi_ms.aclk,
      clki_125 => axi_ms.aclk,
      clko_ipb => clk_ipb_i,
      eth_locked => pcie_user_lnk_up,
      locked => clk_locked,
      nuke => nuke,
      soft_rst => soft_rst,
      rsto_125 => rst125,
      rsto_ipb => rst_ipb,
      rsto_eth => rst_axi,
      rsto_ipb_ctrl => rst_ipb_ctrl,
      onehz => onehz
    );

  clk_ipb <= clk_ipb_i;
  ipb_clk <= clk_ipb_i;
  ipb_rst <= rst_ipb;

  locked <= clk_locked and pcie_user_lnk_up;

  -- TODO: Add equivalent of 'stretched' "pkt" signal from ku105 design
  leds <= '0' & (locked and onehz);


  dma: entity work.pcie_xdma_axi_usp_if
    port map (
      pcie_sys_clk_p => pcie_sys_clk_p,
      pcie_sys_clk_n => pcie_sys_clk_n,
      pcie_sys_rst_n => pcie_sys_rst_n_i,

      pcie_tx_p => pcie_tx_p,
      pcie_tx_n => pcie_tx_n,
      pcie_rx_p => pcie_rx_p,
      pcie_rx_n => pcie_rx_n,

      pcie_user_lnk_up => pcie_user_lnk_up,

      axi_ms => axi_ms,
      axi_sm => axi_sm,

      pcie_int_event0 => ipb_pkt_done
    );


  ipbus_transport_axi: entity work.ipbus_transport_axi_if
    port map (
      ipb_clk => clk_ipb,
      rst_ipb => rst_ipb_ctrl,
      axi_in => axi_ms,
      axi_out => axi_sm,

      pkt_done => ipb_pkt_done,

      ipb_trans_rx => trans_in,
      ipb_trans_tx => trans_out
    );


  ipbus_transactor: entity work.transactor
    port map (
      clk => clk_ipb,
      rst => rst_ipb_ctrl,
      ipb_out => ipb_out,
      ipb_in => ipb_in,
      ipb_req => open,
      ipb_grant => '1',
      trans_in => trans_in,
      trans_out => trans_out,
      cfg_vector_in => (Others => '0'),
      cfg_vector_out => open
    );

end rtl;
