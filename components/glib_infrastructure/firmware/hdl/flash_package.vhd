--=================================================================================================--
--=================================== Package Information =========================================--
--=================================================================================================--
--																																  	--
-- Company:  					CERN (PH-ESE-BE)																			--
-- Engineer: 					Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros@ieee.org)	--
-- 																																--
-- Create Date:		    	08/12/2011		 																			--
-- Module Name:				flash_interface																	      --
-- Package Name:   		 	flash_package																				--
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
package flash_package is   
	--======================== Type Declarations ==========================--
	type c_stateT is (c_s0, c_s1, c_s2);
	type w_stateT is (w_s0, w_s1, w_s2, w_s3);
	type r_stateT is (r_s0, r_s1, r_s2);
	--=====================================================================--	
	--======================= Record Declarations =========================--
	type rFlashR is 
		record 
			data							: std_logic_vector(15 downto 0);		
		end record;
	type wFlashR is 
		record 
			l_b							: std_logic;		
		   e_b							: std_logic;		
		   g_b							: std_logic;		
		   w_b							: std_logic;		
		   tristate						: std_logic;
			addr							: std_logic_vector(22 downto 0);	
			data							: std_logic_vector(15 downto 0);		
		end record;	
	--=====================================================================--
	--===================== Constant Declarations =========================--	
	constant IPBUSDELAY				: integer := 2;  -- Minimum latency achievable (2 Cycles)
	constant ADDRLATCHDELAY			: integer := 1;  -- 16ns@62.5MHz (10ns min)					
	constant WRITEDISABLEDELAY		: integer := 4;  -- 64ns@62.5MHz (50ns min)
	constant NEWWRITEDELAY			: integer := 2;  -- 32ns@62.5MHz (25ns min)	
	constant DATAVALIDDELAY			: integer := 6;  -- 96ns@62.5MHz (85ns min)
	--=====================================================================--
end flash_package;
--=================================================================================================--
package body flash_package is
end flash_package;
--=================================================================================================--
--=================================================================================================--