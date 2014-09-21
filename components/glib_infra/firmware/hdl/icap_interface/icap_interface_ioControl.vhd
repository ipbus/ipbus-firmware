--=================================================================================================--
--==================================== Module information =========================================--
--=================================================================================================--
--																																  	--
-- Company:  					CERN (PH-ESE-BE)																			--
-- Engineer: 					Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros@ieee.org)	--
-- 																																--
-- Create Date:		    	12/01/2012     																			--
-- Project Name:				icap_interface																            --
-- Module Name:   		 	icap_interface_ioControl 									   	               --
-- 																																--
-- Language:					VHDL'93																						--
--																																	--
-- Target Devices: 			Virtex 6																						--
-- Tool versions: 			ISE 13.2																						--
--																																	--
-- Revision:		 			1.0 																							--
--																																	--
-- Additional Comments: 																									--
--                                                                                                 -- 
--=================================================================================================--
--=================================================================================================--
-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Xilinx devices library:
library unisim;
use unisim.vcomponents.all;
-- User libraries and packages:
use work.ipbus.all;
--=================================================================================================--
--======================================= Module Body =============================================-- 
--=================================================================================================--
entity flashIcap_ioControl is	
	port (	
		-- Control:		
		FSM_SELECT_I							: in  std_logic;
		-- Logic Fabric:
		IPBUS_I									: in  ipb_wbus;
		IPBUS_O									: out ipb_rbus;		
		-- Flash:		
		FSM_CS_I									: in  std_logic;
		FSM_WRITE_I								: in  std_logic;
		FSM_DATA_I								: in  std_logic_vector(31 downto 0);
		FSM_ACK_O 								: out std_logic;												
		-- ICAP:			
		ICAP_CS_O								: out std_logic;
		ICAP_WRITE_O							: out std_logic;
		ICAP_DATA_O								: out std_logic_vector(31 downto 0);
		ICAP_DATA_I								: in  std_logic_vector(31 downto 0);	
		ICAP_ACK_I								: in  std_logic
	);
end flashIcap_ioControl;
architecture structural of flashIcap_ioControl is	
--========================================================================--
-----		  --===================================================--
begin		--================== Architecture Body ==================-- 
-----		  --===================================================--
--========================================================================--
	--========================= Port Assignments ==========================--
	IPBUS_O.ipb_err							<= '0'; 
	IPBUS_O.ipb_rdata							<= ICAP_DATA_I;
	--=====================================================================--	
	--============================ User Logic =============================--	
	-- Multiplexors:
		-- CS:		
		ICAP_CS_O								<= FSM_CS_I when FSM_SELECT_I = '1'
														else IPBUS_I.ipb_strobe;		
		-- WRITE:
		ICAP_WRITE_O							<= FSM_WRITE_I when FSM_SELECT_I = '1'
														else IPBUS_I.ipb_write;		
		-- DATA to ICAP:
		ICAP_DATA_O								<= FSM_DATA_I when FSM_SELECT_I = '1'
														else IPBUS_I.ipb_wdata;		
		-- ACK:		
			-- IPBus:
			IPBUS_O.ipb_ack					<= '0' when FSM_SELECT_I = '1'
														else ICAP_ACK_I;			
			-- FSM:
			FSM_ACK_O							<= ICAP_ACK_I when FSM_SELECT_I = '1'
														else '0';																	
	--=====================================================================--	
end structural;
--=================================================================================================--
--=================================================================================================--