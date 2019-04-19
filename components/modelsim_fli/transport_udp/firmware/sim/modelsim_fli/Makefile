# This script designed for 64b QuestaSim/ModelSim
#
# Dave Newbold, February 2011
# Alessandro Thea, December 2016
#

SIMEXE:=vsim

ifeq (, $(shell which ${SIMEXE}))
$(error "No ModelSim/QuestaSim in $(PATH), have you added it to PATH?")
endif

MODELSIM_ROOT:=$(shell cd $$(dirname $$(which ${SIMEXE}) )/.. && pwd)

IP_PORT?="50001"
sim_udp_fli.so: export MTI_VCO_MODE=64
sim_udp_fli.so: sim_udp_fli.c
	gcc -shared -fPIC -Wl,-Bsymbolic,--allow-shlib-undefined,--export-dynamic -D IP_PORT=${IP_PORT} -I${MODELSIM_ROOT}/include/ -o $@ $<

clean:
	rm sim_udp_fli.so
