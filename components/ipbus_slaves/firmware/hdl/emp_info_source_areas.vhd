
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.ipbus.all;


entity emp_info_source_areas is
  generic (
    GIT_REPOS_NAME  : std_logic_vector;
    GIT_REPOS_SHA   : std_logic_vector;
    GIT_REPOS_CLEAN : std_logic_vector;
    GIT_REPOS_REF   : std_logic_vector
    );
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    ipb_in  : in  ipb_wbus;
    ipb_out : out ipb_rbus
    );

end emp_info_source_areas;


architecture rtl of emp_info_source_areas is

  constant N_REPOS : integer := GIT_REPOS_CLEAN'length;

  -- TODO: Assert GIT_REPOS_NAME length is consistent
  -- TODO: Assert GIT_REPOS_CLEAN length is consistent

  signal sel  : std_logic_vector(31 downto 0);
  signal idx  : integer range 0 to N_REPOS;
  signal addr : std_logic_vector(3 downto 0);

  type info_reg_block_t is array (15 downto 0) of std_logic_vector(31 downto 0);
  type info_reg_block_array_t is array (N_REPOS downto 0) of info_reg_block_t;

  signal reg : info_reg_block_array_t;

begin

  addr <= ipb_in.ipb_addr(3 downto 0);

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        sel <= (others => '0');
      elsif ipb_in.ipb_strobe = '1' and ipb_in.ipb_write = '1' and addr = "0001" then
        sel <= ipb_in.ipb_wdata;
      end if;
    end if;
  end process;

  -- TODO: Rework if '<' is actually implemented in FPGA
  idx <= to_integer(unsigned(sel)) when to_integer(unsigned(sel)) < N_REPOS else N_REPOS;

  ipb_out.ipb_ack   <= ipb_in.ipb_strobe;
  ipb_out.ipb_err   <= ipb_in.ipb_strobe when (addr /= "0001") and (ipb_in.ipb_write = '1') else '0';
  ipb_out.ipb_rdata <= reg(idx)(to_integer(unsigned(addr)));

  GEN_REG : for i in 0 to N_REPOS - 1 generate
    reg(i)(0) <= std_logic_vector(to_unsigned(N_REPOS, 32));
    reg(i)(1) <= sel;
    reg(i)(2) <= "000" & GIT_REPOS_CLEAN(i) & GIT_REPOS_SHA(i * 28 + 27 downto i * 28);

    reg(i)(3) <= GIT_REPOS_NAME(i * 160 + 31 downto i * 160);
    reg(i)(4) <= GIT_REPOS_NAME(i * 160 + 63 downto i * 160 + 32);
    reg(i)(5) <= GIT_REPOS_NAME(i * 160 + 95 downto i * 160 + 64);
    reg(i)(6) <= GIT_REPOS_NAME(i * 160 + 127 downto i * 160 + 96);
    reg(i)(7) <= GIT_REPOS_NAME(i * 160 + 159 downto i * 160 + 128);

    reg(i)(8)  <= GIT_REPOS_REF(i * 160 + 31 downto i * 160);
    reg(i)(9)  <= GIT_REPOS_REF(i * 160 + 63 downto i * 160 + 32);
    reg(i)(10) <= GIT_REPOS_REF(i * 160 + 95 downto i * 160 + 64);
    reg(i)(11) <= GIT_REPOS_REF(i * 160 + 127 downto i * 160 + 96);
    reg(i)(12) <= GIT_REPOS_REF(i * 160 + 159 downto i * 160 + 128);

    reg(i)(13) <= (others => '0');
    reg(i)(14) <= (others => '0');
    reg(i)(15) <= (others => '0');
  end generate GEN_REG;

  reg(N_REPOS)(0)  <= std_logic_vector(to_unsigned(N_REPOS, 32));
  reg(N_REPOS)(1)  <= sel;
  reg(N_REPOS)(2)  <= (others => '0');
  reg(N_REPOS)(3)  <= (others => '0');
  reg(N_REPOS)(4)  <= (others => '0');
  reg(N_REPOS)(5)  <= (others => '0');
  reg(N_REPOS)(6)  <= (others => '0');
  reg(N_REPOS)(7)  <= (others => '0');
  reg(N_REPOS)(8)  <= (others => '0');
  reg(N_REPOS)(9)  <= (others => '0');
  reg(N_REPOS)(10) <= (others => '0');
  reg(N_REPOS)(11) <= (others => '0');
  reg(N_REPOS)(12) <= (others => '0');
  reg(N_REPOS)(13) <= (others => '0');
  reg(N_REPOS)(14) <= (others => '0');
  reg(N_REPOS)(15) <= (others => '0');

end rtl;
