#!/bin/sh
mkdir ipcore_dir
cd ipcore_dir
ln -s ../coregen.cgp
for file in `cat ../cores_list`
do
	cp ../$file ./
	coregen -r -b `basename $file` -p coregen.cgp
done
cd ..
xtclsh setup_project.tcl

