
set script_path [ file dirname [ file normalize [ info script ] ] ]

read_bd ${script_path}/../bd/c2c_s_ipb/c2c_s_ipb.bd
#read_bd ${script_path}/../bd/c2c_m_ipb/c2c_m_ipb.bd
generate_target {synthesis implementation} [import_files ${script_path}/../bd/c2c_m_ipb/c2c_m_ipb.bd]
