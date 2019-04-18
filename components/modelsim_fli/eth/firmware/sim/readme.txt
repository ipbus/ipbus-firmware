This directory contains behavioural HDL and c FLI code to implement a simulated MAC interface. This is
primarily used for testing of the ipbus system.

The simulated MAC is used in conjunction with a linux virtual interface to allow the HDL design to
send and receive packets as if it were a physical host on the same network as the host machine. This
facilitates testing with the same driver software as used with a hardware implementation.

The FLI code is designed to block for a few 10s of ms if there is no data on the wire. This 'throttles back'
the simulator so that large numbers of clock cycles are not simulated while waiting for packet data. When a
packet is received, the simulator runs at full speed until the response packet is sent. The code works strictly on a 'one-in, one-out' basis; there is no mechanism to simulate multiple packets in play.

On a decent machine with questasim, a response time of ~50ms is observed to ping packets, with the simulator
taking negligible CPU time when no packets are are being sent.

Basic instructions (tested only on a 64b SL5 machine with Questasim 64b):

- Install the openvpn package on your linux machine

- Create a persistent virtual tap interface, using:

  sudo openvpn --mktun --dev tap0

- Bring the interface up and give it an IP address. On modern systems, this should also set the routing
tables up correctly.

  sudo ifconfig tap0 up 192.168.200.1

- Ensure that the permissions on your /dev/net/tun device allow public access

  sudo chmod a+rw /dev/net/tun

- At this point, you can monitor what's going via the virtual interface if you like

  sudo tshark -i tap0

- Copy the c code and compile script to your simulation directory, and compile it

- Run questasim / modelsim and make sure it picks up the shared library

- By default, linux will sometimes send ipv4 arp and ipv6 router solicitation packets over the
virtual interface - harmless, but sometimes confusing. You can set a hardwired arp address to
avoid this, and turn off ipv6 on the interface via the sysctl mechanism.

Dave Newbold, April 2011

---

$Id: readme.txt 1201 2012-09-28 08:49:12Z phdmn $
