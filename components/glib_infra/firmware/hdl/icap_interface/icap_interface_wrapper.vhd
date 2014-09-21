--=================================================================================================--
--==================================== Module Information =========================================--
--=================================================================================================--
--																																  	--
-- Company:  					CERN (PH-ESE-BE)																			--
-- Engineer: 					Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros@ieee.org)	--
-- 																																--
-- Create Date:		    	12/01/2012     																			--
-- Project Name:				icap_interface																				--
-- Module Name:   		 	icap_interface_wrapper						 											--
-- 																																--
-- Language:					VHDL'93																						--
--																																	--
-- Target Devices: 			GLIB (Virtex 6)																			--
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
entity icap_interface_wrapper is
	port (	
		-- Control:
		RESET_I										: in  std_logic;
		CONF_TRIGG_I								: in  std_logic;
		FSM_CONF_PAGE_I							: in  std_logic_vector(1 downto 0);
		-- IPBus Inteface:			
		IPBUS_CLK_I									: in  std_logic;
		IPBUS_INV_CLK_I							: in  std_logic;
		IPBUS_I										: in 	ipb_wbus;
		IPBUS_O										: out ipb_rbus	
	);
end icap_interface_wrapper;
architecture structural of icap_interface_wrapper is	
	--======================== Signal Declarations ========================--
	-- Internal Configuration Access Port(ICAP) Interface:
	signal icapCs_from_ioControl				: std_logic;
	signal icapWrite_from_ioControl			: std_logic;
	signal icapData_from_ioControl			: std_logic_vector(31 downto 0);
	signal data_from_icapInterface			: std_logic_vector(31 downto 0);
	signal ack_from_icapInterface				: std_logic;
	-- FPGA Configuration Finite State Machine:
	signal select_from_fsm						: std_logic;
	signal cs_from_fsm							: std_logic;
	signal write_from_fsm						: std_logic;
	signal data_from_fsm							: std_logic_vector(31 downto 0);
	signal fsmAck_from_ioControl				: std_logic;	
	--=====================================================================--
--========================================================================--
-----		  --===================================================--
begin		--================== Architecture Body ==================-- 
-----		  --===================================================--
--========================================================================--
	--===================== Component Instantiations ======================--
	-- I/O Control:
	ioControl: entity work.flashIcap_ioControl
		port map (			
			-- Control:	
			FSM_SELECT_I							=> select_from_fsm,
			-- Logic Fabric:				
			IPBUS_I									=> IPBUS_I,
			IPBUS_O									=> IPBUS_O,			
			-- FSM:			
			FSM_CS_I									=> cs_from_fsm,
			FSM_WRITE_I								=> write_from_fsm,
			FSM_DATA_I								=> data_from_fsm,
			FSM_ACK_O								=> fsmAck_from_ioControl,
			-- ICAP:			
		   ICAP_CS_O								=> icapCs_from_ioControl,
			ICAP_WRITE_O							=> icapWrite_from_ioControl,
			ICAP_DATA_O								=> icapData_from_ioControl,		
		   ICAP_DATA_I								=> data_from_icapInterface,		
		   ICAP_ACK_I								=> ack_from_icapInterface		
		);
	-- Internal Configuration Access Port(ICAP) Interface:
	icapInterface: entity work.icap_interface
		port map (	
			RESET_I	 								=> RESET_I,
			CLK_I										=> IPBUS_CLK_I,
			INV_CLK_I								=>	IPBUS_INV_CLK_I,				
			CS_I										=>	icapCs_from_ioControl,
			WRITE_I									=>	icapWrite_from_ioControl,	
			DATA_I   								=> icapData_from_ioControl,
			DATA_O  									=> data_from_icapInterface,
			ACK_O										=> ack_from_icapInterface
		);	
	-- FPGA Configuration Finite State Machine:
	confFsm: entity work.icap_interface_fsm
		port map (	
			RESET_I	 								=> RESET_I,
			CLK_I										=> IPBUS_CLK_I,
			CONF_TRIGG_I							=> CONF_TRIGG_I,			
			FSM_CONF_PAGE_I						=> FSM_CONF_PAGE_I,
			FMS_SELECT_O							=> select_from_fsm,			
			CS_O										=> cs_from_fsm, 
			WRITE_O  								=> write_from_fsm, 
			DATA_O   								=> data_from_fsm,
			ACK_I										=> fsmAck_from_ioControl	
		);		
	--=====================================================================--	
end structural;
--=================================================================================================--
--=================================================================================================--