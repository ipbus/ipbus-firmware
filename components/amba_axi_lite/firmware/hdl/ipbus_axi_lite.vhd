-------------------------------------------------------------------------------
-- File       : ipbus_axi_lite.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: IP Bus to AXI-Lite Bridge
-------------------------------------------------------------------------------
-- Copyright (c) 2018, The Board of Trustees of the Leland Stanford Junior 
-- University, through SLAC National Accelerator Laboratory (subject to receipt 
-- of any required approvals from the U.S. Dept. of Energy). All rights reserved. 
-- Redistribution and use in source and binary forms, with or without 
-- modification, are permitted provided that the following conditions are met:
--  
-- (1) Redistributions of source code must retain the above copyright notice, 
--     this list of conditions and the following disclaimer. 
-- 
-- (2) Redistributions in binary form must reproduce the above copyright notice, 
--     this list of conditions and the following disclaimer in the documentation 
--     and/or other materials provided with the distribution. 
-- 
-- (3) Neither the name of the Leland Stanford Junior University, SLAC National 
--     Accelerator Laboratory, U.S. Dept. of Energy nor the names of its 
--     contributors may be used to endorse or promote products derived from this 
--     software without specific prior written permission. 
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER, THE UNITED STATES GOVERNMENT, 
-- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
-- OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING 
-- IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY 
-- OF SUCH DAMAGE.
-- 
-- You are under no obligation whatsoever to provide any bug fixes, patches, or 
-- upgrades to the features, functionality or performance of the source code 
-- ("Enhancements") to anyone; however, if you choose to make your Enhancements 
-- available either publicly, or directly to SLAC National Accelerator Laboratory, 
-- without imposing a separate written license agreement for such Enhancements, 
-- then you hereby grant the following license: a non-exclusive, royalty-free 
-- perpetual license to install, use, modify, prepare derivative works, incorporate
-- into other computer software, distribute, and sublicense such Enhancements or 
-- derivative works thereof, in binary and source code form.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.ipbus.all;
use work.ipbus_trans_decl.all;

entity ipbus_axi_lite is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clock and Reset
      clk           :     std_logic;
      rst           :     std_logic;
      -- IP Bus Master Interface
      ipb_out       : in  ipb_wbus;
      ipb_in        : out ipb_rbus;
      ipb_req       : in  std_logic;
      ipb_grant     : out std_logic;
      -- AXI-Lite Slave Read Interface
      s_axi_araddr  : out std_logic_vector(31 downto 0);
      s_axi_arprot  : out std_logic_vector(2 downto 0);
      s_axi_arvalid : out std_logic;
      s_axi_rready  : out std_logic;
      s_axi_arready : in  std_logic;
      s_axi_rdata   : in  std_logic_vector(31 downto 0);
      s_axi_rresp   : in  std_logic_vector(1 downto 0);
      s_axi_rvalid  : in  std_logic;
      -- AXI-Lite Slave Write Interface
      s_axi_awaddr  : out std_logic_vector(31 downto 0);
      s_axi_awprot  : out std_logic_vector(2 downto 0);
      s_axi_awvalid : out std_logic;
      s_axi_wdata   : out std_logic_vector(31 downto 0);
      s_axi_wstrb   : out std_logic_vector(3 downto 0);
      s_axi_wvalid  : out std_logic;
      s_axi_bready  : out std_logic;
      s_axi_awready : in  std_logic;
      s_axi_wready  : in  std_logic;
      s_axi_bresp   : in  std_logic_vector(1 downto 0);
      s_axi_bvalid  : in  std_logic);
end ipbus_axi_lite;

