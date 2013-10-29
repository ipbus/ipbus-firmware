# This script designed for 64b Questasim
#
# You will want to replace the include path with one suitable for your system
#
# Dave Newbold, February 2011
#
# $Id: mac_fli_compile.sh 327 2011-04-25 20:23:10Z phdmn $

gcc -c -fPIC -I${MODELSIM_ROOT}/include/ mac_fli.c
gcc -shared -fPIC -Wl,-Bsymbolic,--allow-shlib-undefined,--export-dynamic -o mac_fli.so mac_fli.o
