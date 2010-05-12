#!/bin/bash

MDEV="/dev/ttyUSB1"
DDIR='../measurements/environment/'
DFILEPREFIX="meas_$(hostname)_"

stty -F $MDEV 9600 parenb -parodd cs7 -hupcl cstopb cread clocal -crtscts -ixon -echo


exec 5<>$MDEV

function sendscpi() {
	[ "$3" == "" ] && echo "SENDING>>>: $2"
	echo -e -n "$2\n" >&5
	RESULT=""
        while read -t $1 RES <&5; do
		RES="${RES%%$'\r'*}"
                [ "$3" == "" ] && echo "RESPONSE<<: <$RES>"
		RESULT="$RESULT$RES"
	done
}

sendscpi 1 ';'
sendscpi 1 'SYSTem:REMote'
sendscpi 1 '*RST'
sendscpi 1 '*CLS'
sendscpi 1 '*IDN?'
sendscpi 1 'VOLT:DC:RANGE 5'
sendscpi 1 'VOLT:DC:RANGE?'
sendscpi 1 'SYST:ERR?'
sendscpi 1 'VOLT:DC:NPLC .2'
sendscpi 1 'SENS:ZERO:AUTO ONCE'
sendscpi 1 'SYSTem:BEEPer:STATe OFF'
#sendscpi 1 'CALC:FUNC AVER'
#sendscpi 1 'CALC:STAT 1'
sendscpi 1 'DATA:FEED RDG_STORE, "CALC"'
sendscpi 1 'SAMP:COUNt 4'
sendscpi 1 'TRIG:DELay 2E-3'
sendscpi 1 'TRIGger:SOURce IMM'
sendscpi 1 'SYST:ERR?'

sendscpi 2 "*IDN?"
IDN="$RESULT"
echo $IDN
sendscpi 2 'SYST:ERR?'
sendscpi 2 '*CLS'

DFILE=$DFILEPREFIX$( echo $IDN | sed -e 's%[, /:]%_%g')

#echo "<$DFILE>"
#exit 
mkdir -p $DDIR

echo ""
echo "Starting recording voltages to <$DDIR$DFILE>..."

{

until read -t 4 K; do
sendscpi 1 'READ?' silent
echo "$(date +"%Y-%m-%d %H:%M:%S,%s"),VOLT:,$RESULT" | sed -e 's/,/\t/g'
done

} | tee -a $DDIR$DFILE

#sendscpi 2 'SYST:BEEP'
sendscpi 2 'SYST:LOC'

