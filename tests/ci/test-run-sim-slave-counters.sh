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
PROJ=sim_ctr_slaves

# Stop on the first error
set -e
# set -x

cd ${WORK_ROOT}
rm -rf proj/${PROJ}

ipbb proj create sim -t top_sim.dep ${PROJ} ipbus-firmware:tests/ctr_slaves 
cd proj/sim_ctr_slaves

ipbb sim setup-simlib
ipbb sim ipcores
ipbb sim fli-udp
ipbb sim make-project
ipbb sim addrtab

set -x
./vsim -c work.top -do 'run 60sec' -do 'quit' > /dev/null 2>&1 &
VSIM_PID=$!
VSIM_PGRP=$(ps -p ${VSIM_PID} -o pgrp=)

# wait for the simulation to start
sleep 10

# Run the test script
pytest -x -v ${IPBUS_PATH}/tests/ctr_slaves/scripts/test_ctr_slaves.py --client ipbusudp-2.0://localhost:50001 --addr file://addrtab/ctr_slaves_tester.xml

# Cleanup, send SIGINT to the vsimk process in the current process group
pkill -SIGINT -g ${VSIM_PGRP} vsimk
set +x

exit 0
