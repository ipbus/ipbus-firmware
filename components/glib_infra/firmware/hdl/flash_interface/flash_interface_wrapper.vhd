---------------------------------------------------------------------------------
--
--   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
--                                     - - -
--
--   Additional information about ipbus-firmare and the list of ipbus-firmware
--   contacts are available at
--
--       https://ipbus.web.cern.ch/ipbus
--
---------------------------------------------------------------------------------


--=================================================================================================--
--==================================== Module Information =========================================--
--=================================================================================================--
--																																  	--
-- Company:  					CERN (PH-ESE-BE)																			--
-- Engineer: 					Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros@ieee.org)	--
-- 																																--
-- Create Date:		    	12/01/2012     																			--
-- Project Name:				flash_interface																			--
-- Module Name:   		 	flash_interface_wrapper								 									--
-- 																																--
-- Language:					VHDL'93																						--
--																																	--
-- Target Devices: 			GLIB (Virtex 6)																			--
-- Tool versions: 			ISE 13.2																						--
--																																	--
-- Revision:		 			1.0 																							--
--																																	--
-- Additional Comments: 																									--
--																																   --
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
use work.flash_package.all;
--=================================================================================================--
--======================================= Module Body =============================================-- 
--=================================================================================================--
entity flash_interface_wrapper is
	port (	
		-- Control:
		RESET_I									: in  std_logic;
		-- IPBus Inteface:			
		IPBUS_CLK_I								: in  std_logic;
		IPBUS_I									: in 	ipb_wbus;
		IPBUS_O									: out ipb_rbus;		
		-- Platform Flash:			
		FLASH_I									: in  rFlashR;
		FLASH_O									: out wFlashR
	);
end flash_interface_wrapper;
architecture structural of flash_interface_wrapper is
	--======================== Signal Declarations ========================--	
	signal data_from_flashInterface		: std_logic_vector(15 downto 0);
	--=====================================================================--	
--========================================================================--
-----		  --===================================================--
begin		--================== Architecture Body ==================-- 
-----		  --===================================================--
--========================================================================--
	--========================= Port Assignments ==========================--
	IPBUS_O.ipb_err 							<= '0';
	IPBUS_O.ipb_rdata							<= x"0000" & data_from_flashInterface;
	--=====================================================================--	
	--===================== Component Instantiations ======================--
	-- Flash Interface:
	flashInterface: entity work.flash_interface
		port map (
			RESET_I 								=> RESET_I,
			CLK_I 								=> IPBUS_CLK_I,
			CS_I 									=> IPBUS_I.ipb_strobe,
			WRITE_I 								=> IPBUS_I.ipb_write,
			ADDR_I 								=> IPBUS_I.ipb_addr(22 downto 0),
			DATA_I 								=> IPBUS_I.ipb_wdata(15 downto 0),
			DATA_O 								=> data_from_flashInterface,
			DONE_O 								=> IPBUS_O.ipb_ack,
			FLASH_I 								=> FLASH_I,
			FLASH_O 								=> FLASH_O			
		);			
	--=====================================================================--	
end structural;
--=================================================================================================--
--=================================================================================================--