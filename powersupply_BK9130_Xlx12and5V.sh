#!/bin/bash

#MDEV="/dev/ttyUSB4"
MDEV="/dev/ttyUSB1"
DDIR='../measurements/environment/'
DFILEPREFIX="meas_$(hostname)_"

stty -F $MDEV 9600 -parenb -parodd cs8 hupcl -cstopb cread clocal -crtscts -ixon -echo


exec 5<>$MDEV

function sendscpi() {
	echo "SENDING>>>: $2"
	echo -e -n "$2\n" >&5
	read -t $1 RESULT <&5
	if [ "$RESULT" != "" ]; then
		echo "RESPONSE<<: $RESULT"
	fi
}

sendscpi 2 '*RST' 
sendscpi 1 'SYST:ERR?'
sendscpi 1 '*CLS'

sendscpi 1 "*IDN?"
IDN="$RESULT"
echo $IDN
sendscpi 1 'SYST:ERR?'
sendscpi 1 '*CLS'

[ "$IDN" == "BK,9130,005004156568001016,V1.69" ] && [ "$(hostname)" == "muon" ] && ans="y" # BK#4, 2011-10-26 on muon providing Xilinx powers

until  [ "$ans" == "y" ]; 
do
        echo -n "Is the right device connected? y/n"
        read ans
        if [ "$ans" == "n" ]; then
                sendscpi 2 'SYST:LOC'
                exit
        fi
done

DFILE="$DFILEPREFIX$( echo $IDN | sed -e 's%[, /:]%_%g')"
mkdir -p $DDIR

TO=.5
sendscpi $TO 'APP:OUT 0,0,0'
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
#sendscpi $TO 'APP:VOLT 24,24,3.3'
sendscpi $TO 'APP:VOLT 0,12,5.0'
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
#sendscpi $TO 'APP:CURR 0.2,0.2,0.2' 
sendscpi $TO 'APP:CURR 0.0,1.5,1.0' 
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
sendscpi $TO 'APP:OUT 0,1,1'
#sendscpi $TO 'SYST:ERR?'
#sendscpi $TO '*CLS'

echo ""
echo "Starting recording currents and voltages to $DDIR$DFILE..."

{

while true; do 
read -t .1 RESULTFLUSH <&5
echo -e -n "MEAS:VOLT:ALL?\n" >&5
echo -e -n "MEAS:CURR:ALL?\n" >&5
read -t 2 RESULTVOLT <&5
read -t 2 RESULTCURR <&5
echo "$(date +"%Y-%m-%d %H:%M:%S,%s"),VOLT:,$RESULTVOLT,CURR:,$RESULTCURR" | sed -e 's/,/\t/g'
read -t 1 K && break
done 

} | tee -a $DDIR$DFILE

#sendscpi 2 'SYST:BEEP'
sendscpi 2 'SYST:LOC'

