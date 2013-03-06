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
	xfile add $file
}

proc addcore {file} {
	set bname [exec basename $file]
	exec cp $file ipcore_dir
	cd ipcore_dir
	exec coregen -r -b $bname -p coregen.cgp >& coregen.out
	cd ..
	eval addfile ipcore_dir/$bname
}

dofile file_list

