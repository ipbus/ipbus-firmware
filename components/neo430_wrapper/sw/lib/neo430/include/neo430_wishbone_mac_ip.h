// #################################################################################################
// #  < neo430_wishbone_mac_ip.h - Read/Write to block that sets IPBus address >                   #
// # ********************************************************************************************* #
// # David Cussans, Bristol, UK                                                         04.11.2020 #
// #################################################################################################

#include <stdbool.h>

#ifndef neo430_wishbone_mac_ip_h
#define neo430_wishbone_mac_ip_h

#define DEBUG 1

#define ADDR_IP_ADDR       0x0100
#define ADDR_MAC_ADDR_LOW  0x0110
#define ADDR_MAC_ADDR_HIGH 0x0120
#define ADDR_IPBUS_RESET   0x0130

// prototypes blocking functions for write/read of IP address
uint32_t neo430_wishbone_readIPAddr(void);
void     neo430_wishbone_writeIPAddr(uint32_t addr);

// prototypes blocking functions for write/read of MAC address
uint64_t neo430_wishbone_readMACAddr(void);
void     neo430_wishbone_writeMACAddr(uint64_t addr);

// set/release IPBus reset
bool    neo430_wishbone_readIPBusReset(void);
void    neo430_wishbone_writeIPBusReset(bool rstState);

#endif // neo430_wishbone_mac_ip_h
