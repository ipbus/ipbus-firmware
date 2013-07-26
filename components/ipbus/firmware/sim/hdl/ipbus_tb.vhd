-- This testbench allows users to exercise the ipbus in a purely VHDL environment
-- as opposed to using the ModelSim Foreign Language Interface (FLI).  The FLI 
-- offers a more comprehensive test enevironment, particularly for exercising 
-- the UDP/IP aspects and the concatention of ipbus requests. However, the FLI is
-- complex to setup and it is a proprietary standard of ModelSim.
--
-- The test bench is built upon the "ipbus_simulation" package that provides the 
-- read/writes procedures that would normsally be executed by a CPU. 
--
-- Greg Iles, July 2013


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.ipbus.all;
use work.ipbus_trans_decl.all;
use work.ipbus_simulation.all;

entity ipbus_tb is
end ipbus_tb;

architecture behave of ipbus_tb is

  -- The number of Out-Of-Band interfaces to the ipbus master (i.e. not from the Ethernet MAC)   
  constant N_OOB: natural := 1;
  -- The number of ipbus slaves used in this example. 
  constant NSLV: positive := 3;

  -- Base addreses of ipbus slaves.  THis is defined in package "ipbus_addr_decode"
  constant BASE_ADD_CTRL_REG: std_logic_vector(31 downto 0) := x"00000000";
  constant BASE_ADD_REG: std_logic_vector(31 downto 0) := x"00000002";
  constant BASE_ADD_RAM: std_logic_vector(31 downto 0) := x"00001000";
 
  signal clk, rst: std_logic := '1'; 

  -- The ipbus interface to the ipbus master.
  -- The record type "ipb_wbus" contains elements ipb_addr, ipb_wdata, ipb_strobe, ipb_write
  -- The record type "ipb_rbus" contains elements ipb_rdata, ipb_ack, ipb_err
	signal ipb_out_m, ipbus_shim_out: ipb_wbus;
	signal ipb_in_m, ipbus_shim_in: ipb_rbus;

  -- The following should be ignored by the user.  They simply provide a communication 
  -- path from the read/write procedures into the ibus master for ipbus transactions.
	signal oob_in: ipbus_trans_in := ('0', X"00000000", '0');
	signal oob_out: ipbus_trans_out := (X"000", '0', '0', X"000", X"00000000");

  -- Array of ipbus records for communication to the ipbus slaves. 
	signal ipbw: ipb_wbus_array(NSLV - 1 downto 0);
	signal ipbr: ipb_rbus_array(NSLV - 1 downto 0);

  -- A register...
	signal ctrl: std_logic_vector(31 downto 0);

