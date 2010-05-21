#!/bin/bash

SRC1="/mnt/TFTAutoMeas/export/WeatherOS/DATA/TH/sensor*-1day.csv"

DDIR='../measurements/environment/'
DFILEPREFIX="measTEMP_$(hostname)_"
DFILE="$DFILEPREFIX""RMS300A_N1"

function splittemp() {
T_date="$1" ; shift
T_time="$1" ; shift
T_trend1="$1" ; shift
T_temp="$1" ; shift
T_humid="$1" ; shift
T_trend2="$1" ; shift
T_comf="$1" ; shift
T_heat="$1" ; shift
T_dew="$1" ; shift
}

echo ""
echo "Starting recording temperatures"
echo "  from '$SRC1'"
echo "   to  '$DDIR$DFILE'..."

{

while true; do

TEMPSTR=""
for F in $SRC1; do
  TEMPDATA="$( cat $F | sed -e 's%,%\t%g' )"
  splittemp $TEMPDATA
  TEMPSTR="$TEMPSTR,$T_temp"
done

echo -e "$(date +"%Y-%m-%d %H:%M:%S,%s.%N")$TEMPSTR" | sed -e 's/,/\t/g' 

if read -t 60 K; then break; fi 
done
} | tee -a $DDIR$DFILE


