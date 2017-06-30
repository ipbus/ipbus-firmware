#-------------------------------------------------------------------------------
#
#   Copyright 2017 - Rutherford Appleton Laboratory and University of Bristol
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#                                     - - -
#
#   Additional information about ipbus-firmare and the list of ipbus-firmware
#   contacts are available at
#
#       https://ipbus.web.cern.ch/ipbus
#
#-------------------------------------------------------------------------------


project set "Preferred Language" "VHDL"
project set "Keep Hierarchy" "Soft" -process "Synthesize - XST"
project set "Enable Multi-Threading" "2" -process "Map"
project set "Pack I/O Registers/Latches into IOBs" "For Inputs and Outputs" -process "Map"
project set "Allow Logic Optimization Across Hierarchy" TRUE -process "Map"
project set "Register Duplication" "On" -process "Map"
project set "Generate Detailed MAP Report" TRUE -process "Map"
project set "LUT Combining" "Auto" -process "Map"
project set "Enable Multi-Threading" "2" -process "Place & Route"
project set "Generate Clock Region Report" TRUE -process "Place & Route"
project set "Enable BitStream Compression" TRUE -process "Generate Programming File"
project set "Power Down Device if Over Safe Temperature" TRUE -process "Generate Programming File"
