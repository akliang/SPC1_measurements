#!/bin/bash

MDEV="/dev/ttyUSB1"
DDIR='../measurements/environment/'
DFILEPREFIX="measarraySweep_$(hostname)_"

VOLTFILE='commtemp/arraySweep_volts.scpi'

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

sendscpi 1 '*RST' 
sendscpi 2 'SYST:ERR?'
sendscpi 1 '*CLS'

sendscpi 2 "*IDN?"
IDN="$RESULT"
echo $IDN
sendscpi 1 'SYST:ERR?'
sendscpi 1 '*CLS'

DFILE="$DFILEPREFIX$( echo $IDN | sed -e 's%[, /:]%_%g')"
mkdir -p $DDIR

TO=0.3
sendscpi $TO 'APP:OUT 0,0,0'
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
#sendscpi 'APP:PROT 24,24,5' 0.5
sendscpi $TO 'APP:VOLT 0,0,0'
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
sendscpi $TO 'APP:CURR 0.050,0.100,0.050' 
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
sendscpi $TO 'APP:OUT 1,1,1'
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'

echo ""
echo "Starting recording currents and voltages to $DDIR$DFILE..."

{

until read -t 0.1 K; do
if [ -e $VOLTFILE ]; then
sendscpi 1 "$(<"$VOLTFILE")" >&2
rm "$VOLTFILE"
fi
echo -e -n "MEAS:VOLT:ALL?\n" >&5
echo -e -n "MEAS:CURR:ALL?\n" >&5
read -t 1 RESULTVOLT <&5
read -t 1 RESULTCURR <&5
echo "$(date +"%Y-%m-%d %H:%M:%S,%s.%N"),VOLT:,$RESULTVOLT,CURR:,$RESULTCURR" | sed -e 's/,/\t/g'
done

} | tee -a $DDIR$DFILE

#sendscpi 2 'SYST:BEEP'
sendscpi 2 'SYST:LOC'

