library ieee;
use ieee.std_logic_1164.all;
use work.ipbus_axi_decl.all;

entity axi_ic_top is
  port (
  pcie_axi_ms  : in  axi4mm_ms(araddr(63 downto 0), awaddr(63 downto 0), wdata(63 downto 0));
  pcie_axi_sm  : out axi4mm_sm(rdata (63 downto 0));
  --
  algo_axi_ms  : out axi4mm_ms(araddr(63 downto 0), awaddr(63 downto 0), wdata(63 downto 0));
  algo_axi_sm  : in  axi4mm_sm(rdata (63 downto 0));
  ipb_axi_ms   : out axi4mm_ms(araddr(63 downto 0), awaddr(63 downto 0), wdata(63 downto 0));
  ipb_axi_sm   : in  axi4mm_sm(rdata (63 downto 0))
  );
end axi_ic_top;

architecture structure of axi_ic_top is
  component axi_ic is
  port (
    pcie_axi_aclk : in std_logic;
    pcie_axi_aresetn : in std_logic;
    pcie_axi_awaddr : in std_logic_vector ( 63 downto 0 );
    pcie_axi_awlen : in std_logic_vector ( 7 downto 0 );
    pcie_axi_awsize : in std_logic_vector ( 2 downto 0 );
    pcie_axi_awburst : in std_logic_vector ( 1 downto 0 );
    pcie_axi_awlock : in std_logic_vector ( 0 to 0 );
    pcie_axi_awcache : in std_logic_vector ( 3 downto 0 );
    pcie_axi_awprot : in std_logic_vector ( 2 downto 0 );
    pcie_axi_awvalid : in std_logic_vector ( 0 to 0 );
    pcie_axi_awready : out std_logic_vector ( 0 to 0 );
    pcie_axi_wdata : in std_logic_vector ( 63 downto 0 );
    pcie_axi_wstrb : in std_logic_vector ( 7 downto 0 );
    pcie_axi_wlast : in std_logic_vector ( 0 to 0 );
    pcie_axi_wvalid : in std_logic_vector ( 0 to 0 );
    pcie_axi_wready : out std_logic_vector ( 0 to 0 );
    pcie_axi_bresp : out std_logic_vector ( 1 downto 0 );
    pcie_axi_bvalid : out std_logic_vector ( 0 to 0 );
    pcie_axi_bready : in std_logic_vector ( 0 to 0 );
    pcie_axi_araddr : in std_logic_vector ( 63 downto 0 );
    pcie_axi_arlen : in std_logic_vector ( 7 downto 0 );
    pcie_axi_arsize : in std_logic_vector ( 2 downto 0 );
    pcie_axi_arburst : in std_logic_vector ( 1 downto 0 );
    pcie_axi_arlock : in std_logic_vector ( 0 to 0 );
    pcie_axi_arcache : in std_logic_vector ( 3 downto 0 );
    pcie_axi_arprot : in std_logic_vector ( 2 downto 0 );
    pcie_axi_arvalid : in std_logic_vector ( 0 to 0 );
    pcie_axi_arready : out std_logic_vector ( 0 to 0 );
    pcie_axi_rdata : out std_logic_vector ( 63 downto 0 );
    pcie_axi_rresp : out std_logic_vector ( 1 downto 0 );
    pcie_axi_rlast : out std_logic_vector ( 0 to 0 );
    pcie_axi_rvalid : out std_logic_vector ( 0 to 0 );
    pcie_axi_rready : in std_logic_vector ( 0 to 0 );
    ipb_axi_awaddr : out std_logic_vector ( 63 downto 0 );
    ipb_axi_awlen : out std_logic_vector ( 7 downto 0 );
    ipb_axi_awsize : out std_logic_vector ( 2 downto 0 );
    ipb_axi_awburst : out std_logic_vector ( 1 downto 0 );
    ipb_axi_awlock : out std_logic_vector ( 0 to 0 );
    ipb_axi_awcache : out std_logic_vector ( 3 downto 0 );
    ipb_axi_awprot : out std_logic_vector ( 2 downto 0 );
    ipb_axi_awregion : out std_logic_vector ( 3 downto 0 );
    ipb_axi_awvalid : out std_logic_vector ( 0 to 0 );
    ipb_axi_awready : in std_logic_vector ( 0 to 0 );
    ipb_axi_wdata : out std_logic_vector ( 63 downto 0 );
    ipb_axi_wstrb : out std_logic_vector ( 7 downto 0 );
    ipb_axi_wlast : out std_logic_vector ( 0 to 0 );
    ipb_axi_wvalid : out std_logic_vector ( 0 to 0 );
    ipb_axi_wready : in std_logic_vector ( 0 to 0 );
    ipb_axi_bresp : in std_logic_vector ( 1 downto 0 );
    ipb_axi_bvalid : in std_logic_vector ( 0 to 0 );
    ipb_axi_bready : out std_logic_vector ( 0 to 0 );
    ipb_axi_araddr : out std_logic_vector ( 63 downto 0 );
    ipb_axi_arlen : out std_logic_vector ( 7 downto 0 );
    ipb_axi_arsize : out std_logic_vector ( 2 downto 0 );
    ipb_axi_arburst : out std_logic_vector ( 1 downto 0 );
    ipb_axi_arlock : out std_logic_vector ( 0 to 0 );
    ipb_axi_arcache : out std_logic_vector ( 3 downto 0 );
    ipb_axi_arprot : out std_logic_vector ( 2 downto 0 );
    ipb_axi_arqos : out std_logic_vector ( 3 downto 0 );
    ipb_axi_arvalid : out std_logic_vector ( 0 to 0 );
    ipb_axi_arready : in std_logic_vector ( 0 to 0 );
    ipb_axi_rdata : in std_logic_vector ( 63 downto 0 );
    ipb_axi_rresp : in std_logic_vector ( 1 downto 0 );
    ipb_axi_rlast : in std_logic_vector ( 0 to 0 );
    ipb_axi_rvalid : in std_logic_vector ( 0 to 0 );
    ipb_axi_rready : out std_logic_vector ( 0 to 0 );
    algo_axi_awaddr : out std_logic_vector ( 63 downto 0 );
    algo_axi_awlen : out std_logic_vector ( 7 downto 0 );
    algo_axi_awsize : out std_logic_vector ( 2 downto 0 );
    algo_axi_awburst : out std_logic_vector ( 1 downto 0 );
    algo_axi_awlock : out std_logic_vector ( 0 to 0 );
    algo_axi_awcache : out std_logic_vector ( 3 downto 0 );
    algo_axi_awprot : out std_logic_vector ( 2 downto 0 );
    algo_axi_awqos : out std_logic_vector ( 3 downto 0 );
    algo_axi_awvalid : out std_logic_vector ( 0 to 0 );
    algo_axi_awready : in std_logic_vector ( 0 to 0 );
    algo_axi_wdata : out std_logic_vector ( 63 downto 0 );
    algo_axi_wstrb : out std_logic_vector ( 7 downto 0 );
    algo_axi_wlast : out std_logic_vector ( 0 to 0 );
    algo_axi_wvalid : out std_logic_vector ( 0 to 0 );
    algo_axi_wready : in std_logic_vector ( 0 to 0 );
    algo_axi_bresp : in std_logic_vector ( 1 downto 0 );
    algo_axi_bvalid : in std_logic_vector ( 0 to 0 );
    algo_axi_bready : out std_logic_vector ( 0 to 0 );
    algo_axi_araddr : out std_logic_vector ( 63 downto 0 );
    algo_axi_arlen : out std_logic_vector ( 7 downto 0 );
    algo_axi_arsize : out std_logic_vector ( 2 downto 0 );
    algo_axi_arburst : out std_logic_vector ( 1 downto 0 );
    algo_axi_arlock : out std_logic_vector ( 0 to 0 );
    algo_axi_arcache : out std_logic_vector ( 3 downto 0 );
    algo_axi_arprot : out std_logic_vector ( 2 downto 0 );
    algo_axi_arqos : out std_logic_vector ( 3 downto 0 );
    algo_axi_arvalid : out std_logic_vector ( 0 to 0 );
    algo_axi_arready : in std_logic_vector ( 0 to 0 );
    algo_axi_rdata : in std_logic_vector ( 63 downto 0 );
    algo_axi_rresp : in std_logic_vector ( 1 downto 0 );
    algo_axi_rlast : in std_logic_vector ( 0 to 0 );
    algo_axi_rvalid : in std_logic_vector ( 0 to 0 );
    algo_axi_rready : out std_logic_vector ( 0 to 0 )
  );
  end component axi_ic;
