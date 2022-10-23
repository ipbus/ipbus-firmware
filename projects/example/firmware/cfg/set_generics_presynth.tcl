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
# Presynth script for setting generics from environment variable SYNTH_GENERIC_VALUES

if { [info exists ::env(SYNTH_GENERIC_VALUES) ] } {
  set GENERIC_VALUES $::env(SYNTH_GENERIC_VALUES)
  puts "Generics: $GENERIC_VALUES"
  puts "Current fileset: [current_fileset]"
  set_property generic "$GENERIC_VALUES" [current_fileset]
}

