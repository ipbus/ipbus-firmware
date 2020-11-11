// Code to read/write OpenCores I2C adaptor using NEO420 wishbone.
// I2C routines modified from I2CuHal.py
// David Cussans, Jan 2020

// Libraries
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include "../include/neo430.h"
#include <../include/neo430_i2c.h>

uint8_t eepromAddress;

bool checkack(uint32_t delayVal) {

#ifdef DEBUG
neo430_uart_br_print("\nChecking ACK\n");
#endif

  bool inprogress = true;
  bool ack = false;
  uint8_t cmd_stat = 0;
  while (inprogress) {
    delay(delayVal);
    cmd_stat = neo430_wishbone32_read8(ADDR_CMD_STAT);
    inprogress = (cmd_stat & INPROGRESS) > 0;
    ack = (cmd_stat & RECVDACK) == 0;

#ifdef DEBUG
    neo430_uart_print_hex_byte( (uint8_t)ack );
#endif

  }
  return ack;
}

/* ------------------------------------------------------------
 * Delay by looping over "no-op"
 * ------------------------------------------------------------ */
void delay(uint32_t delayVal){
  for (uint32_t i=0;i<delayVal;i++){
    asm volatile ("MOV r3,r3");
  }
}


/* ------------------------------------------------------------
 * Zero buffer
 * ------------------------------------------------------------ */
uint16_t zero_buffer (uint8_t buffer[] , uint16_t elements) {

  for (uint16_t i=0;i<elements;i++){
    buffer[i] = 0;
  }

  return elements;
}

/* ------------------------------------------------------------
 * INFO Configure Wishbone adapter
 * ------------------------------------------------------------ */
void setup_i2c(void) {

  uint16_t prescale = I2C_PRESCALE;

  neo430_uart_br_print("Setting up I2C core");

  eepromAddress =  neo430_gpio_port_get() & 0xFF ;
  neo430_uart_br_print("I2C address E24AA025E EEPROM = ");
  neo430_uart_print_hex_byte( eepromAddress );
  neo430_uart_br_print("\n");
   
// Disable core
  neo430_wishbone32_write8(ADDR_CTRL, 0);

// Setup prescale
  neo430_wishbone32_write8(ADDR_PRESCALE_LOW , (prescale & 0x00ff) );
  neo430_wishbone32_write8(ADDR_PRESCALE_HIGH, (prescale & 0xff00) >> 8);

#ifdef DEBUG
  uint8_t prescaleByte;
  prescaleByte = neo430_wishbone32_read8(ADDR_PRESCALE_LOW);
  neo430_uart_br_print("\nI2C prescale Low, High byte = ");
  neo430_uart_print_hex_byte( prescaleByte );
  neo430_uart_br_print("\n");
  prescaleByte = neo430_wishbone32_read8(ADDR_PRESCALE_HIGH);
  neo430_uart_print_hex_byte( prescaleByte );
  neo430_uart_br_print("\n");
#endif
      
// Enable core
  neo430_wishbone32_write8(ADDR_CTRL, ENABLECORE);

  // Delay for at least 100us before proceeding
  delay(1000);

  neo430_uart_br_print("\nDone.\n");

}


/* ------------------------------------------------------------
 * INFO Read data from Wishbone address
 * ------------------------------------------------------------ */
int16_t read_i2c_address(uint8_t addr , uint8_t n , uint8_t data[]) {

  //static uint8_t data[MAX_N];

  uint8_t val;
  bool ack;

#ifdef DEBUG
  neo430_uart_br_print("\nReading From I2C.\n");
#endif

  addr &= 0x7f;
  addr = addr << 1;
  addr |= 0x1 ; // read bit
  neo430_wishbone32_write8(ADDR_DATA , addr );
  neo430_wishbone32_write8(ADDR_CMD_STAT, STARTCMD | WRITECMD );
  ack = checkack(DELAYVAL);
  if (! ack) {
      neo430_uart_br_print("\nread_i2c_address: No ACK. Send STOP terminate read.\n");
      neo430_wishbone32_write8(ADDR_CMD_STAT, STOPCMD);
      return 0;
      }

  for (uint8_t i=0; i< n ; i++){

      if (i < (n-1)) {
          neo430_wishbone32_write8(ADDR_CMD_STAT, READCMD);
        } else {
          neo430_wishbone32_write8(ADDR_CMD_STAT, READCMD | ACK | STOPCMD); // <--- This tells the slave that it is the last word
        }
      ack = checkack(DELAYVAL);

#ifdef DEBUG
      neo430_uart_br_print("\nread_i2c_address: ACK = ");
      neo430_uart_print_hex_byte( (uint8_t) ack );
      neo430_uart_br_print("\n");
#endif
      
      val = neo430_wishbone32_read8(ADDR_DATA);

#ifdef DEBUG
      neo430_uart_br_print("\nvalue = ");
      neo430_uart_print_hex_byte( val );
      neo430_uart_br_print("\n");
#endif


      data[i] = val & 0xff;
    }

  return (int16_t) n;

}

