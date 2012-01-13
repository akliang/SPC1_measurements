#!/bin/bash

# $HeadURL$
# $Id$

# This script parses setup.cir to provide structures which allow
# addressing voltages and control signals by names
# it can be sourced by other shell scripts, and later it may also
# produce matlab code to be used in matlab scripts

declare -A vid # voltage IDs, maps net names to vout#
mapstring="$(
  cat setup.cir | grep ^Vmap | sed -r -e 's/.*Vout([0-9]+)\W+(\w*)\W+.*/vid[\2]=\1/'
)"
echo "$mapstring"
eval "$mapstring"

#Xu57ch1 SAFT   Vout12 Vout11 DLread2    MAX333
mapstring="$(
  cat setup.cir | grep ^Xu5 | sed -r -e 's/.*Vout([0-9]+)\W+Vout([0-9]+)\W+(\w*)\W+.*/vid[\3]=\1/'
)"
echo "$mapstring"
eval "$mapstring"


declare -A sid # smu IDs, maps vout# to smuchan: Vsmu1x1  Vsmu1  Vout1    0V
mapstring="$(
  cat setup.cir | grep ^Vsmu | sed -r -e 's/.*Vsmu([0-9]+)\W+Vout(\w*)\W+.*/sid[\2]=\1/'
)"
echo "$mapstring"
eval "$mapstring"


declare -A digio # smu digios, maps digios to PNC control net: Vdigio1x9   PACLK     0   0V
mapstring="$(
  cat setup.cir | grep ^Vdigio | sed -r -e 's/.*Vdigio([0-9]+)x([0-9]+)\W+(\w*)\W+.*/digio[\3]="\1 \2"/'
)"
echo "$mapstring"
eval "$mapstring"


function smuaffects() {
 vouts="";
 for vname in $*; do
 smuchan=${sid[${vid[$vname]}]}
 # find all vids on that smu channel
 for f in ${!sid[*]}; do
   if [ ${sid[$f]} == $smuchan ]; then
     vouts="$vouts $f"
   fi
 done
 done
 echo $vouts
}
function vid2name() {
 vnames=""
 for voutid in $*; do
 for f in ${!vid[*]}; do
   if [ ${vid[$f]} == $voutid ]; then
     vnames="$vnames $f"
   fi
 done
 done
 echo $vnames
}

# in source mode, everything is set up now, so we return to the calling script
if [ "$1" == "source" ]; then return; fi

# in test/demo mode, we test some cases
v=VccCSA
v=VbiasNC
echo ${vid[SFBgateNC]}
echo ${vid[VccCSA]}
echo ${vid[$v]}

echo "${!vid[*]}"
echo "${!sid[*]}"

echo "To set $v, smu channel ${sid[${vid[$v]}]} needs to be altered"
echo "This also affects vouts $( smuaffects $v  )"
echo "i.e. $( vid2name $( smuaffects $v ) )"

exit

# in "matlab" mode, we create the equivalent matlab sources/structures
% create map which voltages are changed together
FN=fieldnames(id); env.vid2names=cell(max(struct2array(id)),1); %cell(size(FN,1),1) 
for n=1:size(FN); env.vid2names{id.(FN{n})}{end+1}=FN{n}; end
vid2names=@(vid) (sprintf('%s ',env.vid2names{vid}{:}));

