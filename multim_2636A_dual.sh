#!/bin/bash

MDEV="/dev/ttyUSB1"
DDIR='../measurements/environment/'
DFILEPREFIX="meas_$(hostname)_"
DFILEPREFIX="testa_$(hostname)_"

CURRFILE='2636_setcurrent.scpi'

if false; then
  # Code for USB communication - somewhat faulty
  #stty -F $MDEV 9600 -parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts -ixon -echo
  stty -F $MDEV 9600 -parenb -parodd cs8 hupcl -cstopb cread clocal -crtscts -ixon -echo
  exec 5<>$MDEV
  exec 6<>$MDEV
else
  # Code for Ethernet communication
  nc 192.168.0.226 1030 
  TD=$( mktemp -d )
  mkfifo "$TD/p5" "$TD/p6"
  exec 5<>"$TD/p5"
  exec 6<>"$TD/p6"
  nc 192.168.0.226 5025 <"$TD/p5" >"$TD/p6" &
  rm "$TD/p5" "$TD/p6" # actual delete will only occur once files are no longer accessed
  NCPID=$!
  #trap "nc 192.168.0.226 1030; rmdir '$TD'; exit" EXIT
  trap "nc 192.168.0.226 1030; kill $NCPID; rmdir '$TD'; exit" EXIT
fi

function sendscpi() {
	# $1: timeout for first response (0 to skip read)
	# $2: string to send
	# $3: optional, if not empty, do show SENDING and RESPONSE
	# $4: optional, if present, wait for a single line of resonse only
        [ "$3" == "" ] && echo "SENDING>>>: $2"
        echo -e -n "$2\n" >&5
        RESULT=""
	if [ "$1" != "0" ]; then
        while read -t $1 RES <&6; do
                RES="${RES%%$'\r'*}"
                [ "$3" == "" ] && echo "RESPONSE<<: <$RES>"
                RESULT="$RESULT$RES"
		[ "$4" != "" ] && break
        done
	fi
}

sendscpi .1 'abort'
sendscpi .1 '*RST'
sendscpi .1 '*CLS'
sendscpi .5 '*IDN?'
IDN="$RESULT"
echo $IDN
#sendscpi 2 '*CLS'

ans="y"
until  [ "$ans" == "y" ]; 
do
        echo -n "Is the right device connected? y/n"
        read ans
        if [ "$ans" == "n" ]; then
              #  sendscpi 2 'SYST:LOC'
                exit
        fi
done

if false; then
#echo 'script.factory.scripts.KIPulse.list()' >&5
echo 'script.factory.scripts.KIParlib.list()' >&5
while read -t 5 K <&6; do echo "$K"; done
fi

sendscpi 4 'tsplink.reset() print(tsplink.state)' "" wait4onelineonly
#sendscpi 1 'print(tsplink.state)'


#Setup:
#ChannelA: Non-Floating, Voltage measurement (source 0 amps, measure Volts)
#ChannelB: Floating, Current measurement     (source 0 volts)

sendscpi .1 '
node[1].smua.reset()
node[1].smua.source.func=smua.OUTPUT_DCAMPS
node[1].smua.source.autorangei=smua.AUTORANGE_ON
node[1].smua.source.autorangev=smua.AUTORANGE_ON
node[1].smua.source.leveli=0
node[1].smua.source.limitv=20
node[1].display.smua.measure.func=display.MEASURE_DCVOLTS
node[1].smua.sense = smua.SENSE_LOCAL
'

sendscpi .1 'node[2].smua.reset()
node[2].smua.source.func=smua.OUTPUT_DCAMPS
node[2].smua.source.autorangei=smua.AUTORANGE_ON
node[2].smua.source.autorangev=smua.AUTORANGE_ON
node[2].smua.source.leveli=0
node[2].smua.source.limitv=20
node[2].display.smua.measure.func=display.MEASURE_DCVOLTS 
node[2].smua.sense = smua.SENSE_LOCAL
'

sendscpi .1 'node[1].smub.reset()
node[1].smub.source.func=smub.OUTPUT_DCVOLTS
node[1].smub.source.autorangei=smub.AUTORANGE_ON
node[1].smub.source.autorangev=smub.AUTORANGE_ON
node[1].smub.source.levelv=0
node[1].smub.source.limiti=0.01
node[1].display.smub.measure.func=display.MEASURE_DCAMPS
node[1].smub.sense = smub.SENSE_LOCAL
'


sendscpi .1 '
node[2].smub.reset()
node[2].smub.source.func=smub.OUTPUT_DCVOLTS
node[2].smub.source.autorangei=smub.AUTORANGE_ON
node[2].smub.source.autorangev=smub.AUTORANGE_ON
node[2].smub.source.levelv=0
node[2].smub.source.limiti=0.01
node[2].display.smub.measure.func=display.MEASURE_DCAMPS
node[2].smub.sense = smub.SENSE_LOCAL
'


sendscpi 2 ' errorcode, message, severity, errnode = errorqueue.next() print(errorcode, message, severity, errnode) '


