
set script_path [ file dirname [ file normalize [ info script ] ] ]

set bd_files [list ${script_path}/../bd/axi_ic/axi_ic.bd]

foreach file_path ${bd_files} {
  set bd_file_path [import_files ${file_path}]
  open_bd_design ${bd_file_path}
  reset_target {synthesis implementation} [get_files ${bd_file_path}]
  generate_target {synthesis implementation} [get_files ${bd_file_path}]
}

