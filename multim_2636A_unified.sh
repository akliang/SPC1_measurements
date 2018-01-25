#!/bin/bash

# Based on git-svn-id: svn://svn.imager.umro/masdax@618 92890ac3-fb6f-4dbc-9a08-888296f68159
# svn://svn.imager.umro/masdax/trunk/scripts/scriptmeas/multim_2636A_unified.sh
# Author: koniczek <koniczek@92890ac3-fb6f-4dbc-9a08-888296f68159>
# Date:   Mon Apr 23 14:18:31 2012 +0000

if [ "$2" == "loop" ]; then
  echo "loop should not be necessary anymore. Aborting."; exit 77
  while true; do
    "$0" "$1"
    echo "$0 returned, short sleep before restarting again"
    read -t 30 N && exit
  done
  exit
fi

# source the settings file
source "$1"
if [ "$MAINSMU" == "" ]; then
 echo "Important variables not set. Did you specify the settings file?"
 exit 5
fi
if [ "$DIRIPC" == "" ]; then
 echo "DIRIPC variable not set. Is your settings file up-to-date?"
 exit 6
fi
if [ ! -d "$DDIR" ]; then
 echo "DDIR '$DDIR' not set or does not exist. Is your settings file up-to-date?"
 exit 7
fi
# check if output file already exist
FLIST= #$( ls -1 $DDIR${DFILEPREFIX}* 2>/dev/null )
if [ "$FLIST" != "" ]; then
 echo -e "File(s) already exist:\n$FLIST\nProceed anyway? [N/y]"
 read a || exit 8
 [ "$a" != "y" ] && exit 9
