#!/bin/bash

MDEV="/dev/ttyUSB1"
DDIR='../measurements/environment/'
DFILEPREFIX="meas_$(hostname)_"

CURRFILE='2636_setcurrent.scpi'

stty -F $MDEV 9600 -parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts -ixon -echo


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

#sendscpi 1 ';'
#sendscpi 1 'SYSTem:REMote'
sendscpi 1 '*RST'
sendscpi 1 '*CLS'
sendscpi 1 '*IDN?'
IDN="$RESULT"
echo $IDN
sendscpi 2 '*CLS'


until  [ "$ans" == "y" ]; 
do
        echo -n "Is the right device connected? y/n"
        read ans
        if [ "$ans" == "n" ]; then
              #  sendscpi 2 'SYST:LOC'
                exit
        fi
done

#Setup:
#ChannelA: Non-Floating, Voltage measurement (source 0 amps, measure Volts)
#ChannelB: Floating, Current measurement     (source 0 volts)

sendscpi 1 'smua.reset()'

sendscpi 1 'smua.source.func=smua.OUTPUT_DCAMPS';
#sendscpi 1 'smua.source.rangei=10e-3'
sendscpi 1 'smua.source.autorangei=smua.AUTORANGE_ON'
sendscpi 1 'smua.source.autorangev=smua.AUTORANGE_ON'
sendscpi 1 'smua.source.leveli=0'
sendscpi 1 'smua.source.limitv=20'
sendscpi 1 'display.smua.measure.func=display.MEASURE_DCVOLTS' 
#sendscpi 1 'smua.measure.delay=2e-3'
#sendscpi 1 'smua.trigger.count=4'
#sendscpi 1 'smua.measure.action=smua.ENABLE'
#sendscpi 1 'smua.trigger.initiate()'



#sendscpi 1 'smua.sense = smua.SENSE_REMOTE' 
sendscpi 1 'smua.sense = smua.SENSE_LOCAL'
sendscpi 1 'smua.source.output = smua.OUTPUT_ON'

#sendscpi 1 'display.smua.measure.func = display.MEASURE_OHMS'


sendscpi 1 'smub.reset()'

sendscpi 1 'smub.source.func=smub.OUTPUT_DCVOLTS';
#sendscpi 1 'smub.source.rangei=10e-3'
sendscpi 1 'smub.source.autorangei=smub.AUTORANGE_ON'
sendscpi 1 'smub.source.autorangev=smub.AUTORANGE_ON'
sendscpi 1 'smub.source.levelv=0'
sendscpi 1 'smub.source.limiti=0.01'
sendscpi 1 'display.smub.measure.func=display.MEASURE_DCAMPS'
#sendscpi 1 'smub.measure.delay=2e-3'
#sendscpi 1 'smub.trigger.count=4'
#sendscpi 1 'smub.measure.action=smua.ENABLE'
#sendscpi 1 'smub.trigger.initiate()'



#sendscpi 1 'smub.sense = smua.SENSE_REMOTE' 
sendscpi 1 'smub.sense = smub.SENSE_LOCAL'
sendscpi 1 'smub.source.output = smub.OUTPUT_ON'

#sendscpi 1 'display.smub.measure.func = display.MEASURE_OHMS'




DFILE=$DFILEPREFIX$( echo $IDN | sed -e 's%[, /:]%_%g')

#echo "<$DFILE>"
#exit 
mkdir -p $DDIR

echo ""
echo "Starting recording voltages to <$DDIR$DFILE>..."

{

T1=0.1 # use full integers for some older BASH shells
T2=5

until read -t $T1  K; do
  if [ -e $CURRFILE ]; then
	sendscpi 1 "$(<"$CURRFILE")" >&2
	rm "$CURRFILE"
  fi
  read -t $T1 RESULTFLUSH <&5 # wait T1 seconds to sync in case of unexpected response etc.
  echo -e -n "print(smua.measure.v(),smub.measure.v()) \n " >&5
  echo -e -n "print(smua.measure.i(),smub.measure.i()) \n " >&5
  read -t $T2 VOLT  <&5 # a full line should be available before T2 elapsed, ie T2 can be larger
  read -t $T2 CURRENT  <&5 # a full line should be available before T2 elapsed, ie T2 can be larger
  echo "$(date +"%Y-%m-%d %H:%M:%S,%s.%N"),VOLT:,$VOLT,CURRENT:,$CURRENT" | sed -e 's/,/\t/g'
#  echo "$(date +"%Y-%m-%d %H:%M:%S,%s.%N"),VOLT:,$VOLT" | sed -e 's/,/\t/g'

done

} | tee -a $DDIR$DFILE

sendscpi 1 'smua.source.output=smua.OUTPUT_OFF'
sendscpi 1 'smua.reset()'
sendscpi 1 'smub.source.output=smua.OUTPUT_OFF'
sendscpi 1 'smub.reset()'






