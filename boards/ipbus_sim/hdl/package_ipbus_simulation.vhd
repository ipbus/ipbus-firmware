-- This package allows users to exercise the ipbus in a purely VHDL environment
-- as opposed to using the ModelSim Foreign Language Interface (FLI).  The FLI 
-- offers a more comprehensive test enevironment, particularly for exercising 
-- the UDP/IP aspects and the concatention of ipbus requests. However, the FLI is
-- complex to setup and it is a proprietary standard of ModelSim.
--
-- The package provides read/writes procedures that would normsally be executed 
-- by a CPU.  It interface to the ipbus master via the OOB (Out-Of-Band) interface.
--
-- Greg Iles, July 2013


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ipbus.all;
use work.ipbus_trans_decl.all;


package ipbus_simulation is

  constant PACKAGE_IPBUS_SIMULATION_VERSION: natural := 1;
  
  constant PROTOCOL_VERSION: std_logic_vector(3 downto 0) := x"2";    
  constant OOB_HDR_LENGTH: natural := 0;

  -- You'll need this type if you want to pass a block of data into procedures 
  -- ipbus_block_write or ipbus_block_read.
  type type_ipbus_buffer is array(natural range <>) of std_logic_vector(31 downto 0);

  procedure ipbus_read(signal clk: in std_logic; 
                        signal cntrl_to_transactor: out ipbus_trans_in; 
                        signal cntrl_from_transactor: in ipbus_trans_out; 
                        add: in std_logic_vector(31 downto 0); 
                        data: out std_logic_vector(31 downto 0));

  procedure ipbus_write(signal clk: in std_logic; 
                        signal cntrl_to_transactor: out ipbus_trans_in; 
                        signal cntrl_from_transactor: in ipbus_trans_out; 
                        add: in std_logic_vector(31 downto 0); 
                        data: in std_logic_vector(31 downto 0));
                        
  procedure ipbus_block_read(signal clk: in std_logic; 
                             signal cntrl_to_transactor: out ipbus_trans_in; 
                             signal cntrl_from_transactor: in ipbus_trans_out; 
                             add: in std_logic_vector(31 downto 0); 
                             data: inout type_ipbus_buffer;
                             inc: in boolean);                                                            
                        
  procedure ipbus_block_write(signal clk: in std_logic; 
                        signal cntrl_to_transactor: out ipbus_trans_in; 
                        signal cntrl_from_transactor: in ipbus_trans_out; 
                        add: in std_logic_vector(31 downto 0); 
                        data: in type_ipbus_buffer;
                        inc: in boolean);
                        
  procedure ipbus_read_modify_write(signal clk: in std_logic; 
                           signal cntrl_to_transactor: out ipbus_trans_in; 
                           signal cntrl_from_transactor: in ipbus_trans_out; 
                           add: in std_logic_vector(31 downto 0);
                           mask: in std_logic_vector(31 downto 0); 
                           data: in std_logic_vector(31 downto 0));
                        
  -- The procedure "perform_ipbus_transaction" executes the ipbus transaction with 
  -- the ipbus master.  It is only intended for use within this package.
  procedure perform_ipbus_transaction(signal clk: in std_logic; 
                        signal cntrl_to_transactor: out ipbus_trans_in; 
                        signal cntrl_from_transactor: in ipbus_trans_out; 
                        ipbus_tx_buffer: in type_ipbus_buffer; 
                        ipbus_rx_buffer: out type_ipbus_buffer);
                        
  -- This procedure "check_ipbus_response" checks the ipbus transaction with the 
  -- ipbus master.  It is only intended for use within this package.
  procedure check_ipbus_response(ipbus_response: in std_logic_vector(31 downto 0); 
                                 PROTOCOL_VERSION: in std_logic_vector(3 downto 0); 
                                 transaction_id: in std_logic_vector(11 downto 0); 
                                 number_of_words: in std_logic_vector(7 downto 0); 
                                 type_id: in std_logic_vector(3 downto 0) );  
                                 
end ipbus_simulation;



