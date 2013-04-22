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
		set parg $::env(REPOS_FW_DIR)/$arg
		if {$cmd == "hdl"} {
			addfile $arg
		} elseif {$cmd == "ghdl"} {
			addfile ipcore_dir/$arg
		} elseif {$cmd == "core"} {
			puts "CORE_XCO: $arg"
			addfile ipcore_dir/[exec basename $arg]
		} elseif {$cmd == "wcore"} {
			puts "CORE_XCO: $arg"
		} elseif {$cmd == "include"} {
			dofile $parg
		}
	}
}

proc addfile {file} {
	puts $file
}

dofile $::env(REPOS_BUILD_DIR)/file_list

