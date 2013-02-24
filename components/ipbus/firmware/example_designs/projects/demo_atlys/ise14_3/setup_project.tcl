# Horrible hacky TCL script to build ISE project from hierarchy of source lists

proc addsources {file base} {
	set fp [open $file r]
	set files [read $fp]
	close $fp
	set flist [split $files "\n"]
	foreach f $flist {
		if {$f == "" || [string index $f 0] == "#"} continue
		if {$base != ""} {
			xfile add ${base}/[exec basename $f]
		} else {
			xfile add $f
		}
	}
}

project new demo_atlys
project set family spartan6
project set device xc6slx45
project set package csg324
project set speed -2

project set "Enable Multi-Threading" "2" -process "Map"
project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" -process "Map"
project set "Enable Multi-Threading" "2" -process "Place & Route"
project set "Enable BitStream Compression" TRUE -process "Generate Programming File"

addsources file_list ""
addsources firmware/ipbus/firmware/ipbus_core/cfg/file_list ""
addsources firmware/ipbus/firmware/example_designs/cfg/file_list ""
addsources cores_list "ipcore_dir"

project close
