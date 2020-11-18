
// Definitions for functions / constands to read/write OpenCores I2C adaptor
// using NEO420 wishbone.
// I2C routines modified from I2CuHal.py
// David Cussans, Jan 2020

#ifndef NEO430_I2C_H
#define NEO430_I2C_H

#include <stdint.h>
#include <string.h>
#include <stdbool.h>

// Prototypes
void setup_i2c(void);
int16_t read_i2c_address(uint8_t addr , uint8_t n , uint8_t data[]);
bool checkack(uint32_t delayVal);
int16_t write_i2c_address(uint8_t addr , uint8_t nToWrite , uint8_t data[], bool stop);
void dump_wb(void);
uint32_t hex_str_to_uint32(char *buffer);
uint16_t hex_str_to_uint16(char *buffer);
void delay(uint32_t n );
bool enable_i2c_bridge();
int64_t read_E24AA025E48T();
uint16_t zero_buffer( uint8_t buffer[] , uint16_t elements);
int16_t write_Prom();
uint32_t read_Prom();
int16_t write_PromGPO();
uint16_t read_PromGPO();

int16_t  read_i2c_prom( uint8_t startAddress , uint8_t wordsToRead , uint8_t buffer[] );
int16_t write_i2c_prom( uint8_t startAddress , uint8_t wordsToWrite, uint8_t buffer[] );
void uint8_to_decimal_str( uint8_t value , uint8_t *buffer) ;
void print_IP_address( uint32_t ipAddr);
void print_MAC_address( uint64_t macAddr);
void print_GPO( uint16_t gpo);

// #define DEBUG 1
#define DELAYVAL 512

#define MAX_CMD_LENGTH 16
#define MAX_N    16

#define ENABLECORE 0x1 << 7
#define STARTCMD 0x1 << 7
#define STOPCMD  0x1 << 6
#define READCMD  0x1 << 5
#define WRITECMD 0x1 << 4
#define ACK      0x1 << 3
#define INTACK   0x1

#define RECVDACK 0x1 << 7
#define BUSY     0x1 << 6
#define ARBLOST  0x1 << 5
#define INPROGRESS  0x1 << 1
#define INTERRUPT 0x1

// define ratio of NEO430 clock to SCL speed.
#define I2C_PRESCALE 0x0400

// Multiply addresses by 4 to go from byte addresses (Wishbone) to Word addresses (IPBus)
#define ADDR_PRESCALE_LOW 0x0
#define ADDR_PRESCALE_HIGH 0x4
#define ADDR_CTRL 0x8
#define ADDR_DATA 0xC
#define ADDR_CMD_STAT 0x10

//#define ADDR_PRESCALE_LOW 0x0
//#define ADDR_PRESCALE_HIGH 0x1
//#define ADDR_CTRL 0x2
//#define ADDR_DATA 0x3
//#define ADDR_CMD_STAT 0x4

// I2C address of Crypto EEPROM on AX3
#define MYSLAVE 0x64

// Pass to neo430 over GPIO.
// I2C address of UiD EEPROM on TLU
// #define EEPROMADDRESS  0x50

// I2C address of UiD EEPROM on timing FMC pc053
// #define EEPROMADDRESS  0x53



// PROM memory address start...
#define PROMMEMORYADDR 0x00

// Define area for general purpose flags.
#define PROMMEMORY_GPO_ADDR 0x10

// UID location in PROM memory ...
#define PROMUIDADDR 0xFA

uint8_t buffer[MAX_N];
char command[MAX_CMD_LENGTH];

#endif
