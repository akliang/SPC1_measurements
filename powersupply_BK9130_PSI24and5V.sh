#!/bin/bash

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
sendscpi 2 'SYST:ERR?'
sendscpi 2 '*CLS'

sendscpi 2 "*IDN?"
IDN="$RESULT"
echo $IDN
sendscpi 2 'SYST:ERR?'
sendscpi 2 '*CLS'

DFILE="$DFILEPREFIX$( echo $IDN | sed -e 's%[, /:]%_%g')"
mkdir -p $DDIR

TO=1
sendscpi $TO 'APP:OUT 0,0,0'
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
#sendscpi 'APP:PROT 24,24,5' 0.5
sendscpi $TO 'APP:VOLT 24,24,5.4'
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
sendscpi $TO 'APP:CURR 0.2,0.2,1.5' 
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
sendscpi $TO 'APP:OUT 1,1,1'
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'

echo ""
echo "Starting recording currents and voltages to $DDIR$DFILE..."

{

until read -t 4 K; do
read -t 1 RESULTFLASH <&5
echo -e -n "MEAS:VOLT:ALL?\n" >&5
echo -e -n "MEAS:CURR:ALL?\n" >&5
read -t 2 RESULTVOLT <&5
read -t 2 RESULTCURR <&5
echo "$(date +"%Y-%m-%d %H:%M:%S,%s"),VOLT:,$RESULTVOLT,CURR:,$RESULTCURR" | sed -e 's/,/\t/g'
done

} | tee -a $DDIR$DFILE

#sendscpi 2 'SYST:BEEP'
sendscpi 2 'SYST:LOC'