int16_t write_i2c_address(uint8_t addr , uint8_t nToWrite , uint8_t data[], bool stop) {


  int16_t nwritten = -1;
  uint8_t val;
  bool ack;
  addr &= 0x7f;
  addr = addr << 1;

#ifdef DEBUG
  neo430_uart_br_print("\nWriting to I2C.\n");
#endif

  // Set transmit register (write operation, LSB=0)
  neo430_wishbone32_write8(ADDR_DATA , addr );
  //  Set Command Register to 0x90 (write, start)
  neo430_wishbone32_write8(ADDR_CMD_STAT, STARTCMD | WRITECMD );

  ack = checkack(DELAYVAL);

  if (! ack){
    neo430_uart_br_print("\nwrite_i2c_address: No ACK in response to device-ID. Send STOP and terminate\n");
    neo430_wishbone32_write8(ADDR_CMD_STAT, STOPCMD);
    return nwritten;
  }

  nwritten += 1;

  for ( uint8_t i=0;i<nToWrite; i++){
      val = (data[i]& 0xff);
      //Write slave data
      neo430_wishbone32_write8(ADDR_DATA , val );
      //Set Command Register to 0x10 (write)
      neo430_wishbone32_write8(ADDR_CMD_STAT, WRITECMD);
      ack = checkack(DELAYVAL);
      if (!ack){
          neo430_wishbone32_write8(ADDR_CMD_STAT, STOPCMD);
          return nwritten;
        }
      nwritten += 1;
    }

  if (stop) {
#ifdef DEBUG
    neo430_uart_br_print("\nwrite_i2c_address: Writing STOP\n");
#endif
    neo430_wishbone32_write8(ADDR_CMD_STAT, STOPCMD);
  } else {
#ifdef DEBUG
    neo430_uart_br_print("\nwrite_i2c_address: Returning, no STOP\n");
#endif
  }
    return nwritten;
}

/*
mystop=True
   print "  Write RegDir to set I/O[7] to output:"
   myslave= 0x21
   mycmd= [0x01, 0x7F]
   nwords= 1
   master_I2C.write(myslave, mycmd, mystop)

mystop=False
   mycmd= [0x01]
   master_I2C.write(myslave, mycmd, mystop)
   res= master_I2C.read( myslave, nwords)
   print "\tPost RegDir: ", res

*/
bool enable_i2c_bridge() {

  bool mystop;
  uint8_t I2CBRIDGE = 0x21;
  uint8_t wordsToRead = 1;
  uint8_t wordsForAddress = 1;
  uint8_t wordsToWrite = 2;

  neo430_uart_br_print("\nEnabling I2C bridge:\n");
  buffer[0] = 0x01;
  buffer[1] = 0x7F;
  mystop = true;
#ifdef DEBUG
   neo430_uart_br_print("\nWriting 0x01,0x7F to I2CBRIDGE. Stop = true:\n");
#endif
  write_i2c_address(I2CBRIDGE , wordsToWrite , buffer, mystop );

  mystop=false;
  buffer[0] = 0x01;
#ifdef DEBUG
   neo430_uart_br_print("\nWriting 0x01 to I2CBRIDGE. Stop = false:\n");
#endif
  write_i2c_address(I2CBRIDGE , wordsForAddress , buffer, mystop );

#ifdef DEBUG
  zero_buffer(buffer , sizeof(buffer));
#endif

#ifdef DEBUG
   neo430_uart_br_print("\nReading word from I2CBRIDGE:\n");
#endif  
  read_i2c_address(I2CBRIDGE, wordsToRead , buffer);

  neo430_uart_br_print("Post RegDir: ");
  neo430_uart_print_hex_dword(buffer[0]);
  neo430_uart_br_print("\n");

  return true; // TODO: return a status, rather than True all the time...
 
}

