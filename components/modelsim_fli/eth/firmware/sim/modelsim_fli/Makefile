# This script designed for 64b QuestaSim/ModelSim
#
# Dave Newbold, February 2011
# Alessandro Thea, December 2016
#

SIMEXE:=vsim

ifeq (, $(shell which ${SIMEXE}))
$(error "No ModelSim/QuestaSim in $(PATH), have you added it to PATH?")
endif

TAP_DEV?="tap0"
MODELSIM_ROOT:=$(shell cd $$(dirname $$(which ${SIMEXE}) )/.. && pwd)

mac_fli.so: export MTI_VCO_MODE=64
mac_fli.so: mac_fli.c
	gcc -shared -fPIC -Wl,-Bsymbolic,--allow-shlib-undefined,--export-dynamic -D TAP_DEV=${TAP_DEV} -I${MODELSIM_ROOT}/include/ -o $@ $<

clean:
	rm mac_fli.so
