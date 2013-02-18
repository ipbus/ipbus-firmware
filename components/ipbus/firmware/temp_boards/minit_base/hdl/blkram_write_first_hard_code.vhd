

library ieee;
use ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity blkram_write_first_hard_code is
  port (
    clkA   : in  std_logic;
    clkB   : in  std_logic;
    enA    : in  std_logic;
    enB    : in  std_logic;
    weA    : in  std_logic;
    weB    : in  std_logic;
    ssrA    : in  std_logic;
    ssrB    : in  std_logic;    
    addrA  : in  std_logic_vector(11 downto 0);
    addrB  : in  std_logic_vector(9 downto 0);
    diA    : in  std_logic_vector(7 downto 0);
    diB    : in  std_logic_vector(31 downto 0);
    doA    : out std_logic_vector(7 downto 0);
    doB    : out std_logic_vector(31 downto 0));
end blkram_write_first_hard_code;

architecture behave of blkram_write_first_hard_code is
  
  signal WEA_LOCAL: std_logic_vector(3 downto 0);
  signal WEB_LOCAL: std_logic_vector(3 downto 0);
  signal ADDRA_LOCAL, ADDRB_LOCAL: std_logic_vector(15 downto 0);
  signal DIA_LOCAL, DOA_LOCAL: std_logic_vector(31 downto 0);

begin
  
  
  WEA_LOCAL <= "0000" when WEA = '0' else "1111";
  WEB_LOCAL <= "0000" when WEB = '0' else "1111";

  DOA <= DOA_LOCAL(7 downto 0);
  DIA_LOCAL <= x"000000" & DIA;
  
  -- Read UG621 for info about addressing
  ADDRA_LOCAL <= "1" & ADDRA & "111";
  ADDRB_LOCAL <= "1" & ADDRB & "11111";
  
  -- RAMB36: 32k+4k Parity Paramatizable True Dual-Port BlockRAM
  -- Virtex-5
  -- Xilinx HDL Libraries Guide, version 13.1
  RAMB36_inst : RAMB36
  generic map (
    READ_WIDTH_A => 9, -- Valid values are 1, 2, 4, 9, 18, or 36
    READ_WIDTH_B => 36, -- Valid values are 1, 2, 4, 9, 18, or 36
    SIM_COLLISION_CHECK => "ALL", -- ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE"
    SIM_MODE => "SAFE", -- Simulation: "SAFE" vs "FAST", see "Synthesis and Simulation
    WRITE_MODE_A => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
    WRITE_MODE_B => "WRITE_FIRST", -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
    WRITE_WIDTH_A => 9, -- Valid values are 1, 2, 3, 4, 9, 18, 36
    WRITE_WIDTH_B => 36) -- Valid values are 1, 2, 3, 4, 9, 18, 36
  port map (
    CASCADEOUTLATA => open, -- 1-bit cascade A latch output
    CASCADEOUTLATB => open, -- 1-bit cascade B latch output
    CASCADEOUTREGA => open, -- 1-bit cascade A register output
    CASCADEOUTREGB => open, -- 1-bit cascade B register output
    DOA => DOA_LOCAL, -- 32-bit A port data output
    DOB => DOB, -- 32-bit B port data output
    DOPA => open, -- 4-bit A port parity data output
    DOPB => open, -- 4-bit B port parity data output
    ADDRA => ADDRA_LOCAL, -- 16-bit A port address input
    ADDRB => ADDRB_LOCAL, -- 16-bit B port address input
    CASCADEINLATA => '0', -- 1-bit cascade A latch input
    CASCADEINLATB => '0', -- 1-bit cascade B latch input
    CASCADEINREGA => '0', -- 1-bit cascade A register input
    CASCADEINREGB => '0', -- 1-bit cascade B register input
    CLKA => CLKA, -- 1-bit A port clock input
    CLKB => CLKB, -- 1 bit B port clock input
    DIA => DIA_LOCAL, -- 32-bit A port data input
    DIB => DIB, -- 32-bit B port data input
    DIPA => "0000", -- 4-bit A port parity data input
    DIPB => "0000", -- 4-bit B port parity data input
    ENA => ENA, -- 1-bit A port enable input
    ENB => ENB, -- 1-bit B port enable input
    REGCEA => '0', -- 1-bit A port register enable input
    REGCEB => '0', -- 1-bit B port register enable input
    SSRA => SSRA, -- 1-bit A port set/reset input
    SSRB => SSRB, -- 1-bit B port set/reset input
    WEA => WEA_LOCAL, -- 4-bit A port write enable input
    WEB => WEB_LOCAL -- 4-bit B port write enable input
  );

end behave;

							