/*
#EEPROM BEGIN
doEeprom= True
if doEeprom:
  zeEEPROM= E24AA025E48T(master_I2C, 0x57)
  res=zeEEPROM.readEEPROM(0xfa, 6)
  result="  EEPROM ID:\n\t"
  for iaddr in res:
      result+="%02x "%(iaddr)
  print result
#EEPROM END
 */


/* ---------------------------*
 *  Read bytes from PROM      *
 * ---------------------------*/
int16_t  read_i2c_prom( uint8_t startAddress , uint8_t  wordsToRead, uint8_t buffer[] ){

  bool mystop = false;

  buffer[0] = startAddress;
#ifdef DEBUG
  neo430_uart_br_print(" read_i2c_prom: Write device ID: ");
#endif
  write_i2c_address( eepromAddress , 1 , buffer, mystop );

#ifdef DEBUG
  neo430_uart_br_print("read_i2c_prom: Read EEPROM memory: ");
  zero_buffer(buffer , wordsToRead);
#endif

  read_i2c_address( eepromAddress , wordsToRead , buffer);

#ifdef DEBUG
  neo430_uart_br_print("Data from EEPROM\n");
  for (uint8_t i=0; i< wordsToRead; i++){
    neo430_uart_br_print("\n");
    neo430_uart_print_hex_dword(buffer[i]);    
  }
#endif

  return wordsToRead;
}

/* -------------------------------------*
 *  Print 32 bit number as IP address   *
 * -------------------------------------*/
void print_IP_address( uint32_t ipAddr){


  neo430_uart_br_print("\nData from PROM = \n");
  neo430_uart_print_hex_dword(ipAddr);
  neo430_uart_br_print("\n");
  neo430_uart_br_print("\nIP Address = ");

  for (uint8_t i = 3; i >= 0 && i<4; --i)
  {
    zero_buffer(buffer,4);
    uint8_to_decimal_str( (uint8_t)((ipAddr>>(i*8))&0xFF)  , buffer);
    neo430_uart_br_print( (char *)buffer  );
    neo430_uart_br_print(".");
  }
  neo430_uart_br_print( "\n"  );

}

/* ---------------------------*
 *  Read UID from E24AA025E   *
 * ---------------------------*/
int64_t read_E24AA025E48T(){

  uint8_t wordsToRead = 6;
  //  int16_t status;
  uint64_t uid = 0;

  //status =  read_i2c_prom( startAddress , wordsToRead, buffer );
  read_i2c_prom( PROMUIDADDR , wordsToRead, buffer );

  uid = (uint64_t)buffer[5] + ((uint64_t)buffer[4]<<8) + ((uint64_t)buffer[3]<<16) + ((uint64_t)buffer[2]<<24) + ((uint64_t)buffer[1]<<32) + ((uint64_t)buffer[0]<<40);

  return uid; // Returns bottom 48-bit UID in a 64-bit word

}

/* ---------------------------*
 *  Read 4 bytes from E24AA025E   *
 * ---------------------------*/
uint32_t read_Prom() {

  uint8_t wordsToRead = 4;
  //  int16_t status;
  uint32_t uid ;

  //status =  read_i2c_prom( startAddress , wordsToRead, buffer );
  read_i2c_prom( PROMMEMORYADDR , wordsToRead, buffer );

  uid = (uint32_t)buffer[3] + ((uint32_t)buffer[2]<<8) + ((uint32_t)buffer[1]<<16) + ((uint32_t)buffer[0]<<24);

  return uid; // Returns 32-bit word read from PROM

}


int16_t write_Prom(){

  uint8_t wordsToWrite = 4;
 
  int16_t status = 0;
  bool mystop = true;

  neo430_uart_br_print("Enter hexadecimal data to write to PROM: 0x");
  neo430_uart_scan(command, 9,1); // 8 hex chars for address plus '\0'
  uint32_t data = hex_str_to_uint32(command);

  // Pack data to write into buffer
  buffer[0] = PROMMEMORYADDR;
  
  for (uint8_t i=0; i< wordsToWrite; i++){
    buffer[wordsToWrite-i] = (data >> (i*8)) & 0xFF ;    
  }

  status = write_i2c_address(eepromAddress , (wordsToWrite+1), buffer, mystop);

  return status;

}

/*
int16_t write_i2c_prom( uint8_t startAddress , uint8_t wordsToWrite, uint8_t buffer[] ){

  int16_t status = 0;
  bool mystop = true;

  buffer[0] = startAddress;

  for (uint8_t i=0; i< wordsToWrite; i++){
    buffer[i+1] = wordsToWrite;    
  }

  status = write_i2c_address(eepromAddress , (wordsToWrite+1), buffer, mystop);

  return status;
}
*/

/*
def write(self, addr, data, stop=True):
    """Write data to the device with the given address."""
    # Start transfer with 7 bit address and write bit (0)
    nwritten = -1
    addr &= 0x7f
    addr = addr << 1
    startcmd = 0x1 << 7
    stopcmd = 0x1 << 6
    writecmd = 0x1 << 4
    #Set transmit register (write operation, LSB=0)
    self.data.write(addr)
    #Set Command Register to 0x90 (write, start)
    self.cmd_stat.write(I2CCore.startcmd | I2CCore.writecmd)
    self.target.dispatch()
    ack = self.delayorcheckack()
    if not ack:
        self.cmd_stat.write(I2CCore.stopcmd)
        self.target.dispatch()
        return nwritten
    nwritten += 1
    for val in data:
        val &= 0xff
        #Write slave memory address
        self.data.write(val)
        #Set Command Register to 0x10 (write)
        self.cmd_stat.write(I2CCore.writecmd)
        self.target.dispatch()
        ack = self.delayorcheckack()
        if not ack:
            self.cmd_stat.write(I2CCore.stopcmd)
            self.target.dispatch()
            return nwritten
        nwritten += 1
    if stop:
        self.cmd_stat.write(I2CCore.stopcmd)
        self.target.dispatch()
    return nwritten

*/


/* ------------------------------------------------------------
 * INFO Hex-char-string conversion function
 * PARAM String with hex-chars (zero-terminated)
 * not case-sensitive, non-hex chars are treated as '0'
 * RETURN Conversion result (32-bit)
 * ------------------------------------------------------------ */
uint32_t hex_str_to_uint32(char *buffer) {

  uint16_t length = strlen(buffer);
  uint32_t res = 0, d = 0;
  char c = 0;

  while (length--) {
    c = *buffer++;

    if ((c >= '0') && (c <= '9'))
      d = (uint32_t)(c - '0');
    else if ((c >= 'a') && (c <= 'f'))
      d = (uint32_t)((c - 'a') + 10);
    else if ((c >= 'A') && (c <= 'F'))
      d = (uint32_t)((c - 'A') + 10);
    else
      d = 0;

    res = res + (d << (length*4));
  }

  return res;
}

/* -----------------------------------
 * Convert uint8_t into a decimal string
 * Without using divide - we don't want
 * to implement divide unit and we 
 * don't care about speed.
 * ----------------------------------- */
void uint8_to_decimal_str( uint8_t value , uint8_t *buffer) {

  const uint8_t magnitude[3] = {1,10,100};

  uint16_t delta;
  uint16_t trialValue = 0;

  const char ASCII_zero_character = 48;

  buffer[0] = ASCII_zero_character; buffer[1] = ASCII_zero_character; buffer[2] = ASCII_zero_character; buffer[3] = 0;

  //printf("Start, converting %i\n",value);
  //for ( int i =0; i<4; i++){
  //  printf("%i , %i\n",i,buffer[i]);
  //}

  // loop through 100's , 10's and 1's
  for ( int16_t magnitudeIdx =2; magnitudeIdx > -1; magnitudeIdx-- ){

    delta = magnitude[magnitudeIdx];

    // printf("Delta = %i\n",delta);

    // for each magnitude
    for ( uint16_t digit = 0; digit < 10 ; digit ++ ){

      // printf("trialValue = %i\n",trialValue);

      if (( value - ( trialValue + delta )) >= 0) {

	  trialValue += delta;
	  buffer[2-magnitudeIdx] += 1;

	} else {
	  break; // go to the next order of magnitude.
	}
    }
  }

  //for ( int i =0; i<4; i++){
  //  printf("%i , %i\n",i,buffer[i]);
  //}
  return;

}

