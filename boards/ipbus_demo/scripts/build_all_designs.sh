#!/bin/sh

export REPOS_FW_DIR=`pwd`

for dir in `ls ipbus/firmware/example_designs/projects`; do
	echo Building $dir
	cd $REPOS_FW_DIR
	mkdir work_$dir
	cd work_$dir
	export REPOS_BUILD_DIR=$REPOS_FW_DIR/ipbus/firmware/example_designs/projects/$dir/ise14
	. $REPOS_FW_DIR/ipbus/firmware/example_designs/scripts/setup.sh >& setup_out.txt
	xtclsh $REPOS_BUILD_DIR/build_project.tcl >& build_out.txt
done

