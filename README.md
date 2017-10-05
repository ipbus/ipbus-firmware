IPbus firmware
==============

The IPbus protocol is a simple packet-based control protocol for reading
and modifying memory-mapped resources within FPGA-based IP-aware
hardware devices which have a virtual A32/D32 bus.

The IPbus suite of software and firmware implement a reliable
high-performance control link for particle physics electronics, based on
the IPbus protocol. This suite has successfully replaced VME control in
several large projects, and consists of the following components:

* **IPbus firmware** : A module that implements the IPbus protocol within end-user
    hardware.

* **ControlHub** : A software application that mediates simultaneous hardware access
    from multiple uHAL clients, and implements the IPbus reliability
    mechanism over UDP

* **uHAL** : The Hardware Access Library (HAL) providing an end-user C++/Python
    API for IPbus reads, writes and RMW (read-modify-write)
    transactions.

This repository contains a reference implementation for an IPbus 2.0 UDP
server. It has been extensively tested on several different boards
within several particle physics experiments. However, it is supported on
a best-effort basis, and is provided on an "AS IS" BASIS, WITHOUT
WARRANTY OF ANY KIND, either express or implied, including, without
limitation, any warranties or conditions of TITLE, NON-INFRINGEMENT,
MERCHANTABILITY, or FITNESS FOR A PARTICULAR PURPOSE.

*Further reading*

The **most recent paper** describing IPbus is from the proceedings for
TWEPP2014:

> C. Ghabrous Larrea, K. Harder, D. Newbold, D. Sankey, A. Rose, A. Thea
> and T. Williams, "IPbus: a flexible Ethernet-based control system for
> xTCA hardware", *JINST* **10** (2015) no.02, C02019. [DOI:
> 10.1088/1748-0221/10/02/C02019](http://dx.doi.org/10.1088/1748-0221/10/02/C02019)
