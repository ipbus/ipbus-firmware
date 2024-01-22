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
        AXI_ADDR_MASK: std_logic_vector(31 downto 0) := X"ffffffff";
        AXI_ADDR_BASE: std_logic_vector(31 downto 0) := X"00000000";
        C_S_AXI_DATA_WIDTH: integer	:= 32;
        C_S_AXI_ADDR_WIDTH: integer	:= 4
    );
    port(
        ipb_clk: in std_logic;
		ipb_rst: in std_logic;       
        ipb_in_addr: in std_logic_vector(31 downto 0);
        ipb_in_wdata: in std_logic_vector(31 downto 0);
        ipb_in_write: in std_logic;
        ipb_in_strobe: in std_logic;
        ipb_out_ack: out std_logic;
        ipb_out_err: out std_logic;
        ipb_out_rdata: out std_logic_vector(31 downto 0);
        S_AXI_ARESETN: out std_logic;
        S_AXI_AWADDR: out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWPROT: out std_logic_vector(2 downto 0);
        S_AXI_AWVALID: out std_logic;
        S_AXI_AWREADY: in std_logic;
        S_AXI_WDATA: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB: out std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID: out std_logic;
        S_AXI_WREADY: in std_logic;
        S_AXI_BRESP: in std_logic_vector(1 downto 0);
        S_AXI_BVALID: in std_logic;
        S_AXI_BREADY: out std_logic;
        S_AXI_ARADDR: out std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARPROT: out std_logic_vector(2 downto 0);
        S_AXI_ARVALID: out std_logic;
        S_AXI_ARREADY: in std_logic;
        S_AXI_RDATA: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP: in std_logic_vector(1 downto 0);
        S_AXI_RVALID: in std_logic;
        S_AXI_RREADY: out std_logic
    );

end ipbus_ipb2axi4lite_wrapper;

architecture rtl of ipbus_ipb2axi4lite_wrapper is

begin

    bridge: entity work.ipbus_ipb2axi4lite is
        generic(
            AXI_ADDR_MASK => AXI_ADDR_MASK,
            AXI_ADDR_BASE => AXI_ADDR_BASE
        );
        port(
            ipb_clk => ipb_clk,
            ipb_rst => ipb_rst,
            ipb_in.ipb_addr => ipb_in_addr,
            ipb_in.ipb_wdata => ipb_in_wdata,
            ipb_in.ipb_write => ipb_in_write,
            ipb_in.ipb_strobe => ipb_in_strobe,
            ipb_out.ipb_ack => ipb_out_ack,
            ipb_out.ipb_err => ipb_out_err,
            ipb_out.ipb_rdata => ipb_out_rdata,
            axi_out.awaddr => S_AXI_AWADDR,
            axi_out.awprot => S_AXI_AWPROT,
            axi_out.awvalid => S_AXI_AWVALID,
            axi_out.wdata => S_AXI_WDATA,
            axi_out.wstrb => S_AXI_WSTRB,
            axi_out.wvalid => S_AXI_WVALID,
            axi_out.bready => S_AXI_BREADY,
            axi_out.araddr => S_AXI_ARADDR,
            axi_out.arprot => S_AXI_ARPROT,
            axi_out.arvalid => S_AXI_ARVALID,
            axi_out.rready => S_AXI_RREADY,
            axi_in.awready => S_AXI_AWREADY,
            axi_in.wready => S_AXI_WREADY,
            axi_in.bvalid => S_AXI_BVALID,
            axi_in.arready => S_AXI_ARREADY,
            axi_in.rdata => S_AXI_RDATA,
            axi_in.rresp => S_AXI_RRESP,
            axi_in.rvalid => S_AXI_RVALID,
            axi_rstn => S_AXI_ARESETN
        );

end rtl;
