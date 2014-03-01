-- The ipbus slaves live in this entity - modify according to requirements
--
-- Ports can be added to give ipbus slaves access to the chip top level.
--
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;
use ieee.numeric_std.all;
use work.ipbus_decode_root.all;

entity slaves is
	port(
		ipb_clk: in std_logic;
		ipb_rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		rst_out: out std_logic;
		eth_err_ctrl: out std_logic_vector(35 downto 0);
		eth_err_stat: in std_logic_vector(47 downto 0) := X"000000000000";
		pkt_rx: in std_logic := '0';
		pkt_tx: in std_logic := '0'
	);

end slaves;

architecture rtl of slaves is

	signal ipbw: ipb_wbus_array(N_SLAVES - 1 downto 0);
	signal ipbr, ipbr_d: ipb_rbus_array(N_SLAVES - 1 downto 0);
	signal ctrl_reg: std_logic_vector(31 downto 0);
	signal inj_ctrl, inj_stat: std_logic_vector(63 downto 0);
	
begin
  
  fabric: entity work.ipbus_fabric_sel
    generic map(
    	NSLV => N_SLAVES,
    	SEL_WIDTH => IPBUS_SEL_WIDTH)
    port map(
      ipb_in => ipb_in,
      ipb_out => ipb_out,
      sel => ipbus_sel_root(ipb_in.ipb_addr),
      ipb_to_slaves => ipbw,
      ipb_from_slaves => ipbr
    );

-- Slave 0: id / rst reg

	slave0: entity work.ipbus_ctrlreg
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_BUFFERS),
			ipbus_out => ipbr(N_SLV_BUFFERS),
			d => X"abcdfedc",
			q => ctrl_reg
		);
		
	rst_out <= ctrl_reg(0)

-- Slave 1: register

	slave1: entity work.ipbus_reg
		generic map(addr_width => 0)
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_MGT),
			ipbus_out => ipbr(N_SLV_MGT),
			q => open
		);

end rtl;
