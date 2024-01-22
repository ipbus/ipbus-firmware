library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ipbus_axi4lite_decl is

-- Master to slave signals

    type ipb_axi4lite_mosi is
        record
            awaddr: std_logic_vector(31 downto 0);
            awprot: std_logic_vector(2 downto 0);
            awvalid: std_logic;
            wdata: std_logic_vector(31 downto 0);
            wstrb: std_logic_vector(3 downto 0);
            wvalid: std_logic;
            bready: std_logic;
            araddr: std_logic_vector(31 downto 0);
            arprot: std_logic_vector(2 downto 0);
            arvalid: std_logic;
            rready: std_logic;
        end record;

-- Slave to master signals

    type ipb_axi4lite_miso is
        record
            awready: std_logic;
            wready: std_logic;
            bresp: std_logic_vector(1 downto 0);
            bvalid: std_logic;
            arready: std_logic;
            rdata: std_logic_vector(31 downto 0);
            rresp: std_logic_vector(1 downto 0);
            rvalid: std_logic;
        end record;

end ipbus_axi4lite_decl;