sendscpi .1 'node[1].smua.trigger.measure.iv(node[1].smua.nvbuffer1,node[1].smua.nvbuffer2) '
sendscpi .1 'node[1].smua.trigger.measure.action = node[1].smua.ENABLE'
sendscpi .1 'node[1].smua.trigger.measure.stimulus = trigger.EVENT_ID'
#sendscpi .1 'node[1].smua.trigger.initiate() '
sendscpi .1 'node[2].smua.trigger.measure.iv(node[2].smua.nvbuffer1,node[2].smua.nvbuffer2) '
sendscpi .1 'node[2].smua.trigger.measure.action = node[2].smua.ENABLE'
sendscpi .1 'node[2].smua.trigger.measure.stimulus = trigger.EVENT_ID'
#sendscpi .1 'node[2].smua.trigger.initiate() '

sendscpi 1 ' errorcode, message, severity, errnode = errorqueue.next() print(errorcode, message, severity, errnode) '
sendscpi 1 '
loadandrunscript MKmultiMonitor

function MKmultiMeasure()
  node[1].smua.measure.overlappediv(node[1].smua.nvbuffer1,node[1].smua.nvbuffer2)
  node[1].smub.measure.overlappediv(node[1].smub.nvbuffer1,node[1].smub.nvbuffer2)
  node[2].smua.measure.overlappediv(node[2].smua.nvbuffer1,node[2].smua.nvbuffer2)
  node[2].smub.measure.overlappediv(node[2].smub.nvbuffer1,node[2].smub.nvbuffer2)
end

function MKmultiPrint()
  waitcomplete(0)
  print(node[1].smua.nvbuffer1[1],node[1].smua.nvbuffer2[1],
        node[1].smub.nvbuffer1[1],node[1].smub.nvbuffer2[1],
        node[2].smua.nvbuffer1[1],node[2].smua.nvbuffer2[1],
        node[2].smub.nvbuffer1[1],node[2].smub.nvbuffer2[1])
end

function MKcheckError()
  errorcode, message, severity, errnode = errorqueue.next()
  if errorcode>0 then
    --print(errorcode, message, severity, errnode)
    print(string.format("%d %s %d",errorcode, message, severity), errnode)
  end
end

endscript
'
sendscpi 2 ' errorcode, message, severity, errnode = errorqueue.next() print(string.format("%d %s %d",errorcode, message, severity), errnode) '


#sendscpi 2 '*TRG'

#sendscpi 2 '
#print(triggered)
#print(node[1].smua.nvbuffer1[1], node[1].smua.nvbuffer2[1])
#print(node[2].smua.nvbuffer1[1], node[2].smua.nvbuffer2[1])
#'

#sendscpi 2 ' errorcode, message, severity, errnode = errorqueue.next() print(errorcode, message, severity, errnode) '

#'printbuffer(1,1,node[1].smua.nvbuffer1)'

SMUS="node[1].smua node[1].smub node[2].smua node[2].smub"
for SMU in $SMUS; do
sendscpi 1 "
$SMU.measure.nplc = 0.1
$SMU.measure.delay = $SMU.DELAY_OFF
MKcheckError()
"
done

sendscpi .1 '
node[1].smua.source.output = smua.OUTPUT_ON
node[1].smub.source.output = smub.OUTPUT_ON
node[2].smua.source.output = smua.OUTPUT_ON
node[2].smub.source.output = smub.OUTPUT_ON
'

sendscpi 2 ' errorcode, message, severity, errnode = errorqueue.next() print(errorcode, message, severity, errnode) '
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
  sendscpi 5 'MKmultiMeasure() MKmultiPrint() MKcheckError()' silent singleline
  echo "$(date +"%Y-%m-%d %H:%M:%S,%s.%N"),"$RESULT | sed -e 's/,/\t/g'
  #read -t 4 K && break # on user input, break loop
  #sendscpi 1 'MKcheckError()' >&2
  sendscpi 0.2 '-- reading errors' >&2
  #read -t $T1 RESULTFLUSH <&6 # wait T1 seconds to sync in case of unexpected response etc.
  #echo -e -n "print(smua.measure.v(),smub.measure.v()) \n " >&5
  #echo -e -n "print(smua.measure.i(),smub.measure.i()) \n " >&5
  #read -t $T2 VOLT  <&6 # a full line should be available before T2 elapsed, ie T2 can be larger
  #read -t $T2 CURRENT  <&6 # a full line should be available before T2 elapsed, ie T2 can be larger
  #echo "$(date +"%Y-%m-%d %H:%M:%S,%s.%N"),VOLT:,$VOLT,CURRENT:,$CURRENT" | sed -e 's/,/\t/g'
#  echo "$(date +"%Y-%m-%d %H:%M:%S,%s.%N"),VOLT:,$VOLT" | sed -e 's/,/\t/g'

done

} | tee -a $DDIR$DFILE

sendscpi 1 '
node[1].smua.source.output=smua.OUTPUT_OFF
node[1].smub.source.output=smua.OUTPUT_OFF
node[2].smua.source.output=smua.OUTPUT_OFF
node[2].smub.source.output=smua.OUTPUT_OFF
node[1].smua.reset()
node[1].smub.reset()
node[2].smua.reset()
node[2].smub.reset()
'

sendscpi 2 ' errorcode, message, severity, errnode = errorqueue.next() print(string.format("%d %s %d",errorcode, message, severity), errnode) '
#sendscpi 2 ' errorcode, message, severity, errnode = errorqueue.next() print(errorcode, message, severity, errnode) '

sendscpi 1 'abort'


