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
		if {$cmd != "ghdl"} {
			set f_list [glob $::env(REPOS_FW_DIR)/$arg1]
		} else {
			set f_list [glob ipcore_dir/$arg1]
		}			
		foreach f_loc $f_list {	
			set f_loc_s [exec basename $f_loc]
			if {$cmd == "hdl"} {
				addfile $f_loc $arg2
			} elseif {$cmd == "ghdl"} {
				addfile $f_loc $arg2
			} elseif {$cmd == "core"} {
				buildcore $f_loc
				addfile ipcore_dir/$f_loc_s $arg2
			} elseif {$cmd == "wcore"} {
				buildcore $f_loc
			} elseif {$cmd == "include"} {
				dofile $f_loc
			}
		}
	}
}

proc addfile {f lib} {
	global libs
	puts "*** Adding file to project: $f"
	if {$lib == ""} {
		xfile add $f
	} else {
		if {[lsearch $libs $lib] == -1} {
			lib_vhdl new $lib
			lappend libs $lib
		}
		xfile add $f -lib_vhdl $lib -include_global
	}		
}

proc buildcore {f} {
	puts "*** Building core: $f"
	set bname [exec basename $f]
	exec cp $f ipcore_dir
	cd ipcore_dir
	exec coregen -r -b $bname -p coregen.cgp >& coregen.out
	cd ..
}

set libs ""
dofile $::env(REPOS_BUILD_DIR)/file_list

