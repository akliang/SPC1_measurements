#!/bin/bash

# $HeadURL$
# $Id$

MDEV="/dev/ttyUSB1"
NDEV="smu1.imager.umro"
DDIR='../measurements/environment/'
DFILEPREFIX="meas_$(hostname)_"
DFILEPREFIX="testXX_TAA-29B1-1_ch1=GlobRST_ch2=DL16_ch3=Vreset_ch4=DL10_ch5=Vbias_ch6=DL03_GL13HI_$(hostname)_"

echo "$(date)" >> "$DDIR$DFILEPREFIX.log"
svn diff "$0"  >> "$DDIR$DFILEPREFIX.log"

SCPIFILE='2636_command.scpi'
# BASH code for live interaction:
# while true; do read N; echo "$N" >>2636_command.scpi; done
DATACTRLFILE='2636_datactrl'

if false; then
  # Code for USB communication - somewhat faulty
  #stty -F $MDEV 9600 -parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts -ixon -echo
  stty -F $MDEV 9600 -parenb -parodd cs8 hupcl -cstopb cread clocal -crtscts -ixon -echo
  exec 5<>$MDEV
  exec 6<>$MDEV
else
  # Code for Ethernet communication
  nc $NDEV 1030 
  TD=$( mktemp -d )
  mkfifo "$TD/p5" "$TD/p6"
  exec 5<>"$TD/p5"
  exec 6<>"$TD/p6"
  nc $NDEV 5025 <"$TD/p5" >"$TD/p6" &
  rm "$TD/p5" "$TD/p6" # actual delete will only occur once files are no longer accessed
  NCPID=$!
  #trap "nc 192.168.0.226 1030; rmdir '$TD'; exit" EXIT
  trap "nc $NDEV 1030; kill $NCPID; rmdir '$TD'; exit" EXIT
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

function sendscpi_cond() {
	sendscpi "$1" "$2" dontshow "$4" "$5"
	if [ "$RESULT" != "" ]; then
        [ "$3" == "" ] && echo "SENT>>>: $2"
        [ "$3" == "" ] && echo "RESP<<: <$RESULT>"
        [ "$5" != "" ] && sleep $5
	fi
}

function check_error() {
  sendscpi_cond 1 'errorcode, message, severity, errnode = errorqueue.next() if errorcode~=0 then print(string.format("%d %s %d",errorcode, message, severity), errnode) end' "" "" 5 >&2
}

sendscpi .1 'abort'
sendscpi .1 '*RST'
sendscpi .1 '*CLS'
sendscpi 5  '*IDN?' "" wait4onelineonly
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

sendscpi 8 'tsplink.reset() print(tsplink.state)' "" wait4onelineonly
check_error

SMUS="
node[1].smua
node[1].smub
node[2].smua
node[2].smub
node[3].smua
node[3].smub
"

# Showing all channels and resetting them
MSG=""
for SMU in $SMUS; do
echo "SMU: $SMU"
MSG="$MSG
$SMU.reset()"
done
sendscpi 1 "$MSG"
check_error

# Building defaults for all channels
N=0
for SMU in $SMUS; do
N=$(( $N + 1 ))
sendscpi 0.1 "
$SMU.source.autorangei=$SMU.AUTORANGE_ON
$SMU.source.autorangev=$SMU.AUTORANGE_ON
$SMU.source.leveli=0
$SMU.source.levelv=0
$SMU.source.limiti=0.001
$SMU.source.limitv=15.0
$SMU.sense = $SMU.SENSE_LOCAL
$SMU.measure.nplc = 1
$SMU.measure.delay = $SMU.DELAY_OFF
v$N = makesetter($SMU.source, 'levelv')
i$N = makesetter($SMU.source, 'leveli')
$SMU.source.highc = $SMU.ENABLE
"
check_error
done

if false; then

#Setup:
#ChannelA: Non-Floating, Voltage measurement (source 0 amps, measure volts)
#ChannelB: Floating, Current measurement     (source 0 volts, measure amps)
#others  : Non-Floating, Current measurement (source X volts, measure amps)
#settable using vN(volts), where N is the smu channel as in the order of $SMUS

