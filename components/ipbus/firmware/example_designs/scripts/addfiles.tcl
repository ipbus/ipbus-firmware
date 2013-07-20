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
		set arg1 [lindex $l 1]
		set arg2 [lindex $1 2]
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

proc addfile {file lib} {
	puts "*** Adding file to project: $file"
	if {$lib == ""} {
		xfile add $file
	} else {
		if {[lsearch $libs $lib] == -1} {
			xfile lib_vhdl new $lib
			lappend libs $lib
		}
		xfile add $file -lib_vhdl $mlib
	}		
}

proc buildcore {file} {
	puts "*** Building core: $file"
	set bname [exec basename $file]
	exec cp $file ipcore_dir
	cd ipcore_dir
	exec coregen -r -b $bname -p coregen.cgp >& coregen.out
	cd ..
}

set libs ""
dofile $::env(REPOS_BUILD_DIR)/file_list

