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

N_ERRORS=0

for componentDir in $(find -L ${IPBUS_PATH} -type d  -printf "%P\n")
do
  if [ -d ${IPBUS_PATH}/${componentDir}/firmware ]
  then

    for depFile in $(find ${IPBUS_PATH}/${componentDir}/firmware/cfg -name "*.dep" -printf "%P\n")
    do
      TOOLSET=$([[ "${componentDir}/firmware/cfg/${depFile}" =~ "sim" ]] && echo "sim" || echo "vivado")

      echo "Checking ${componentDir} - ${depFile}   [tool: ${TOOLSET}]"
      ipbb toolbox check-dep -t ${TOOLSET} ipbus-firmware:${componentDir} $(basename ${depFile})

      if [ $? -ne 0 ]; then
        ((N_ERRORS++))
      fi
      echo
    done

  fi
done

if [ ${N_ERRORS} -ne 0 ]; then
  echo "Errors found in ${N_ERRORS} dependency files"
  exit 1
fi

