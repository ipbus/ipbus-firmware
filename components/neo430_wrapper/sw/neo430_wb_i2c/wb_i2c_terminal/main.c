// Hacked from "Wishbone Explorer" , part of the NEO430 project by S Nolting ( see below )
// David Cussans, Jan 2020

// #################################################################################################
// #  < Wishbone bus explorer >                                                                    #
// # ********************************************************************************************* #
// # Manual access to the registers of modules, which are connected to Wishbone bus. This is also  #
// # a neat example to illustrate the construction of a console-like user interface.               #
// # ********************************************************************************************* #
// # This file is part of the NEO430 Processor project: https://github.com/stnolting/neo430        #
// # Copyright by Stephan Nolting: stnolting@gmail.com                                             #
// #                                                                                               #
// # This source file may be used and distributed without restriction provided that this copyright #
// # statement is not removed from the file and that any derivative work contains the original     #
// # copyright notice and the associated disclaimer.                                               #
// #                                                                                               #
// # This source file is free software; you can redistribute it and/or modify it under the terms   #
// # of the GNU Lesser General Public License as published by the Free Software Foundation,        #
// # either version 3 of the License, or (at your option) any later version.                       #
// #                                                                                               #
// # This source is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;      #
// # without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     #
// # See the GNU Lesser General Public License for more details.                                   #
// #                                                                                               #
// # You should have received a copy of the GNU Lesser General Public License along with this      #
// # source; if not, download it from https://www.gnu.org/licenses/lgpl-3.0.en.html                #
// # ********************************************************************************************* #
// #  Stephan Nolting, Hannover, Germany                                               06.10.2017  #
// #################################################################################################


// Libraries
#include <stdint.h>
#include <string.h>
#include "../../lib/neo430/include/neo430.h"
#include "../../lib/neo430/include/neo430_i2c.h"
#include "../../lib/neo430/include/neo430_wishbone_mac_ip.h"
#include <stdbool.h>

// Configuration
#define BAUD_RATE 19200

uint64_t uid;
uint32_t ipAddr;

/* ------------------------------------------------------------
 * Function to read EEPROM and set MAC,IP addresses
 * ------------------------------------------------------------ */
int setMacIP(void){

  // first enable I2C brige
  enable_i2c_bridge();

  // set IPBus reset
  neo430_wishbone_writeIPBusReset(true);

  // Then read MAC address
  uid = read_E24AA025E48T();
  // and write to control lines
  neo430_wishbone_writeMACAddr(uid);

  // then read IP address
  ipAddr = read_Prom();
  // and write to control lines
  neo430_wishbone_writeIPAddr(ipAddr);

  // then release IPBus reset line
  neo430_wishbone_writeIPBusReset(false);

  return 0;
}


/* ------------------------------------------------------------
 * INFO Main function
 * ------------------------------------------------------------ */
int main(void) {

  uint16_t length = 0;
  uint16_t selection = 0;

  // setup UART
  neo430_uart_setup(BAUD_RATE);
  //  USI_CT = (1<<USI_CT_EN);
 
  neo430_uart_br_print("\n-----------------------------------------\n"
                          "- I2C Wishbone Explorer Terminal v0.12 -\n"
                          "----------------------------------------\n\n");

  // check if WB unit was synthesized, exit if no WB is available
  if (!(SYS_FEATURES & (1<<SYS_WB32_EN))) {
    neo430_uart_br_print("Error! No WB synthesized!");
    return 1;
  }


  // set for 32 bit transfer
  //wb_config = 4;

  // set up I2C pre-scale
  setup_i2c();

  // read EEPROM and write to IPBus IP and MAC addresses
  setMacIP();
    
  for (;;) {

    neo430_uart_br_print("\nEnter a command:> ");

    //length = uart_scan(command, MAX_CMD_LENGTH);
    length = neo430_uart_scan(command, MAX_CMD_LENGTH,1);
    neo430_uart_br_print("\n");

    if (!length) // nothing to be done
     continue;

        // decode input
    selection = 0;
    if (!strcmp(command, "help"))
      selection = 1;
    if (!strcmp(command, "enable"))
      selection = 2;
    if (!strcmp(command, "id"))
      selection = 3;
    if (!strcmp(command, "write"))
      selection = 4;
    if (!strcmp(command, "read"))
      selection = 5;
    if (!strcmp(command, "set"))
      selection = 6;
    if (!strcmp(command, "reset"))
      selection = 7;

        // execute command
    switch(selection) {

      case 1: // print help menu
        neo430_uart_br_print("Available commands:\n"
                      " help   - show this text\n"
                      " enable - enable I2C bridge on Enclustra\n"
                      " id     - Read from E24AA025E48T Unique ID\n"
                      " write  - write to E24AA025E48T PROM area \n"
                      " read   - read from E24AA025E48T PROM area \n"
                      " set    - read from E24AA025E48T UID and PROM area. Set MAC and IP address\n"
                      " reset  - reset CPU\n"
                      );
        break;

      case 2: // Enable I2C Bridge
	     
	enable_i2c_bridge();
        break;

      case 3: // read from Unique ID address
	uid = read_E24AA025E48T();
	neo430_uart_br_print("\nUID from E24AA025E48T = ");
	neo430_uart_print_hex_dword((uid>>32) & 0xFFFFFFFF );
  neo430_uart_print_hex_dword(uid & 0xFFFFFFFF );
	neo430_uart_br_print("\n");
        break;

      case 4: // write to PROM
	write_Prom();
        break;

      case 5: // read from PROM
	 ipAddr = read_Prom();
	 print_IP_address(ipAddr);
	 break;

      case 6: // set MAC , IP address

	setMacIP();
	
        break;
        

      case 7: // restart
	while ((UART_CT & (1<<UART_CT_TX_BUSY)) != 0); // wait for current UART transmission
        neo430_soft_reset();
        break;

      default: // invalid command
        neo430_uart_br_print("Invalid command. Type 'help' for list.\n");
        break;
    }
    


  }
     return 0;
}