# Current sourcing:
#sendscpi .1 '
#node[1].smua.source.func=smua.OUTPUT_DCAMPS
#node[1].DISPLAY.SMUA.MEASURE.FUNc=display.MEASURE_DCVOLTS
#'
sendscpi .1 '
node[1].smua.source.func=smua.OUTPUT_DCVOLTS
node[1].display.smua.measure.func=display.MEASURE_DCAMPS
'

#sendscpi .1 '
#node[1].smub.source.func=smub.OUTPUT_DCVOLTS
#node[1].display.smub.measure.func=display.MEASURE_DCAMPS
#node[1].smub.source.highc=smub.DISABLE
#'
sendscpi .1 '
node[1].smub.source.func=smub.OUTPUT_DCAMPS
node[1].display.smub.measure.func=display.MEASURE_DCVOLTS
node[1].smub.source.highc=smub.DISABLE
'

sendscpi .1 '
node[2].smua.source.func=smua.OUTPUT_DCVOLTS
node[2].display.smua.measure.func=display.MEASURE_DCAMPS
node[2].smua.source.sink=smua.ENABLE
node[2].smua.source.limitv=10
'

sendscpi .1 '
node[2].smub.source.func=smub.OUTPUT_DCVOLTS
node[2].display.smub.measure.func=display.MEASURE_DCAMPS
node[2].smub.source.limitv=10
'

sendscpi .1 '
node[3].smua.source.func=smua.OUTPUT_DCVOLTS
node[3].display.smua.measure.func=display.MEASURE_DCAMPS
'

sendscpi .1 '
node[3].smub.source.func=smub.OUTPUT_DCVOLTS
node[3].display.smub.measure.func=display.MEASURE_DCAMPS
'

## for triple-channel measurement, no high-C on DL channels
sendscpi .1 '
node[1].smub.source.highc=smub.DISABLE
node[2].smub.source.highc=smub.DISABLE
node[3].smub.source.highc=smub.DISABLE
'

check_error
fi


sendscpi 0.1 '
loadandrunscript MKmultiMonitor

function MKmultiMeasure()
  node[1].smua.measure.overlappediv(node[1].smua.nvbuffer1,node[1].smua.nvbuffer2)
  node[1].smub.measure.overlappediv(node[1].smub.nvbuffer1,node[1].smub.nvbuffer2)
  node[2].smua.measure.overlappediv(node[2].smua.nvbuffer1,node[2].smua.nvbuffer2)
  node[2].smub.measure.overlappediv(node[2].smub.nvbuffer1,node[2].smub.nvbuffer2)
  node[3].smua.measure.overlappediv(node[3].smua.nvbuffer1,node[3].smua.nvbuffer2)
  node[3].smub.measure.overlappediv(node[3].smub.nvbuffer1,node[3].smub.nvbuffer2)
end

function MKmultiPrint()
  waitcomplete(0)
  print(node[1].smua.nvbuffer2[1],",",node[1].smua.nvbuffer1[1],",",
        node[1].smub.nvbuffer2[1],",",node[1].smub.nvbuffer1[1],",",
        node[2].smua.nvbuffer2[1],",",node[2].smua.nvbuffer1[1],",",
        node[2].smub.nvbuffer2[1],",",node[2].smub.nvbuffer1[1],",",
        node[3].smua.nvbuffer2[1],",",node[3].smua.nvbuffer1[1],",",
        node[3].smub.nvbuffer2[1],",",node[3].smub.nvbuffer1[1])
end

function MKcheckError()
  repeat
  errorcode, message, severity, errnode = errorqueue.next()
  if errorcode~=0 then
    --print(errorcode, message, severity, errnode)
    print(string.format("%d %s %d",errorcode, message, severity), errnode)
  end
  until errorcode==0
end

endscript
'
check_error

MSG=""
for SMU in $SMUS; do
MSG="$MSG
$SMU.source.output = $SMU.OUTPUT_ON"
done
sendscpi .5 "$MSG
MKcheckError()"

