
set script_path [ file dirname [ file normalize [ info script ] ] ]

set bd_files [list ${script_path}/../bd/c2c_m_ipb/c2c_m_ipb.bd ${script_path}/../bd/c2c_s_ipb/c2c_s_ipb.bd]

foreach file_path ${bd_files} {
  set bd_file_path [import_files ${file_path}]
  open_bd_design ${bd_file_path}
  reset_target {synthesis implementation} [get_files ${bd_file_path}]
  generate_target {synthesis implementation} [get_files ${bd_file_path}]
}

