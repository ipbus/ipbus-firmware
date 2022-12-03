-- axi_proto_checker_wrapper
--
-- Wrapper for Xilinx axi4 protocol checker IP block
--
-- Dave Newbold, November 2022

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.ipbus.all;
use work.ipbus_axi4lite_decl.all;

entity axi_proto_checker_wrapper is
	port(
        status: out std_logic_vector(159 downto 0);
        asserted: out std_logic;
        aclk: in std_logic;
        aresetn: in std_logic;
        axi_mosi: in ipb_axi4lite_mosi;
        axi_miso: in ipb_axi4lite_miso      
	);

end axi_proto_checker_wrapper;

architecture rtl of paylaxi_proto_checker_wrapper is

    COMPONENT axi_protocol_checker_0
        PORT (
            pc_status : OUT STD_LOGIC_VECTOR(159 DOWNTO 0);
            pc_asserted : OUT STD_LOGIC;
            aclk : IN STD_LOGIC;
            aresetn : IN STD_LOGIC;
            pc_axi_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            pc_axi_awvalid : IN STD_LOGIC;
            pc_axi_awready : IN STD_LOGIC;
            pc_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            pc_axi_wvalid : IN STD_LOGIC;
            pc_axi_wready : IN STD_LOGIC;
            pc_axi_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            pc_axi_bvalid : IN STD_LOGIC;
            pc_axi_bready : IN STD_LOGIC;
            pc_axi_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            pc_axi_arvalid : IN STD_LOGIC;
            pc_axi_arready : IN STD_LOGIC;
            pc_axi_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            pc_axi_rvalid : IN STD_LOGIC;
            pc_axi_rready : IN STD_LOGIC
        );
    END COMPONENT;

begin

    checker : axi_protocol_checker_0
        port map(
            pc_status => status,
            pc_asserted => asserted,
            aclk => aclk,
            aresetn => aresetn,
            pc_axi_awaddr => axi_mosi.awaddr,
            pc_axi_awprot => axi_mosi.awprot,
            pc_axi_awvalid => axi_mosi.awvalid,
            pc_axi_awready => axi_miso.awready,
            pc_axi_wdata => axi_mosi.wdata,
            pc_axi_wstrb => axi_mosi.wstrb,
            pc_axi_wvalid => axi_mosi.wvalid,
            pc_axi_wready => axi_miso.awready,
            pc_axi_bresp => axi_miso.bresp,
            pc_axi_bvalid => axi_miso.bvalid,
            pc_axi_bready => axi_mosi.bready,
            pc_axi_araddr => axi_mosi.araddr,
            pc_axi_arprot => axi_mosi.arprot,
            pc_axi_arvalid => axi_mosi.arvalid,
            pc_axi_arready => axi_miso.arready,
            pc_axi_rdata => axi_miso.rdata,
            pc_axi_rresp => axi_miso.rresp,
            pc_axi_rvalid => axi_miso.rvalid,
            pc_axi_rready => axi_mosi.rready
        );

end rtl;