begin
axi_ic_i: component axi_ic
     port map (
      algo_axi_araddr(63 downto 0)  => algo_axi_ms.araddr(63 downto 0),
      algo_axi_arburst(1 downto 0)  => algo_axi_ms.arburst(1 downto 0),
      algo_axi_arcache(3 downto 0)  => algo_axi_ms.arcache(3 downto 0),
      algo_axi_arlen(7 downto 0)    => algo_axi_ms.arlen(7 downto 0),
      algo_axi_arlock(0)            => algo_axi_ms.arlock,
      algo_axi_arprot(2 downto 0)   => algo_axi_ms.arprot(2 downto 0),
      algo_axi_arready(0)           => algo_axi_sm.arready,
      algo_axi_arsize(2 downto 0)   => algo_axi_ms.arsize(2 downto 0),
      algo_axi_arvalid(0)           => algo_axi_ms.arvalid,
      algo_axi_awaddr(63 downto 0)  => algo_axi_ms.awaddr(63 downto 0),
      algo_axi_awburst(1 downto 0)  => algo_axi_ms.awburst(1 downto 0),
      algo_axi_awcache(3 downto 0)  => algo_axi_ms.awcache(3 downto 0),
      algo_axi_awlen(7 downto 0)    => algo_axi_ms.awlen(7 downto 0),
      algo_axi_awlock(0)            => algo_axi_ms.awlock,
      algo_axi_awprot(2 downto 0)   => algo_axi_ms.awprot(2 downto 0),
      algo_axi_awready(0)           => algo_axi_sm.awready,
      algo_axi_awsize(2 downto 0)   => algo_axi_ms.awsize(2 downto 0),
      algo_axi_awvalid(0)           => algo_axi_ms.awvalid,
      algo_axi_bready(0)            => algo_axi_ms.bready,
      algo_axi_bresp(1 downto 0)    => algo_axi_sm.bresp(1 downto 0),
      algo_axi_bvalid(0)            => algo_axi_sm.bvalid,
      algo_axi_rdata(63 downto 0)   => algo_axi_sm.rdata(63 downto 0),
      algo_axi_rlast(0)             => algo_axi_sm.rlast,
      algo_axi_rready(0)            => algo_axi_ms.rready,
      algo_axi_rresp(1 downto 0)    => algo_axi_sm.rresp(1 downto 0),
      algo_axi_rvalid(0)            => algo_axi_sm.rvalid,
      algo_axi_wdata(63 downto 0)   => algo_axi_ms.wdata(63 downto 0),
      algo_axi_wlast(0)             => algo_axi_ms.wlast,
      algo_axi_wready(0)            => algo_axi_sm.wready,
      algo_axi_wstrb(7 downto 0)    => algo_axi_ms.wstrb(7 downto 0),
      algo_axi_wvalid(0)            => algo_axi_ms.wvalid,
      --
      ipb_axi_araddr(63 downto 0)   => ipb_axi_ms.araddr(63 downto 0),
      ipb_axi_arburst(1 downto 0)   => ipb_axi_ms.arburst(1 downto 0),
      ipb_axi_arcache(3 downto 0)   => ipb_axi_ms.arcache(3 downto 0),
      ipb_axi_arlen(7 downto 0)     => ipb_axi_ms.arlen(7 downto 0),
      ipb_axi_arlock(0)             => ipb_axi_ms.arlock,
      ipb_axi_arprot(2 downto 0)    => ipb_axi_ms.arprot(2 downto 0),
      ipb_axi_arready(0)            => ipb_axi_sm.arready,
      ipb_axi_arsize(2 downto 0)    => ipb_axi_ms.arsize(2 downto 0),
      ipb_axi_arvalid(0)            => ipb_axi_ms.arvalid,
      ipb_axi_awaddr(63 downto 0)   => ipb_axi_ms.awaddr(63 downto 0),
      ipb_axi_awburst(1 downto 0)   => ipb_axi_ms.awburst(1 downto 0),
      ipb_axi_awcache(3 downto 0)   => ipb_axi_ms.awcache(3 downto 0),
      ipb_axi_awlen(7 downto 0)     => ipb_axi_ms.awlen(7 downto 0),
      ipb_axi_awlock(0)             => ipb_axi_ms.awlock,
      ipb_axi_awprot(2 downto 0)    => ipb_axi_ms.awprot(2 downto 0),
      ipb_axi_awready(0)            => ipb_axi_sm.awready,
      ipb_axi_awsize(2 downto 0)    => ipb_axi_ms.awsize(2 downto 0),
      ipb_axi_awvalid(0)            => ipb_axi_ms.awvalid,
      ipb_axi_bready(0)             => ipb_axi_ms.bready,
      ipb_axi_bresp(1 downto 0)     => ipb_axi_sm.bresp(1 downto 0),
      ipb_axi_bvalid(0)             => ipb_axi_sm.bvalid,
      ipb_axi_rdata(63 downto 0)    => ipb_axi_sm.rdata(63 downto 0),
      ipb_axi_rlast(0)              => ipb_axi_sm.rlast,
      ipb_axi_rready(0)             => ipb_axi_ms.rready,
      ipb_axi_rresp(1 downto 0)     => ipb_axi_sm.rresp(1 downto 0),
      ipb_axi_rvalid(0)             => ipb_axi_sm.rvalid,
      ipb_axi_wdata(63 downto 0)    => ipb_axi_ms.wdata(63 downto 0),
      ipb_axi_wlast(0)              => ipb_axi_ms.wlast,
      ipb_axi_wready(0)             => ipb_axi_sm.wready,
      ipb_axi_wstrb(7 downto 0)     => ipb_axi_ms.wstrb(7 downto 0),
      ipb_axi_wvalid(0)             => ipb_axi_ms.wvalid,
      --
      pcie_axi_aclk                 => pcie_axi_ms.aclk,
      pcie_axi_araddr(63 downto 0)  => pcie_axi_ms.araddr(63 downto 0),
      pcie_axi_arburst(1 downto 0)  => pcie_axi_ms.arburst(1 downto 0),
      pcie_axi_arcache(3 downto 0)  => pcie_axi_ms.arcache(3 downto 0),
      pcie_axi_aresetn              => pcie_axi_ms.aresetn,
      pcie_axi_arlen(7 downto 0)    => pcie_axi_ms.arlen(7 downto 0),
      pcie_axi_arlock(0)            => pcie_axi_ms.arlock,
      pcie_axi_arprot(2 downto 0)   => pcie_axi_ms.arprot(2 downto 0),
      pcie_axi_arready(0)           => pcie_axi_sm.arready,
      pcie_axi_arsize(2 downto 0)   => pcie_axi_ms.arsize(2 downto 0),
      pcie_axi_arvalid(0)           => pcie_axi_ms.arvalid,
      pcie_axi_awaddr(63 downto 0)  => pcie_axi_ms.awaddr(63 downto 0),
      pcie_axi_awburst(1 downto 0)  => pcie_axi_ms.awburst(1 downto 0),
      pcie_axi_awcache(3 downto 0)  => pcie_axi_ms.awcache(3 downto 0),
      pcie_axi_awlen(7 downto 0)    => pcie_axi_ms.awlen(7 downto 0),
      pcie_axi_awlock(0)            => pcie_axi_ms.awlock,
      pcie_axi_awprot(2 downto 0)   => pcie_axi_ms.awprot(2 downto 0),
      pcie_axi_awready(0)           => pcie_axi_sm.awready,
      pcie_axi_awsize(2 downto 0)   => pcie_axi_ms.awsize(2 downto 0),
      pcie_axi_awvalid(0)           => pcie_axi_ms.awvalid,
      pcie_axi_bready(0)            => pcie_axi_ms.bready,
      pcie_axi_bresp(1 downto 0)    => pcie_axi_sm.bresp(1 downto 0),
      pcie_axi_bvalid(0)            => pcie_axi_sm.bvalid,
      pcie_axi_rdata(63 downto 0)   => pcie_axi_sm.rdata(63 downto 0),
      pcie_axi_rlast(0)             => pcie_axi_sm.rlast,
      pcie_axi_rready(0)            => pcie_axi_ms.rready,
      pcie_axi_rresp(1 downto 0)    => pcie_axi_sm.rresp(1 downto 0),
      pcie_axi_rvalid(0)            => pcie_axi_sm.rvalid,
      pcie_axi_wdata(63 downto 0)   => pcie_axi_ms.wdata(63 downto 0),
      pcie_axi_wlast(0)             => pcie_axi_ms.wlast,
      pcie_axi_wready(0)            => pcie_axi_sm.wready,
      pcie_axi_wstrb(7 downto 0)    => pcie_axi_ms.wstrb(7 downto 0),
      pcie_axi_wvalid(0)            => pcie_axi_ms.wvalid
    );
      -- aclk & aresetn forwarding
      ipb_axi_ms.aclk               <= pcie_axi_ms.aclk;
      ipb_axi_ms.aresetn            <= pcie_axi_ms.aresetn;
      algo_axi_ms.aclk              <= pcie_axi_ms.aclk;
      algo_axi_ms.aresetn           <= pcie_axi_ms.aresetn;

end structure;