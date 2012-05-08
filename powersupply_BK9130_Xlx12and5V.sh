#!/bin/bash

# $HeadURL$
# $Id$

#MDEV="/dev/ttyUSB4"
MDEV="/dev/ttyUSB1"
DDIR='../measurements/environment/'
DFILEPREFIX="meas_$(hostname)_"

NDEV="192.168.0.36 4098" # Port1 on Star1
DIRIPC="/dev/shm/ipc_bk9130_PSI24and5"
mkdir -p "$DIRIPC" || { echo -e "Cannot create Inter-process-comm directory $DIRIPC"; exit 10; }
PIDFILE="/dev/shm/pid_bk9130_PSI24and5"

if false; then
  # Code for USB communication - somewhat faulty and needs updating
  #stty -F $MDEV 9600 -parenb -parodd cs8 -hupcl -cstopb cread clocal -crtscts -ixon -echo
  stty -F $MDEV 9600 -parenb -parodd cs8 hupcl -cstopb cread clocal -crtscts -ixon -echo
  exec 5<>$MDEV
  exec 6<>$MDEV
else
  # Code for Ethernet communication
  #TD=$( mktemp -d )
  TD="$DIRIPC"
  mkfifo "$TD/p5" "$TD/p6"
  exec 5<>"$TD/p5"
  exec 6<>"$TD/p6"
  nc $NDEV <"$TD/p5" >"$TD/p6" &
  NCPID=$!
  rm "$TD/p5" "$TD/p6" # actual delete will only occur once files are no longer accessed
  trap "kill $NCPID; rmdir '$TD'; rm '$PIDFILE'; exit" EXIT
  echo $$ > "$PIDFILE"
fi

function sendscpi() {
	echo "SENDING>>>: $2"
	echo -e -n "$2\n" >&5
	read -t $1 RESULT <&6
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
#[ "$IDN" == "BK,9130,005004156568001016,V1.69" ] && [ "$(hostname)" == "exciton" ] && ans="y" # BK#4, 2012-02-15 on exciton providing Xilinx powers
#[ "$IDN" == "BK,9130,005004156568001016,V1.69" ] && [ "$(hostname)" == "muon"    ] && ans="y" # BK#4, 2011-10-26 on muon providing Xilinx powers
#[ "$IDN" == "BK,9130,005004156568001013,V1.69" ] && [ "$(hostname)" == "muon"    ] && ans="y" # BK#6, 2012-02-24 on muon providing Xilinx powers
#[ "$IDN" == "BK,9130,005004156568001013,V1.69" ] && [ "$(hostname)" == "simwork" ] && ans="y" # BK#6, 2012-01-21 on simwork providing Xilinx powers

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
sendscpi $TO 'APP:CURR 0.0,3.5,1.0' 
sendscpi $TO 'SYST:ERR?'
sendscpi $TO '*CLS'
sendscpi $TO 'APP:OUT 0,1,1'
#sendscpi $TO 'SYST:ERR?'
#sendscpi $TO '*CLS'

echo ""
echo "Starting recording currents and voltages to $DDIR$DFILE..."

{

while true; do 
read -t .1 RESULTFLUSH <&6
echo -e -n "MEAS:VOLT:ALL?\n" >&5
echo -e -n "MEAS:CURR:ALL?\n" >&5
read -t 2 RESULTVOLT <&6
read -t 2 RESULTCURR <&6
echo "$(date +"%Y-%m-%d %H:%M:%S,%s"),VOLT:,$RESULTVOLT,CURR:,$RESULTCURR" | sed -e 's/,/\t/g'
read -t 1 K && break
done 

} | tee -a $DDIR$DFILE

sendscpi $TO 'APP:OUT 0,0,0'
sendscpi $TO 'SYST:ERR?'
#sendscpi 2 'SYST:BEEP'
sendscpi 2 'SYST:LOC'

