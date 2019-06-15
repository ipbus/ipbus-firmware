
set script_path [ file dirname [ file normalize [ info script ] ] ]

set locPath [import_files -force -norecurse ${script_path}/../bd/c2c_s_ipb/c2c_s_ipb.bd]
export_ip_user_files -of_objects [get_files ${locPath}] -force -quiet
set locPath [import_files -force -norecurse ${script_path}/../bd/c2c_m_ipb/c2c_m_ipb.bd]
export_ip_user_files -of_objects [get_files ${locPath}] -force -quiet
