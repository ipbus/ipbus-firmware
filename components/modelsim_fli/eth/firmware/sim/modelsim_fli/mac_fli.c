/* FLI code to allow reception and transmission of ethernet packets via the
   simulated MAC.

   Dave Newbold, February 2011.

   $Id: mac_fli.c 1001 2012-07-14 20:56:40Z phdmn $

*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <linux/if_tun.h>
#include <sys/select.h>
#include <sys/time.h>

#include <mti.h>

#define Q(x) #x
#define QUOTE(x) Q(x)

#define TAP_DEV_STR QUOTE(TAP_DEV)
#define TAP_MTU 1500
#define WAIT_USECS 50000 /* 50ms */

static unsigned char* rxbuffer, *txbuffer;
static int tun_fd;
static int rxidx, txidx, rxlen;

__attribute__((constructor)) static void cinit()
{
    /* First time called, set up the interfaces */
    mti_PrintFormatted ( "fli: initialising\n" );

    if ( NULL== ( rxbuffer= ( unsigned char* ) malloc ( TAP_MTU ) ) )
    {
      perror ( "malloc for rxbuffer" );
      mti_FatalError();
      return;
    }

    if ( NULL== ( txbuffer= ( unsigned char* ) malloc ( TAP_MTU ) ) )
    {
      perror ( "malloc for txbuffer" );
      mti_FatalError();
      return;
    }

    tun_fd = tun_alloc ( TAP_DEV_STR, IFF_TAP | IFF_NO_PI );

    if ( tun_fd < 0 )
    {
      perror ( "Allocating interface" );
      mti_FatalError();
      return;
    }

    txidx = 0;
    rxlen = 0;
    
    mti_PrintFormatted ( "fli: initalised\n" );
}

__attribute__((destructor)) static void cdestruct()
{
  free(rxbuffer);
  free(txbuffer);
  close(tun_fd);
  mti_PrintFormatted ( "fli: shutting down\n" );
}

	
int tun_alloc ( char* dev, int flags )
{
  struct ifreq ifr;
  int fd, err;

  /* open the clone device */
  if ( ( fd = open ( "/dev/net/tun", O_RDWR ) ) < 0 )
  {
    return fd;
  }

  /* preparation of the struct ifr, of type "struct ifreq" */
  memset ( &ifr, 0, sizeof ( ifr ) );
  ifr.ifr_flags = flags;   /* IFF_TUN or IFF_TAP, plus maybe IFF_NO_PI */

  if ( *dev )
  {
    /* if a device name was specified, put it in the structure; otherwise,
     * the kernel will try to allocate the "next" device of the
     * specified type */
    strncpy ( ifr.ifr_name, dev, IFNAMSIZ );
  }

  /* try to create the device */
  if ( ( err = ioctl ( fd, TUNSETIFF, ( void* ) &ifr ) ) < 0 )
  {
    close ( fd );
    return err;
  }

  /* this is the special file descriptor that the caller will use to talk
   * with the virtual interface */
  return fd;
}

void get_mac_data ( int del_return,
                    int* mac_data_out,
                    int* mac_data_valid )
{
  fd_set fds;
  static struct timeval tv;
  int s;

  if ( rxlen==0 )
  {
    /* A new packet is expected - see if there's data */
    FD_ZERO ( &fds );
    FD_SET ( tun_fd, &fds );
    tv.tv_sec=0;
    tv.tv_usec= ( del_return==0 ) ?0:WAIT_USECS;

    while ( ( s = select ( tun_fd+1, &fds, NULL, NULL, &tv ) ) ==-1 )
    {
      if ( errno!=EINTR )
      {
        perror ( "Select" );
        mti_FatalError();
        return;
      }
    }

    if ( s==0 )
    {
      *mac_data_out=0;
      *mac_data_valid=0;
      return;
    }
    else
    {
      rxlen = read ( tun_fd, rxbuffer, TAP_MTU );

      if ( rxlen < 0 )
      {
        perror ( "Reading from interface" );
        mti_FatalError();
        return;
      }

      rxidx=0;
      mti_PrintFormatted ( "fli: get_mac_data received packet, length %d\n", rxlen );
    }
  }

  if ( rxidx<rxlen )
  {
    /* We're in the middle of a packet, return next octet */
    *mac_data_out = * ( rxbuffer+rxidx );
    *mac_data_valid=1;
    rxidx++;
  }
  else
  {
    mti_PrintFormatted ( "fli: get_mac_data packet finished\n", rxlen );
    rxlen=0;
    *mac_data_out=0;
    *mac_data_valid=0;
  }

  return;
}

void store_mac_data ( int mac_data_in )
{
  /* Store an octet for the outgoing packet */
  * ( txbuffer+txidx ) = ( unsigned char ) ( mac_data_in & 0xff );
  txidx++;

  if ( txidx==TAP_MTU )
  {
    mti_PrintFormatted ( "fli: put_mac_data data length exceeds MTU\n" );
    mti_FatalError();
  }

  return;
}

void put_packet()
{
  /* Send a packet */
  int txlen;
  txlen=write ( tun_fd, txbuffer, txidx );
  
  if ( txlen < 0 )
  {
  	  perror ( "Writing to interface" );
  	  mti_FatalError();
  	  return;
  }
  
  if ( txlen!=txidx )
  {
    mti_PrintFormatted ( "fli: put_mac_data partial packet write error, length %d\n", txlen);
    mti_FatalError();
    return;
  }
  else
  {
    mti_PrintFormatted ( "fli: put_mac_data send packet of length %d\n", txidx );
    txidx=0;
  }
}

