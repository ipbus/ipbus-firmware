library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity phy_mdio_configurator_vcu118 is
    port (
        clk125      : in    std_logic;  -- system clock, 125 MHz
        mdc         : in    std_logic;  -- Clock for MDIO communication; <= 2.5 MHz, sync with clk125
        rst         : in    std_logic;  -- reset signal (sync to clk125)
        clkdone     : out   std_logic;  -- phy clock was enabled 
        done        : out   std_logic;  -- phy was programmed successfully
        poll_enable : in    std_logic;  -- set to 1 to periodically poll the phy mdio registers
        poll_clk    : in    std_logic;  -- ~1Hz clock, for the periodic polling of the registers
        poll_done   : out   std_logic;  -- phy was polled successfully
        status_reg1 : out   std_logic_vector(15 downto 0);  -- phy status reg 1
        status_reg2 : out   std_logic_vector(15 downto 0);  -- phy status reg 2
        status_reg3 : out   std_logic_vector(15 downto 0);  -- phy status reg 2
        status_reg4 : out   std_logic_vector(15 downto 0);  -- phy status reg 2
        status_reg5 : out   std_logic_vector(15 downto 0);  -- phy status reg 2
        phy_mdio    : inout std_logic   -- control line to program the PHY chip
        );
end phy_mdio_configurator_vcu118;

architecture behavioral of phy_mdio_configurator_vcu118 is
    signal mdc_del : std_logic := '0';  -- 2MHz generated clock for MDIO/MDC interface

    signal mdio_t : std_logic := '1';   --\
    signal mdio_i : std_logic := '0';   --+--- tri-state inputs for mdio
    signal mdio_o : std_logic := '0';   --/

    -- encode a MDIO write sequence: see Xiling PG047 (Gigabit Ethernet PCS/PMA IP) under "MDIO management interface" (page 42 of the 4 Oct 2017 version)
    -- note that it has to be transmitted from MSB to LSB
    function encode_mdio_reg_write(phyad : std_logic_vector(4 downto 0);
                                   regad : std_logic_vector(4 downto 0);
                                   data  : std_logic_vector(15 downto 0))
        return std_logic_vector is
    begin
        return x"FFFF_FFFF" & b"01" & b"01" & phyad & regad & b"10" & data;
    end;

    -- encode a MDIO read sequence: see Xiling PG047 (Gigabit Ethernet PCS/PMA IP) under "MDIO management interface" (page 42 of the 4 Oct 2017 version)
    -- note that it has to be transmitted from MSB to LSB
    -- see mask below for which bits to send
    function encode_mdio_reg_read(phyad : std_logic_vector(4 downto 0);
                                  regad : std_logic_vector(4 downto 0))
        return std_logic_vector is
    begin
        return x"FFFF_FFFF" & b"01" & b"10" & phyad & regad & b"00" & x"0000";
    end;
    -- returns a mask, aligned with the one from encode_mdio_reg_read, where '1' means write to PHY, '0' means read from PHY
    function mdio_reg_read_mask return std_logic_vector is
    begin
        return x"FFFF_FFFF" & b"11" & b"11" & b"11111" & b"11111" & b"00" & x"0000";
    end;

    --- encode an extended register write (see data sheet of TI DP83867, section 8.6.12 "Extended Register Addressing" )
    -- note that it has to be transmitted from MSB to LSB
    function encode_mdio_extreg_write(phyad  : std_logic_vector(4 downto 0);
                                      extreg : std_logic_vector(15 downto 0);
                                      data   : std_logic_vector(15 downto 0))
        return std_logic_vector is
        constant MDIO_REG_0xD     : std_logic_vector(4 downto 0)  := b"01101";
        constant MDIO_REG_0xE     : std_logic_vector(4 downto 0)  := b"01110";
        constant MDIO_WRITE_ADDR  : std_logic_vector(15 downto 0) := b"00_000000000_11111";
        constant MDIO_WRITE_VALUE : std_logic_vector(15 downto 0) := b"01_000000000_11111";
    begin
        return encode_mdio_reg_write(phyad, MDIO_REG_0xD, MDIO_WRITE_ADDR) &
            encode_mdio_reg_write(phyad, MDIO_REG_0xE, extreg) &
            encode_mdio_reg_write(phyad, MDIO_REG_0xD, MDIO_WRITE_VALUE) &
            encode_mdio_reg_write(phyad, MDIO_REG_0xE, data);
    end;

    -- predefined MDIO PHYADD for the VCU118 PHY, from UG1224 (vcu118 user manual)
    constant VCU118_PHYADD : std_logic_vector(4 downto 0) := b"00011";
    -- we bit-reverse it in the definition, so that we can send LSB to MSB 
    -- try follow 8-13 of https://forums.xilinx.com/t5/Xilinx-Boards-and-Kits/VCU118-SGMII-Ethernet/td-p/801826
    signal mdio_data       : std_logic_vector(0 to 1023)  := encode_mdio_extreg_write(VCU118_PHYADD, x"00D3", x"4000") &  -- enable sgmii clk
                                                      encode_mdio_extreg_write(VCU118_PHYADD, x"0032", x"0000") &  -- disable rgmii
                                                      encode_mdio_reg_write(VCU118_PHYADD, "10101", x"0000") &  -- NOP 
                                                      encode_mdio_reg_write(VCU118_PHYADD, "10101", x"0000") &  -- NOP 
                                                      encode_mdio_reg_write(VCU118_PHYADD, "10000", x"F860") &  -- enable sgmii
                                                      encode_mdio_extreg_write(VCU118_PHYADD, x"0031", x"0170") &  -- set the SGMII auto-negotiation timer to 11 ms and perform the software workaround mentioned in AR #69494 because the TI PHY is not strapped to mode 3
                                                      encode_mdio_reg_write(VCU118_PHYADD, "00000", x"1340");  -- re-trigger AN
    signal mdio_data_addr : unsigned(10 downto 0) := (others => '0');
    signal mdio_clkdone   : std_logic             := '0';

    constant MDIO_POLL_LENGTH : integer := 320;
    signal mdio_poll_data     : std_logic_vector(0 to MDIO_POLL_LENGTH-1) :=
        encode_mdio_reg_read(VCU118_PHYADD, b"00001") &  -- basic mode status register
        encode_mdio_reg_read(VCU118_PHYADD, b"01010") &  -- status register 1
        encode_mdio_reg_read(VCU118_PHYADD, b"00101") &  -- Auto-Negotiation Link Partner Ability Register
        encode_mdio_reg_read(VCU118_PHYADD, b"10001") &  -- PHY Status Register 
        encode_mdio_reg_read(VCU118_PHYADD, b"10101");   -- error counter
    signal mdio_poll_mask : std_logic_vector(0 to MDIO_POLL_LENGTH-1) := mdio_reg_read_mask &
                                                                         mdio_reg_read_mask &
                                                                         mdio_reg_read_mask &
                                                                         mdio_reg_read_mask &
                                                                         mdio_reg_read_mask;
    signal mdio_poll_addr                 : unsigned(8 downto 0)                    := (others => '0');
    signal mdio_polled_data               : std_logic_vector(0 to MDIO_POLL_LENGTH) := (others => '0');
    signal mdio_poll_last, mdio_poll_done : std_logic                               := '0';


    type state_type is (ST_INIT);       -- Define the states
    signal state : state_type;          -- Create a signal that uses 

