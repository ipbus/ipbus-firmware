--------------------------------------------------------------------------------
-- File       : gig_eth_pcs_pma_v11_5_tx_elastic_buffer.vhd
-- Author     : Xilinx Inc.
--------------------------------------------------------------------------------
-- (c) Copyright 2002-2008 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES. 
-- 
-- 
--------------------------------------------------------------------------------
-- Description: This is the Transmitter Elastic Buffer for the design
--              example of the Ethernet 1000BASE-X PCS/PMA or SGMII
--              core.
--
--              The FIFO is created from Distributed Memory and is of
--              depth 16 words.
--
--              When the write clock is a few parts per million faster
--              than the read clock, the occupancy of the FIFO will
--              increase and Idles should be removed. A MAC transmitter
--              should always insert a minimum of 12 Idles in a single
--              Inter-Packet Gap.  The IEEE802.3 specification allows
--              for up to 4 Idles to be lost within the system (eg. due
--              to clock correction) so that a minimum of 8 Idles should
--              always be presented to a MAC receiver.  Consequently the
--              logic in this example design will only remove a single
--              Idle per minimum Inter-Packet Gap. This leaves clock
--              correction potential for other components in the overall
--              system.
--
--              When the read clock is a few parts per million faster
--              than the write clock, the occupancy of the FIFO will
--              decrease and Idles should be inserted.  The logic in
--              this example design will always insert as many idles as
--              necessary in every Inter-frame Gap period to restore the
--              FIFO occupancy.
--
--              Because the Idle insertion logic is stronger than the
--              Idle removal logic, the bias in this example design is
--              to keep the occupancy of the FIFO low.  This allows more
--              overhead for the FIFO to fill up during heavy bursts of
--              traffic.



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;



--------------------------------------------------------------------------------
-- Entity declaration.
--------------------------------------------------------------------------------

entity gig_eth_pcs_pma_v11_5_tx_elastic_buffer is

   port(

      reset            : in std_logic;                      -- Asynchronous Reset.

      -- Signals received from the input gmii_tx_clk_wr domain.
      ---------------------------------------------------------

      gmii_tx_clk_wr   : in std_logic;                      -- Write clock domain.
      gmii_txd_wr      : in std_logic_vector(7 downto 0);   -- gmii_txd synchronous to gmii_tx_clk_wr.
      gmii_tx_en_wr    : in std_logic;                      -- gmii_tx_en synchronous to gmii_tx_clk_wr.
      gmii_tx_er_wr    : in std_logic;                      -- gmii_tx_er synchronous to gmii_tx_clk_wr.

      -- Signals transfered onto the new gmii_tx_clk_rd domain.
      ---------------------------------------------------------

      gmii_tx_clk_rd   : in std_logic;                      -- Read clock domain.
      gmii_txd_rd      : out std_logic_vector(7 downto 0);  -- gmii_txd synchronous to gmii_tx_clk_rd.
      gmii_tx_en_rd    : out std_logic;                     -- gmii_tx_en synchronous to gmii_tx_clk_rd.
      gmii_tx_er_rd    : out std_logic                      -- gmii_tx_er synchronous to gmii_tx_clk_rd.
   );

end gig_eth_pcs_pma_v11_5_tx_elastic_buffer;



