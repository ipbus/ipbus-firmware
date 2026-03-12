library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;

library altera_lnsim;
use altera_lnsim.altera_lnsim_components.all;

entity clocks_agilex7 is
    port(
        -- Clock
        clk          : in  std_logic;   -- Input 100MHz Clk
        global_rst   : in  std_logic;
        --
        mac_clk      : out std_logic;
        mac_half_clk : out std_logic;
        mac_rst      : out std_logic;
        --
        ipb_clk      : out std_logic;
        ipb_rst      : out std_logic;
        ipb_ctrl_rst : out std_logic;
        --
        ipb_nuke     : in  std_logic;
        ipb_soft_rst : in  std_logic;
        --
        locked       : out std_logic
    );
end entity clocks_agilex7;

architecture rtl of clocks_agilex7 is

    component iopll is
        port(
            refclk      : in  std_logic := 'X';
            locked      : out std_logic;
            rst         : in  std_logic := 'X';
            clock_125   : out std_logic;
            clock_62_5  : out std_logic;
            clock_31_25 : out std_logic
        );
    end component iopll;

    signal i_mac_clk, i_ipb_clk : std_logic;
    signal i_locked             : std_logic := '0';

    signal g_rst_d1, g_rst, rst, rst_d1, srst                                                  : std_logic                      := '1';
    signal i_mac_rst, i_mac_rst_d1, i_ipb_rst, i_ipb_rst_d1, i_ipb_ctrl_rst, i_ipb_ctrl_rst_d1 : std_logic                      := '1';
    signal i_nuke, i_nuke_d2, i_nuke_d3, i_nuke_d4                                             : std_logic                      := '0';
    signal i_nuke_delay                                                                        : std_logic_vector(127 downto 0) := (others => '0');
    signal rctr                                                                                : unsigned(3 downto 0)           := "0000";

begin

    -- Global Reset Syncornisation

    proc_global_rst : process(clk) is
    begin
        if rising_edge(clk) then
            g_rst    <= global_rst;
            g_rst_d1 <= g_rst;
        end if;
    end process proc_global_rst;

    -- Clocks

    -- The Paramatizable Macro IOPLL is not compiling currenty so an IP based IOPLL is being used

    -- Documentation :
    -- https://www.intel.com/content/www/us/en/docs/programmable/772350/
    -- Macro Location :
    -- $QUARTUS_ROOTDIR/eda/sim_lib/altera_lnsim_components.vhd

    -- inst_mac_iopll : IPM_IOPLL
    --     generic map(
    --         REFERENCE_CLOCK_FREQUENCY => "100.0 MHz",
    --         N_CNT                     => 1,
    --         M_CNT                     => 10,
    --         C0_CNT                    => 8,
    --         C1_CNT                    => 16,
    --         C2_CNT                    => 32,
    --         OPERATION_MODE            => "direct",
    --         PLL_SIM_MODEL             => "Agilex 7 (I-Series)"
    --     )
    --     port map(
    --         refclk  => clk,                 -- 100MHz input
    --         reset   => g_rst_d1,
    --         outclk0 => i_mac_clk,           -- 125MHz output
    --         outclk1 => mac_half_clk,        -- 62.5MHz output
    --         outclk2 => i_ipb_clk,           -- 31.25MHz output
    --         locked  => i_locked
    --     );

    inst_mac_iopll : component iopll
        port map(
            refclk      => clk,
            locked      => i_locked,
            rst         => g_rst_d1,
            clock_125   => i_mac_clk,
            clock_62_5  => mac_half_clk,
            clock_31_25 => i_ipb_clk
        );

    mac_clk <= i_mac_clk;
    ipb_clk <= i_ipb_clk;

    locked <= i_locked;

    -- Resets

    -- Generate hard reset signal
    proc_hard_rst : process(clk) is
    begin
        if rising_edge(clk) then
            i_nuke_d3 <= i_nuke_d2;
            i_nuke_d4 <= i_nuke_d3;

            rst    <= i_nuke_d4 or g_rst_d1 or not i_locked;
            rst_d1 <= rst;
        end if;
    end process proc_hard_rst;

    -- Generate MAC reset signal
    proc_mac_rst : process(i_mac_clk) is
    begin
        if rising_edge(i_mac_clk) then
            i_mac_rst    <= rst_d1;
            i_mac_rst_d1 <= i_mac_rst;
        end if;
    end process proc_mac_rst;

    mac_rst <= i_mac_rst_d1;

    -- Generate IPB slave reset signal for soft and hard reset
    srst <= '1' when rctr /= "0000" else '0';

    proc_ipb_rst : process(i_ipb_clk) is
    begin
        if rising_edge(i_ipb_clk) then
            i_ipb_rst    <= rst_d1 or srst;
            i_ipb_rst_d1 <= i_ipb_rst;

            if srst = '1' or ipb_soft_rst = '1' then
                rctr <= rctr + 1;
            end if;

            i_nuke       <= ipb_nuke;   -- delay (allows return packet to be sent)
            i_nuke_delay <= i_nuke_delay(i_nuke_delay'high - 1 downto i_nuke_delay'low) & i_nuke;
            i_nuke_d2    <= i_nuke_delay(i_nuke_delay'high);
        end if;
    end process proc_ipb_rst;

    ipb_rst <= i_ipb_rst_d1;

    -- Generate IPB infra reset signal for hard reset
    proc_ipb_ctrl_rst : process(i_ipb_clk) is
    begin
        if rising_edge(i_ipb_clk) then
            i_ipb_ctrl_rst    <= rst_d1;
            i_ipb_ctrl_rst_d1 <= i_ipb_ctrl_rst;
        end if;
    end process proc_ipb_ctrl_rst;

    ipb_ctrl_rst <= i_ipb_ctrl_rst_d1;

end architecture rtl;