package body ipbus_simulation is

  
  procedure ipbus_block_write(signal clk: in std_logic; 
                        signal cntrl_to_transactor: out ipbus_trans_in; 
                        signal cntrl_from_transactor: in ipbus_trans_out; 
                        add: in std_logic_vector(31 downto 0); 
                        data: in type_ipbus_buffer;
                        inc: in boolean)is
        
    variable ipbus_tx_buffer, ipbus_rx_buffer: type_ipbus_buffer((2**ADDR_WIDTH)-1 downto 0) := (others => x"00000000");
    
    variable ipbus_tx_packet_length: natural := 0;
    variable transaction_id: std_logic_vector(11 downto 0) := x"000";
    variable type_id : std_logic_vector(3 downto 0) := x"0";
    variable number_of_words : std_logic_vector(7 downto 0) := x"01";
    variable ipbus_response: std_logic_vector(31 downto 0) := x"00000000";
    
  begin

    -- User can select whether they wish the address to increment or not.
    -- An incrementing address is typlically used when writing to a ram
    -- whereas a non-incrementing address is used for a fifo.
    if (inc = true) then
      type_id := x"1";
    else
      type_id := x"3";
    end if;
    
    -- Transaction header, base address and data 
    ipbus_tx_packet_length := 2 + data'length;
    -- Number of words to write
    number_of_words := std_logic_vector(to_unsigned(data'length, 8)); 
      
    -- Build OOB packet
    -- Fisrt word specifies length of OOB header and IPbus packet
    ipbus_tx_buffer(0) := std_logic_vector(to_unsigned(OOB_HDR_LENGTH, 16) & to_unsigned(ipbus_tx_packet_length, 16));
    -- OOB Header Words would go here if we wanted some...
    -- Do NOT send IPbus Packet Header or it will not work
    -- IPbus Packet Write Header (only sends single word).
    -- Format: Protocol version / Transaction Id / Words To Write / Type Id (i.e. Write transaction) / Info Code
    ipbus_tx_buffer(1) := PROTOCOL_VERSION & transaction_id & number_of_words & type_id & x"f";
    -- IPbus Packet Write Address
    -- Format: Base Address
    ipbus_tx_buffer(2) := add;
    -- IPbus Packet Write Data
    -- Format: Write Data (repeat N times for base address + N)
    blk_write: for i in data'low to data'high loop
      ipbus_tx_buffer(3+i) := data(i);
    end loop;
    
    -- Perform transaction
    perform_ipbus_transaction(clk, cntrl_to_transactor, cntrl_from_transactor, ipbus_tx_buffer, ipbus_rx_buffer);
      
    -- Check response
    ipbus_response := ipbus_rx_buffer(OOB_HDR_LENGTH+1);
    check_ipbus_response(ipbus_response, PROTOCOL_VERSION, transaction_id, number_of_words, type_id);
            
  end procedure;
  
      
  ---------------------------------------------------------------------  
  ---------------------------------------------------------------------
  ---------------------------------------------------------------------

  procedure ipbus_write(signal clk: in std_logic; 
                        signal cntrl_to_transactor: out ipbus_trans_in; 
                        signal cntrl_from_transactor: in ipbus_trans_out; 
                        add: in std_logic_vector(31 downto 0); 
                        data: in std_logic_vector(31 downto 0))is
       
     variable data_int, ipbus_rx_buffer: type_ipbus_buffer(0 downto 0) := (others => x"00000000");
     
  begin
  
    data_int(0) := data;
    ipbus_block_write(clk, cntrl_to_transactor, cntrl_from_transactor, add, data_int, true);
            
  end procedure;
  
  ---------------------------------------------------------------------  
  ---------------------------------------------------------------------
  ---------------------------------------------------------------------
  
  procedure ipbus_block_read(signal clk: in std_logic; 
                             signal cntrl_to_transactor: out ipbus_trans_in; 
                             signal cntrl_from_transactor: in ipbus_trans_out; 
                             add: in std_logic_vector(31 downto 0); 
                             data: inout type_ipbus_buffer;
                             inc: in boolean)is
                                     
    variable ipbus_tx_buffer, ipbus_rx_buffer: type_ipbus_buffer((2**ADDR_WIDTH)-1 downto 0) := (others => x"00000000");
    
    variable ipbus_tx_packet_length: natural := 0;
    variable transaction_id: std_logic_vector(11 downto 0) := x"000";
    variable type_id : std_logic_vector(3 downto 0) := x"0";
    variable number_of_words : std_logic_vector(7 downto 0) := x"01";
    variable ipbus_response: std_logic_vector(31 downto 0) := x"00000000";
    
  begin

    -- User can select whether they wish the address to increment or not.
    -- An incrementing address is typlically used when writing to a ram
    -- whereas a non-incrementing address is used for a fifo.
    if (inc = true) then
      type_id := x"0";
    else
      type_id := x"2";
    end if;
    
    -- Transaction header and base address 
    ipbus_tx_packet_length := 2;
    -- Number of words to write
    number_of_words := std_logic_vector(to_unsigned(data'length, 8)); 

    -- Build OOB packet
    -- Fisrt word specifies length of OOB header and IPbus packet
    ipbus_tx_buffer(0) := std_logic_vector(to_unsigned(OOB_HDR_LENGTH, 16) & to_unsigned(ipbus_tx_packet_length, 16));
    -- OOB Header Words would go here if we wanted some...
    -- Do NOT send IPbus Packet Header or it will not work
    -- IPbus Packet Write Header (only sends single word).
    -- Format: Protocol version / Transaction Id / Words To Write / Type Id (i.e. Write transaction) / Info Code
    ipbus_tx_buffer(1) := PROTOCOL_VERSION & transaction_id & number_of_words & type_id & x"f";
    -- IPbus Packet Write Address
    -- Format: Base Address
    ipbus_tx_buffer(2) := add;

    -- Perform transaction
    perform_ipbus_transaction(clk, cntrl_to_transactor, cntrl_from_transactor, ipbus_tx_buffer, ipbus_rx_buffer);
      
    -- Check response
    ipbus_response := ipbus_rx_buffer(OOB_HDR_LENGTH+1);
    check_ipbus_response(ipbus_response, PROTOCOL_VERSION, transaction_id, number_of_words, type_id);
    
    -- Obtain read data
    data := ipbus_rx_buffer(OOB_HDR_LENGTH+1+data'length downto OOB_HDR_LENGTH+2);
    
  end procedure;
      
  ---------------------------------------------------------------------  
  ---------------------------------------------------------------------
  ---------------------------------------------------------------------
  
  procedure ipbus_read(signal clk: in std_logic; 
                        signal cntrl_to_transactor: out ipbus_trans_in; 
                        signal cntrl_from_transactor: in ipbus_trans_out; 
                        add: in std_logic_vector(31 downto 0); 
                        data: out std_logic_vector(31 downto 0))is

     variable data_int, ipbus_rx_buffer: type_ipbus_buffer(0 downto 0) := (others => x"00000000");
     
  begin
  
    ipbus_block_read(clk, cntrl_to_transactor, cntrl_from_transactor, add, data_int, true);
    data := data_int(0);
    
  end procedure;
  
    
  ---------------------------------------------------------------------  
  ---------------------------------------------------------------------
  ---------------------------------------------------------------------
  
    procedure ipbus_read_modify_write(signal clk: in std_logic; 
                             signal cntrl_to_transactor: out ipbus_trans_in; 
                             signal cntrl_from_transactor: in ipbus_trans_out; 
                             add: in std_logic_vector(31 downto 0);
                             mask: in std_logic_vector(31 downto 0); 
                             data: in std_logic_vector(31 downto 0)) is
                                     
    variable ipbus_tx_buffer, ipbus_rx_buffer: type_ipbus_buffer((2**ADDR_WIDTH)-1 downto 0) := (others => x"00000000");
    
    variable ipbus_tx_packet_length: natural := 0;
    variable transaction_id: std_logic_vector(11 downto 0) := x"000";
    variable type_id : std_logic_vector(3 downto 0) := x"0";
    variable number_of_words : std_logic_vector(7 downto 0) := x"01";
    variable ipbus_response: std_logic_vector(31 downto 0) := x"00000000";
    variable data_int: std_logic_vector(31 downto 0) := x"00000000";
    variable bitshift: natural := 0;
    variable continue: boolean := false;

  begin
    
    -- Should there be a check that the integer is fits inside the add mask?
    -- Should there be a check that the mask is sensible?
    continue := true;
    find_bitshift: while continue loop
      if mask(bitshift) = '1' then
        continue := false;
      else
        bitshift := bitshift + 1;
      end if;
      if bitshift > 31 then
        report "Mask for Read-Modif-Write transaction is empty" severity failure;
      end if;
    end loop;
     
    -- find_rightmost doesn't seem available despite being available in IEEE Std 1076-2008
    -- bitshift := find_rightmost(unsigned(mask), '1');
        
    data_int := std_logic_vector(shift_left(unsigned(data), bitshift));    

    -- Indicate that this is a RMW transaction
    type_id := x"4";
    -- Transaction header and base address 
    ipbus_tx_packet_length := 4;
    -- Number of words to write
    number_of_words := std_logic_vector(to_unsigned(1, 8)); 

    -- Build OOB packet
    -- Fisrt word specifies length of OOB header and IPbus packet
    ipbus_tx_buffer(0) := std_logic_vector(to_unsigned(OOB_HDR_LENGTH, 16) & to_unsigned(ipbus_tx_packet_length, 16));
    -- OOB Header Words would go here if we wanted some...
    -- Do NOT send IPbus Packet Header or it will not work
    -- IPbus Packet Write Header (only sends single word).
    -- Format: Protocol version / Transaction Id / Words To Write / Type Id (i.e. Write transaction) / Info Code
    ipbus_tx_buffer(1) := PROTOCOL_VERSION & transaction_id & number_of_words & type_id & x"f";
    -- IPbus Packet Write Address
    ipbus_tx_buffer(2) := add;
    -- IPbus Packet AND term
    ipbus_tx_buffer(3) := not mask;
    -- IPbus Packet OR term
    ipbus_tx_buffer(4) := data_int and mask;

    -- Perform transaction
    perform_ipbus_transaction(clk, cntrl_to_transactor, cntrl_from_transactor, ipbus_tx_buffer, ipbus_rx_buffer);
      
    -- Check response
    ipbus_response := ipbus_rx_buffer(OOB_HDR_LENGTH+1);
    check_ipbus_response(ipbus_response, PROTOCOL_VERSION, transaction_id, number_of_words, type_id);
    
    
  end procedure;

  ---------------------------------------------------------------------  
  ---------------------------------------------------------------------
  ---------------------------------------------------------------------
  
  procedure perform_ipbus_transaction(signal clk: in std_logic; 
                        signal cntrl_to_transactor: out ipbus_trans_in; 
                        signal cntrl_from_transactor: in ipbus_trans_out; 
                        ipbus_tx_buffer: in type_ipbus_buffer; 
                        ipbus_rx_buffer: out type_ipbus_buffer) is
  
    variable transacting: boolean := false;
    variable raddr_int, waddr_int: natural := 0;
  
  begin
    transacting := true;
    while transacting loop
      wait until rising_edge(clk);
         -- Detect end of transaction
        if (cntrl_from_transactor.pkt_done = '1') then
          transacting := false;
          cntrl_to_transactor.pkt_rdy <= '0';
          cntrl_to_transactor.busy <= '0';
          cntrl_to_transactor.rdata <= x"00000000";
        else
          -- Sending packet to transactor
          cntrl_to_transactor.pkt_rdy <= '1';
          cntrl_to_transactor.busy <= '0';
          raddr_int := to_integer(unsigned(cntrl_from_transactor.raddr));
          cntrl_to_transactor.rdata <= ipbus_tx_buffer(raddr_int);
        end if;
        -- Receiving packet from transactor
        if (cntrl_from_transactor.we = '1') then
          waddr_int := to_integer(unsigned(cntrl_from_transactor.waddr));
          ipbus_rx_buffer(waddr_int) := cntrl_from_transactor.wdata;
        end if;
    end loop;
    
  end procedure;

  ---------------------------------------------------------------------  
  ---------------------------------------------------------------------
  ---------------------------------------------------------------------
  
  procedure check_ipbus_response(ipbus_response: in std_logic_vector(31 downto 0); 
                                 PROTOCOL_VERSION: in std_logic_vector(3 downto 0); 
                                 transaction_id: in std_logic_vector(11 downto 0); 
                                 number_of_words: in std_logic_vector(7 downto 0); 
                                 type_id: in std_logic_vector(3 downto 0) ) is
  begin
          
    assert (ipbus_response(31 downto 28) = PROTOCOL_VERSION)  
      report "Incorrect protocol version in response"
      severity FAILURE;
    assert (ipbus_response(27 downto 16) = transaction_id)  
      report "Incorrect transaction id in response"
      severity FAILURE;
    assert (ipbus_response(15 downto 8) = number_of_words)  
      report "Incorrect number of words returned"
      severity FAILURE;             
    assert (ipbus_response(7 downto 4) = type_id)  
      report "Incorrect type id in response"
      severity FAILURE;        
      
    if (ipbus_response(3 downto 0) = x"1") then 
      report "Info code indicates bad header"
      severity FAILURE;
    end if;
    if (ipbus_response(3 downto 0) = x"2") then 
      report "Info code indicates bad transaction id (non sequential)"
      severity FAILURE;
    end if;        
    if (ipbus_response(3 downto 0) = x"3") then 
      report "Info code indicates bus error on read"
      severity FAILURE;
    end if;
    if (ipbus_response(3 downto 0) = x"4") then 
      report "Info code indicates bus error on write"
      severity FAILURE;        
    end if;
    if (ipbus_response(3 downto 0) = x"5") then 
      report "Info code indicates bus timeout on read"
      severity FAILURE;        
    end if;
    if (ipbus_response(3 downto 0) = x"6") then 
      report "Info code indicates  bus timeout on write"
      severity FAILURE;
    end if;
    if (ipbus_response(3 downto 0) = x"f") then 
      report "Info code indicates this is an outbound request, when it should be inbound"
      severity FAILURE;
    end if;
    
    assert (ipbus_response(3 downto 0) = x"0")  
      report "Incorrect info code in response"
      severity FAILURE;
 
  end procedure ;

 
 
end ipbus_simulation;