begin

-- State machine example
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if rst = '1' then
--                state <= ST_IDLE;
--            else        
--                case state is
---- Starting state
--                when ST_IDLE =>
--                    if ipb_in.ipb_strobe = '1' then
--                        state <= ST_SEL;
--                    end if;             
---- Send slave select word           
--                when ST_SEL =>
--                    state <= ST_ADDR;
---- Send address word
--                when ST_ADDR =>
--                    state <= ST_WDATA;
---- Send data
--                when ST_WDATA =>
--                    state <= ST_RDATA;
---- Receive data
--                when ST_RDATA =>
--                    if ret = '1' or ipb_in.ipb_strobe = '0' then
--                        state <= ST_IDLE;
--                    end if;

--                end case;
--            end if;

--        end if;
--    end process;


    mdio_3st : IOBUF
        port map(
            T  => mdio_t,
            I  => mdio_o,
            O  => mdio_i,
            IO => phy_mdio
            );

    phy_prog : process(clk125)
    begin
        if rising_edge(clk125) then
            mdc_del <= mdc;
            if mdc = '1' and mdc_del = '0' then  -- falling edge of mcd

                --if rst = '1' then
                --    state <= ST_IDLE;
                --    mdio_data_addr <= (others => '0');
                --    mdio_t         <= '1';      -- read/dont-care
                --    mdio_clkdone   <= '0';
                --else:
                --    case state is
                --    -- Starting state
                --    when ST_IDLE =>
                --        mdio_t         <= '0';  -- write
                --        mdio_o         <= mdio_data(to_integer(mdio_data_addr(9 downto 0)));
                --        mdio_data_addr <= mdio_data_addr + 1;
                --        mdio_poll_last <= poll_clk;
                --        if mdio_data_addr(8) = '1' then
                --            mdio_clkdone <= '1';
                --        end if;
                --    end case;
                --end if;

                if rst = '1' then
                    mdio_data_addr <= (others => '0');
                    mdio_t         <= '1';      -- read/dont-care
                    mdio_clkdone   <= '0';
                else
                    if mdio_data_addr(10) = '0' then
                        mdio_t         <= '0';  -- write
                        mdio_o         <= mdio_data(to_integer(mdio_data_addr(9 downto 0)));
                        mdio_data_addr <= mdio_data_addr + 1;
                        mdio_poll_last <= poll_clk;
                        if mdio_data_addr(8) = '1' then
                            mdio_clkdone <= '1';
                        end if;
                    else
                        if mdio_poll_last /= poll_clk then
                            mdio_poll_addr <= (others => '0');
                            mdio_poll_last <= poll_clk;
                            mdio_poll_done <= '0';
                        elsif mdio_poll_done = '0' and poll_enable = '1' then
                            mdio_poll_addr <= mdio_poll_addr + 1;
                            if mdio_poll_mask(to_integer(mdio_poll_addr)) = '1' then
                                mdio_t <= '0';
                                mdio_o <= mdio_poll_data(to_integer(mdio_poll_addr));
                            else
                                mdio_t                                       <= '1';
                                mdio_polled_data(to_integer(mdio_poll_addr)) <= mdio_i;
                            end if;
                            if mdio_poll_addr = to_unsigned(MDIO_POLL_LENGTH-1, mdio_poll_addr'length) then
                                mdio_poll_done <= '1';
                            end if;
                        else
                            mdio_t <= '1';      -- read/dont-care
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    done      <= mdio_data_addr(10);
    clkdone   <= mdio_clkdone;
    poll_done <= mdio_poll_done;

    phy_stat : process(clk125)
    begin
        if rising_edge(clk125) then
            for I in 15 downto 0 loop
                status_reg1(I) <= mdio_polled_data(64-I);
                status_reg2(I) <= mdio_polled_data(128-I);
                status_reg3(I) <= mdio_polled_data(192-I);
                status_reg4(I) <= mdio_polled_data(256-I);
                status_reg5(I) <= mdio_polled_data(320-I);
            end loop;
        end if;
    end process;

end behavioral;
