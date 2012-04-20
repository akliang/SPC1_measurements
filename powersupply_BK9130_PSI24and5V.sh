#!/bin/bash

# $HeadURL$
# $Id$

#MDEV="/dev/ttyUSB4"
MDEV="/dev/ttyUSB0"
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

# uncomment the configuration you intend to use on this computer:
#[ "$IDN" == "BK,9130,005004156568001063,V1.69" ] && [ "$(hostname)" == "exciton" ] && ans="y" # BK#3, 2012-02-15 on exciton providing PNC power
#[ "$IDN" == "BK,9130,005004156568001063,V1.69" ] && [ "$(hostname)" == "muon"    ] && ans="y" # BK#3, 2011-10-25 on muon providing PNC power
#[ "$IDN" == "BK,9130,005004156568001088,V1.69" ] && [ "$(hostname)" == "muon"    ] && ans="y" # BK#5, 2012-02-24 on muon providing PNC power
[ "$IDN" == "BK,9130,005004156568001088,V1.69" ] && [ "$(hostname)" == "simwork" ] && ans="y" # BK#5, 2011-10-28 on simwork providing PNC power for actual array measurements

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
sendscpi $TO 'APP:VOLT 24,24,5.4'
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
#sendscpi $TO 'APP:CURR 0.2,0.2,0.2' 
sendscpi $TO 'APP:CURR 0.5,0.5,1.5' 
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
sendscpi $TO 'APP:OUT 1,1,1'
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

