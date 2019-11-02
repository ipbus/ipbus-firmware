--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Sat Nov  2 15:49:28 2019
--Host        : heplnw017.pp.rl.ac.uk running 64-bit CentOS Linux release 7.7.1908 (Core)
--Command     : generate_target c2c_s_ipb_wrapper.bd
--Design      : c2c_s_ipb_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity c2c_s_ipb_wrapper is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    c2c_stat_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
    gt_clk_clk_n : in STD_LOGIC;
    gt_clk_clk_p : in STD_LOGIC;
    gt_i_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    gt_i_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    gt_o_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    gt_o_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    gtx_stat_o : out STD_LOGIC_VECTOR ( 4 downto 0 );
    ipb_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ipb_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ipb_axi_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ipb_axi_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ipb_axi_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_arregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ipb_axi_arvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ipb_axi_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ipb_axi_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ipb_axi_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ipb_axi_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_awregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ipb_axi_awvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_bready : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ipb_axi_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    ipb_axi_rlast : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_rready : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ipb_axi_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_wdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    ipb_axi_wlast : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_wstrb : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ipb_axi_wvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_clk_o : out STD_LOGIC;
    ipb_ic_rst_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_periph_rst_o : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
end c2c_s_ipb_wrapper;

architecture STRUCTURE of c2c_s_ipb_wrapper is
  component c2c_s_ipb is
  port (
    gt_o_txn : out STD_LOGIC_VECTOR ( 0 to 0 );
    gt_o_txp : out STD_LOGIC_VECTOR ( 0 to 0 );
    gt_i_rxn : in STD_LOGIC_VECTOR ( 0 to 0 );
    gt_i_rxp : in STD_LOGIC_VECTOR ( 0 to 0 );
    gt_clk_clk_n : in STD_LOGIC;
    gt_clk_clk_p : in STD_LOGIC;
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    ipb_clk_o : out STD_LOGIC;
    ipb_ic_rst_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_periph_rst_o : out STD_LOGIC_VECTOR ( 0 to 0 );
    gtx_stat_o : out STD_LOGIC_VECTOR ( 4 downto 0 );
    c2c_stat_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ipb_axi_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ipb_axi_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ipb_axi_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ipb_axi_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ipb_axi_awlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ipb_axi_awregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_awqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_awvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_awready : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_wdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    ipb_axi_wstrb : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ipb_axi_wlast : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_wvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_wready : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ipb_axi_bvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_bready : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ipb_axi_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ipb_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ipb_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ipb_axi_arlock : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ipb_axi_arregion : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_arqos : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ipb_axi_arvalid : out STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_arready : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
    ipb_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ipb_axi_rlast : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_rvalid : in STD_LOGIC_VECTOR ( 0 to 0 );
    ipb_axi_rready : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component c2c_s_ipb;
begin
c2c_s_ipb_i: component c2c_s_ipb
     port map (
      aclk => aclk,
      aresetn => aresetn,
      c2c_stat_o(2 downto 0) => c2c_stat_o(2 downto 0),
      gt_clk_clk_n => gt_clk_clk_n,
      gt_clk_clk_p => gt_clk_clk_p,
      gt_i_rxn(0) => gt_i_rxn(0),
      gt_i_rxp(0) => gt_i_rxp(0),
      gt_o_txn(0) => gt_o_txn(0),
      gt_o_txp(0) => gt_o_txp(0),
      gtx_stat_o(4 downto 0) => gtx_stat_o(4 downto 0),
      ipb_axi_araddr(31 downto 0) => ipb_axi_araddr(31 downto 0),
      ipb_axi_arburst(1 downto 0) => ipb_axi_arburst(1 downto 0),
      ipb_axi_arcache(3 downto 0) => ipb_axi_arcache(3 downto 0),
      ipb_axi_arlen(7 downto 0) => ipb_axi_arlen(7 downto 0),
      ipb_axi_arlock(0) => ipb_axi_arlock(0),
      ipb_axi_arprot(2 downto 0) => ipb_axi_arprot(2 downto 0),
      ipb_axi_arqos(3 downto 0) => ipb_axi_arqos(3 downto 0),
      ipb_axi_arready(0) => ipb_axi_arready(0),
      ipb_axi_arregion(3 downto 0) => ipb_axi_arregion(3 downto 0),
      ipb_axi_arsize(2 downto 0) => ipb_axi_arsize(2 downto 0),
      ipb_axi_arvalid(0) => ipb_axi_arvalid(0),
      ipb_axi_awaddr(31 downto 0) => ipb_axi_awaddr(31 downto 0),
      ipb_axi_awburst(1 downto 0) => ipb_axi_awburst(1 downto 0),
      ipb_axi_awcache(3 downto 0) => ipb_axi_awcache(3 downto 0),
      ipb_axi_awlen(7 downto 0) => ipb_axi_awlen(7 downto 0),
      ipb_axi_awlock(0) => ipb_axi_awlock(0),
      ipb_axi_awprot(2 downto 0) => ipb_axi_awprot(2 downto 0),
      ipb_axi_awqos(3 downto 0) => ipb_axi_awqos(3 downto 0),
      ipb_axi_awready(0) => ipb_axi_awready(0),
      ipb_axi_awregion(3 downto 0) => ipb_axi_awregion(3 downto 0),
      ipb_axi_awsize(2 downto 0) => ipb_axi_awsize(2 downto 0),
      ipb_axi_awvalid(0) => ipb_axi_awvalid(0),
      ipb_axi_bready(0) => ipb_axi_bready(0),
      ipb_axi_bresp(1 downto 0) => ipb_axi_bresp(1 downto 0),
      ipb_axi_bvalid(0) => ipb_axi_bvalid(0),
      ipb_axi_rdata(63 downto 0) => ipb_axi_rdata(63 downto 0),
      ipb_axi_rlast(0) => ipb_axi_rlast(0),
      ipb_axi_rready(0) => ipb_axi_rready(0),
      ipb_axi_rresp(1 downto 0) => ipb_axi_rresp(1 downto 0),
      ipb_axi_rvalid(0) => ipb_axi_rvalid(0),
      ipb_axi_wdata(63 downto 0) => ipb_axi_wdata(63 downto 0),
      ipb_axi_wlast(0) => ipb_axi_wlast(0),
      ipb_axi_wready(0) => ipb_axi_wready(0),
      ipb_axi_wstrb(7 downto 0) => ipb_axi_wstrb(7 downto 0),
      ipb_axi_wvalid(0) => ipb_axi_wvalid(0),
      ipb_clk_o => ipb_clk_o,
      ipb_ic_rst_o(0) => ipb_ic_rst_o(0),
      ipb_periph_rst_o(0) => ipb_periph_rst_o(0)
    );
end STRUCTURE;
