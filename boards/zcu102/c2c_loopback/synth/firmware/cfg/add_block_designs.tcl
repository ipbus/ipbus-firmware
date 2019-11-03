
set script_path [ file dirname [ file normalize [ info script ] ] ]

generate_target {synthesis implementation} [import_files ${script_path}/../bd/c2c_m_ipb/c2c_m_ipb.bd]

set c2c_s_bd_file_path [import_files ${script_path}/../bd/c2c_s_ipb/c2c_s_ipb.bd]
open_bd_design ${c2c_s_bd_file_path}
reset_target {synthesis implementation} [get_files ${c2c_s_bd_file_path}]
generate_target {synthesis implementation} [get_files ${c2c_s_bd_file_path}]