begin


  clk <= not clk after 10 ns;
  
  -----------------------------------------------------------------------
  -- Stage 1: CPU Simulator 
  --
  -- The following mimics a CPU executing a series of writes & reads.
  -- At present it just verifies that the following procedures behave 
  -- as expected.  The user should replace these reads & writes with 
  -- whatever they wish to test.
  --
  -- ipbus_write & ipbus_read
  -- ipbus_block_write & ipbus_block_read
  -- ipbus_read_modify_write
  ----------------------------------------------------------------------- 
   
  cpu: process
    
    variable rdata, wdata: std_logic_vector(31 downto 0) := x"00000000";
    variable rdata_buf, wdata_buf: type_ipbus_buffer(4 downto 0) := (others => x"00000000");
    variable mask: std_logic_vector(31 downto 0) := x"00000000";
  
  begin
  
    -- Wait for 1ns to get rid of all those pesky warnings at startup
    wait for 100 ns;
      
      report 
      " "  & CR & LF & 
      "----------------------------------------------------------------"  & CR & LF & 
      "Starting Simulation - Run for 5 us"  & CR & LF & 
      "----------------------------------------------------------------"  & CR & LF & 
      " ";

    wait for 100 ns;
      rst <= '0';
      report "### Exiting reset"  & CR & LF;
      -- Allow end of reset to propagate
    wait for 100 ns;
    
      report  "### Checking Write / Read ###"  & CR & LF;
      wdata := x"DEADBEEF";
      ipbus_write(clk, oob_in, oob_out, BASE_ADD_CTRL_REG, wdata);
      ipbus_read(clk, oob_in, oob_out, BASE_ADD_CTRL_REG, rdata);
      assert (wdata = rdata)
        report "Data read back does not equal data written" severity failure;

      report "### Checking BlockWrite / BlockRead ###"  & CR & LF;
      wdata_buf := (x"55555555", x"44444444", x"33333333", x"22222222", x"11111111");
      ipbus_block_write(clk, oob_in, oob_out, BASE_ADD_RAM, wdata_buf, true);
      ipbus_block_read(clk, oob_in, oob_out, BASE_ADD_RAM, rdata_buf, true);
      assert (wdata_buf = rdata_buf)
        report "Data read back does not equal data written" severity failure;
      
      report "### Checking Read-Modify-Write ###"  & CR & LF;
      -- First just make sure register value set to a know value
      wdata := x"DEADBEEF";
      ipbus_write(clk, oob_in, oob_out, BASE_ADD_CTRL_REG, wdata);
      mask := x"00ff0000";      
      ipbus_read_modify_write(clk, oob_in, oob_out, BASE_ADD_CTRL_REG, mask, x"00000007");
      -- New data sould be the folowing.  Check with read   
      ipbus_read(clk, oob_in, oob_out, BASE_ADD_CTRL_REG, rdata);
      assert (x"DE07BEEF" = rdata)
      report "Data read back does not equal data written" severity failure;
      
      report 
      " "  & CR & LF & 
      "----------------------------------------------------------------"  & CR & LF & 
      "Ending Simulation"  & CR & LF & 
      "----------------------------------------------------------------"  & CR & LF & 
      " ";

      -- Following stops modelsim restarting....
    wait for 10 ms;

  end process;


  -----------------------------------------------------------------------
  -- Stage 2: The ipbus master.  
  --
  -- The bus master processes the ipbus requests generated in the 
  -- read/write procedures and passed into the master via "oob_in".  
  -- The ipbus read/write cycles take place on the bus and the result 
  -- is returned via "oob_out".  The user should not touch "oob_in" or
  -- "oob_out" - they are just the communication channel from the 
  -- read/write procedures to the ipbus bus master.
  -----------------------------------------------------------------------
   

  -- MAC input must have clock, even if usused, to avoid undefined signals (reset clocked).
	ipbus: entity work.ipbus_ctrl
		generic map(
			N_OOB => N_OOB)
		port map(
			mac_clk => clk,
			rst_macclk => '1',
			ipb_clk => clk,
			rst_ipb => rst,
			mac_rx_data => x"00",
			mac_rx_valid => '0',
			mac_rx_last => '0',
			mac_rx_error => '0',
			mac_tx_data => open,
			mac_tx_valid => open,
			mac_tx_last => open,
			mac_tx_error => open,
			mac_tx_ready => '0',
			ipb_out => ipb_out_m,
			ipb_in => ipb_in_m,
			mac_addr => x"000000000000",
			ip_addr => x"00000000",
			pkt_rx_led => open,
			pkt_tx_led => open,
			oob_in(0) => oob_in,
			oob_out(0) => oob_out);

  -----------------------------------------------------------------------
  -- Stage 2a: IPbus shim 
  --
  -- Splits back to back transactions apart (i.e. strobe will go low between transactions)
  -- Waits for acknowledge to go low before starting another transaction
  -- Will slow bus down, which can be compensated with a faster bus if req.
  -----------------------------------------------------------------------

	shim: entity work.ipbus_shim
    generic map(
      enable => true)
    port map(
      clk => clk,
      reset => rst,
      ipbus_in => ipb_out_m,
      ipbus_out => ipb_in_m,
      ipbus_shim_out => ipbus_shim_out,
      ipbus_shim_in => ipbus_shim_in);

  -----------------------------------------------------------------------
  -- Stage 3: Bus distribution, address decoder and bus slaves
  --
  -- The reads & writes are tested with the "ipbus_fabric" and
  -- slaves: "ipbus_ctrlreg", "ipbus_reg" and "ipbus_ram".  The "fabric"
  -- distributes the master ipbus signals "ipb_out_m" and "ipb_out_m" 
  -- to an array of ipbus slaves with "ipbw(x)" and fans back in their 
  -- response with array "ipbr(x)".  The fabric also contains an 
  -- addres decoder with parameters set in package "ipbus_addr_decode".  
  -- The user needs to create their own version of this file if they wish 
  -- to set up slaves with different base addresses.  The different slaves 
  -- are selected by either forwadrding or blocking the strobe.
  --
  -- While the fabric and slaves have been used in this test bench 
  -- the user is free to remove them and hang whatever they like 
  -- on the master bus: "ipb_out_m" and "ipb_out_m".  
  -----------------------------------------------------------------------
   
	fabric: entity work.ipbus_fabric
    generic map(NSLV => NSLV)
    port map(
      ipb_clk => clk,
      rst => rst,
      ipb_in => ipbus_shim_out,
      ipb_out => ipbus_shim_in,
      ipb_to_slaves => ipbw,
      ipb_from_slaves => ipbr
    );

  -- Generic control / status register block
  -- Provides 2**n control registers (32b each), rw
  -- Provides 2**m status registers (32b each), ro
  -- Bottom part of read address space is control, top is status
	slave0: entity work.ipbus_ctrlreg
		port map(
			clk => clk,
			reset => rst,
			ipbus_in => ipbw(0),
			ipbus_out => ipbr(0),
			d => X"abcdfedc",
			q => ctrl
		);

  -- Generic ipbus slave config register for testing
  -- generic addr_width defines number of significant address bits
  -- We use one cycle of read / write latency to ease timing (probably not necessary)
  -- The q outputs change immediately on write (no latency).
	slave1: entity work.ipbus_reg
		generic map(addr_width => 0)
		port map(
			clk => clk,
			reset => rst,
			ipbus_in => ipbw(1),
			ipbus_out => ipbr(1),
			q => open
		);
    
  -- Generic ipbus ram block for testing
  -- generic addr_width defines number of significant address bits
  -- In order to allow Xilinx block RAM to be inferred:
  -- Reset does not clear the RAM contents (not implementable in Xilinx)
  -- There is one cycle of latency on the read / write
	slave2: entity work.ipbus_ram
		generic map(addr_width => 4)
		port map(
			clk => clk,
			reset => rst,
			ipbus_in => ipbw(2),
			ipbus_out => ipbr(2)
		);


end behave;