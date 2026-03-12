library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;

entity eth_agilex7_tse is
    port(
        -- Clock
        mac_clk           : in  std_logic; -- 125MHz Clk
        mac_half_clk      : in  std_logic; -- 62.5MHz Clk
        refclk            : in  std_logic; -- 156.25MHz F-Tile Clk
        -- Reset
        mac_rst           : in  std_logic;
        phy_rst           : in  std_logic;
        -- Serial Interface
        rx_serial_data    : in  std_logic;
        rx_serial_data_n  : in  std_logic;
        tx_serial_data    : out std_logic;
        tx_serial_data_n  : out std_logic;
        -- Receive AXI Stream
        mac_rx_data       : out std_logic_vector(7 downto 0);
        mac_rx_last       : out std_logic;
        mac_rx_sop        : out std_logic;
        mac_rx_valid      : out std_logic;
        -- Transmit AXI Stream
        mac_tx_data       : in  std_logic_vector(7 downto 0);
        mac_tx_last       : in  std_logic;
        mac_tx_error      : in  std_logic;
        mac_tx_ready      : out std_logic;
        mac_tx_valid      : in  std_logic;
        -- Status Leds
        led_crs           : out std_logic;
        led_link          : out std_logic;
        led_panel_link    : out std_logic;
        led_col           : out std_logic;
        led_an            : out std_logic;
        led_char_err      : out std_logic;
        led_disp_err      : out std_logic;
        -- Status Signals
        mac_syspll_locked : out std_logic;
        channel_tx_ready  : out std_logic;
        channel_rx_ready  : out std_logic
    );
end entity eth_agilex7_tse;

