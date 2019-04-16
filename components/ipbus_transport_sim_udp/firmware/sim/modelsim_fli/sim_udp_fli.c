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

#define MYNAME "sim_udp"
#define IPADDR INADDR_ANY /* Always listen on 127.0.0.1:50001 for now */
#define IPPORT 50001
#define BUFSZ 512 /* In 32b words; assuming 1500 octet packets, and datagram smaller than this */
#define WAIT_USECS 50000 /* 50ms */

static uint32_t *rxbuf, *txbuf;
static int fd;
static int rxidx, txidx, rxlen;
static uint16_t rxnum, txnum;

__attribute__((constructor)) static void cinit()
{
	
	struct sockaddr_in addr;

    mti_PrintFormatted (MYNAME ": initialising\n");
    
    if((fd = socket(AF_INET, SOCK_DGRAM, 0)) < 0){
		perror(MYNAME ": socket() failed");
		mti_FatalError();		
		return;
	}
	
	addr.sin_family = AF_INET;
	addr.sin_port = htons(IPPORT);
	addr.sin_addr.s_addr = htonl(IPADDR); 
	
	if(bind(fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
		perror(MYNAME ": bind() failed");
		mti_FatalError();		
		return;
	}

    if(NULL == (rxbuf = (uint32_t*)malloc(BUFSZ)))
    {
      perror (MYNAME ": rxbuf malloc() failed");
      mti_FatalError();
      return;
    }

    if(NULL == (txbuf = (uint32_t*)malloc(BUFSZ)))
    {
      perror (MYNAME ": txbuf malloc() failed");
      mti_FatalError();
      return;
    }
    
    txidx = 0;
    rxlen = 0;
    rxnum = 0;
    txnum = 0;
    
    mti_PrintFormatted(MYNAME ": listening on %s:%d, fd %d\n", inet_ntoa(addr.sin_addr), IPPORT, fd);
}

__attribute__((destructor)) static void cfini()
{
  free(rxbuf);
  free(txbuf);
  close(fd);
  mti_PrintFormatted(MYNAME ": shut down\n");
}

void get_pkt_data (int del_return,
                   int* mac_data_out,
                   int* mac_data_valid )
{
	
	static struct timeval tv;
	fd_set fds;
	int s, i, len;
	struct sockaddr_in addr;
	socklen_t addrlen = sizeof(addr);
	uint32_t ip;
	unsigned char buf[BUFSZ * 4];
	
	if (rxlen == 0){
		tv.tv_sec = 0;
		tv.tv_usec = (del_return == 0) ? 0 : WAIT_USECS;
		FD_ZERO(&fds);
		FD_SET(fd, &fds);		
		
		while((s = select(fd + 1, &fds, NULL, NULL, &tv)) == -1){
			if(errno != EINTR){
				perror(MYNAME ": select() failed");
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
			len = recvfrom(fd, buf, BUFSZ * 4, 0, (struct sockaddr *)&addr, &addrlen);
			if(len < 0){
				perror(MYNAME ": recvfrom() failed" );
				mti_FatalError();
				return;
			}
			mti_PrintFormatted(MYNAME ": received packet %d from %s:%d, length %d\n", rxnum, inet_ntoa(addr.sin_addr), ntohs(addr.sin_port), len);
			if(len % 4 != 0){
				mti_PrintFormatted(MYNAME ": bad length %d\n", len);
				mti_FatalError();
				return;
			}

/*			for(i = 0; i < len; i++){
				mti_PrintFormatted("%04x: %02x\n", i, (int)buf[i]);
			} */
			rxlen = len / 4;
			*(rxbuf) = 0x30000 + rxlen - 1; /* Packet header */
			*(rxbuf + 1) = addr.sin_addr.s_addr; /* Header word 0: return IP address */
			*(rxbuf + 2) = (addr.sin_port << 16) + rxnum; /* Header word 1: return port and packet number */
			for(i = 0; i < rxlen; i++){
				*(rxbuf + 3 + i) = ntohl((buf[i * 4] << 24) + (buf[i * 4 + 1] << 16) + (buf[i * 4 + 2] << 8) + buf[i * 4 + 3]); /* Convert from big-endian network order to local order */
			}
			rxidx = 0;
		}
	}
	
	if(rxidx < rxlen + 3){
		*mac_data_out = *(rxbuf + rxidx);
		*mac_data_valid = 1;
/*		mti_PrintFormatted(MYNAME ": get_mac_data packet %d returning data for index %d: %08x\n", rxnum, rxidx, *(rxbuf + rxidx)); */
		rxidx++;
	}
	else{
/*		mti_PrintFormatted(MYNAME ": get_mac_data packet %d finished\n", rxnum); */
		rxlen = 0;
		*mac_data_out = 0;
		*mac_data_valid = 0;
		rxnum++;
	}
	
	return;
}

void store_pkt_data(int mac_data_in)
{
	
	*(txbuf + txidx) = (uint32_t)mac_data_in;
/*	mti_PrintFormatted("Got data %d %08x\n", txidx, mac_data_in); */
	txidx++;
	
	if(txidx == BUFSZ){
		mti_PrintFormatted(MYNAME ": store_pkt_data buffer overflow\n" );
		mti_FatalError();
	}

	return;
}

void send_pkt()
{
	
	struct sockaddr_in addr;
	int txlen, i;
	uint32_t w;
	unsigned char buf[BUFSZ * 4];
	
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = txbuf[1];
	addr.sin_port = txbuf[2] >> 16;
		
/*	mti_PrintFormatted(MYNAME ": sending packet %d to %s:%d\n", txnum, inet_ntoa(addr.sin_addr), ntohs(addr.sin_port)); */

	for(i = 0; i < txidx - 3; i++){
		w = htonl(*(txbuf + i + 3)); /* Convert from local order to big-endian network order */
/*		mti_PrintFormatted("%d %08x %08x\n", i, *(txbuf + i + 3), w); */
		buf[i * 4] = w >> 24 & 0xff;
		buf[i * 4 + 1] = w >> 16 & 0xff;
		buf[i * 4 + 2] = w >> 8 & 0xff;
		buf[i * 4 + 3] = w & 0xff;
	}
	
/*	for(i = 0; i < (txidx - 3) * 4; i++){
		mti_PrintFormatted("%04x: %02x\n", i, (int)buf[i]);
	} */
		
/*	mti_PrintFormatted("Sending %d\n", (txidx - 3) * 4); */
	
	txlen = sendto(fd, buf, (txidx - 3) * 4, 0, (struct sockaddr *)&addr, sizeof(addr));
	
	if (txlen < 0){
		perror(MYNAME ": sendto() failed");
		mti_FatalError();
		return;
	}
	
	if (txlen != (txidx - 3) * 4){
		mti_PrintFormatted(MYNAME ": packet %d write error, length sent %d\n", txnum, txlen);
		mti_FatalError();
	}
	else{
		mti_PrintFormatted(MYNAME ": sent packet %d to %s:%d, index %d, length %d\n", txnum, inet_ntoa(addr.sin_addr), ntohs(addr.sin_port), txbuf[2] & 0xffff, (txidx - 3) * 4);
		txidx = 0;
		txnum++;
	}
	
	return;
}

