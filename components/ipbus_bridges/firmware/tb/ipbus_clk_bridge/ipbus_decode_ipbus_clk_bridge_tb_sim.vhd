-- Address decode logic for ipbus fabric
-- 
-- This file has been AUTOGENERATED from the address table - do not hand edit
-- 
-- We assume the synthesis tool is clever enough to recognise exclusive conditions
-- in the if statement.
-- 
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

package ipbus_decode_ipbus_clk_bridge_tb_sim is

  constant IPBUS_SEL_WIDTH: positive := 3;
  subtype ipbus_sel_t is std_logic_vector(IPBUS_SEL_WIDTH - 1 downto 0);
  function ipbus_sel_ipbus_clk_bridge_tb_sim(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t;

-- START automatically generated VHDL (Sat Oct 29 12:35:44 2022)
  constant N_SLV_REG: integer := 0;
  constant N_SLV_AF_REG: integer := 1;
  constant N_SLV_AS_REG: integer := 2;
  constant N_SLV_RF_REG: integer := 3;
  constant N_SLV_RS_REG: integer := 4;
  constant N_SLV_C_REG: integer := 5;
  constant N_SLAVES: integer := 6;
-- END automatically generated VHDL

    
end ipbus_decode_ipbus_clk_bridge_tb_sim;

package body ipbus_decode_ipbus_clk_bridge_tb_sim is

  function ipbus_sel_ipbus_clk_bridge_tb_sim(addr : in std_logic_vector(31 downto 0)) return ipbus_sel_t is
    variable sel: ipbus_sel_t;
  begin

-- START automatically generated VHDL (Sat Oct 29 12:35:44 2022)
    if    std_match(addr, "-----------------------------000") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_REG, IPBUS_SEL_WIDTH)); -- reg / base 0x00000000 / mask 0x00000007
    elsif std_match(addr, "-----------------------------001") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_AF_REG, IPBUS_SEL_WIDTH)); -- af_reg / base 0x00000001 / mask 0x00000007
    elsif std_match(addr, "-----------------------------010") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_AS_REG, IPBUS_SEL_WIDTH)); -- as_reg / base 0x00000002 / mask 0x00000007
    elsif std_match(addr, "-----------------------------011") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_RF_REG, IPBUS_SEL_WIDTH)); -- rf_reg / base 0x00000003 / mask 0x00000007
    elsif std_match(addr, "-----------------------------100") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_RS_REG, IPBUS_SEL_WIDTH)); -- rs_reg / base 0x00000004 / mask 0x00000007
    elsif std_match(addr, "-----------------------------101") then
      sel := ipbus_sel_t(to_unsigned(N_SLV_C_REG, IPBUS_SEL_WIDTH)); -- c_reg / base 0x00000005 / mask 0x00000007
-- END automatically generated VHDL

    else
        sel := ipbus_sel_t(to_unsigned(N_SLAVES, IPBUS_SEL_WIDTH));
    end if;

    return sel;

  end function ipbus_sel_ipbus_clk_bridge_tb_sim;

end ipbus_decode_ipbus_clk_bridge_tb_sim;
