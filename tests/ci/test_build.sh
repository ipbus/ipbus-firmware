#!/usr/bin/env bash


SH_SOURCE=${BASH_SOURCE}
IPBUS_ROOT=$(cd $(dirname ${SH_SOURCE})/../.. && pwd)
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

echo "#------------------------------------------------"
echo "Building Project ${PROJ}"
echo "#------------------------------------------------"
if [[ "$PROJ" == "sim" ]]; then
  ipbb proj create sim sim ipbus-firmware:boards/sim
  cd $(ipbb proj path ${PROJ})
  ipbb sim ipcores fli project
else
  ipbb proj create vivado -t top_${PROJ}.dep ${PROJ} ipbus-firmware:projects/example
  cd $(ipbb proj path ${PROJ})
  ipbb vivado project synth impl bitfile
fi

exit 0


# Simulation
ipbb proj create sim sim ipbus-firmware:boards/sim
cd proj/sim
set +e
{ 
ipbb sim ipcores fli project && ./vsim -c work.top -do "run 10 us; quit" 
} || {
    echo "ERROR: sim test failed" >> ${TEST_ROOT}/failures.log
}
set -e

# Vivado projects
TEST_PROJ_ARRAY=(enclustra_ax3_pm3_a35 enclustra_ax3_pm3_a50 kc705_basex kc705_gmii kcu105_basex)

for TEST_PROJ in "${TEST_PROJ_ARRAY[@]}"; do
    echo "#------------------------------------------------"
    echo "# Testing ${TEST_PROJ}"
    echo "#------------------------------------------------"
    cd ${TEST_ROOT}
    ipbb proj create vivado -t top_${TEST_PROJ}.dep ${TEST_PROJ} ipbus-firmware:projects/example
    cd proj/${TEST_PROJ}
    set +e
    ipbb vivado project synth impl bitfile || echo "ERROR: ${TEST_PROJ} build failed" >> ${TEST_ROOT}/failures.log
    set -e
done

echo "#------------------------------------------------"
echo "# Summary"
echo "#------------------------------------------------"

if [ -f ${TEST_ROOT}/failures.log ]; then
   echo "Build Error detected!"
   cat ${TEST_ROOT}/failures.log
   return -1
fi
