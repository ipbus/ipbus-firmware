#! /usr/bin/env bash
# EMACS settings: -*-	tab-width: 2; indent-tabs-mode: t -*-
# vim: tabstop=2:shiftwidth=2:noexpandtab
# kate: tab-width 2; replace-tabs off; indent-width 2;
#
# Bash Script: Script to compile the IPbus library for GHDL on Linux.

# save working directory
WorkingDir=$(pwd)
ScriptDir="$(dirname $0)"
ScriptDir="$(readlink -f $ScriptDir)"

SrcDir=${ScriptDir}/../..
SrcDir=$(readlink -f $SrcDir)

GHDLBinDir=""
GHDLLibDir=/usr/local/lib
DestDir="."

# command line argument processing
SUPPRESS_WARNINGS=0
HALT_ON_ERROR=0
while [[ $# > 0 ]]; do
	key="$1"
	case $key in
		-h|--help)
		HELP=TRUE
		;;
		-n|--no-warnings)
		SUPPRESS_WARNINGS=1
		;;
		-H|--halt-on-error)
		HALT_ON_ERROR=1
		;;
		--ghdl)
		GHDLBinDir="$2"
		shift						# skip argument
		;;
		--ghdl-lib)
		GHDLLibDir="$2"
		shift						# skip argument
		;;
		--out)
		DestDir="$2"
		shift						# skip argument
		;;
		*)		# unknown option
		echo 1>&2 -e "Unknown command line option '$key'."
		exit -1
		;;
	esac
	shift # past argument or value
done

# source useful files from GHDL's library directory
. $GHDLLibDir/ghdl/ansi_color.sh
. $GHDLLibDir/ghdl/vendors/shared.sh

# makes no sense to enable it for IPbus
SKIP_EXISTING_FILES=0

if [ "$HELP" == "TRUE" ]; then
	echo "Synopsis:"
	echo "  A script to compile the IPbus firmware as a library for GHDL on Linux."
	echo "  Library directories are created in the current working directory,"
	echo "  so you should call this script from the directory where you want to install"
	echo "  IPbus library."
	echo ""
	echo "Usage:"
	echo "  ghdl_compile.sh [common command] [<adv. options>]"
	echo ""
	echo "Common commands:"
	echo "  -h --help             Print this help page."
	echo "  -H --halt-on-error    Halt on error(s)."
	echo ""
	echo "Advanced options:"
	echo "  --ghdl <GHDL bin dir>          Path to GHDL's binary directory, e.g. /usr/local/bin"
	echo "  --ghdl-lib <GHDL library path> Path to GHDL's library directory, default /usr/local/lib"
	echo "  --out <dir name>               Name of the output directory, that will be created"
	echo "                                 in the current working directory e.g. ipbus."
	echo ""
	echo "Verbosity:"
	echo "  -n --no-warnings      Suppress all warnings. Show only error messages."
	echo ""
	exit 0
fi

SetupDirectories

CreateDestinationDirectory
cd $DestinationDirectory

SetupGRCat

# define global GHDL Options
GHDL_OPTIONS=(-fexplicit -frelaxed-rules --no-vital-checks --warn-binding --mb-comments)

# create a set of GHDL parameters
GHDL_PARAMS=(${GHDL_OPTIONS[@]})
GHDL_PARAMS+=(--std=08 --ieee=synopsys -P$DestinationDirectory)

# IPbus library
# ==============================================================================

