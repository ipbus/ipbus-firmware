-- mp7 <-> uC link for MP7 top
-- Simon Fayer, Imperial College, Feb 2013
-- Updated with bug fixes, June 2013

LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY uclink_mp7 IS
PORT
(
  clk125    : IN std_logic;
  rst       : IN std_logic; -- (clk125 reset)
  -- uC interface (uC clock domain)
  ebi_nwe   : IN std_logic;
  ebi_nrd   : IN std_logic;
  ebi_d     : INOUT std_logic_vector(15 DOWNTO 0) := (OTHERS => 'Z');
  uc_new    : IN std_logic; -- (UC4)
  uc_done   : OUT std_logic := '0'; -- (UC3)
  -- IPBus interface (clk125 domain)
  --- Data to packet buffer
  buf_wdata : OUT std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
  --- Write enable
  buf_we    : OUT std_logic := '0';
  --- Data from packet buffer
  buf_rdata : IN std_logic_vector(15 DOWNTO 0);
  --- Read enable
  buf_re    : OUT std_logic := '0';
  --- Request to start processing packet
  buf_req   : OUT std_logic := '0';
  --- Processed packet data available
  buf_done  : IN std_logic := '0'
);
END ENTITY uclink_mp7;

ARCHITECTURE rtl OF uclink_mp7 IS

  SIGNAL data_in_raw : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');

  SIGNAL samp_nwe : std_logic_vector(1 DOWNTO 0) := (OTHERS => '1');
  SIGNAL samp_nrd : std_logic_vector(1 DOWNTO 0) := (OTHERS => '1');
  SIGNAL samp_uc_new : std_logic_vector(1 DOWNTO 0) := (OTHERS => '1');

  -- Book-keeping signals
  SIGNAL done_nwe : std_logic := '0';
  SIGNAL done_nrd : std_logic := '0';
  SIGNAL done_uc_new : std_logic := '0';

BEGIN

  samp_nwe_ddr : IDDR
  GENERIC MAP
  (
    DDR_CLK_EDGE => "SAME_EDGE_PIPELINED",
    INIT_Q1 => '1',
    INIT_Q2 => '1',
    SRTYPE => "SYNC"
  )
  PORT MAP
  (
    Q1 => samp_nwe(0), 
    Q2 => samp_nwe(1),
    C  => clk125,
    CE => '1',
    D  => ebi_nwe,
    R  => '0',
    S  => '0'
  );
  samp_nrd_ddr : IDDR
  GENERIC MAP
  (
    DDR_CLK_EDGE => "SAME_EDGE_PIPELINED",
    INIT_Q1 => '1',
    INIT_Q2 => '1',
    SRTYPE => "SYNC"
  )
  PORT MAP
  (
    Q1 => samp_nrd(0), 
    Q2 => samp_nrd(1),
    C  => clk125,
    CE => '1',
    D  => ebi_nrd,
    R  => '0',
    S  => '0'
  );
  samp_uc_new_ddr : IDDR
  GENERIC MAP
  (
    DDR_CLK_EDGE => "SAME_EDGE_PIPELINED",
    INIT_Q1 => '0',
    INIT_Q2 => '0',
    SRTYPE => "SYNC"
  )
  PORT MAP
  (
    Q1 => samp_uc_new(0), 
    Q2 => samp_uc_new(1),
    C  => clk125,
    CE => '1',
    D  => uc_new,
    R  => '0',
    S  => '0'
  );

  uc_signals : PROCESS
  BEGIN
    WAIT UNTIL rising_edge(clk125);
    buf_we <= '0';
    buf_re <= '0';
    buf_req <= '0';
    -- Look for NWE being stable low
    IF done_nwe = '0' and (samp_nwe = "00") THEN
      done_nwe <= '1';
      buf_we <= '1';
      -- The data bus should have settled a few (slow) clocks ago
      -- If should be safe to directly sample it
      buf_wdata <= ebi_d;
    ELSIF (samp_nwe = "11") THEN
      -- NWE is stable high again, reset book-keeping
      done_nwe <= '0';
    END IF;

    -- NRD processing
    IF done_nrd = '0' and (samp_nrd = "00") THEN
      done_nrd <= '1';
      buf_re <= '1';
    ELSIF (samp_nrd = "11") THEN
      done_nrd <= '0';
    END IF;

    -- uc_new processing
    IF done_uc_new = '0' and (samp_uc_new = "11") THEN
      done_uc_new <= '1';
      buf_req <= '1';
    ELSIF (samp_uc_new = "00") THEN
      done_uc_new <= '0';
    END IF;
  END PROCESS;


  -- Just pass signals out to the uc directly.
  -- We trust the uC GPIO logic to sample it correctly.
  uc_done <= buf_done;
  ebi_d <= buf_rdata WHEN ebi_nrd = '0' ELSE (OTHERS => 'Z');

END ARCHITECTURE rtl;