architecture rtl of gig_eth_pcs_pma_v11_5_tx_elastic_buffer is



  ------------------------------------------------------------------------------
  -- Component declaration for the synchronisation flip-flop pair
  ------------------------------------------------------------------------------
  component gig_eth_pcs_pma_v11_5_sync_block
  port (
    clk                : in  std_logic;                     -- clock to be sync'ed to
    data_in            : in  std_logic;                     -- Data to be 'synced'
    data_out           : out std_logic                      -- synced data
    );
  end component;



  ------------------------------------------------------------------------------
  -- Component declaration for the reset synchroniser
  ------------------------------------------------------------------------------
  component gig_eth_pcs_pma_v11_5_reset_sync
  port (
    reset_in           : in  std_logic;                     -- Active high asynchronous reset
    clk                : in  std_logic;                     -- clock to be sync'ed to
    reset_out          : out std_logic                      -- "Synchronised" reset signal
    );
  end component;



   -----------------------------------------------------------------------------
   -- Internal signals used in this entity
   -----------------------------------------------------------------------------

   constant lower_threshold : unsigned := "0110";           -- FIFO occupancy should be kept at 6 or above.
   constant upper_threshold : unsigned := "1001";           -- FIFO occupancy should be kept at 9 or below.

   -- create a synchronous reset in the write clock domain
   signal reset_wr          : std_logic;

   -- create a synchronous reset in the read clock domain
   signal reset_rd          : std_logic;

   signal gmii_txd_wr_reg   : std_logic_vector(7 downto 0); -- Registered version of gmii_txd_wr.
   signal gmii_tx_en_wr_reg : std_logic;                    -- Registered version of gmii_tx_en_wr.
   signal gmii_tx_er_wr_reg : std_logic;                    -- Registered version of gmii_tx_er_wr.
   signal wr_enable         : std_logic;                    -- write enable for FIFO.
   signal rd_enable         : std_logic;                    -- read enable for FIFO.
   signal nearly_full       : std_logic;                    -- FIFO is getting full.
   signal nearly_empty      : std_logic;                    -- FIFO is running empty.
   signal wr_addr_plus2     : unsigned(3 downto 0);         -- Always ahead of the FIFO write address by 2.
   signal wr_addr_plus1     : unsigned(3 downto 0);         -- Always ahead of the FIFO write address by 1.
   signal wr_addr           : unsigned(3 downto 0);         -- FIFO write address.
   signal wr_addrgray       : std_logic_vector(3 downto 0); -- FIFO write address converted to Gray Code.
   signal wag_readsync      : std_logic_vector(3 downto 0); -- wr_addrgray Registered on read clock for the 2nd time.
   signal wr_addrbin        : unsigned(3 downto 0);         -- wag_readsync converted back to binary - on READ clock.
   signal rd_addr_plus2     : unsigned(3 downto 0);         -- Always ahead of the FIFO read address by 2.
   signal rd_addr_plus1     : unsigned(3 downto 0);         -- Always ahead of the FIFO read address by 1.
   signal rd_addr           : unsigned(3 downto 0);         -- FIFO read address.
   signal rd_addrgray       : std_logic_vector(3 downto 0); -- FIFO read address converted to Gray Code.
   signal rag_writesync     : std_logic_vector(3 downto 0); -- rd_addrgray Registered on write clock for the 2nd time.
   signal rd_addrbin        : unsigned(3 downto 0);         -- rag_writesync converted back to binary - on WRITE clock.
   signal tx_en_fifo        : std_logic;                    -- gmii_tx_en_wr read out of FIFO.
   signal tx_er_fifo        : std_logic;                    -- gmii_tx_er_wr read out of FIFO.
   signal txd_fifo          : std_logic_vector(7 downto 0); -- gmii_txd_wr read out of FIFO.
   signal tx_en_fifo_reg1   : std_logic;                    -- Registered version of tx_en_fifo.
   signal tx_er_fifo_reg1   : std_logic;                    -- Registered version of tx_er_fifo.
   signal txd_fifo_reg1     : std_logic_vector(7 downto 0); -- Registered version of txd_fifo.
   signal tx_en_fifo_reg2   : std_logic;                    -- Registered version of tx_en_fifo_reg1.
   signal tx_er_fifo_reg2   : std_logic;                    -- Registered version of tx_er_fifo_reg1.
   signal txd_fifo_reg2     : std_logic_vector(7 downto 0); -- Registered version of txd_fifo_reg1.
   signal wr_occupancy      : unsigned(3 downto 0);         -- The occupancy of the FIFO in write clock domain.
   signal rd_occupancy      : unsigned(3 downto 0);         -- The occupancy of the FIFO in read clock domain.
   signal wr_idle           : std_logic;                    -- Detect an Idle written into the FIFO in the write clock domain.
   signal rd_idle           : std_logic;                    -- Detect an Idle read out of the FIFO in the read clock domain.
   signal ipg_count         : unsigned(3 downto 0);         -- Count the Inter-Packet Gap period.
   signal allow_idle_removal: std_logic;                    -- Allow the removal of a single Idle.



