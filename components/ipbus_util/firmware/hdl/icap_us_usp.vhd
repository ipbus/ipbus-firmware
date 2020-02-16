--======================================================================
-- Details about the ICAPE3 primitive itself can be found in UG974 and
-- UG570.
--======================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity icap_us_usp is
  port (
    clk : in std_logic;
    rst : in std_logic;
    base_address : in std_logic_vector(31 downto 0);
    reconfigure : in std_logic
  );
end icap_us_usp;

architecture rtl of icap_us_usp is

  signal should_reconfigure : std_logic;
  constant C_MAX_STEP : integer := 8;
  signal step : integer range 0 to C_MAX_STEP;
  signal icap_ready : std_logic;
  signal icap_ready_d : std_logic;
  signal icap_cs : std_logic;
  signal icap_rw : std_logic;
  signal icap_data : std_logic_vector(31 downto 0);
  signal icap_data_bitswapped : std_logic_vector(31 downto 0);

  type STATE is (STATE_IDLE, STATE_RECONFIGURE);
  signal fsm_state : STATE;

  -- attribute mark_debug : string;
  -- attribute mark_debug of fsm_state : signal is "true";
  -- attribute mark_debug of should_reconfigure : signal is "true";
  -- attribute mark_debug of step : signal is "true";
  -- attribute mark_debug of icap_ready : signal is "true";
  -- attribute mark_debug of icap_cs : signal is "true";
  -- attribute mark_debug of icap_rw : signal is "true";
  -- attribute mark_debug of icap_data : signal is "true";
  -- attribute mark_debug of icap_data_bitswapped : signal is "true";

  -- Helper function to bit-swap an std_logic_vector into SelectMap
  -- bit order (which is what is expected of the ICAP data).
  -- NOTE: See 'Parallel Bus Bit Order' in UG570.
  -- NOTE: Basically just 'bit-swapping within each byte'.
  function bit_swap (vec_in : std_logic_vector) return std_logic_vector is
    variable byte_num : integer;
    variable bit_num : integer;
    variable vec_out : std_logic_vector(31 downto 0);
  begin
    for byte_num in 0 to 3 loop
      for bit_num in 0 to 7 loop
        vec_out((8 * byte_num) + bit_num) := vec_in((8 * byte_num) + (7 - bit_num));
      end loop;
    end loop;
    return vec_out;
  end function bit_swap;

begin

  -- The ICAP primitive itself.
  ICAPE3_inst : ICAPE3
    generic map (
      DEVICE_ID => X"03628093",
      ICAP_AUTO_SWITCH => "DISABLE",
      SIM_CFG_FILE_NAME => "NONE"
    )
    port map (
      clk => clk,
      avail => icap_ready,
      csib => icap_cs,
      rdwrb => icap_rw,
      i => icap_data_bitswapped,
      o => open,
      prdone => open,
      prerror => open
    );

  -- One process to capture the trigger condition.
  icap_trigger : process(clk) is
  begin
    if rising_edge(clk) then
      if rst = '1' then
        should_reconfigure <= '0';
      else
        should_reconfigure <= reconfigure;
      end if;
    end if;
  end process;

  -- One process to drive the ICAP command sequence.
  icap_driver : process(clk) is
  begin
    if rising_edge(clk) then
      if rst = '1' then
        fsm_state <= STATE_IDLE;
      else
        case fsm_state is
          when STATE_IDLE =>
            icap_cs <= '1';
            icap_rw <= '1';
            step <= 0;
            fsm_state <= fsm_state;
            icap_data <= x"00000000";
          when STATE_RECONFIGURE =>
            icap_cs <= icap_cs;
            icap_rw <= icap_rw;
            fsm_state <= fsm_state;
            icap_data <= icap_data;

            if icap_ready = '1' then
              case step is
                when 0 =>
                  icap_cs <= '0';
                  icap_rw <= '0';
                when 1 =>
                  -- Send dummy word.
                  icap_data <= x"ffffffff";
                when 2 =>
                  -- Send sync word.
                  icap_data <= x"aa995566";
                when 3 =>
                  -- Send type 1 'NOOP'.
                  icap_data <= x"20000000";
                when 4 =>
                  -- Send type 1 'Write 1 word to WBSTAR'.
                  icap_data <= x"30020001";
                when 5 =>
                  -- Send warm-boot start address.
                  icap_data <= base_address;
                when 6 =>
                  -- Send type 1 'NOOP'.
                  icap_data <= x"20000000";
                when 7 =>
                  -- Send type 1 'Write 1 word to CMD'.
                  icap_data <= x"30008001";
                when 8 =>
                  -- Send the actual IPROG command.
                  icap_data <= x"0000000f";
                when others =>
                  -- Just in case.
                  fsm_state <= STATE_IDLE;
              end case;

              if step /= C_MAX_STEP then
                step <= step + 1;
              else
                step <= step;
              end if;

            end if;
        end case;

        if should_reconfigure = '1' then
          fsm_state <= STATE_RECONFIGURE;
        else
          fsm_state <= STATE_IDLE;
        end if;

        -- If the ICAP ready signal drops low, something else is going
        -- on (most likely JTAG or MCAP access). In that case we back
        -- off.
        if icap_ready = '0' and icap_ready_d = '1' then
          fsm_state <= STATE_IDLE;
        end if;

      end if;
    end if;
  end process;

  icap_ready_d <= icap_ready;
  icap_data_bitswapped <= bit_swap(icap_data);

end rtl;

--======================================================================
