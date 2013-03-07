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
			addcore $arg
		} elseif {$cmd == "include"} {
			dofile $arg
		}
	}
}

proc addfile {file} {
	project addfile $file
}

proc addcore {file} {
	addfile [file rootname $file].vhd
}

dofile file_list