architecture rtl of eth_agilex7_tse is

    component tse_sys is
        port(
            clock_125_clk                                          : in  std_logic                     := 'X';
            clock_62_5_clk                                         : in  std_logic                     := 'X';
            mac_reset_reset                                        : in  std_logic                     := 'X';
            syspll_synthlock_out_systempll_synthlock               : out std_logic;
            syspll_refclk_fgt_in_refclk_fgt_0                      : in  std_logic                     := 'X';
            syspll_disable_refclk_monitor_disable_refclk_monitor_0 : in  std_logic                     := 'X';
            mac_receive_data                                       : out std_logic_vector(7 downto 0);
            mac_receive_endofpacket                                : out std_logic;
            mac_receive_error                                      : out std_logic_vector(5 downto 0);
            mac_receive_ready                                      : in  std_logic                     := 'X';
            mac_receive_startofpacket                              : out std_logic;
            mac_receive_valid                                      : out std_logic;
            mac_transmit_data                                      : in  std_logic_vector(7 downto 0)  := (others => 'X');
            mac_transmit_endofpacket                               : in  std_logic                     := 'X';
            mac_transmit_error                                     : in  std_logic                     := 'X';
            mac_transmit_ready                                     : out std_logic;
            mac_transmit_startofpacket                             : in  std_logic                     := 'X';
            mac_transmit_valid                                     : in  std_logic                     := 'X';
            mac_misc_connection_ff_tx_crc_fwd                      : in  std_logic                     := 'X';
            mac_misc_connection_ff_tx_septy                        : out std_logic;
            mac_misc_connection_tx_ff_uflow                        : out std_logic;
            mac_misc_connection_ff_tx_a_full                       : out std_logic;
            mac_misc_connection_ff_tx_a_empty                      : out std_logic;
            mac_misc_connection_rx_err_stat                        : out std_logic_vector(17 downto 0);
            mac_misc_connection_rx_frm_type                        : out std_logic_vector(3 downto 0);
            mac_misc_connection_ff_rx_dsav                         : out std_logic;
            mac_misc_connection_ff_rx_a_full                       : out std_logic;
            mac_misc_connection_ff_rx_a_empty                      : out std_logic;
            tse_control_port_readdata                              : out std_logic_vector(31 downto 0);
            tse_control_port_read                                  : in  std_logic                     := 'X';
            tse_control_port_writedata                             : in  std_logic_vector(31 downto 0) := (others => 'X');
            tse_control_port_write                                 : in  std_logic                     := 'X';
            tse_control_port_waitrequest                           : out std_logic;
            tse_control_port_address                               : in  std_logic_vector(7 downto 0)  := (others => 'X');
            mac_leds_led_crs                                       : out std_logic;
            mac_leds_led_link                                      : out std_logic;
            mac_leds_led_panel_link                                : out std_logic;
            mac_leds_led_col                                       : out std_logic;
            mac_leds_led_an                                        : out std_logic;
            mac_leds_led_char_err                                  : out std_logic;
            mac_leds_led_disp_err                                  : out std_logic;
            mac_tx_serial_data_tx_serial_data                      : out std_logic_vector(0 downto 0);
            mac_tx_serial_data_n_tx_serial_data_n                  : out std_logic_vector(0 downto 0);
            mac_rx_serial_data_rx_serial_data                      : in  std_logic_vector(0 downto 0)  := (others => 'X');
            mac_rx_serial_data_n_rx_serial_data_n                  : in  std_logic_vector(0 downto 0)  := (others => 'X');
            phy_rx_is_lockedtodata_rx_is_lockedtodata              : out std_logic_vector(0 downto 0);
            phy_reset_tx_ack_tx_reset_ack                          : out std_logic;
            phy_reset_rx_ack_rx_reset_ack                          : out std_logic;
            phy_reset_tx_in_tx_reset                               : in  std_logic                     := 'X';
            phy_reset_rx_in_rx_reset                               : in  std_logic                     := 'X';
            phy_tx_ready_tx_ready                                  : out std_logic;
            phy_rx_ready_rx_ready                                  : out std_logic
        );
    end component tse_sys;

    constant c_rx_ready_delay : integer := 20;

    signal mac_tx_sop, i_mac_tx_ready, i_mac_rx_ready, i_mac_rx_valid, i_mac_rx_last : std_logic;
    signal sop_status                                                                : std_logic := '1';

    signal mac_rx_last_d1, mac_rx_valid_alert, mac_rx_valid_alert_d1, mac_rx_valid_alert_d2 : std_logic;

    signal i_tx_serial_data, i_tx_serial_data_n : std_logic_vector(0 downto 0);
    signal i_rx_serial_data, i_rx_serial_data_n : std_logic_vector(0 downto 0);

    signal rx_is_lockedtodata                 : std_logic_vector(0 downto 0);
    signal phy_reset_tx_ack, phy_reset_rx_ack : std_logic;
    signal tx_ready, rx_ready                 : std_logic;

    type   t_state is (s_start, s_PCS_IF_mode, s_PCS_control, s_MAC_address_MSB, s_MAC_address_LSB, s_MAC_SW_rst, s_MAC_SW_rst_delay, s_MAC_command_config, s_finish, s_readback);
    signal state   : t_state;

    signal tse_waitrequest, tse_write, tse_read  : std_logic;
    signal tse_writedata, tse_readdata, readback : std_logic_vector(31 downto 0);
    signal tse_address                           : std_logic_vector(7 downto 0);

