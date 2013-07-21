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
		set arg1 [lindex $l 1]
		set arg2 [lindex $l 2]
		set parg $::env(REPOS_FW_DIR)/$arg1
		if {$cmd == "hdl"} {
			addfile $parg $arg2
		} elseif {$cmd == "ghdl"} {
			addfile ipcore_dir/$arg1 $arg2
		} elseif {$cmd == "core"} {
			buildcore $parg
			addfile ipcore_dir/[exec basename $parg] $arg2
		} elseif {$cmd == "wcore"} {
			buildcore $parg
		} elseif {$cmd == "include"} {
			dofile $parg
		}
	}
}

proc addfile {f lib} {
	puts "*** Adding file to project: $f"
	if {$lib == ""} {
		xfile add $f
	} else {
		if {[lsearch $libs $lib] == -1} {
			xfile lib_vhdl new $lib
			lappend libs $lib
		}
		xfile add $f -lib_vhdl $mlib
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

