#!/bin/bash

# $HeadURL$
# $Id$




#### CORE SMU FUNCTIONS (also requires multim_2636A_unified.sh to be running) ###

# source the settings file
source "$1"
if [ "$MAINSMU" == "" ]; then
 echo "Important variables not set. Did you specify the settings file?"
 exit 5
fi

[ -e "$SCPIFILE" ] && rm "$SCPIFILE"
trap "rm '$SCPIFILE' '$DATACTRLFILE'; exit" EXIT

function send_cmd() { # sends command to scpi file
  if [ -e "$SCPIFILE" ]; then
    echo "ERROR: $SCPIFILE exists unexpectedly, aborting!"
    exit 3
  fi
  echo -n 'SEND>>   '
  echo "$*" 
  echo "$*" > "$SCPIFILE.pre"
  mv "$SCPIFILE.pre" "$SCPIFILE"
  while [ -e "$SCPIFILE" ]; do
      read -t 0.1 N && break
  done
  if [ -e "$SCPIFILE.error" ]; then
    mv "$SCPIFILE.error" "$SCPIFILE.error.tmp"
    echo
    echo "SCPIERROR: $(<$SCPIFILE.error.tmp)"
    echo
    rm "$SCPIFILE.error.tmp"
  fi
}
function help() {  # help currently displayed
  FUNCLIST="$( grep "^function " $0 | sed -e 's/[^ ]* /\t/' -e 's/[( ].*#/ \t#/' -e 's/[(].*$//' )"
  echo "Defined functions:"
  echo "$FUNCLIST" | column -t -s "	";
}
function quit() {  # exits this program
  exit
}




#### BEGIN SPC-SPECIFIC FUNCTIONS ###



function amp_bias_sweep() {  # sweep two amp biases manually
  send_cmd "v1(4) v2(-4) v3(-3.5) v4(-4) v5(-4)"
  CH1="v2"
  CH2="v4"
  for F in $( seq -4 0.25 2 ); do
    for J in $( seq -4 0.5 2 ); do
      read -p "Press any key to change $CH1 to $F and $CH2 to $J..." -n1 -s
      send_cmd "$CH1($F)"
      send_cmd "$CH2($J)"
    done
  done
}

function amp_bias_sweep_extflag() {  # use pytrigger to automatically step bias voltages
  if [ "$1" == "" ]; then echo "Could not source \$1 (hint: SPCpytrigger    ;  user-defined python variables file)"; return; fi
  source $1

  send_cmd "v1(4) v2(-4) v3(-3.5) v4(-4) v5(-4)"
  CH1="v2"
  CH2="v4"
  for F in $( seq -4 0.25 2 ); do
    for J in $( seq -4 0.5 2 ); do

      echo -n "Waiting for pytrigger... "
      while [ ! -e $PYTRIGGER ]; do
        sleep 0.1
      done
      echo "hit!"
      rm $PYTRIGGER

      send_cmd "$CH1($F)"
      send_cmd "$CH2($J)"
    done
  done
}

function ext_bias_ctrl() { # change the channel voltages with an external file
  if [ "$1" == "" ]; then echo "Could not source \$1 (hint: SPCpytrigger    ;  user-defined python variables file)"; return; fi
  source $1

  while true; do
    echo -n "Waiting for pytrigger... "
    while [ ! -e $PYTRIGGER ]; do
      sleep 0.1
    done
    echo "hit!"

    while read LINE; do
      echo "$LINE"
      if [ "$LINE" == "FIN" ]; then
        echo "Caught FIN signal -- exiting!"
        rm $PYTRIGGER
        exit
      else
        send_cmd "$LINE"
      fi
      sleep 1
    done < $PYTRIGGER
    rm $PYTRIGGER
  done

}




# main program loop
while true; do
  #echo -n "$0> "
  read -e -p "$0> " C
  if [ "$C" != "" ]; then
    if [ "${C:0:1}" == "!" ]; then
      echo "EXEC::  ${C:1}"
      ${C:1}
    else
      send_cmd "$C"
    fi     
  fi
done

