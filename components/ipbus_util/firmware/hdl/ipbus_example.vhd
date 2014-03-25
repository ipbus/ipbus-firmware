-- ipbus_example
--
-- selection of different IPBus slaves without actual function,
-- just for performance evaluation of the IPbus/uhal system
--
-- Kristian Harder, March 2014
-- based on code by Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.all;
use work.ipbus_trans_decl.all;
use work.ipbus_decode_ipbus_example.all;


entity ipbus_example is
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

end ipbus_example;

architecture rtl of ipbus_example is

	signal ipbw: ipb_wbus_array(N_SLAVES-1 downto 0);
	signal ipbr: ipb_rbus_array(N_SLAVES-1 downto 0);
	signal ctrl_reg: std_logic_vector(31 downto 0);
	signal inj_ctrl, inj_stat: std_logic_vector(63 downto 0);

begin

-- ipbus address decode
		
	fabric: entity work.ipbus_fabric_sel
    generic map(
    	NSLV => N_SLAVES,
    	SEL_WIDTH => IPBUS_SEL_WIDTH)
    port map(
      ipb_in => ipb_in,
      ipb_out => ipb_out,
      sel => ipbus_sel_ipbus_example(ipb_in.ipb_addr),
      ipb_to_slaves => ipbw,
      ipb_from_slaves => ipbr
    );

-- Slave 0: id / rst reg

	slave0: entity work.ipbus_ctrlreg
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_CTRL_REG),
			ipbus_out => ipbr(N_SLV_CTRL_REG),
			d => X"abcdfedc",
			q => ctrl_reg
		);
		
		rst_out <= ctrl_reg(0);

-- Slave 1: register

	slave1: entity work.ipbus_reg
		generic map(addr_width => 0)
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_REG),
			ipbus_out => ipbr(N_SLV_REG),
			q => open
		);
			
-- Slave 2: ethernet error injection

	slave2: entity work.ipbus_ctrlreg
		generic map(
			ctrl_addr_width => 1,
			stat_addr_width => 1
		)
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_ERR_INJECT),
			ipbus_out => ipbr(N_SLV_ERR_INJECT),
			d => inj_stat,
			q => inj_ctrl
		);
		
	eth_err_ctrl <= inj_ctrl(49 downto 32) & inj_ctrl(17 downto 0);
	inj_stat <= X"00" & eth_err_stat(47 downto 24) & X"00" & eth_err_stat(23 downto 0);
	
-- Slave 3: packet counters

	slave3: entity work.ipbus_pkt_ctr
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_PKT_CTR),
			ipbus_out => ipbr(N_SLV_PKT_CTR),
			pkt_rx => pkt_rx,
			pkt_tx => pkt_tx
		);

-- Slave 4: 1kword RAM

	slave4: entity work.ipbus_ram
		generic map(addr_width => 10)
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_RAM),
			ipbus_out => ipbr(N_SLV_RAM)
		);
	
-- Slave 5: peephole RAM

	slave5: entity work.ipbus_peephole_ram
		generic map(addr_width => 10)
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_PRAM),
			ipbus_out => ipbr(N_SLV_PRAM)
		);

end rtl;
