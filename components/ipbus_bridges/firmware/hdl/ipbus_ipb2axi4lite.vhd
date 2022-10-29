library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ipbus;
use work.ipbus.all;

entity ipbus_ipb2axi4lite is
	generic(
		C_S_AXI_DATA_WIDTH: integer	:= 32;
		C_S_AXI_ADDR_WIDTH: integer	:= 32;
        ADDR_MASK: std_logic_vector(31 downto 0) := X"11111111";
        ADDR_BASE: std_logic_vector(31 downto 0) := X"00000000"
	);
	port(
        ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus
		s_axi_aclk: in std_logic;
		s_axi_aresetn: in std_logic;
		s_axi_awaddr: out std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_awprot: out std_logic_vector(2 downto 0);
		s_axi_awvalid: out std_logic;
		s_axi_awready: in std_logic;
		s_axi_wdata: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_wstrb: out std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
		s_axi_wvalid: out std_logic;
		s_axi_wready: in std_logic;
		s_axi_bresp: in std_logic_vector(1 downto 0);
		s_axi_bvalid: in std_logic;
		s_axi_bready: out std_logic;
		s_axi_araddr: out std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_arprot: out std_logic_vector(2 downto 0);
		s_axi_arvalid: out std_logic;
		s_axi_arready: in std_logic;
		s_axi_rdata: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_rresp: in std_logic_vector(1 downto 0);
		s_axi_rvalid: in std_logic;
		s_axi_rready: out std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus
	);
end ipbus_ipb2axi4lite;

architecture rtl of ipbus_ipb2axi4lite is

begin

end rtl;