begin

    -- TSE system

    inst_tse_sys : component tse_sys
        port map(
            clock_125_clk                                          => mac_clk,
            clock_62_5_clk                                         => mac_half_clk,
            mac_reset_reset                                        => mac_rst,
            --                                      
            syspll_synthlock_out_systempll_synthlock               => mac_syspll_locked,
            syspll_refclk_fgt_in_refclk_fgt_0                      => refclk,
            syspll_disable_refclk_monitor_disable_refclk_monitor_0 => '0',
            --
            mac_receive_data                                       => mac_rx_data,
            mac_receive_endofpacket                                => i_mac_rx_last,
            mac_receive_error                                      => open,
            mac_receive_ready                                      => i_mac_rx_ready,
            mac_receive_startofpacket                              => mac_rx_sop,
            mac_receive_valid                                      => i_mac_rx_valid,
            --
            mac_transmit_data                                      => mac_tx_data,
            mac_transmit_endofpacket                               => mac_tx_last,
            mac_transmit_error                                     => mac_tx_error,
            mac_transmit_ready                                     => i_mac_tx_ready,
            mac_transmit_startofpacket                             => mac_tx_sop,
            mac_transmit_valid                                     => mac_tx_valid,
            --
            tse_control_port_readdata                              => tse_readdata,
            tse_control_port_read                                  => tse_read,
            tse_control_port_writedata                             => tse_writedata,
            tse_control_port_write                                 => tse_write,
            tse_control_port_waitrequest                           => tse_waitrequest,
            tse_control_port_address                               => tse_address,
            --
            mac_misc_connection_ff_tx_crc_fwd                      => '0',
            mac_misc_connection_ff_tx_septy                        => open,
            mac_misc_connection_tx_ff_uflow                        => open,
            mac_misc_connection_ff_tx_a_full                       => open,
            mac_misc_connection_ff_tx_a_empty                      => open,
            mac_misc_connection_rx_err_stat                        => open,
            mac_misc_connection_rx_frm_type                        => open,
            mac_misc_connection_ff_rx_dsav                         => open,
            mac_misc_connection_ff_rx_a_full                       => open,
            mac_misc_connection_ff_rx_a_empty                      => open,
            --
            mac_leds_led_crs                                       => led_crs,
            mac_leds_led_link                                      => led_link,
            mac_leds_led_panel_link                                => led_panel_link,
            mac_leds_led_col                                       => led_col,
            mac_leds_led_an                                        => led_an,
            mac_leds_led_char_err                                  => led_char_err,
            mac_leds_led_disp_err                                  => led_disp_err,
            --
            mac_tx_serial_data_tx_serial_data                      => i_tx_serial_data,
            mac_tx_serial_data_n_tx_serial_data_n                  => i_tx_serial_data_n,
            mac_rx_serial_data_rx_serial_data                      => i_rx_serial_data,
            mac_rx_serial_data_n_rx_serial_data_n                  => i_rx_serial_data_n,
            --
            phy_rx_is_lockedtodata_rx_is_lockedtodata              => rx_is_lockedtodata,
            phy_reset_tx_ack_tx_reset_ack                          => phy_reset_tx_ack,
            phy_reset_rx_ack_rx_reset_ack                          => phy_reset_rx_ack,
            phy_reset_tx_in_tx_reset                               => phy_rst,
            phy_reset_rx_in_rx_reset                               => phy_rst,
            phy_tx_ready_tx_ready                                  => tx_ready,
            phy_rx_ready_rx_ready                                  => rx_ready
        );

    tx_serial_data        <= i_tx_serial_data(0);
    tx_serial_data_n      <= i_tx_serial_data_n(0);
    i_rx_serial_data(0)   <= rx_serial_data;
    i_rx_serial_data_n(0) <= rx_serial_data_n;

    channel_tx_ready <= tx_ready and (not phy_reset_tx_ack);
    channel_rx_ready <= rx_ready and (not phy_reset_rx_ack) and rx_is_lockedtodata(0);

    mac_tx_ready <= i_mac_tx_ready;
    mac_rx_last  <= i_mac_rx_last;

    -- Start of packet (SOP) generator
    mac_tx_sop <= sop_status and mac_tx_valid;
    proc_sop_gen : process(mac_clk)
    begin
        if rising_edge(mac_clk) then
            if mac_rst = '1' then
                sop_status <= '1';
            else
                if sop_status = '1' then
                    -- next valid transfer marks start of a packet
                    sop_status <= not (mac_tx_valid and i_mac_tx_ready);
                else
                    -- packet transmission going on
                    sop_status <= i_mac_tx_ready and mac_tx_valid and mac_tx_last;
                end if;
            end if;
        end if;
    end process proc_sop_gen;

    -- Explanation for the process below:
    -- The UDP interface in ipb_ctrl uses an rx_reset signal to reset all of the sate machines to ready them to start on a new packet.
    -- This reset signal is generated 12 clk cycles after tlast is asserted.
    -- If a new packet comes in before this occures the reset is never generated as it is only asserted if tvalid is low.
    -- This means the state machines are in an invalid state and the packet is dropped.
    -- Using tready to apply 20 clk cycles of back pressure after tlast allows the UDP interface to reset.
    --
    -- This introduces a new issue where the TSE IP pulses tvalid high for one clk cycle if a new packet is available.
    -- If this occures while tready is low it will not be output again when tready is asserted lieading to the MAC address validation failing.
    -- By detecting this tvalid pulse and emitting it before trady is asserted it allows the wave to match what would occur on a clean new packet arriving.
    -- However there is a 2 clk cycle delay bettween tready being asserted and tvalid being assetted by the TSE IP which leads to the payload data being
    -- generated by the UDP interface to be malformed. Thios is due to the two clk cycle gap bettween the inital tvalid pulse and the mid transmission tvalid.
    -- Adding a two clk delay to the tvalid alert pulse solves this.
    --
    -- The tvalid input to the ipb_ctrl entity follows tvalid if tready is asserted which blocks the alert pulse during the reset process.
    -- The delayd allert pulse is then added back to this signal.

    -- Apply back pressure for 20 clks after tlast recived to allow time for rx_reset to trigger in ipb_ctrl
    proc_rx_ready : process(mac_clk)
        variable ready_delay           : integer   := c_rx_ready_delay;
        variable next_packet_available : std_logic := '0';
    begin
        if rising_edge(mac_clk) then
            mac_rx_last_d1 <= i_mac_rx_last;

            mac_rx_valid_alert_d1 <= mac_rx_valid_alert; -- 2 clock delay for the TSE IP to assert rx_valid after rx_ready assertion
            mac_rx_valid_alert_d2 <= mac_rx_valid_alert_d1;

            if mac_rst = '1' then
                ready_delay := c_rx_ready_delay;
            elsif mac_rx_last_d1 = '1' and i_mac_rx_last = '0' then
                ready_delay := 0;
            end if;

            if ready_delay < c_rx_ready_delay then
                i_mac_rx_ready <= '0';
                ready_delay    := ready_delay + 1;

                -- TSE ip pulses valid when a new packet is available
                -- If this is detected during the reset period pass this pulse on to ipb_ctrl be for asserting rx_ready
                if i_mac_rx_valid = '1' then
                    next_packet_available := '1';
                end if;

                if ready_delay = c_rx_ready_delay then
                    mac_rx_valid_alert <= next_packet_available;
                else
                    mac_rx_valid_alert <= '0';
                end if;
            else
                i_mac_rx_ready        <= '1';
                mac_rx_valid_alert    <= '0';
                next_packet_available := '0';
            end if;
        end if;
    end process;

    -- Modified tvalid signal for ipb_ctrl
    mac_rx_valid <= (i_mac_rx_valid and i_mac_rx_ready) or mac_rx_valid_alert_d2;

    -- TSE register config FSM

    proc_MAC_init_FSM : process(mac_clk) is
        variable fsm_delay_counter : integer range 0 to 1000 := 0;
    begin
        if rising_edge(mac_clk) then
            if mac_rst = '1' then
                state             <= s_start;
                fsm_delay_counter := 0;
            else
                case state is
                    when s_start =>
                        fsm_delay_counter := fsm_delay_counter + 1;

                        if fsm_delay_counter = 1000 then
                            fsm_delay_counter := 0;
                            state             <= s_PCS_IF_mode;
                        end if;

                    when s_PCS_IF_mode =>
                        if tse_waitrequest = '0' then
                            state <= s_PCS_control;
                        end if;

                    when s_PCS_control =>
                        if tse_waitrequest = '0' then
                            state <= s_MAC_address_MSB;
                        end if;

                    when s_MAC_address_MSB =>
                        if tse_waitrequest = '0' then
                            state <= s_MAC_address_LSB;
                        end if;

                    when s_MAC_address_LSB =>
                        if tse_waitrequest = '0' then
                            state <= s_MAC_SW_rst;
                        end if;

                    when s_MAC_SW_rst =>
                        if tse_waitrequest = '0' then
                            state <= s_MAC_SW_rst_delay;
                        end if;

                    when s_MAC_SW_rst_delay =>
                        fsm_delay_counter := fsm_delay_counter + 1;

                        if fsm_delay_counter = 1000 then
                            fsm_delay_counter := 0;
                            state             <= s_MAC_command_config;
                        end if;

                    when s_MAC_command_config =>
                        if tse_waitrequest = '0' then
                            state <= s_finish;
                        end if;

                    when s_finish =>
                        null;

                    when s_readback =>
                        if tse_waitrequest = '0' then
                            readback <= tse_readdata;
                            state    <= s_finish;
                        end if;

                end case;
            end if;
        end if;
    end process proc_MAC_init_FSM;

    proc_MAC_init_FSM_output : process(state) is
    begin
        tse_read      <= '0';
        tse_write     <= '0';
        tse_address   <= (others => '0');
        tse_writedata <= (others => '0');

        case state is
            when s_start =>
                tse_read      <= '0';
                tse_write     <= '0';
                tse_address   <= (others => '0');
                tse_writedata <= (others => '0');

            -- <IF Mode> - Addr 0x14
            -- Enable SGMII mode
            -- Disable SGMII AN
            -- SGMII speed: 1G
            when s_PCS_IF_mode =>
                tse_read      <= '0';
                tse_write     <= '1';
                tse_address   <= x"94";
                tse_writedata <= x"00000009";

            -- <Control> - Addr 0x00
            -- Speed: 1G
            -- AN Enable: False
            -- SW Reset: True (This will be deasserted after reset leading to the following command validation check failing)
            when s_PCS_control =>
                tse_read      <= '0';
                tse_write     <= '1';
                tse_address   <= x"80";
                tse_writedata <= x"00008140";

            -- Set MAC Address: 00:07:ED:50:D9:EE
            -- 0x03 : 50ED0700
            -- 0x04 : 0000EED9
            when s_MAC_address_MSB =>
                tse_read      <= '0';
                tse_write     <= '1';
                tse_address   <= x"03";
                tse_writedata <= x"50ED0700";

            when s_MAC_address_LSB =>
                tse_read      <= '0';
                tse_write     <= '1';
                tse_address   <= x"04";
                tse_writedata <= x"0000EED9";

            -- <Command Config> - Addr 0x02
            -- Eth Speed: 1G
            -- Forward pause frames: True
            -- Accept control frames: True
            -- Disable read timeout: True (?)
            -- Software reset (This will be deasserted after reset leading to the following command validation check failing)
            when s_MAC_SW_rst =>
                tse_read      <= '0';
                tse_write     <= '1';
                tse_address   <= x"02";
                tse_writedata <= x"08802088";

            when s_MAC_SW_rst_delay =>
                tse_read      <= '0';
                tse_write     <= '0';
                tse_address   <= (others => '0');
                tse_writedata <= (others => '0');

            -- Previous config except SW reset
            -- Enable TX and RX datapaths
            when s_MAC_command_config =>
                tse_read      <= '0';
                tse_write     <= '1';
                tse_address   <= x"02";
                tse_writedata <= x"0880008B";

            when s_finish =>
                tse_read      <= '0';
                tse_write     <= '0';
                tse_address   <= (others => '0');
                tse_writedata <= (others => '0');

            when s_readback =>
                tse_read    <= '1';
                tse_write   <= '0';
                tse_address <= x"02";

        end case;
    end process;

end architecture rtl;
