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


function print_log_on_error {
  set +x
  echo " ----------------------------------------------------"
  echo " ----------------------------------------------------"
  echo "ERROR occurred. Printing simulation output before bailing"
  cat ${SIM_LOGFILE}
}

function wait_for_licence {
  i=0
  while [ ! -f ${HAVE_LICENCE_FILE} ]; do 
    ((i=i+1))
    m=$(($i%6))
    if [[ "$m" -eq "0" ]]; then
      echo "Waiting for license to be acquired (${HAVE_LICENCE_FILE}) [$i]"
    fi
    sleep 10; 
  done
}


SH_SOURCE=${BASH_SOURCE}
IPBUS_PATH=$(cd $(dirname ${SH_SOURCE})/../.. && pwd)
WORK_ROOT=$(cd ${IPBUS_PATH}/../.. && pwd)

SIM_LOGFILE=sim_output.txt

PROJ=sim_eth
cd ${WORK_ROOT}
rm -rf proj/${PROJ}
echo "#------------------------------------------------"
echo "Building Project ${PROJ}"
echo "#------------------------------------------------"

ipbb proj create sim ${PROJ} ipbus-firmware:projects/example top_sim_eth.dep
cd proj/${PROJ}
ipbb sim setup-simlib
ipbb sim ipcores
ipbb sim fli-eth
ipbb sim generate-project

set -x
HAVE_LICENCE_FILE="i_got_a_licence.txt"
./run_sim -c work.top -gIP_ADDR='X"c0a8c902"' -do "exec touch ${HAVE_LICENCE_FILE}" -do 'run 60sec' -do 'quit' > ${SIM_LOGFILE} 2>&1 &
VSIM_PID=$!
VSIM_PGRP=$(ps -p ${VSIM_PID} -o pgrp=)
trap print_log_on_error EXIT

# Wait for a licence to be available
set +x
wait_for_licence
set -x
# ait for the simulation to start
sleep 10
# tickle the simulation
ping 192.168.201.2 -c 5
# Cleanup, send SIGINT to the vsimk process in the current process group
pkill -SIGINT -g ${VSIM_PGRP} vsimk
set +x
# fi

exit 0
