LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY neo430;
USE neo430.neo430_package.all;

ENTITY ipbus_neo430_wrapper IS
  GENERIC( 
    CLOCK_SPEED : natural := 12000000;
    UID_I2C_ADDR : std_logic_vector(7 downto 0) := x"53" -- Address on I2C bus of E24AA025E
    );
  PORT( 
    clk_i      : IN     std_logic;                      -- global clock, rising edge
    rst_i      : IN     std_logic;                      -- global reset, async, active high
    uart_txd_o : OUT    std_logic;                      -- UART from NEO to host
    uart_rxd_i : IN     std_logic;                      -- from host to NEO UART
    leds       : OUT    std_logic_vector (3 DOWNTO 0);  -- status LEDs
    scl_o      : OUT    std_logic;                      -- I2C clock from NEO
    scl_i      : IN     std_logic;                      -- the actual state of the line back to NEO
    sda_o      : OUT    std_logic;                      -- I2C data from NEO
    sda_i      : IN     std_logic;
    ip_addr_o  : OUT    std_logic_vector(31 downto 0);  -- IP address to give to IPBus core
    mac_addr_o : OUT    std_logic_vector(47 downto 0);  -- MAC address to give to IPBus core
    ipbus_rst_o: OUT    std_logic                       -- Reset line to IPBus core
    );

-- Declarations

END ENTITY ipbus_neo430_wrapper ;

architecture rtl of ipbus_neo430_wrapper is

  signal wb_adr_o_int   : std_logic_vector(31 downto 0);
  signal wb_dat_i_int   : std_logic_vector(31 downto 0);
  signal wb_dat_o_int   : std_logic_vector(31 downto 0);
  signal wb_we_o_int    : std_logic;
  signal wb_sel_o_int   : std_logic_vector(03 downto 0);
  signal wb_stb_o_int   : std_logic;
  signal wb_cyc_o_int   : std_logic;
  signal wb_ack_i_int   : std_logic;

  signal s_i2c_data   : std_logic_vector(7 downto 0); -- Data from I2C controller
  signal s_mac_addr_data : std_logic_vector(31 downto 0); -- data from IP/MAC address block
  signal s_i2c_ack , s_mac_addr_ack : std_logic; -- ACK from WB blocks
  signal s_pio: std_logic_vector(15 downto 0);
  signal s_i2c_addr : std_logic_vector(2 downto 0); -- need 3 bits for I2C master.
  signal s_ipmac_ni2c_flag : std_logic; -- high if addressing MAC/IP output. Low for I2C
  
  --attribute mark_debug : string; 
  --attribute mark_debug of  wb_adr_o_int , wb_dat_i_int , wb_dat_o_int , wb_stb_o_int , wb_ack_i_int , s_i2c_ack , s_mac_addr_ack , s_i2c_addr , s_ipmac_ni2c_flag : signal is "true";

