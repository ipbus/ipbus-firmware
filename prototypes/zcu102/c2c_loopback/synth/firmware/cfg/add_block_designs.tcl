
set script_path [ file dirname [ file normalize [ info script ] ] ]

set bd_files [list ${script_path}/../bd/c2c_m_ipb/c2c_m_ipb.bd ${script_path}/../bd/c2c_s_ipb/c2c_s_ipb.bd]

foreach file_path ${bd_files} {
  puts "${file_path}"
  set bd_file_path [import_files -force ${file_path}]
  open_bd_design ${bd_file_path}


  set bd_ips [get_ips [current_bd_design]_*]

  foreach ip $bd_ips {
    upgrade_ip [get_ips $ip]
  }

  reset_target {synthesis implementation} [get_files ${bd_file_path}]
  generate_target {synthesis implementation} [get_files ${bd_file_path}]
}

