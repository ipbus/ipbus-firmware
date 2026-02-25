package require -exact qsys 24.3.1

# create the system "probe"
proc do_create_probe {} {
	# create the system
	create_system probe
	set_project_property BOARD {Agilex 7 FPGA I-Series Transceiver Development Kit 6x F-Tile DK-SI-AGI040FES}
	set_project_property DEVICE {AGIC040R39A2E2VR0}
	set_project_property DEVICE_FAMILY {Agilex 7}
	set_project_property HIDE_FROM_IP_CATALOG {true}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_instance in_system_sources_probes_0 altera_in_system_sources_probes 19.2.1
	set_instance_parameter_value in_system_sources_probes_0 {create_source_clock} {0}
	set_instance_parameter_value in_system_sources_probes_0 {create_source_clock_enable} {0}
	set_instance_parameter_value in_system_sources_probes_0 {gui_use_auto_index} {1}
	set_instance_parameter_value in_system_sources_probes_0 {instance_id} {NONE}
	set_instance_parameter_value in_system_sources_probes_0 {probe_width} {10}
	set_instance_parameter_value in_system_sources_probes_0 {sld_instance_index} {0}
	set_instance_parameter_value in_system_sources_probes_0 {source_initial_value} {0}
	set_instance_parameter_value in_system_sources_probes_0 {source_width} {0}
	set_instance_property in_system_sources_probes_0 AUTO_EXPORT true

	# add wirelevel expressions

	# preserve ports for debug

	# add the exports
	set_interface_property probes EXPORT_OF in_system_sources_probes_0.probes

	# set values for exposed HDL parameters

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="in_system_sources_probes_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {probe.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {probe}

	# save the system
	sync_sysinfo_parameters
	save_system probe
}

proc do_set_exported_interface_sysinfo_parameters {} {
}

# create all the systems, from bottom up
do_create_probe

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters
