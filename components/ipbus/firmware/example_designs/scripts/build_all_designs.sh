#!/bin/sh

export REPOS_FW_DIR=`pwd`

for dir in `ls ipbus/firmware/example_designs/projects`; do
	echo Building $dir
	mkdir work_$dir
	cd work_$dir
	export REPOS_BUILD_DIR=ipbus/firmware/example_designs/projects/$dir/ise14_3
	. $REPOS_FW_DIR/ipbus/firmware/example_designs/scripts/setup.sh
	xtclsh $REPOS_BUILD_DIR/build_project.tcl
done

