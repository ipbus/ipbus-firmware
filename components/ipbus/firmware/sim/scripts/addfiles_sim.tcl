# Horrible hacky TCL script to build ISE project from hierarchy of source lists

proc dofile {f} {
	set fp [open $f r]
	set files [read $fp]
	close $fp
	foreach f_line [split $files "\n"] {
		if {$f_line == "" || [string index $f_line 0] == "#"} {
			continue
		}
		set l [split $f_line]
		set cmd [lindex $l 0]
		set arg1 [lindex $l 1]
		set arg2 [lindex $l 2]
		set f_list [glob $::env(REPOS_FW_DIR)/$arg1]
		foreach f_loc $f_list {
			set f_loc_s [exec basename $f_loc]
			if {$cmd == "hdl"} {
				addfile $f_loc $arg2
			} elseif {$cmd == "core"} {
				addcore $f_loc $arg2
			} elseif {$cmd == "include"} {
				dofile $f_loc
			}
		}
	}
}

proc addfile {f lib} {
	project addfile $f
}

proc addcore {f lib} {
	addfile [file rootname $f].vhd $lib
}

dofile $::env(REPOS_BUILD_DIR)/file_list