begin



--------------------------------------------------------------------------------
-- FIFO write logic (Idles are removed as necessary).
--------------------------------------------------------------------------------



   -- Create a synchronous reset in the write clock domain.
   gen_wr_reset : gig_eth_pcs_pma_v11_5_reset_sync
   port map(
      clk            => gmii_tx_clk_wr,
      reset_in       => reset,
      reset_out      => reset_wr
   );



   -- Reclock the GMII Tx inputs.
   reclock_gmii: process (gmii_tx_clk_wr)
   begin
      if gmii_tx_clk_wr'event and gmii_tx_clk_wr = '1' then
         if reset_wr = '1' then
            gmii_txd_wr_reg   <= (others => '0');
            gmii_tx_en_wr_reg <= '0';
            gmii_tx_er_wr_reg <= '0';
         else
            gmii_txd_wr_reg   <= gmii_txd_wr;
            gmii_tx_en_wr_reg <= gmii_tx_en_wr;
            gmii_tx_er_wr_reg <= gmii_tx_er_wr;
       end if;
    end if;
   end process reclock_gmii;



   -- Detect Idles (Normal inter-frame encodings as desribed in
   -- IEEE802.3 table 35-2)
   wr_idle <= '1' when (
                       -- 1st type of Idle.
                       (gmii_tx_en_wr = '0' and gmii_tx_er_wr = '0')
                       or
                       -- 2nd type of Idle.
                       (gmii_tx_en_wr = '0' and gmii_tx_er_wr = '1'
                        and gmii_txd_wr = "00000000")

              ) else '0';



   -- Create a counter to count from 0 to 8.  When the counter reaches 8
   -- it is reset to 0 and a pulse is generated (allow_idle_removal).

   -- allow_idle_removal is therefore high for a single clock cycle once
   -- every 9 clock periods.  This is used to ensure that the Idle
   -- removal logic will only ever remove a single idle from a minimum
   -- transmitter interframe gap (12 idles).  This leaves clock
   -- correction potential for other components in the overall system
   -- (the IEEE802.3 spec allows for a total of 4 idles to be lost
   -- between a MAC transmitter and a MAC receiver).
   idle_removal_control: process (gmii_tx_clk_wr)
   begin
      if gmii_tx_clk_wr'event and gmii_tx_clk_wr = '1' then
         if reset_wr = '1' then
            ipg_count          <= "0000";
            allow_idle_removal <= '0';
         else
            if ipg_count(3) = '1' then
               ipg_count          <= "0000";
               allow_idle_removal <= '1';
            else
               ipg_count          <= ipg_count + 1;
               allow_idle_removal <= '0';
            end if;
         end if;
    end if;
   end process idle_removal_control;



   -- Create the FIFO write enable.  This is not asserted when Idles are
   -- to be removed.
   gen_wr_enable: process (gmii_tx_clk_wr)
   begin
      if gmii_tx_clk_wr'event and gmii_tx_clk_wr = '1' then
         if reset_wr = '1' then
            wr_enable <= '0';
         else
            if wr_idle = '1' and allow_idle_removal = '1'
               and nearly_full = '1' then              -- remove 1 Idle.

               wr_enable <= '0';
            else
               wr_enable <= '1';
            end if;
         end if;
    end if;
   end process gen_wr_enable;



   -- Create the FIFO write address pointer.  Note that wr_addr_plus2
   -- will be converted to gray code and passed across the async clock
   -- boundary.
   gen_wr_addr: process (gmii_tx_clk_wr)
   begin
      if gmii_tx_clk_wr'event and gmii_tx_clk_wr = '1' then
         if reset_wr = '1' then
            wr_addr_plus2 <= "0010";
            wr_addr_plus1 <= "0001";
            wr_addr       <= "0000";
         elsif wr_enable = '1' then
            wr_addr_plus2 <= wr_addr_plus2 + 1;
            wr_addr_plus1 <= wr_addr_plus2;
            wr_addr       <= wr_addr_plus1;
         end if;
    end if;
   end process gen_wr_addr;



