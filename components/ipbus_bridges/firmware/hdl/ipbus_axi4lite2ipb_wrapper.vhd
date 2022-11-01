-- ipbus_ipb2axi4lite_wrapper
--
-- Vivado-friendly wrapper for ipbus_ipb2axi4lite
--
-- Dave Newbold, 30/10/22

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.ipbus_axi4lite_decl.all;

entity ipbus_ipb2axi4lite_wrapper is
    generic(
        IPB_ADDR_MASK: std_logic_vector(31 downto 0) := X"ffffffff";
        IPB_ADDR_BASE: std_logic_vector(31 downto 0) := X"00000000";
        C_S_AXI_DATA_WIDTH: integer	:= 32;
        C_S_AXI_ADDR_WIDTH: integer	:= 4
    );
    port(
        S_AXI_ACLK: in std_logic;
        S_AXI_ARESETN: in std_logic;
        S_AXI_AWADDR: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWPROT: in std_logic_vector(2 downto 0);
        S_AXI_AWVALID: in std_logic;
        S_AXI_AWREADY: out std_logic;
        S_AXI_WDATA: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID: in std_logic;
        S_AXI_WREADY: out std_logic;
        S_AXI_BRESP: out std_logic_vector(1 downto 0);
        S_AXI_BVALID: out std_logic;
        S_AXI_BREADY: in std_logic;
        S_AXI_ARADDR: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARPROT: in std_logic_vector(2 downto 0);
        S_AXI_ARVALID: in std_logic;
        S_AXI_ARREADY: out std_logic;
        S_AXI_RDATA: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP: out std_logic_vector(1 downto 0);
        S_AXI_RVALID: out std_logic;
        S_AXI_RREADY: in std_logic;
        ipb_out_addr: out std_logic_vector(31 downto 0);
        ipb_out_wdata: out std_logic_vector(31 downto 0);
        ipb_out_write: out std_logic;
        ipb_out_strobe: out std_logic;
        ipb_in_ack: in std_logic;
        ipb_in_err: in std_logic;
        ipb_in_rdata: in std_logic_vector(31 downto 0);
        ipb_rst: out std_logic
    );

end ipbus_ipb2axi4lite_wrapper;

architecture rtl of ipbus_ipb2axi4lite_wrapper is

begin

    bridge: entity work.ipbus_axi4lite2ipb is
        generic(
            IPB_ADDR_MASK => IPB_ADDR_MASK,
            IPB_ADDR_BASE => IPB_ADDR_BASE
        );
        port(
            axi_clk => S_AXI_ACLK,
            axi_rstn => S_AXI_ARESETN,
            axi_in.awaddr => S_AXI_AWADDR,
            axi_in.awprot => S_AXI_AWPROT,
            axi_in.awvalid => S_AXI_AWVALID,
            axi_in.wdata => S_AXI_WDATA,
            axi_in.wstrb => S_AXI_WSTRB,
            axi_in.wvalid => S_AXI_WVALID,
            axi_in.bready => S_AXI_BREADY,
            axi_in.araddr => S_AXI_ARADDR,
            axi_in.arprot => S_AXI_ARPROT,
            axi_in.arvalid => S_AXI_ARVALID,
            axi_out.rready => S_AXI_RREADY,
            axi_out.awready => S_AXI_AWREADY,
            axi_out.wready => S_AXI_WREADY,
            axi_out.bvalid => S_AXI_BVALID,
            axi_out.arready => S_AXI_ARREADY,
            axi_out.rdata => S_AXI_RDATA,
            axi_out.rresp => S_AXI_RRESP,
            axi_out.rvalid => S_AXI_RVALID,
            ipb_out.ipb_addr => ipb_out_addr,
            ipb_out.ipb_wdata => ipb_out_wdata,
            ipb_out.ipb_write => ipb_out_write,
            ipb_out.ipb_strobe => ipb_out_strobe,
            ipb_in.ipb_ack => ipb_in_ack,
            ipb_in.ipb_err => ipb_in_err,
            ipb_in.ipb_rdata => ipb_in_rdata,
            ipb_rst => ipb_rst
        );

end rtl;
