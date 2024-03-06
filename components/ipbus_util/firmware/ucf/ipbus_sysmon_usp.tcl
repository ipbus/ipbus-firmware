# SYSMON number 0 will become (by careful placement constraints) the
# primary sysmon instance, located in the primary SLR. The other
# instances will cover the other SLRs.

# Don't mess with the SYSMON instances and anything connected to them.
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ *sysmon*}]

# Find all SYSMONs.
set sysmons [lsort [get_cells -hierarchical -regexp {.*sysmon.*} -filter {REF_NAME =~ {.*SYSMONE[14].*}}]]

# Find primary and secondary SLRs.
set slr_pri [get_slrs -filter IS_MASTER]
set slrs_sec [get_slrs -filter !IS_MASTER]

# Check that we found one, and only one, SYSMON for each SLR.
if {[llength $sysmons] != ([llength $slr_pri] + [llength $slrs_sec])} \
    {error "There must be exactly one SYSMON instance for each SLR."}

# The first SYSMON goes into the primary SLR.
set sysmon_pri [lindex $sysmons 0]
set slr_index [get_property SLR_INDEX $slr_pri]
set_property LOC [format "SYSMONE4_X0Y%d" $slr_index] $sysmon_pri

# The others get distributed in order.
set sysmons_sec [lrange $sysmons 1 end]

set cnt 0
foreach sm $sysmons_sec {
    set slr [lindex $slrs_sec $cnt]
    set slr_index [get_property SLR_INDEX $slr]
    set_property LOC [format "SYSMONE4_X0Y%d" $slr_index] $sm
    incr cnt
}