ERRORCOUNT=0
Library="ipbus"
VHDLVersion="v08"
Files=(
	ipbus_core/firmware/hdl/ipbus_package.vhd
	ipbus_core/firmware/hdl/ipbus_arb.vhd
	ipbus_core/firmware/hdl/transactor_sm.vhd
	ipbus_core/firmware/hdl/udp_dualportram_tx.vhd
	ipbus_core/firmware/hdl/ipbus_trans_decl.vhd
	ipbus_core/firmware/hdl/transactor_if.vhd
	ipbus_core/firmware/hdl/transactor_cfg.vhd
	ipbus_core/firmware/hdl/transactor.vhd
	ipbus_core/firmware/hdl/udp_dualportram.vhd
	ipbus_core/firmware/hdl/ipbus_dc_fabric_sel.vhd
	ipbus_core/firmware/hdl/trans_arb.vhd
	ipbus_core/firmware/hdl/udp_ipaddr_block.vhd
	ipbus_core/firmware/hdl/udp_rarp_block.vhd
	ipbus_core/firmware/hdl/udp_build_arp.vhd
	ipbus_core/firmware/hdl/udp_build_payload.vhd
	ipbus_core/firmware/hdl/udp_build_ping.vhd
	ipbus_core/firmware/hdl/udp_build_resend.vhd
	ipbus_core/firmware/hdl/udp_build_status.vhd
	ipbus_core/firmware/hdl/udp_status_buffer.vhd
	ipbus_core/firmware/hdl/udp_byte_sum.vhd
	ipbus_core/firmware/hdl/udp_do_rx_reset.vhd
	ipbus_core/firmware/hdl/udp_packet_parser.vhd
	ipbus_core/firmware/hdl/udp_rxram_mux.vhd
	ipbus_core/firmware/hdl/udp_buffer_selector.vhd
	ipbus_core/firmware/hdl/udp_rxram_shim.vhd
	ipbus_core/firmware/hdl/udp_dualportram_rx.vhd
	ipbus_core/firmware/hdl/udp_rxtransactor_if_simple.vhd
	ipbus_core/firmware/hdl/udp_tx_mux.vhd
	ipbus_core/firmware/hdl/udp_txtransactor_if_simple.vhd
	ipbus_core/firmware/hdl/udp_clock_crossing_if.vhd
	ipbus_core/firmware/hdl/udp_if_flat.vhd
	ipbus_core/firmware/hdl/ipbus_dc_node.vhd
	ipbus_core/firmware/hdl/ipbus_fabric_sel.vhd
	ipbus_core/firmware/hdl/ipbus_fabric_simple.vhd
	ipbus_util/firmware/hdl/ipbus_addr_decode.vhd
	ipbus_core/firmware/hdl/ipbus_fabric.vhd
#	ipbus_core/firmware/hdl/ipbus_pipeline.vhd  <- In this file there is a compilation error. https://github.com/ipbus/ipbus-firmware/issues/99
	ipbus_core/firmware/hdl/ipbus_shim.vhd
	ipbus_core/firmware/hdl/ipbus_ctrl.vhd
	ipbus_slaves/firmware/hdl/drp_decl.vhd
	ipbus_slaves/firmware/hdl/ipbus_reg_types.vhd
	ipbus_slaves/firmware/hdl/syncreg_w.vhd
	ipbus_slaves/firmware/hdl/syncreg_r.vhd
	ipbus_slaves/firmware/hdl/ipbus_syncreg_v.vhd
	ipbus_slaves/firmware/hdl/ipbus_ctrs_samp.vhd
	ipbus_slaves/firmware/hdl/ipbus_dpram.vhd
#	ipbus_slaves/firmware/hdl/ipbus_freq_ctr.vhd  <- Depends on Xilinx unisim library
	ipbus_slaves/firmware/hdl/ipbus_ported_dpram36.vhd
	ipbus_slaves/firmware/hdl/ipbus_ram.vhd
	ipbus_slaves/firmware/hdl/ipbus_sdpram72.vhd
	ipbus_slaves/firmware/hdl/uc_spi_interface.vhd
#	ipbus_slaves/firmware/hdl/ipbus_clk_bridge.vhd  <- In this file there is a compilation error. https://github.com/ipbus/ipbus-firmware/issues/101
	ipbus_slaves/firmware/hdl/ipbus_ctrs_v.vhd
	ipbus_slaves/firmware/hdl/ipbus_drp_bridge.vhd
#	ipbus_slaves/firmware/hdl/ipbus_oob_test.vhd  <- Depends on Xilinx unisim library
	ipbus_slaves/firmware/hdl/ipbus_ported_dpram72.vhd
	ipbus_slaves/firmware/hdl/trans_buffer_test.vhd
	ipbus_slaves/firmware/hdl/ipbus_ctrlreg_v.vhd
	ipbus_slaves/firmware/hdl/ipbus_ctr.vhd 
	ipbus_eth/firmware/hdl/emac_hostbus_decl.vhd
	ipbus_slaves/firmware/hdl/ipbus_emac_hostbus.vhd
	ipbus_slaves/firmware/hdl/ipbus_peephole_ram.vhd
	ipbus_slaves/firmware/hdl/ipbus_ported_dpram.vhd
	ipbus_slaves/firmware/hdl/ipbus_reg_v.vhd
	ipbus_slaves/firmware/hdl/ipbus_ver.vhd
	ipbus_slaves/firmware/hdl/trans_buffer.vhd
	ipbus_slaves/firmware/hdl/ipbus_ctrs_ported.vhd
	ipbus_slaves/firmware/hdl/ipbus_dpram36.vhd
	ipbus_slaves/firmware/hdl/ipbus_freq_ctr_div.vhd
	ipbus_slaves/firmware/hdl/ipbus_pkt_ctr.vhd
	ipbus_slaves/firmware/hdl/ipbus_ported_sdpram72.vhd
	ipbus_slaves/firmware/hdl/ipbus_roreg_v.vhd
#	ipbus_slaves/firmware/hdl/uc_pipe_interface.vhd <- Depends on Xilinx unisim library
)

# append absolute source path
SourceFiles=()
for File in ${Files[@]}; do
	SourceFiles+=("$SourceDirectory/$File")
done

GHDLCompilePackages

echo "--------------------------------------------------------------------------------"
echo -n "Compiling IPbus library "
if [ $ERRORCOUNT -gt 0 ]; then
	echo -e $COLORED_FAILED
else
	echo -e $COLORED_SUCCESSFUL
fi
