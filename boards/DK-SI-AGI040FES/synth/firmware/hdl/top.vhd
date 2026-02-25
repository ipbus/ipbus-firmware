library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;

entity top is
    port(
        -- Clock
        clk              : in  std_logic; -- 100MHz Clk
        refclk           : in  std_logic; -- 156.25MHz F-Tile Clk
        -- Serial Interface
        rx_serial_data   : in  std_logic;
        rx_serial_data_n : in  std_logic;
        tx_serial_data   : out std_logic;
        tx_serial_data_n : out std_logic
    );
end entity top;

architecture rtl of top is

    component reset_release is
        port(
            ninit_done : out std_logic
        );
    end component reset_release;

    component probe is
        port(
            probe : in std_logic_vector(9 downto 0) := (others => 'X')
        );
    end component probe;

    signal mac_addr : std_logic_vector(47 downto 0);
    signal ip_addr  : std_logic_vector(31 downto 0);

    signal ninit_done                                 : std_logic;
    signal global_rst, mac_rst, ipb_rst, ipb_ctrl_rst : std_logic;

    signal mac_iopll_locked, mac_syspll_locked : std_logic;
    signal mac_clk, mac_half_clk, ipb_clk      : std_logic;

    signal mac_tx_data, mac_rx_data                              : std_logic_vector(7 downto 0);
    signal mac_tx_valid, mac_tx_last, mac_tx_error, mac_tx_ready : std_logic;
    signal mac_rx_valid, mac_rx_last                             : std_logic;

    signal led_crs, led_link, led_panel_link, led_col, led_an, led_char_err, led_disp_err : std_logic;

    signal channel_tx_ready, channel_rx_ready : std_logic;

    signal ipb_nuke, ipb_soft_rst, ipb_userled : std_logic;
    signal ipb_out                             : ipb_wbus;
    signal ipb_in                              : ipb_rbus;

begin

    mac_addr <= X"0007ed50d9ee";
    ip_addr  <= X"c0a8c811";

    -- Clock and Reset

    inst_reset_release : component reset_release
        port map(
            ninit_done => ninit_done
        );

    global_rst <= ninit_done;

    inst_clock_gen : entity work.clocks_agilex7
        port map(
            clk          => clk,
            global_rst   => global_rst,
            mac_clk      => mac_clk,
            mac_half_clk => mac_half_clk,
            mac_rst      => mac_rst,
            ipb_clk      => ipb_clk,
            ipb_rst      => ipb_rst,
            ipb_ctrl_rst => ipb_ctrl_rst,
            ipb_nuke     => ipb_nuke,
            ipb_soft_rst => ipb_soft_rst,
            locked       => mac_iopll_locked
        );

    -- TSE system

    inst_eth_if : entity work.eth_agilex7_tse
        port map(
            mac_clk           => mac_clk,
            mac_half_clk      => mac_half_clk,
            refclk            => refclk,
            mac_rst           => mac_rst,
            phy_rst           => global_rst,
            --
            rx_serial_data    => rx_serial_data,
            rx_serial_data_n  => rx_serial_data_n,
            tx_serial_data    => tx_serial_data,
            tx_serial_data_n  => tx_serial_data_n,
            --
            mac_rx_data       => mac_rx_data,
            mac_rx_last       => mac_rx_last,
            mac_rx_valid      => mac_rx_valid,
            --
            mac_tx_data       => mac_tx_data,
            mac_tx_last       => mac_tx_last,
            mac_tx_error      => mac_tx_error,
            mac_tx_ready      => mac_tx_ready,
            mac_tx_valid      => mac_tx_valid,
            --
            led_crs           => led_crs,
            led_link          => led_link,
            led_panel_link    => led_panel_link,
            led_col           => led_col,
            led_an            => led_an,
            led_char_err      => led_char_err,
            led_disp_err      => led_disp_err,
            mac_syspll_locked => mac_syspll_locked,
            channel_tx_ready  => channel_tx_ready,
            channel_rx_ready  => channel_rx_ready
        );

    -- IPBus UDP interface

    ipbus_ctrl : entity work.ipbus_ctrl
        port map(
            mac_clk      => mac_clk,
            rst_macclk   => mac_rst,
            ipb_clk      => ipb_clk,
            rst_ipb      => ipb_ctrl_rst,
            mac_rx_data  => mac_rx_data,
            mac_rx_valid => mac_rx_valid,
            mac_rx_last  => mac_rx_last,
            mac_rx_error => '0',
            mac_tx_data  => mac_tx_data,
            mac_tx_valid => mac_tx_valid,
            mac_tx_last  => mac_tx_last,
            mac_tx_error => mac_tx_error,
            mac_tx_ready => mac_tx_ready,
            ipb_out      => ipb_out,
            ipb_in       => ipb_in,
            mac_addr     => mac_addr,
            ip_addr      => ip_addr,
            pkt          => open
        );

    -- IPB Payload

    ipbus_payload : entity work.ipbus_example
        port map(
            ipb_clk  => ipb_clk,
            ipb_rst  => ipb_rst,
            ipb_in   => ipb_out,
            ipb_out  => ipb_in,
            nuke     => ipb_nuke,
            soft_rst => ipb_soft_rst,
            userled  => ipb_userled
        );

    -- Probes

    channel_probe : component probe
        port map(
            probe => mac_rst & ipb_rst & channel_tx_ready & channel_rx_ready & '0' & '0' & '0' & '0' & '0' & ipb_userled
        );

    led_probe : component probe
        port map(
            probe => led_crs & led_link & led_panel_link & led_col & led_an & led_char_err & led_disp_err & '0' & mac_iopll_locked & mac_syspll_locked
        );

end architecture rtl;
