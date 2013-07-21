# Horrible hacky TCL script to build ISE project from hierarchy of source lists

proc dofile {f} {
	set fp [open $f r]
	set files [read $fp]
	close $fp
	foreach f2 [split $files "\n"] {
		if {$f2 == "" || [string index $f2 0] == "#"} {
			continue
		}
		set l [split $f2]
		set cmd [lindex $l 0]
		set parg $::env(REPOS_FW_DIR)/[lindex $l 1]
		set arg2 [lindex $1 2]
		if {$cmd == "hdl"} {
			addfile $arg $arg2
		} elseif {$cmd == "core"} {
			addcore $arg $arg2
		} elseif {$cmd == "include"} {
			dofile $arg
		}
	}
}

proc addfile {f lib} {
	project addfile $f
}

proc addcore {f lib} {
	addfile [file rootname $f].vhd
}

dofile $::env(REPOS_BUILD_DIR)/file_list

