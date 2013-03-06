#!/bin/sh

for dir in `ls ipbus/firmware/example_designs/projects`; do
	echo Building $dir
	cp -r ipbus/firmware/example_designs/projects/ise14_3 ./work_$dir
	cd work_$dir
	ln -s .. firmware
	chmod u+x setup.sh
	./setup.sh
	xtclsh build_project.tcl
done