begin  -- architecture rtl

  -- -----------------------------------------------------------------------------
  -- neo430_inst : entity work.neo430_top_std_logic_noz
  neo430_inst : entity work.neo430_top_std_logic
    generic map (
      -- general configuration --
      CLOCK_SPEED => CLOCK_SPEED,       -- main clock in Hz
      IMEM_SIZE   => 6*1024,  -- internal IMEM size in bytes, max 32kB (default=4kB)
      DMEM_SIZE   => 2*1024,  -- internal DMEM size in bytes, max 28kB (default=2kB)
      -- additional configuration --
      USER_CODE   => x"BEAD",           -- custom user code
      -- module configuration --
      -- DADD_USE    => false,  -- implement DADD instruction? (default=true)
      MULDIV_USE  => false,  -- implement multiplier/divider unit? (default=true)
      WB32_USE    => true,              -- implement WB32 unit? (default=true)
      WDT_USE     => false,             -- implement WDT? (default=true)
      GPIO_USE    => true,              -- implement GPIO unit? (default=true)
      TIMER_USE   => false,             -- implement timer? (default=true)
      UART_USE    => true,              -- implement USART? (default=true)
      TWI_USE     => false,  -- implement two wire serial interface? (default=true)
      CRC_USE     => false,             -- implement CRC unit? (default=true)
      PWM_USE     => false,  -- implement PWM controller? (default=true)
      EXIRQ_USE   => false,              -- implement EXIRQ? (default=true)
      SPI_USE     => false, -- implement SPI? (default=true)
      FREQ_GEN_USE => false,
      -- boot configuration --
      -- BOOTLD_USE  => true,              -- implement and use bootloader? (default=true)
      -- IMEM_AS_ROM => false              -- implement IMEM as read-only memory? (default=false)
      BOOTLD_USE  => false,  -- implement and use bootloader? (default=true)
      IMEM_AS_ROM => true  -- implement IMEM as read-only memory? (default=false)
      )
    port map (
      -- global control --
      clk_i      => clk_i,              -- global clock, rising edge
      rst_i      => not rst_i,          -- global reset, async, high active
      -- gpio --
      gpio_o             => s_pio,        -- status LEDs
      gpio_i(7 downto 0) => UID_I2C_ADDR, -- address on I2C bus of PROM
      
      -- serial com --
      uart_txd_o => uart_txd_o,         -- UART send data
      uart_rxd_i => uart_rxd_i,         -- UART receive data

      -- SPI
      spi_sclk_o => open,               -- serial clock line
      spi_mosi_o => open,               -- serial data line out
      spi_miso_i => '0',                -- serial data line in
      spi_cs_o   => open,               -- SPI CS 0..5
      
      -- 32-bit wishbone interface --
      wb_adr_o   => wb_adr_o_int,               -- address
      wb_dat_i   => wb_dat_i_int,        -- read data
      wb_dat_o   => wb_dat_o_int,               -- write data
      wb_we_o    => wb_we_o_int,               -- read/write
      wb_sel_o   => wb_sel_o_int,               -- byte enable
      wb_stb_o   => wb_stb_o_int,               -- strobe
      wb_cyc_o   => wb_cyc_o_int,               -- valid cycle
      wb_ack_i   => wb_ack_i_int,                -- transfer acknowledge

      -- I2C lines. Not used
      --twi_sda_o => open,             -- twi serial data line
      --twi_scl_o => open,              -- twi serial clock line
      --twi_sda_i => '1',             -- twi serial data line
      --twi_scl_i => '1',              -- twi serial clock line

      -- -- external interrupt --
      ext_irq_i     => ( others => '0'),                 -- external interrupt request line
      ext_ack_o => open  -- external interrupt request acknowledge
      );


  leds <= s_pio(3 downto 0);

  s_i2c_addr        <= wb_adr_o_int(4 downto 2); -- to cope with byte/word shift in NEO divide addresses by 4. 
  s_ipmac_ni2c_flag <= wb_adr_o_int(8); -- if bit 8 set then MAC/IP output
  
  cmp_i2c: entity work.i2c_master_top port map(
    wb_clk_i => clk_i,
    wb_rst_i => rst_i,
    arst_i => '1',
    wb_adr_i => s_i2c_addr,
    wb_dat_i => wb_dat_o_int(7 downto 0),
    wb_dat_o => s_i2c_data,
    wb_we_i => wb_we_o_int,
    wb_stb_i => wb_stb_o_int and (not s_ipmac_ni2c_flag) and not s_i2c_ack,
    wb_cyc_i => '1',
    wb_ack_o => s_i2c_ack,
    scl_pad_i => scl_i,
    scl_padoen_o => scl_o,
    sda_pad_i => sda_i,
    sda_padoen_o => sda_o
    );

  -- Multiplex Wishbone busses based on wb_addr(4). 0=I2C, 1=MAC/IP
  wb_ack_i_int <=             s_i2c_ack  when s_ipmac_ni2c_flag='0' else s_mac_addr_ack;
  wb_dat_i_int <= x"000000" & s_i2c_data when s_ipmac_ni2c_flag='0' else s_mac_addr_data;

  cmp_mac_ip_output: entity work.wb_ip_mac_output
    generic map (
      dat_sz  => 32 -- wb_dat_i_int'length;
      )
    port map (

      clk_i  => clk_i,
      rst_i  => rst_i,
      --
      -- Wishbone Interface
      --
      dat_i  => wb_dat_o_int,  -- data into core
      dat_o  => s_mac_addr_data, -- data out of core
      adr_i  => wb_adr_o_int(5 downto 4), -- ......X. bits (5..4) of address
      we_i   => wb_we_o_int, 
      ack_o  => s_mac_addr_ack,  
      err_o  => open,
      stb_i  => wb_stb_o_int and s_ipmac_ni2c_flag,
      --
      -- IP , MAC addresses
      --
      ip_addr_o  => ip_addr_o  , -- IP address to give to IPBus core
      mac_addr_o => mac_addr_o  ,-- MAC address to give to IPBus core
      ipbus_rst_o => ipbus_rst_o  
      );


end architecture rtl;