fi
# check if inter-process-comm-files already exist...
FLIST=$( ls -1 $DIRIPC/* 2>/dev/null )
if [ "$FLIST" != "" ]; then
 echo -e "Inter-process-comm directory $DIRIPC already contains:\n$FLIST\nProceed anyway? [N/y]"
 read a || exit 10
 [ "$a" != "y" ] && exit 9
fi
mkdir -p "$DIRIPC" || { echo -e "Cannot create Inter-process-comm directory $DIRIPC"; exit 10; }
SLOCK="$DIRIPC/sleep.lock"

# TODO: add channel mapping to file name? or print to log?
#ch1=Von_ch2=Voff_ch3=Qinj_ch4=Vbias_ch5=Vreset_ch6=VccSF_ch7=PLHI_ch8=DLHI_$(hostname)_"

echo "$(date)" >> "$DDIR$DFILEPREFIX.log"
###svn stat "$0"  >> "$DDIR$DFILEPREFIX.log"
###svn diff "$0"  >> "$DDIR$DFILEPREFIX.log"


if false; then
  # Code for USB communication - somewhat faulty and needs updating
  #stty -F $MDEV 9600 -parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts -ixon -echo
  stty -F $MDEV 9600 -parenb -parodd cs8 hupcl -cstopb cread clocal -crtscts -ixon -echo
  exec 5<>$MDEV
  exec 6<>$MDEV
else
  # Code for Ethernet communication
  nc $NDEV 1030 
  #TD=$( mktemp -d )
  TD="$DIRIPC"
  mkfifo "$TD/p5" "$TD/p6"
  exec 5<>"$TD/p5"
  exec 6<>"$TD/p6"
  nc $NDEV 5025 <"$TD/p5" >"$TD/p6" &
  NCPID=$!
  rm "$TD/p5" "$TD/p6" # actual delete will only occur once files are no longer accessed
  trap "nc $NDEV 1030; kill $NCPID; rm '$SLOCK' '$SCPIFILE'; rmdir '$TD'; rm '$PIDFILE'; date; exit" EXIT
  echo $$ > "$PIDFILE"
fi

function sendscpi() { # send commands to the device (not only SCPI)
	# $1: timeout for first response (0 to skip read)
	# $2: string to send
	# $3: optional, if not empty, do show SENDING and RESPONSE
	# $4: optional, if present, wait for a single line of resonse only
        [ "$3" == "" ] && echo "SENDING>>>: $2"
        echo -e -n "$2\n" >&5
        RESULT=""
	if [ "$1" != "0" ]; then
        while read -u 6 -t $1 RES; do
                RES="${RES%%$'\r'*}"
                [ "$3" == "" ] && echo "RESPONSE<<: <$RES>"
                RESULT="$RESULT$RES"
		[ "$4" != "" ] && break
        done
	fi
}

function sendscpi_cond() { # silent if no result is read
	sendscpi "0" "$2" dontshow "$4" "$5"
	sleep "$1"
	if read -u 6 -t 0; then
	sendscpi "1" "" dontshow "$4" "$5"
	if [ "$RESULT" != "" ]; then
        [ "$3" == "" ] && echo "SENT>>>: $2"
        [ "$3" == "" ] && echo "RESP<<: <$RESULT>"
        [ "$5" != "" ] && sleep $5
	fi
	fi
}

function check_error() {
  sendscpi_cond 1 'errorcode, message, severity, errnode = errorqueue.next() if errorcode~=0 then print(string.format("%d %s %d",errorcode, message, severity), errnode) end' "" "" 5 >&2
}

sendscpi .1 'abort'
sendscpi .1 '*RST'
sendscpi .1 '*CLS'
sendscpi .5 '*IDN?'
IDN="$RESULT"
echo $IDN

ans="y" # comment this line if you want to verify the connected device (REQUIRED FOR USB!)
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
while read -u 6 -t 5 K; do echo "$K"; done
fi

sendscpi 6 'tsplink.reset() print(tsplink.state)' "" wait4onelineonly
check_error

# Showing all channels and resetting them
MSG=""
for SMU in $SMUS; do
echo "SMU: $SMU"
MSG="$MSG
$SMU.reset()"
done
sendscpi 1 "$MSG"
check_error

function get_chan_props() {
  chname=$1
  limitvmin=$2
  limitvmax=$3
  limiti=$4
  limiti_pulse=$5
  highc=$6
  sourcecurrent=$7
}

# Building defaults for all channels
N=0
for SMU in $SMUS; do
N=$(( $N + 1 ))
SMUdisp=$( echo "$SMU" | sed -e 's%\.%.display.%' )
echo "Setting SMU: $SMU  DISPLAY: $SMUdisp"
eval "get_chan_props \${ch$N}" 
sendscpi 0.1 "
$SMU.source.autorangei=$SMU.AUTORANGE_ON
--$SMU.source.autorangev=$SMU.AUTORANGE_ON
$SMU.source.autorangev=$SMU.AUTORANGE_OFF
$SMU.source.rangev=math.max(math.abs($limitvmin),math.abs($limitvmax))
$SMU.source.leveli=0
$SMU.source.levelv=0
$SMU.source.limiti=$limiti
$SMU.source.limitv=math.max(math.abs($limitvmin),math.abs($limitvmax))
$SMU.sense = $SMU.SENSE_LOCAL
$SMU.measure.nplc = 1
$SMU.measure.delay = $SMU.DELAY_OFF
--v$N = makesetter($SMU.source, 'levelv')
v$N = function ( v ) if v<$limitvmin then return end if v>$limitvmax then return end $SMU.source.levelv=v end
i$N = makesetter($SMU.source, 'leveli')
select_ilim_default_ch$N = function () $SMU.source.limiti=$limiti end
select_ilim_pulse_ch$N = function () $SMU.source.limiti=$limiti_pulse end
autorangei$N = function ( ar ) arold = $SMU.measure.autorangei $SMU.measure.autorangei=ar return(arold)  end
if ($highc) then $SMU.source.highc = $SMU.ENABLE else $SMU.source.highc = $SMU.DISABLE end
--for now this ugly sequence of ifs, because if needs to be completed in a single line in interactive mode
if (not $sourcecurrent) then $SMU.source.func=$SMU.OUTPUT_DCVOLTS          end
if (not $sourcecurrent) then $SMUdisp.measure.func=display.MEASURE_DCAMPS  end
if (    $sourcecurrent) then $SMU.source.func=$SMU.OUTPUT_DCAMPS           end
if (    $sourcecurrent) then $SMUdisp.measure.func=display.MEASURE_DCVOLTS end
"
check_error
done

# Special config: optimize channel for current sinking
#node[2].smua.source.sink=smua.ENABLE

check_error

STR_MEAS=""
STR_PRNT=""
for SMU in $SMUS; do
  STR_MEAS="$STR_MEAS
  $SMU.measure.overlappediv($SMU.nvbuffer1,$SMU.nvbuffer2)"
  STR_PRNT="$STR_PRNT
  $SMU.nvbuffer2[1],',',$SMU.nvbuffer1[1],',',"
done
# add digio sampling if desired
for DIGIO in $DIGIOS; do
  STR_PRNT="$STR_PRNT
  string.format(\"%04X,\", $DIGIO.digio.readport()),"
done


sendscpi 1 '
loadandrunscript MKmultiMonitor

function MKmultiMeasure()
'"$STR_MEAS"'
end

function MKmultiPrint()
  waitcomplete(0)
  print(
'"$STR_PRNT"'
  "")
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
sendscpi .1 "$MSG"

check_error
#DFILE=$DFILEPREFIX$( echo $IDN | sed -e 's%[, /:]%_%g')
DFILE="$DFILEPREFIX.session"

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
  #F1="$( echo $1 | gawk '{ printf "%+.3e\n", $1 }' )"
  #F2="$( echo $2 | gawk '{ printf "%+.3e\n", $1 }' )"
  F1="$( printf "%+.3e" $1 )"
  F2="$( printf "%+.3e" $2 )"
  CURSUM="$( echo $CURSUM $2 | gawk '{ printf "%+.3e\n", $1+$2 }' )"
  STR="$STR$( echo -e "$SMU\tv$N()\t$F1\ti$N()\t$F2" )
"
  shift 2
done
  STR="$STR$( 
  echo -e "\t\t\t\t\t\t----------"; 
  echo -e "\t\t\t\t\t\t$CURSUM" 
  echo -n -e "\t" )"
N=0
for DIGIO in $DIGIOS; do
  N=$(( $N + 1 ))
  STR="$STR digio$N: $1 "
  shift 1
done
  #IND=$( echo $LCNT | gawk '{ if ($1 % 2) { print "+"; } else { print "o"; } }' )
  if [ $(( $LCNT % 2 )) = 0 ]; then IND="+"; else IND="0"; fi
  echo
  echo "$IND $STR"
  echo
}

( # Use a sub-process () instead of context {}, so that wait only waits for the sleep?

T1=0.2 # use full integers for some older BASH shells
T2=5  # Maximum time to wait for results and after error messages
LCNT=0 # Loop counter

#until read -t 0.01 K; do # Is this the read which sometimes blocks? Using "while true" for now...
while true; do
  LCNT=$(( LCNT + 1 ))
  #touch "$SLOCK"
  #{ sleep $T1; rm "$SLOCK"; } &
  sleep $T1 &
  #echo # to clear echo -n from below?
  if [ -e "$SCPIFILE" ]; then
	mv "$SCPIFILE" "$SCPIFILE.tmp"
	sendscpi 0 "$(<"$SCPIFILE.tmp")" >&2
	rm "$SCPIFILE.tmp"
	#check_error
        #[ "$RESULT" != "" ] && echo "$RESULT" >> "$SCPIFILE.error"
  #else
	# echo # to maintain same linecount even if nothing sent?
  fi
  sendscpi $T2 'MKmultiMeasure() MKmultiPrint() MKcheckError()' silent singleline
  RESLINE="$(
  echo "$(date +"%Y-%m-%d %H:%M:%S,%s.%N"),"$RESULT | sed -e 's/ *, */\t/g' )"
  echo "$RESLINE" >>"$DDIR$DFILE"
  [ -p /dev/shm/fifo_uart ] && echo -e "SMUDATA\t$RESLINE" >/dev/shm/fifo_uart
  sendscpi_cond 0.1 '-- reading errors' "" "" $T2 >&2
  if [ -e "$DATACTRLFILE" ]; then
	DATAEXT="$(<"$DATACTRLFILE")"
	echo -n "  >> Data mirror extension: '$DATAEXT'" >&2
  	echo "$RESLINE" >>"$DDIR$DFILEPREFIX.$DATAEXT"
  fi
  if [ -e "$DATASAMPFILE" ]; then
	echo -n "  >> Serving data sample to: '$DATASAMPFILE.result'" >&2
	echo "$RESLINE" >"$DATASAMPFILE.result"
	rm "$DATASAMPFILE"
  fi
  print_result $RESLINE # used to be in background with &, might have caused race condition. TODO: check name space?
  wait
  #while [ -e "$SLOCK" ]; do sleep 0.01; done
done

)

MSG=""
for SMU in $SMUS; do
MSG="$MSG
$SMU.source.output=$SMU.OUTPUT_OFF"
done
sendscpi 1 "$MSG"

if false; then
MSG=""
for SMU in $SMUS; do
MSG="$MSG
$SMU.reset()"
done
sendscpi 1 "$MSG"
fi

sendscpi 3 'errorcode, message, severity, errnode = errorqueue.next() print(string.format("%d %s %d",errorcode, message, severity), errnode) '

sendscpi 1 'abort'

