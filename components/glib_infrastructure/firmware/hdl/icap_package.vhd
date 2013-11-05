--=================================================================================================--
--=================================== Package Information =========================================--
--=================================================================================================--
--																																  	--
-- Company:  					CERN (PH-ESE-BE)																			--
-- Engineer: 					Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros@ieee.org)	--
-- 																																--
-- Create Date:		    	12/01/2011		 																			--
-- Module Name:				icap_interface																	      --
-- Package Name:   		 	icap_package																				--
--																																	--
-- Revision:		 			1.0 																							--
--																																	--
-- Additional Comments: 																									--
--																																	--
--=================================================================================================--
--=================================================================================================--
-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--=================================================================================================--
--====================================== Package Body =============================================-- 
--=================================================================================================--
package icap_package is   
	--======================== Type Declarations ==========================--	
	-- Interface:
	type c_stateT is (c_s0, c_s1);
	type w_stateT is (w_s0, w_s1, w_s2, w_s3, w_s4, w_s5);
	type r_stateT is (r_s0, r_s1, r_s2, r_s3);	
	-- FSM:
	type stateT is (s0, s1, s2, s3, s4);
	type iprog_command_1_3T is array (0 to 4) of std_logic_vector(31 downto 0);	
	type iprog_commandT     is array (0 to 10) of std_logic_vector(31 downto 0);
	--=====================================================================--	
	--===================== Constant Declarations =========================--	
	-- Interface:
	constant IPBUSDELAY				: integer := 2;  -- Minimum latency achievable (2 Cycles)
	-- FSM:
	constant COMMAND_1				: iprog_command_1_3T :=	(x"FFFFFFFF",
																			 x"AA995566",
																			 x"20000000",
																			 x"20000000",
																			 x"30020001");
	constant COMMAND_2 : std_logic_vector(7 downto 0)  :=	(x"14");	-- & Address 																				 
	constant COMMAND_3				: iprog_command_1_3T :=	(x"20000000",
																			 x"30008001", 
																			 x"0000000F",
																			 x"20000000",
																			 x"20000000");																			  
	--=====================================================================--
end icap_package;
--=================================================================================================--
package body icap_package is
end icap_package;
--=================================================================================================--
--=================================================================================================--