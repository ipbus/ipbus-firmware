library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ipbus;
use work.ipbus.all;

entity ipbus_axi4lite2ipb is
	generic(
		C_S_AXI_DATA_WIDTH: integer	:= 32;
		C_S_AXI_ADDR_WIDTH: integer	:= 32;
        ADDR_MASK: std_logic_vector(31 downto 0) := X"11111111";
        ADDR_BASE: std_logic_vector(31 downto 0) := X"00000000"
	);
	port(
		s_axi_aclk: in std_logic;
		s_axi_aresetn: in std_logic;
		s_axi_awaddr: in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_awprot: in std_logic_vector(2 downto 0);
		s_axi_awvalid: in std_logic;
		s_axi_awready: out std_logic;
		s_axi_wdata: in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_wstrb: in std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
		s_axi_wvalid: in std_logic;
		s_axi_wready: out std_logic;
		s_axi_bresp: out std_logic_vector(1 downto 0);
		s_axi_bvalid: out std_logic;
		s_axi_bready: in std_logic;
		s_axi_araddr: in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		s_axi_arprot: in std_logic_vector(2 downto 0);
		s_axi_arvalid: in std_logic;
		s_axi_arready: out std_logic;
		s_axi_rdata: out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		s_axi_rresp: out std_logic_vector(1 downto 0);
		s_axi_rvalid: out std_logic;
		s_axi_rready: in std_logic;
		ipb_out: out ipb_wbus;
		ipb_in: in ipb_rbus
	);
end ipbus_axi4lite2ipb;

architecture rtl of ipbus_axi4lite2ipb is

begin

end rtl;
