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
			addfile $parg
		} elseif {$cmd == "ghdl"} {
			addfile ipcore_dir/$arg
		} elseif {$cmd == "core"} {
			buildcore $parg
			addfile ipcore/$bname
		} elseif {$cmd == "wcore"} {
			buildcore $parg
		} elseif {$cmd == "include"} {
			dofile $parg
		}
	}
}

proc addfile {file} {
	puts "*** Adding file to project: $file"
	xfile add $file
}

proc buildcore {file} {
	puts "*** Building core: $file"
	set bname [exec basename $file]
	exec cp $file ipcore_dir
	cd ipcore_dir
	exec coregen -r -b $bname -p coregen.cgp >& coregen.out
	cd ..
}

dofile $::env(REPOS_BUILD_DIR)/file_list

