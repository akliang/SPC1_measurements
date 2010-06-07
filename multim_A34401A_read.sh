#!/bin/bash

MDEV="/dev/ttyUSB2"
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

T1=0.1 # use full integers for some older BASH shells
T2=1

until read -t $T1  K; do
  read -t $T1 RESULTFLUSH <&5 # wait T1 seconds to sync in case of unexpected response etc.
  echo -e -n "READ?\n" >&5
  read -t $T2 RESULT <&5 # a full line should be available before T2 elapsed, ie T2 can be larger
  echo "$(date +"%Y-%m-%d %H:%M:%S,%s.%N"),VOLT:,$RESULT" | sed -e 's/,/\t/g'
done

} | tee -a $DDIR$DFILE

#sendscpi 2 'SYST:BEEP'
sendscpi 2 'SYST:LOC'