--------------------------------------------------------------------------------
-- Build FIFO out of distributed RAM.
--------------------------------------------------------------------------------



   gen_txd_fifo:
   for i in 7 downto 0 generate
      dist_ram: ram16x1d
      port map (
            d          => gmii_txd_wr_reg(i),
            we         => wr_enable,
            wclk       => gmii_tx_clk_wr,
            a0         => wr_addr(0),
            a1         => wr_addr(1),
            a2         => wr_addr(2),
            a3         => wr_addr(3),
            dpra0      => rd_addr(0),
            dpra1      => rd_addr(1),
            dpra2      => rd_addr(2),
            dpra3      => rd_addr(3),

            spo        => open,
            dpo        => txd_fifo(i)
      );
   end generate;



   gen_tx_en_fifo: ram16x1d
   port map (
         d          => gmii_tx_en_wr_reg,
         we         => wr_enable,
         wclk       => gmii_tx_clk_wr,
         a0         => wr_addr(0),
         a1         => wr_addr(1),
         a2         => wr_addr(2),
         a3         => wr_addr(3),
         dpra0      => rd_addr(0),
         dpra1      => rd_addr(1),
         dpra2      => rd_addr(2),
         dpra3      => rd_addr(3),

         spo        => open,
         dpo        => tx_en_fifo
   );



   gen_tx_er_fifo: ram16x1d
   port map (
         d          => gmii_tx_er_wr_reg,
         we         => wr_enable,
         wclk       => gmii_tx_clk_wr,
         a0         => wr_addr(0),
         a1         => wr_addr(1),
         a2         => wr_addr(2),
         a3         => wr_addr(3),
         dpra0      => rd_addr(0),
         dpra1      => rd_addr(1),
         dpra2      => rd_addr(2),
         dpra3      => rd_addr(3),

         spo        => open,
         dpo        => tx_er_fifo
   );



