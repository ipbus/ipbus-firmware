---------------------------------------------------------------------------------
-- Address decode logic for IPbus fabric.
--
-- This file has been AUTOGENERATED from the address table - do not
-- hand edit.
--
-- We assume the synthesis tool is clever enough to recognise
-- exclusive conditions in the if statement.
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ipbus_decode_ipbus_sysmon_usp is

-- START automatically generated VHDL (Wed Feb 21 13:58:51 2024)
  constant IPBUS_SEL_WIDTH: positive := 2;
-- END automatically generated VHDL

  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_ipbus_sysmon_usp(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically generated VHDL (Wed Feb 21 13:58:51 2024)
  constant N_SLV_CSR: integer := 0;
  constant N_SLV_DRP: integer := 1;
  constant N_SLAVES: integer := 2;
-- END automatically generated VHDL

end ipbus_decode_ipbus_sysmon_usp;

package body ipbus_decode_ipbus_sysmon_usp is

  function ipbus_sel_ipbus_sysmon_usp(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically generated VHDL (Wed Feb 21 13:58:51 2024)
    if    std_match(addr, "-----------------------0--------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_CSR, IPBUS_SEL_WIDTH)); -- csr / base 0x00000000 / mask 0x00000100
    elsif std_match(addr, "-----------------------1--------") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_DRP, IPBUS_SEL_WIDTH)); -- drp / base 0x00000100 / mask 0x00000100
    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;
-- END automatically generated VHDL

    return sel;

  end function ipbus_sel_ipbus_sysmon_usp;

end ipbus_decode_ipbus_sysmon_usp;

---------------------------------------------------------------------------------
