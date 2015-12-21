-- UDP_master_slave_shim
-- (dummy) interface between master and slave
--
-- In reality you would add your preferred means of transporting these 
-- between the two FPGA.
--
-- The _data ports can be interpreted as input to 8B/10B,
-- (8 downto 1 data, 0 isKchar)
--
-- _err should be asserted if a transmission error is detected these
--
-- _pause is the sloppy FIFO signal
--
-- FIFO depth in UDP_master_fifo needs to be set large enough that it can 
-- accommodate the latency on these transfers

--  Dave Sankey Oct 2015

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY UDP_master_slave_shim IS
  Generic (
		constant DELAY: time := 4 ns
  );
  PORT( 
		mac_clk: IN std_logic;
-- master ports
		master_rx_data: in std_logic_vector(8 DOWNTO 0);
		master_tx_pause: in std_logic;

		master_tx_data: out std_logic_vector(8 DOWNTO 0);
		master_tx_err: out std_logic;
-- slave ports
		slave_tx_data: in std_logic_vector(8 DOWNTO 0);

		slave_rx_data: out std_logic_vector(8 DOWNTO 0);
		slave_rx_err: out std_logic;

		slave_tx_pause: out std_logic
   );

END UDP_master_slave_shim;

architecture Behavioral of UDP_master_slave_shim is

Begin

slave_rx_err <= '0';
master_tx_err <= '0';

Patch_Block: process(mac_clk)
  Begin
    If rising_edge(mac_clk) then
      slave_rx_data <= master_rx_data
-- pragma translate_off
      after DELAY
-- pragma translate_on
      ;
      master_tx_data <= slave_tx_data
-- pragma translate_off
      after DELAY
-- pragma translate_on
      ;
      slave_tx_pause <= master_tx_pause
-- pragma translate_off
      after DELAY
-- pragma translate_on
      ;
    End If;
  End process Patch_Block;

End Behavioral;
