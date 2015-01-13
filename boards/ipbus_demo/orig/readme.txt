How to compile the example designs

DMN, 2013-03-19

Example designs for several evaluation boards are provided, along with scripts to
set things up on a linux platform.

Example designs are currently only supported on ISE14.3 or later.

The setup steps are as follows:

- Create and move to an appropriate working directory

mkdir firmware
cd firmware

- Check out the ipbus directory

svn co PATH_TO_REPOSITORY/trunk/components/ipbus

- Set the path to the firmware base directory and to the build scripts directory
for the chosen example design

export REPOS_FW_DIR=`pwd`
export REPOS_BUILD_DIR=`pwd`/ipbus/firmware/example_designs/projects/demo_sp605_extphy/ise14

- Creaet and move to a working directory for the example design:

mkdir work
cd work

- Run the setup script

. $REPOS_FW_DIR/ipbus/firmware/example_designs/scripts/setup.sh

- The scripts will build all necessary cores and set up an ISE project file which
you can use in the ISE GUI.

- To build the design (up to place-and-route), you can also use a script:

xtclsh $REPOS_BUILD_DIR/build_project.tcl

For Windows platform, either create the ISE project file on linux and copy it,
or set up the project manually using the project settings and file list from
the example design directory.

Bug reports to the CACTUS TRAC list, please.