--------------------------------------------------------------------------------
-- FIFO read logic (Idles are repeated as necessary).
--------------------------------------------------------------------------------



   -- Create a synchronous reset in the read clock domain.
   gen_rd_reset : gig_eth_pcs_pma_v11_5_reset_sync
   port map(
      clk            => gmii_tx_clk_rd,
      reset_in       => reset,
      reset_out      => reset_rd
   );



   -- Register the FIFO outputs.
   drive_new_gmii: process (gmii_tx_clk_rd)
   begin
      if gmii_tx_clk_rd'event and gmii_tx_clk_rd = '1' then
         if reset_rd = '1' then
            txd_fifo_reg1      <= (others => '0');
            tx_en_fifo_reg1    <= '0';
            tx_er_fifo_reg1    <= '0';
            txd_fifo_reg2      <= (others => '0');
            tx_en_fifo_reg2    <= '0';
            tx_er_fifo_reg2    <= '0';

         elsif rd_enable = '1' then
            txd_fifo_reg1      <= txd_fifo;
            tx_en_fifo_reg1    <= tx_en_fifo;
            tx_er_fifo_reg1    <= tx_er_fifo;
            txd_fifo_reg2      <= txd_fifo_reg1;
            tx_en_fifo_reg2    <= tx_en_fifo_reg1;
            tx_er_fifo_reg2    <= tx_er_fifo_reg1;
       end if;                              
    end if;
   end process drive_new_gmii;



   -- Route GMII outputs, now synchronous to gmii_tx_clk_rd.
   gmii_txd_rd   <= txd_fifo_reg2;
   gmii_tx_en_rd <= tx_en_fifo_reg2;
   gmii_tx_er_rd <= tx_er_fifo_reg2;



   -- Detect Idles (Normal inter-frame encodings as desribed in
   -- IEEE802.3 table 35-2)
   rd_idle <= '1' when (
                       -- 1st type of Idle.
                       (tx_en_fifo_reg1 = '0' and tx_er_fifo_reg1 = '0')
                       or
                       -- 2nd type of Idle.
                       (tx_en_fifo_reg1 = '0' and tx_er_fifo_reg1 = '1'
                        and txd_fifo_reg1 = "00000000")

              ) else '0';



   -- Create the FIFO read enable.  This is not asserted when Idles are
   -- to be repeated.
   gen_rd_enable: process (gmii_tx_clk_rd)
   begin
      if gmii_tx_clk_rd'event and gmii_tx_clk_rd = '1' then
         if reset_rd = '1' then
            rd_enable <= '0';
         else
            if rd_idle = '1'            -- Detect an Idle
            and nearly_empty = '1' then -- when FIFO is running empty.

               -- Repeat the Idle by freezing read pointer of FIFO (as
               -- many times as necessary).
               rd_enable <= '0';

            else
               rd_enable <= '1';
            end if;
         end if;
    end if;
   end process gen_rd_enable;



   -- Create the FIFO read address pointer.  Note that rd_addr_plus2
   -- will be converted to gray code and passed across the async clock
   -- boundary.
   gen_rd_addr: process (gmii_tx_clk_rd)
   begin
      if gmii_tx_clk_rd'event and gmii_tx_clk_rd = '1' then
         if reset_rd = '1' then
            rd_addr_plus2 <= "0010";
            rd_addr_plus1 <= "0001";
            rd_addr       <= "0000";
         elsif rd_enable = '1' then
            rd_addr_plus2 <= rd_addr_plus2 + 1;
            rd_addr_plus1 <= rd_addr_plus2;
            rd_addr       <= rd_addr_plus1;
         end if;
    end if;
   end process gen_rd_addr;



--------------------------------------------------------------------------------
-- Create nearly_full threshold in write clock domain.
--------------------------------------------------------------------------------

-- Please refer to Xilinx Application Note 131 for a complete
-- description of this logic.



   -- Convert Binary Read Pointer to Gray Code.
   rd_addrgray_bits: process (gmii_tx_clk_rd)
   begin
      if gmii_tx_clk_rd'event and gmii_tx_clk_rd = '1' then
         if reset_rd = '1' then
            rd_addrgray    <= (others => '0');
         else
            rd_addrgray(3) <= rd_addr_plus2(3);
            rd_addrgray(2) <= rd_addr_plus2(3) xor rd_addr_plus2(2);
            rd_addrgray(1) <= rd_addr_plus2(2) xor rd_addr_plus2(1);
            rd_addrgray(0) <= rd_addr_plus2(1) xor rd_addr_plus2(0);
       end if;
    end if;
   end process rd_addrgray_bits;



   -- Register rd_addrgray on gmii_tx_clk_wr.  By reclocking the gray
   -- code, the worst case senario is that the reclocked value is only
   -- in error by -1, since only 1 bit at a time changes between gray
   -- code increment.
   reclock_rd_addrgray:    
   for j in 3 downto 0 generate
   
      sync_rd_addrgray: gig_eth_pcs_pma_v11_5_sync_block
      port map (
         clk       => gmii_tx_clk_wr,
         data_in   => rd_addrgray(j),
         data_out  => rag_writesync(j)
      );
   end generate;



   -- Convert rag_writesync Gray Code read address back to binary.
   -- This has crossed clock domains from gmii_tx_clk_rd to
   -- gmii_tx_clk_wr.
   rd_addrbin(3) <= rag_writesync(3);
   rd_addrbin(2) <= rag_writesync(3) xor rag_writesync(2);

   rd_addrbin(1) <= rag_writesync(3) xor rag_writesync(2)
                    xor rag_writesync(1);

   rd_addrbin(0) <= rag_writesync(3) xor rag_writesync(2)
                    xor rag_writesync(1) xor rag_writesync(0);



   -- Determine the occupancy of the FIFO.  One clock of latency is
   -- created here by registering wr_occupancy.
   gen_wr_occupancy: process (gmii_tx_clk_wr)
   begin
      if gmii_tx_clk_wr'event and gmii_tx_clk_wr = '1' then
         wr_occupancy <= wr_addr - rd_addrbin;

      end if;
   end process gen_wr_occupancy;



   -- Set nearly_full flag if FIFO occupancy is greater than
   -- upper_threshold.
   gen_nearly_full : process (wr_occupancy)
   begin
      if wr_occupancy > upper_threshold then
         nearly_full <= '1';
      else
         nearly_full <= '0';
      end if;
   end process gen_nearly_full;



