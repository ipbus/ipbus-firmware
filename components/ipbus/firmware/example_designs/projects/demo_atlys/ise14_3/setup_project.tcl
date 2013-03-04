# Horrible hacky TCL script to build ISE project from hierarchy of source lists

proc dofile {file} {
	set fp [open $file r]
	set files [read $fp]
	close $fp
	foreach f [split $files "\n"] {
		if {$f == "" || [string index $f 0] == "#"} {
			continue
		}
		set l [split $f]
		set cmd [lindex $l 0]
		set arg [lindex $l 1]
		if {$cmd == "hdl"} {
			addfile $arg
		} elseif {$cmd == "core"} {
			addcore $arg ipcore_dir
		} elseif {$cmd == "include"} {
			dofile $arg
		}
	}
}

proc addfile {file} {
	xfile add $file
}

proc addcore {file base} {
	set bname [exec basename $file]
	exec cp ../${file} ipcore_dir
	cd ipcore_dir
	exec coregen -r -b $bname -p coregen.cgp
	cd ..
	eval addfile ${base}/$bname
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

dofile file_list

project close
