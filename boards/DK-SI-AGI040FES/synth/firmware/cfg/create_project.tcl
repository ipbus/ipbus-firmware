package require ::quartus::project

puts "Creating project: quartus_ipbus_example"
project_new -revision top quartus_ipbus_example

set script_path [file dirname [file normalize [info script]]]

# Configure project
source $script_path/add_assignments.tcl
source $script_path/add_files.tcl
source $script_path/add_pins.tcl

export_assignments

puts "Finished"