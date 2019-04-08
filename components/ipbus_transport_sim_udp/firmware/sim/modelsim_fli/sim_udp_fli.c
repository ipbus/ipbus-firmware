/* FLI code to allow reception and transmission of ipbus UDP packets.

   Dave Newbold, April 2019.

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/time.h>

#include <mti.h>

#define MYNAME sim_udp_fli
#define IPADDR INADDR_ANY /* Always listen on 127.0.0.1:50001 for now */
#define IPPORT 50001
#define BUFSZ 2048 /* Assuming 1500 octet packets, and UDP datagram smaller than this */
#define WAIT_USECS 50000 /* 50ms */

static unsigned char *rxbuf, *txbuf;
static int fd;
fd_set fds;
static int rxidx, txidx, rxlen, rxnum, txnum;

__attribute__((constructor)) static void cinit()
{
	
	struct sockaddr_in addr;

    mti_PrintFormatted ( "MYNAME: initialising\n" );
    
    if((fd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
		perror("MYNAME: socket() failed");
		mti_FatalError();		
		return;
	}
	
	addr.sin_family = AF_INET;
	addr.sin_port = htons(IPPORT);
	addr.sin_addr.s_addr = htonl(IPADDR); 
	
	if(bind(fd, (struct sockaddr *)&myaddr, sizeof(myaddr)) < 0) {
		perror("MYNAME: bind() failed");
		mti_FatalError();		
		return;
	}

    if(NULL == (rxbuf = (unsigned char*)malloc(BUFSZ)))
    {
      perror ("MYNAME: rxbuf malloc() failed");
      mti_FatalError();
      return;
    }

    if(NULL == (txbuf = (unsigned char*)malloc(BUFSZ)))
    {
      perror ("MYNAME: txbuf malloc() failed");
      mti_FatalError();
      return;
    }

    FD_ZERO(&fds);
    FD_SET(fd, &fds);
    
    txidx = 0;
    rxlen = 0;
    rxnum = 0;
    txnum = 0;
    
    mti_PrintFormatted("MYNAME: listening on %s:%d\n", inet_ntoa(myaddr.sin_addr), myaddr.sin_port);
}

__attribute__((destructor)) static void cdestruct()
{
  free(rxbuffer);
  free(txbuffer);
  close(fd);
  mti_PrintFormatted("MYNAME: shut down\n");
}

void get_pkt_data (int del_return,
                   int* mac_data_out,
                   int* mac_data_valid )
{
	
	static struct timeval tv;
	int s;
	struct sockaddr_in addr;
	socklen_t addrlen = sizeof(remaddr);
	uint_32t ip;
	
	if (rxlen == 0){
		tv.tv_sec = 0;
		tv.tv_usec = (del_return == 0) ? 0 : WAIT_USECS;
		
		while((s = select(fd + 1, &fds, NULL, NULL, &tv)) == -1){
			if(errno != EINTR){
				perror("MYNAME: select() failed");
				mti_FatalError();
				return;
			}
		}
		
		if(s == 0){
			*mac_data_out = 0;
			*mac_data_valid = 0;
			return;
		}
		else{
			rxlen = recvfrom(fd, rxbuf + 5, BUFSZ - 6, 0, (struct sockaddr *)&addr, &addrlen);
			if(rxlen < 0){
				perror ( "Reading from interface" );
				mti_FatalError();
				return;
			}
			ip = ntohl(addr.sin_addr.s_addr);
			*(rxbuffer) = (ip >> 24) & 0xff;
			*(rxbuffer + 1) = (ip >> 16) & 0xff;
			*(rxbuffer + 2) = (ip >> 8) & 0xff;
			*(rxbuffer + 3) = ip & 0xff;
			*(rxbuffer + 4) = addr.sin_port;			
			rxidx = 0;
			mti_PrintFormatted("MYNAME: received packet %d from %s:%d, length %d\n", rxnum, inet_ntoa(addr.sin_addr), addr.sin_port, rxlen );
		}
	}
	
	if(rxidx < rxlen){
		*mac_data_out = *(rxbuffer + rxidx);
		*mac_data_valid = 1;
		rxidx++;
	}
	else{
		mti_PrintFormatted("MYNAME: get_mac_data packet finished\n");
		rxlen = 0;
		*mac_data_out = 0;
		*mac_data_valid = 0;
		rxnum++;
	}
	
	return;
}

void store_pkt_data(int mac_data_in)
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

void put_pkt()
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