architecture rtl of ipbus_axi_lite is

   type StateType is (
      IDLE_S,
      WR_DATA_S,
      RD_DATA_S);

   type RegType is record
      state         : StateType;
      -- IP Bus Interface
      ipb_in        : ipb_rbus;
      ipb_grant     : std_logic;
      -- AXI-Lite Slave Read Interface
      s_axi_araddr  : std_logic_vector(31 downto 0);
      s_axi_arvalid : std_logic;
      s_axi_rready  : std_logic;
      -- AXI-Lite Slave Write Interface
      s_axi_awaddr  : std_logic_vector(31 downto 0);
      s_axi_awvalid : std_logic;
      s_axi_wdata   : std_logic_vector(31 downto 0);
      s_axi_wvalid  : std_logic;
      s_axi_bready  : std_logic;
   end record;

   constant REG_INIT_C : RegType := (
      state         => IDLE_S,
      -- IP Bus Interface
      ipb_in        => IPB_RBUS_NULL,
      ipb_grant     => '0',
      -- AXI-Lite Slave Read Interface
      s_axi_araddr  => (others => '0'),
      s_axi_arvalid => '0',
      s_axi_rready  => '0',
      -- AXI-Lite Slave Write Interface
      s_axi_awaddr  => (others => '0'),
      s_axi_awvalid => '0',
      s_axi_wdata   => (others => '0'),
      s_axi_wvalid  => '0',
      s_axi_bready  => '0');

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (ipb_out, r, rst, s_axi_arready, s_axi_awready, s_axi_bresp,
                   s_axi_bvalid, s_axi_rdata, s_axi_rresp, s_axi_rvalid,
                   s_axi_wready) is
      variable v : RegType;
   begin
      -- Latch the current value   
      v := r;

      -- Reset strobes
      v.ipb_in.ipb_ack := '0';
      v.ipb_in.ipb_err := '0';

      -- AXI-Lite Flow control
      if (s_axi_arready = '1') then
         v.s_axi_arvalid := '0';
      end if;
      v.s_axi_rready := '0';
      if (s_axi_awready = '1') then
         v.s_axi_awvalid := '0';
      end if;
      if (s_axi_wready = '1') then
         v.s_axi_wvalid := '0';
      end if;
      v.s_axi_bready := '0';

      -- Write State Machine
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Ready for next IP bus transaction
            v.ipb_grant := '1';
            -- Check if IP transaction and ready to accept the transaction
            if (ipb_out.ipb_strobe = '1') and (r.ipb_in.ipb_ack = '0') then
               -- Reset the flag while processing the transaction
               v.ipb_grant    := '0';
               -- Convert from 32-bit word address to byte address
               v.s_axi_araddr := ipb_out.ipb_addr(29 downto 0) & "00";
               v.s_axi_awaddr := ipb_out.ipb_addr(29 downto 0) & "00";
               -- Register the WDATA bus
               v.s_axi_awaddr := ipb_out.ipb_wdata;
               -- Check for read or write
               if (ipb_out.ipb_write = '1') then
                  -- Start the Write transaction
                  v.s_axi_awvalid := '1';
                  v.s_axi_wvalid  := '1';
                  -- Next State
                  v.state         := WR_DATA_S;
               else
                  -- Start the Read transaction
                  v.s_axi_arvalid := '1';
                  -- Next State
                  v.state         := RD_DATA_S;
               end if;
            end if;
         ----------------------------------------------------------------------
         when WR_DATA_S =>
            -- Wait for the transaction to complete
            if (r.s_axi_awvalid = '0') and (r.s_axi_wvalid = '0') and (s_axi_bvalid = '1') then
               -- Accept the bus transaction
               v.s_axi_bready := '1';
               -- Check for bus error
               if (s_axi_bresp /= 0) then
                  v.ipb_in.ipb_err := '1';
               end if;
               -- Acknowledge the IP bus transaction
               v.ipb_in.ipb_ack := '1';
               -- Next State
               v.state          := IDLE_S;
            end if;
         ----------------------------------------------------------------------
         when RD_DATA_S =>
            -- Wait for the transaction to complete
            if (r.s_axi_awvalid = '0') and (s_axi_rvalid = '1') then
               -- Accept the bus transaction
               v.s_axi_rready     := '1';
               -- Register the data value
               v.ipb_in.ipb_rdata := s_axi_rdata;
               -- Check for bus error
               if (s_axi_rresp /= 0) then
                  v.ipb_in.ipb_err := '1';
               end if;
               -- Acknowledge the IP bus transaction
               v.ipb_in.ipb_ack := '1';
               -- Next State
               v.state          := IDLE_S;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Outputs
      ipb_in        <= r.ipb_in;
      ipb_grant     <= r.ipb_grant;
      s_axi_araddr  <= r.s_axi_araddr;
      s_axi_arprot  <= "000";  -- IP bus doesn't support "protection control"
      s_axi_arvalid <= r.s_axi_arvalid;
      s_axi_rready  <= v.s_axi_rready;  -- Combinatorial output
      s_axi_awaddr  <= r.s_axi_awaddr;
      s_axi_awprot  <= "000";  -- IP bus doesn't support "protection control"
      s_axi_awvalid <= r.s_axi_awvalid;
      s_axi_wdata   <= r.s_axi_wdata;
      s_axi_wstrb   <= x"F";  -- IP bus only support 32-bit write transaction (byte level transactions not supported)
      s_axi_wvalid  <= r.s_axi_wvalid;
      s_axi_bready  <= v.s_axi_bready;  -- Combinatorial output

      -- Reset
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
