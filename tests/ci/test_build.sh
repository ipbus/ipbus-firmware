#!/usr/bin/env bash
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




SH_SOURCE=${BASH_SOURCE}
IPBUS_PATH=$(cd $(dirname ${SH_SOURCE})/../.. && pwd)
WORK_ROOT=$(cd ${IPBUS_PATH}/../.. && pwd)

PROJECTS=(sim enclustra_ax3_pm3_a35 enclustra_ax3_pm3_a50 kc705_basex kc705_gmii kcu105_basex)

if (( $# != 1 )); then
  echo "No project specified."
  echo "Available projects:" $(printf "'%s' " "${PROJECTS[@]}")

  exit -1
fi
PROJ=$1
if [[ ! " ${PROJECTS[@]} " =~ " ${PROJ} " ]]; then
  # whatever you want to do when arr doesn't contain value
  echo "Project ${PROJ} not known."
  echo "Available projects: ${PROJECTS[@]}"
  exit -1
fi

# Stop on the first error
set -e
# set -x

cd ${WORK_ROOT}
rm -rf proj/${PROJ}
echo "#------------------------------------------------"
echo "Building Project ${PROJ}"
echo "#------------------------------------------------"
if [[ "$PROJ" == "sim" ]]; then
  ipbb proj create sim sim ipbus-firmware:boards/sim
  ipbb sim -p ${PROJ} ipcores
  ipbb sim -p ${PROJ} fli
  ipbb sim -p ${PROJ} project
else
  ipbb proj create vivado -t top_${PROJ}.dep ${PROJ} ipbus-firmware:projects/example
  ipbb vivado -p ${PROJ} project
  ipbb vivado -p ${PROJ} synth 
  ipbb vivado -p ${PROJ} impl 
  ipbb vivado -p ${PROJ} bitfile
fi

exit 0
