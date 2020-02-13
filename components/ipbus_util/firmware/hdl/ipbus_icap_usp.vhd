--======================================================================
-- IPbus wrapper for the Xilinx UltraScale(+) ICAPE3 primitive to
-- trigger a programmatic firmware reload (from a specified address)
-- using the IPROG command.
-- ======================================================================

library ieee;
use ieee.std_logic_1164.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_icap_usp is
  port (
    clk : in std_logic;
    rst : in std_logic;
    ipb_in : in ipb_wbus;
    ipb_out : out ipb_rbus
  );
end ipbus_icap_usp;

architecture rtl of ipbus_icap_usp is

  signal ctrl : ipb_reg_v(1 downto 0);

  signal d17, d17_d : std_logic;
  signal want_reconf, want_reconf_d : std_logic;
  signal base_address_i : std_logic_vector(31 downto 0);
  signal trigger_reconf : std_logic;

begin

  csr : entity work.ipbus_ctrlreg_v
    generic map (
      N_CTRL => 2,
      N_STAT => 0
    )
    port map (
      clk       => clk,
      reset     => rst,
      ipbus_in  => ipb_in,
      ipbus_out => ipb_out,
      d         => open,
      q         => ctrl
    );

  clk_div: entity work.ipbus_clock_div
    port map (
      clk => clk,
      d17 => d17
    );

  -- Just delay the reconfiguration trigger a bit. Just enough to
  -- nicely handle the IPbus reply.
  trigger_delay : process(clk) is
  begin
    if rising_edge(clk) then
      d17_d <= d17;
      if d17='1' and d17_d='0' then
        trigger_reconf <= want_reconf_d;
        want_reconf_d <= want_reconf;
      end if;
    end if;
  end process;

  icap_actor : entity work.icap_usp
    port map (
      clk => clk,
      rst => rst,
      base_address => base_address_i,
      reconfigure => trigger_reconf
    );

  base_address_i <= ctrl(0);
  want_reconf <= ctrl(1)(0);

end rtl;

-- ======================================================================