--------------------------------------------------------------------------------
-- Create nearly_empty threshold logic in read clock domain.
--------------------------------------------------------------------------------

-- Please refer to Xilinx Application Note 131 for a complete
-- description of this logic.



   -- Convert Binary Write Pointer to Gray Code.
   wr_addrgray_bits: process (gmii_tx_clk_wr)
   begin
      if gmii_tx_clk_wr'event and gmii_tx_clk_wr = '1' then
         if reset_wr = '1' then
            wr_addrgray    <= (others => '0');
         else
            wr_addrgray(3) <= wr_addr_plus2(3);
            wr_addrgray(2) <= wr_addr_plus2(3) xor wr_addr_plus2(2);
            wr_addrgray(1) <= wr_addr_plus2(2) xor wr_addr_plus2(1);
            wr_addrgray(0) <= wr_addr_plus2(1) xor wr_addr_plus2(0);
       end if;
    end if;
   end process wr_addrgray_bits;



   -- Register wr_addrgray on gmii_tx_clk_rd.  By reclocking the gray
   -- code, the worst case senario is that the reclocked value is only
   -- in error by -1, since only 1 bit at a time changes between gray
   -- code increment.
   reclock_wr_addrgray:    
   for k in 3 downto 0 generate
   
      sync_wr_addrgray: gig_eth_pcs_pma_v11_5_sync_block
      port map (
         clk       => gmii_tx_clk_rd,
         data_in   => wr_addrgray(k),
         data_out  => wag_readsync(k)
      );
   end generate;



   -- Convert wag_readsync Gray Code write address back to binary.
   -- This has crossed clock domains from gmii_tx_clk_wr to
   -- gmii_tx_clk_rd.
   wr_addrbin(3) <= wag_readsync(3);
   wr_addrbin(2) <= wag_readsync(3) xor wag_readsync(2);

   wr_addrbin(1) <= wag_readsync(3) xor wag_readsync(2)
                    xor wag_readsync(1);

   wr_addrbin(0) <= wag_readsync(3) xor wag_readsync(2)
                    xor wag_readsync(1) xor wag_readsync(0);



   -- Determine the occupancy of the FIFO.  One clock of latency is
   -- created here by registering rd_occupancy.
   gen_rd_occupancy: process (gmii_tx_clk_rd)
   begin
      if gmii_tx_clk_rd'event and gmii_tx_clk_rd = '1' then
         rd_occupancy <= wr_addrbin - rd_addr;

      end if;
   end process gen_rd_occupancy;



   -- Set nearly_empty flag if FIFO occupancy is less than
   -- lower_threshold.
   gen_nearly_empty : process (rd_occupancy)
   begin
      if rd_occupancy < lower_threshold then
         nearly_empty <= '1';
      else
         nearly_empty <= '0';
      end if;
   end process gen_nearly_empty;



end rtl;

