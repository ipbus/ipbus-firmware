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
use work.ipbus_reg_types.all;
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
	signal ctrl_v, stat_v: ipb_reg_v(0 downto 0);
	signal inj_ctrl_v, inj_stat_v: ipb_reg_v(1 downto 0);

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

	slave0: entity work.ipbus_ctrlreg_v
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_CTRL_REG),
			ipbus_out => ipbr(N_SLV_CTRL_REG),
			d => stat_v,
			q => ctrl_v
		);
		stat_v(0) <= X"abcdfedc";
		rst_out <= ctrl_v(0)(0);

-- Slave 1: register

	slave1: entity work.ipbus_reg_v
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_REG),
			ipbus_out => ipbr(N_SLV_REG),
			q => open
		);
			
-- Slave 2: ethernet error injection

	slave2: entity work.ipbus_ctrlreg_v
                generic map(
                  N_CTRL => 2,
                  N_STAT => 2
                )
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_ERR_INJECT),
			ipbus_out => ipbr(N_SLV_ERR_INJECT),
			d => inj_stat_v,
			q => inj_ctrl_v
		);
		
	eth_err_ctrl <= inj_ctrl_v(1)(17 downto 0) & inj_ctrl_v(0)(17 downto 0);
	inj_stat_v(1) <= X"00" & eth_err_stat(47 downto 24);
	inj_stat_v(0) <= X"00" & eth_err_stat(23 downto 0);
	
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
		generic map(ADDR_WIDTH => 10)
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_RAM),
			ipbus_out => ipbr(N_SLV_RAM)
		);
	
-- Slave 5: peephole RAM

	slave5: entity work.ipbus_peephole_ram
		generic map(ADDR_WIDTH => 10)
		port map(
			clk => ipb_clk,
			reset => ipb_rst,
			ipbus_in => ipbw(N_SLV_PRAM),
			ipbus_out => ipbr(N_SLV_PRAM)
		);

end rtl;
