#!/usr/bin/env bash


SH_SOURCE=${BASH_SOURCE}
IPBUS_PATH=$(cd $(dirname ${SH_SOURCE})/../.. && pwd)
WORK_ROOT=$(cd ${IPBUS_PATH}/../.. && pwd)

PROJECTS=(sim enclustra_ax3_pm3_a35 enclustra_ax3_pm3_a50 kc705_basex kc705_gmii kcu105_basex)

if (( $# != 1 )); then
  echo "No project specified."
  echo "Available projects: ${PROJECTS[@]}"

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
set -x

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
