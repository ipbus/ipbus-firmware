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