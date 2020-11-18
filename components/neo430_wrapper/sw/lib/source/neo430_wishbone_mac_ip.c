// #################################################################################################
// #  < neo430_wishbone_mac_ip.c - Use Neo430 to set IPBus IP and MAC addresses >                  #
// # ********************************************************************************************* #
// # Uses the NEO430 Processor project: https://github.com/stnolting/neo430                        #
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
// # David Cussans, Bristol, UK                                                         02.11.2020 #
// #################################################################################################

#include "neo430.h"
#include "neo430_wishbone.h"
#include "neo430_wishbone_mac_ip.h"

// #define DEBUG 1

/* ------------------------------------------------------------
 * INFO Read the 32-bit IP address
 * PARAM none
 * RETURN read data
 * ------------------------------------------------------------ */
uint32_t neo430_wishbone_readIPAddr() {

  int32_t ipAddr;

  ipAddr = neo430_wishbone32_read32(ADDR_IP_ADDR);

#ifdef DEBUG
  neo430_uart_br_print("\nRead IP address\n");
  neo430_uart_print_hex_dword(ipAddr);
#endif

  return ipAddr;

}

/* ------------------------------------------------------------
 * INFO Write the 32-bit IP address
 * PARAM IP address to write
 * RETURN none
 * ------------------------------------------------------------ */
void neo430_wishbone_writeIPAddr(uint32_t ipAddr) {

#ifdef DEBUG
  neo430_uart_br_print("\nWriting IP address\n");
  neo430_uart_print_hex_dword(ipAddr);
#endif

  neo430_wishbone32_write32(ADDR_IP_ADDR, ipAddr);
}

/* ------------------------------------------------------------
 * INFO Read the 48-bit MAC address
 * PARAM none
 * RETURN read data
 * ------------------------------------------------------------ */
uint64_t neo430_wishbone_readMACAddr() {

  int32_t macAddr_low , macAddr_high;
  int64_t macAddr;

  macAddr_low  = neo430_wishbone32_read32(ADDR_MAC_ADDR_LOW);
  macAddr_high = neo430_wishbone32_read32(ADDR_MAC_ADDR_HIGH);

#ifdef DEBUG
  neo430_uart_br_print("\nReading MAC address\n");
  neo430_uart_print_hex_dword(macAddr_low);
  neo430_uart_print_hex_dword(macAddr_high);
#endif

  /*  macAddr = (macAddr_high << 32) | macAddr_low; */
  macAddr = macAddr_high;
  macAddr = macAddr <<32;
  macAddr += macAddr_low;
 
  return macAddr;

}

/* ------------------------------------------------------------
 * INFO Write the 48-bit MAC address
 * PARAM MAC address to write
 * RETURN none
 * ------------------------------------------------------------ */
void neo430_wishbone_writeMACAddr(uint64_t macAddr) {

  int32_t macAddr_low , macAddr_high;

  macAddr_low  = macAddr & 0xFFFFFFFF;
  neo430_wishbone32_write32(ADDR_MAC_ADDR_LOW,macAddr_low);

  macAddr_high = (macAddr >> 32) & 0x0000FFFF;
  neo430_wishbone32_write32(ADDR_MAC_ADDR_HIGH,macAddr_high);

#ifdef DEBUG
  neo430_uart_br_print("\nWritten MAC address (low,high)\n");
  neo430_uart_print_hex_dword(macAddr_low);
  neo430_uart_br_print("\n");
  neo430_uart_print_hex_dword(macAddr_high);
  neo430_uart_br_print("\n");
#endif

}

bool neo430_wishbone_readRarpFlag(void){

  bool RarpFlagStatus;
  uint32_t statusReg;

  statusReg = neo430_wishbone32_read32(ADDR_RARP_FLAG);

  RarpFlagStatus = statusReg ?  1 : 0;  

#ifdef DEBUG
  neo430_uart_br_print("\nRARP flag state (1-> use RARP) = ");
  neo430_uart_print_hex_dword(statusReg);
  neo430_uart_br_print("\n");
#endif

  return RarpFlagStatus;
}

void neo430_wishbone_writeRarpFlag(bool flagState){

   uint32_t statusReg;
   statusReg = flagState ? 0x00000001 : 0x00000000;

#ifdef DEBUG
  neo430_uart_br_print("\nSetting RARP flag state (1-> use RARP) = ");
  neo430_uart_print_hex_dword(statusReg);
  neo430_uart_br_print("\n");
#endif

  neo430_wishbone32_write32(ADDR_RARP_FLAG,statusReg);

  return;
}

bool neo430_wishbone_readIPBusReset(void){

  bool ipbusResetStatus;
  uint32_t statusReg;

  statusReg = neo430_wishbone32_read32(ADDR_IPBUS_RESET);

  ipbusResetStatus = statusReg ?  1 : 0;  

#ifdef DEBUG
  neo430_uart_br_print("\nIPBus reset state = ");
  neo430_uart_print_hex_dword(statusReg);
  neo430_uart_br_print("\n");
#endif

  return ipbusResetStatus;
}

void neo430_wishbone_writeIPBusReset(bool rstState){

   uint32_t statusReg;
   statusReg = rstState ? 0x00000001 : 0x00000000;

#ifdef DEBUG
  neo430_uart_br_print("\nSetting IPBus reset state = ");
  neo430_uart_print_hex_dword(statusReg);
  neo430_uart_br_print("\n");
#endif

  neo430_wishbone32_write32(ADDR_IPBUS_RESET,statusReg);

  return;
};

