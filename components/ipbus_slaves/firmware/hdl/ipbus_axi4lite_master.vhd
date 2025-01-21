--======================================================================
-- ipbus_axi4lite_master
--
-- Interfaces an IPbus master to a Xilinx AXI4-lite bus.
--
-- Written by Jeroen Hegeman.
-- Based on code originally written by Dominique Gigi.
--======================================================================

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.ipbus.all;
use work.ipbus_reg_types.all;

entity ipbus_axi4lite_master is
  generic (
    -- AXI words have an internal granularity of bytes. So that's how
    -- we specify the width on the AXI side. The IPBus side width (or
    -- depth, really) will be derived from this too.
    -- NOTE: Possible values for the AXI side width are 4, 8, ..., 32.
    NUM_BYTES_PER_AXI_WORD : positive := 4
  );
  port (
    -- IPbus side.
    clk : in std_logic;
    rst : in std_logic;
    ipb_in  : in ipb_wbus;
    ipb_out : out ipb_rbus;

    -- AXI side.
    m_axi_clock   : in std_logic;
    m_axi_awaddr  : out std_logic_vector(31 downto 0);
    m_axi_awvalid : out std_logic;
    m_axi_awready : in std_logic;
    m_axi_wdata   : out std_logic_vector(8 * NUM_BYTES_PER_AXI_WORD - 1 downto 0);
    m_axi_wstrb   : out std_logic_vector(NUM_BYTES_PER_AXI_WORD - 1 downto 0);
    m_axi_wvalid  : out std_logic;
    m_axi_wready  : in std_logic;
    m_axi_bresp   : in std_logic_vector(1 downto 0);
    m_axi_bvalid  : in std_logic;
    m_axi_bready  : out std_logic;
    m_axi_araddr  : out std_logic_vector(31 downto 0);
    m_axi_arvalid : out std_logic;
    m_axi_arready : in std_logic;
    m_axi_rdata   : in std_logic_vector(8 * NUM_BYTES_PER_AXI_WORD - 1 downto 0);
    m_axi_rvalid  : in std_logic;
    m_axi_rresp   : in std_logic_vector(1 downto 0);
    m_axi_rready  : out std_logic
  );
end ipbus_axi4lite_master;

architecture behavioral of ipbus_axi4lite_master is

  -- IPBus words are 32 bits wide. Wider AXI sizes lead to greater
  -- depths on the IPBus side.
  constant C_IPBUS_DEPTH : positive := NUM_BYTES_PER_AXI_WORD / 4;

  constant C_ACCESS_MODE_READ  : std_logic := '0';
  constant C_ACCESS_MODE_WRITE : std_logic := '1';

  signal ctrl : ipb_reg_v(10 downto 0);
  signal stat : ipb_reg_v(9 downto 0);

  signal access_mode   : std_logic;
  signal trigger       : std_logic;
  signal access_strobe : std_logic;
  signal trigger_rq_rd : std_logic;
  signal trigger_rq_wr : std_logic;

  signal axi_rq_add  : std_logic_vector(31 downto 0);
  signal axi_rq_strb : std_logic_vector(NUM_BYTES_PER_AXI_WORD - 1 downto 0);
  signal axi_rq_dti  : std_logic_vector(8 * NUM_BYTES_PER_AXI_WORD - 1 downto 0);
  signal axi_rtn_dto : std_logic_vector(8 * NUM_BYTES_PER_AXI_WORD - 1 downto 0);
  signal axi_rq_rd   : std_logic;
  signal axi_rq_wr   : std_logic;
  signal axi_tick    : std_logic;
  signal axi_status  : std_logic_vector(31 downto 0);
  signal axi_done    : std_logic;

begin

  csr : entity work.ipbus_ctrlreg_v
    generic map (
      N_CTRL => ctrl'length,
      N_STAT => stat'length
    )
    port map (
      clk       => clk,
      reset     => rst,
      ipbus_in  => ipb_in,
      ipbus_out => ipb_out,
      q         => ctrl,
      d         => stat
    );

  access_mode <= ctrl(0)(0);
  trigger     <= ctrl(0)(2);
  axi_rq_add  <= ctrl(1);
  axi_rq_strb <= ctrl(2)(NUM_BYTES_PER_AXI_WORD - 1 downto 0);
  axi_tick    <= ctrl(2)(8);
  ctrl_axi_rq_dti : for i in 0 to (C_IPBUS_DEPTH - 1) generate
    axi_rq_dti(32 * (i + 1) - 1 downto 32 * i) <= ctrl(3 + i);
  end generate;

  stat(0) <= std_logic_vector(to_unsigned(NUM_BYTES_PER_AXI_WORD, 32));
  stat(1) <= axi_status;
  stat_axi_rtn_dto : for i in 0 to (C_IPBUS_DEPTH - 1) generate
    stat(2 + i) <= axi_rtn_dto(32 * (i + 1) - 1 downto 32 * i);
  end generate;

  -- Make sure the trigger is a proper strobe.
  pulser : entity work.edge_detector
    port map (
      clk => clk,
      rst => rst,
      signal_in => trigger,
      pulse_out => access_strobe
    );

  trigger_rq_rd <= access_strobe when (access_mode = C_ACCESS_MODE_READ) else '0';
  trigger_rq_wr <= access_strobe when (access_mode = C_ACCESS_MODE_WRITE) else '0';

  pulser_rd : entity work.edge_detector
    port map (
      clk => clk,
      rst => rst,
      signal_in => trigger_rq_rd,
      pulse_out => axi_rq_rd
    );

  pulser_wr : entity work.edge_detector
    port map (
      clk => clk,
      rst => rst,
      signal_in => trigger_rq_wr,
      pulse_out => axi_rq_wr
    );

  axi4lite_interface : entity work.axi4lite_interface
    generic map (
      NUM_BYTES_PER_AXI_WORD => NUM_BYTES_PER_AXI_WORD
    )
    port map (
      -- User interface side.
      reset        => rst,
      usr_clock    => clk,
      usr_add      => axi_rq_add,
      usr_strb     => axi_rq_strb,
      usr_dti      => axi_rq_dti,
      usr_dto      => axi_rtn_dto,
      usr_rdreq    => axi_rq_rd,
      usr_wrreq    => axi_rq_wr,
      usr_axi_tick => axi_tick,
      axi_status   => axi_status,
      axi_done     => axi_done,

      -- AXI side.
      s_axi_clock   => m_axi_clock,
      s_axi_awaddr  => m_axi_awaddr,
      s_axi_awvalid => m_axi_awvalid,
      s_axi_awready => m_axi_awready,
      s_axi_wdata   => m_axi_wdata,
      s_axi_wstrb   => m_axi_wstrb,
      s_axi_wvalid  => m_axi_wvalid,
      s_axi_wready  => m_axi_wready,
      s_axi_bresp   => m_axi_bresp,
      s_axi_bvalid  => m_axi_bvalid,
      s_axi_bready  => m_axi_bready,
      s_axi_araddr  => m_axi_araddr,
      s_axi_arvalid => m_axi_arvalid,
      s_axi_arready => m_axi_arready,
      s_axi_rdata   => m_axi_rdata,
      s_axi_rresp   => m_axi_rresp,
      s_axi_rvalid  => m_axi_rvalid,
      s_axi_rready  => m_axi_rready
    );

end behavioral;

--======================================================================
