library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;
use work.ipbus_reg_types.all;

entity patt_gen is
    generic (
        ADDR_WIDTH: positive;
        DATA_WIDTH: positive
    );
    port (
        ipb_clk: in std_logic;
        ipb_rst: in std_logic;
        ipb_in: in ipb_wbus;
        ipb_out: out ipb_rbus;
        clk : in std_logic;
        rst: in std_logic;
        stb : out std_logic;
        addr : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
        q : out std_logic_vector(DATA_WIDTH - 1 downto 0)  
    );
end patt_gen;

architecture rtl of patt_gen is

    constant N_WORDS : positive := DATA_WIDTH/8+1; -- +1 to be on the safe side with rounding
    signal actr: unsigned(ADDR_WIDTH - 1 downto 0);
    signal ctrl: ipb_reg_v(0 downto 0);
    signal ctrl_stb: std_logic_vector(0 downto 0);
    signal mode: std_logic_vector(1 downto 0);
    signal word: std_logic_vector(7 downto 0);
    signal long_word: std_logic_vector((N_WORDS)*8-1 downto 0);

    signal fire, last, stb_i: std_logic; 
begin

    -- Control register
    csr: entity work.ipbus_ctrlreg_v
    generic map(
        N_CTRL => 1,
        N_STAT => 0
    )
    port map(
        clk => ipb_clk,
        reset => ipb_rst,
        ipbus_in => ipb_in,
        ipbus_out => ipb_out,
        --d => stat,
        q => ctrl,
        stb => ctrl_stb
    );

    fire <= ctrl(0)(0) and ctrl_stb(0);
    mode <= ctrl(0)(2 downto 1);
    word <= ctrl(0)(31 downto 24);

    -- Rebuild the long word when 'word' is updated
    process(word)
    begin
        for i in 0 to N_WORDS-1 loop
            long_word( (i+1)*8-1 downto i*8 ) <= word;
        end loop;
    end process;

    process( clk )
    begin


    if rising_edge(clk) then
        stb_i <= (fire or (stb_i and not last)) and not rst;

        if rst = '1' or stb_i = '0' then
            actr <= (others => '0');
        else
            actr <= actr + 1;
        end if;
    end if;

    end process;

    -- Last is when we're at the max values
    last <= '1' when actr = to_unsigned(2 ** actr'length - 1, actr'length) else '0';
    
    -- outputs
    addr <= std_logic_vector(actr);
    stb <= stb_i;

    with mode select q <= 
        long_word( DATA_WIDTH - 1 downto 0) when "01",
        (q'left downto addr'left+1 => '0') & std_logic_vector(actr) when others;
        
end rtl;