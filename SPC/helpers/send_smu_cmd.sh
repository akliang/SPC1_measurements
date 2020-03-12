#!/bin/bash

# script to handle writing the SCPI information directly to /dev/shm of the SMU-controlling computer
# depends on a proxy port open through eve (to cross imager domain to meas domain)
# e.g., ssh -D 9998 eve

# TODO: retcode is "1" when voltage is transmitted successfully
# TODO: automatically build proxy to eve?


if [ "$1" == "" ]; then
  echo "Error: needs a setup file and an input file"
  exit
fi
if [ "$2" == "" ]; then
  echo "Error: needs an input file"
  exit
fi
SETFILE="$1"
INFILE="$2"
# source the settings file (e.g., SPCsetup1)
source "$SETFILE"


# the command sequence to send to SMUHOST
CMD="
if [ -e $SCPIFILE ]; then
  echo 'Error: SCPI file ($SCPIFILE) already exists!  Exiting...'
  exit 126
fi
cat > $SCPIFILE.pre
mv $SCPIFILE.pre $SCPIFILE
echo 'Waiting for SMUs to consume the file...'
while [ -e $SCPIFILE ]; do
  read -t 0.1 N && break
done
"


# send the command over to SMUHOST (make sure proxy port on eve is open!)
# TODO: evesock isn't needed anymore
if [ -e "/usr/bin/nc" ]; then
  cat "$INFILE" | ssh -o ProxyCommand='/usr/bin/nc -x 127.0.0.1:9998 %h %p' $SMUHOST "$CMD"
else
  cat "$INFILE" | ssh -o ProxyCommand='/bin/nc -x 127.0.0.1:9998 %h %p' $SMUHOST "$CMD"
fi



