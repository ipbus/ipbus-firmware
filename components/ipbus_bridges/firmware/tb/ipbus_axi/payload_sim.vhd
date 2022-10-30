-- payload_sim
--
-- Testbench design for ipbus_clk_bridge blocks
--
-- Dave Newbold, October 2022

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.ipbus.all;
--use work.ipbus_decode_ipbus_axi_tb_sim.all;
use work.ipbus_axi4lite_decl.all;

entity payload is
	generic(
		CARRIER_TYPE: std_logic_vector(7 downto 0) := x"00"
	);
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clk: in std_logic;
		rst: in std_logic;
		nuke: out std_logic;
		soft_rst: out std_logic;
		userled: out std_logic
	);

end payload;

architecture rtl of payload is

--	constant DESIGN_TYPE: std_logic_vector := X"00";

--	signal ipbw: ipb_wbus_array(N_SLAVES - 1 downto 0);
--	signal ipbr: ipb_rbus_array(N_SLAVES - 1 downto 0);

	signal axi_mosi: ipb_axi4lite_mosi;
	signal axi_miso: ipb_axi4lite_miso;
	signal axi_rstn: std_logic;

	COMPONENT axi4lite_reg_0
		PORT (
			s00_axi_awaddr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			s00_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			s00_axi_awvalid : IN STD_LOGIC;
			s00_axi_awready : OUT STD_LOGIC;
			s00_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			s00_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			s00_axi_wvalid : IN STD_LOGIC;
			s00_axi_wready : OUT STD_LOGIC;
			s00_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			s00_axi_bvalid : OUT STD_LOGIC;
			s00_axi_bready : IN STD_LOGIC;
			s00_axi_araddr : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			s00_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			s00_axi_arvalid : IN STD_LOGIC;
			s00_axi_arready : OUT STD_LOGIC;
			s00_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			s00_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			s00_axi_rvalid : OUT STD_LOGIC;
			s00_axi_rready : IN STD_LOGIC;
			s00_axi_aclk : IN STD_LOGIC;
			s00_axi_aresetn : IN STD_LOGIC
		);
	END COMPONENT;

begin

	nuke <= '0';
	soft_rst <= '0';
	userled <= '0';

-- ipbus address decode
		
--	fabric: entity work.ipbus_fabric_sel
--		generic map(
--   		NSLV => N_SLAVES,
--    		SEL_WIDTH => IPBUS_SEL_WIDTH
--    	)
--		port map(
--			ipb_in => ipb_in,
--			ipb_out => ipb_out,
--			sel => ipbus_sel_ipbus_axi_tb_sim(ipb_in.ipb_addr),
--			ipb_to_slaves => ipbw,
--			ipb_from_slaves => ipbr
--		);
		
	bridge: entity work.ipbus_ipb2axi4lite
		port map(
			ipb_clk => ipb_clk,
			ipb_rst => ipb_rst,
			ipb_in => ipb_in,
			ipb_out => ipb_out,
			axi_out => axi_mosi,
			axi_in => axi_miso,
			axi_rstn => axi_rstn	
		);

	axi_reg: axi4lite_reg_0
		port map(
			s00_axi_awaddr => axi_mosi.awaddr,
			s00_axi_awprot => axi_mosi.awprot,
			s00_axi_awvalid => axi_mosi.awvalid,
			s00_axi_awready => axi_miso.awready,
			s00_axi_wdata => axi_mosi.wdata,
			s00_axi_wstrb => axi_mosi.wstrb,
			s00_axi_wvalid => axi_mosi.wvalid,
			s00_axi_wready => axi_miso.wready,
			s00_axi_bresp => axi_miso.bresp,
			s00_axi_bvalid => axi_miso.bvalid,
			s00_axi_bready => axi_mosi.bready,
			s00_axi_araddr => axi_mosi.araddr,
			s00_axi_arprot => axi_mosi.arprot,
			s00_axi_arvalid => axi_mosi.arvalid,
			s00_axi_arready => axi_miso.arready,
			s00_axi_rdata => axi_miso.rdata,
			s00_axi_rresp => axi_miso.rresp,
			s00_axi_rvalid => axi_miso.rvalid,
			s00_axi_rready => axi_mosi.rready,
			s00_axi_aclk => ipb_clk,
			s00_axi_aresetn => axi_rstn
		);

end rtl;
