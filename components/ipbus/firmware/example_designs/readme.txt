How to compile the example designs

DMN, 2013/1/20

Example designs for several evaluation boards are provided, along with scripts to
set things up on a linux platform.

Example designs are currently only supported on ISE14.2 or later. They will work
on ISE13.4, but you will need to change the versions of the Xilinx IP blocks.
ISE 14.1 has a variety of bugs, and should be avoided.

The setup steps are as follows:

- Move to an appropriate working directory

- Either check out the firmware base directory from the repository straight into
your working area (i.e. so that you end up with a subdirectory named 'firmware'),
or make a link named 'firmware' to the wherever your working copy exist:

	svn co PATH_TO_REPOSITORY/trunk/uHAL/firmware
	
	or
	
	ln -s PATH_TO_WORKING_COPY firmware
	
- Copy one of the example design directories to your working directory

	cp -r firmware/example_designs/projects/DESIGN_NAME/ise14_3 DESIGN_NAME
	
- Enter the design directory and run the setup script

	cd DESIGN_NAME
	chmod u+x ./setup.sh
	./setup.sh
	
- The scripts will set up an ISE project with the necessary HDL files, copy the
XCO files for any necessary cores into the local working area, and compile the
cores. This last step may take a few minutes.

- Open the XISE project file in the ISE GUI, and it should be ready to
synthesise.

For Windows platform, either create the XISE file on linux and copy it, or set
up the project manually using the project settings and file list from the
example design directory.

Bug reports to dave.newbold@cern.ch.