if true; then
for SMU in $SMUS; do
NOD=$( echo $SMU | sed -e 's/\..*//' )
sendscpi .1 "
$SMU.nvbuffer1.clear()
$SMU.nvbuffer1.collecttimestamps = smua.ENABLE
$SMU.trigger.measure.iv($SMU.nvbuffer1,$SMU.nvbuffer2) 
$SMU.trigger.measure.action = $SMU.ENABLE
-- This event can be triggered by *TRG, but only on the network/usb-connected SMU:
-- smua.trigger.measure.stimulus = trigger.EVENT_ID
-- This event can be initiated by: tsplink.writebit(1,1) tsplink.writebit(1,0)
-- Or is it: tsplink.trigger[1].assert()
-- can't use falling right now - sets the output to always-HI
-- ATTENTION: TRIG_RISINGM CAN NOT BE DETECTED BY SMUs, DO NOT USE!
$NOD.tsplink.trigger[1].mode  = tsplink.TRIG_FALLING
--$NOD.tsplink.writebit(1,0)
$SMU.trigger.measure.stimulus = tsplink.trigger[1].EVENT_ID
-- set to N triggers an enable
$SMU.trigger.count=5
$SMU.trigger.initiate()

MKcheckError()
"
done
fi

#DFILE=$DFILEPREFIX$( echo $IDN | sed -e 's%[, /:]%_%g')
DFILE="$DFILEPREFIX.session"

#echo "<$DFILE>"
#exit 
mkdir -p $DDIR

echo ""
echo "Starting recording measurements to <$DDIR$DFILE>..."

function print_result() {
STR="$1 $2 $3
"
shift 3
N=0
CURSUM=0
for SMU in $SMUS; do
  N=$(( $N + 1 ))
  F1="$( echo $1 | gawk '{ printf "%+.3e\n", $1 }' )"
  F2="$( echo $2 | gawk '{ printf "%+.3e\n", $1 }' )"
  CURSUM="$( echo $CURSUM $2 | gawk '{ printf "%+.3e\n", $1+$2 }' )"
  STR="$STR$( echo -e "$SMU\tv$N()\t$F1\ti$N()\t$F2" )
"
  shift 2
done
  STR="$STR$( 
  echo -e "\t\t\t\t\t\t----------"; 
  echo -e "\t\t\t\t\t\t$CURSUM" )"
  echo "$STR"
  echo
  echo
}

{

T1=0.1 # use full integers for some older BASH shells
T2=5

until read -t $T1 K; do
  if [ -e "$SCPIFILE" ]; then
	mv "$SCPIFILE" "$SCPIFILE.tmp"
	sendscpi 0.1 "$(<"$SCPIFILE.tmp")" >&2
	rm "$SCPIFILE.tmp"
	check_error
        [ "$RESULT" != "" ] && echo "$RESULT" >> "$SCPIFILE.error"
  fi
  if false; then
  sendscpi 5 'MKmultiMeasure() MKmultiPrint() MKcheckError()' silent singleline
  RESLINE="$(
  echo "$(date +"%Y-%m-%d %H:%M:%S,%s.%N"),"$RESULT | sed -e 's/ *, */\t/g' 
  )"
  echo "$RESLINE" >>"$DDIR$DFILE"
  #| tee -a $DDIR$DFILE
  sendscpi_cond 0.1 '-- reading errors' "" "" 5 >&2
  print_result $RESLINE 
  if [ -e "$DATACTRLFILE" ]; then
	DATAEXT="$(<"$DATACTRLFILE")"
	echo "Data mirror extension active: '$DATAEXT'" >&2
  	echo "$RESLINE" >>"$DDIR$DFILEPREFIX.$DATAEXT"
	echo "$RESLINE" >"$SCPIFILE.result"
  fi
  fi
done

} \
#| tee -a "$DDIR$DFILE"

MSG=""
for SMU in $SMUS; do
MSG="$MSG
$SMU.source.output=$SMU.OUTPUT_OFF
$SMU.reset()"
done
sendscpi 1 "$MSG"

sendscpi 2 'errorcode, message, severity, errnode = errorqueue.next() print(string.format("%d %s %d",errorcode, message, severity), errnode) '

sendscpi 1 'abort'


