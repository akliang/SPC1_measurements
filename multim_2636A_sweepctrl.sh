#!/bin/bash

# $HeadURL$
# $Id$

DATACTRLFILE='2636_datactrl'
SCPIFILE='2636_command.scpi'

rm "$SCPIFILE"

function send_cmd() { # sends command to scpi file
  if [ -e "$SCPIFILE" ]; then
    echo "ERROR: $SCPIFILE exists unexpectedly, aborting!"
    exit 3
  fi
  echo -n 'SEND>>   '
  echo "$*" | tee -a "$SCPIFILE"
  if [ -e "$SCPIFILE.error" ]; then
    mv "$SCPIFILE.error" "$SCPIFILE.error.tmp"
    echo
    echo "SCPIERROR: $(<$SCPIFILE.error.tmp)"
    echo
    rm "$SCPIFILE.error.tmp"
  fi
}

function do_sweep() { # performs a defined sweep
  echo
  echo "Sweep $SWEEP: CH=$CH, TO=$TO, VALS=( " $VALS " )"
  if [ "$1" == "" ]; then echo "Sweep info completed."; return; fi
  echo $SWEEP >"$DATACTRLFILE"
  for V in $VALS; do
      send_cmd "$CH($V)"
      read -t $TO N && break
  done
  V=0
  send_cmd "$CH($V)"
  rm "$DATACTRLFILE"
  echo "Sweep completed."
}

function extract_val() {
  shift $(( $1 + 1 ))
  echo $1
}
function do_sweep_getval() { # performs a defined sweep
  echo
  echo "Sweep_getval $SWEEP: CH=$CH, TO=$TO, VALS=( " $VALS " )"
  GETVALS=""
  if [ "$1" == "" ]; then echo "Sweep info completed."; return; fi
  echo $SWEEP >"$DATACTRLFILE"
  for V in $VALS; do
      send_cmd "$CH($V)"
      read -t $TO N && break
      NEWVALS="$(<$SCPIFILE.result)"
      echo $( extract_val $GET_COLUMN $NEWVALS )
  done
  V=0
  send_cmd "$CH($V)"
  rm "$DATACTRLFILE"
  echo "Sweep completed."
}

function help() {  # help currently displayed
  FUNCLIST="$( grep "^function " $0 | sed -e 's/[^ ]* /\t/' -e 's/[( ].*#/ \t#/' -e 's/[(].*$//' )"
  echo "Defined functions:"
  echo "$FUNCLIST" | column -t -s "     ";
}
function quit() {  # exits this program
  exit
}

function set_sweep() {
  SWEEP="$*"
  do_sweep
}

function set_to() {
  TO="$*"
  do_sweep
}

function set_ch() {
  CH="$*"
  do_sweep
}

function sweep_gateline() {
  SWEEP="gateline"
  VALS=$( octave --quiet --eval "for v=0:0.5:15; disp(v); end" )
  TO=5
  CH="v5"
  do_sweep
}

function sweep_glfull() {
  SWEEP="gateline"
  VALS=$( octave --quiet --eval "for v=-2.5:0.5:15; disp(v); end" )
  TO=5
  CH="v5"
  do_sweep
}

function sweep_vcc() {
  SWEEP="vcc"
  VALS=$( octave --quiet --eval "for v=0:0.5:8; disp(v); end" )
  TO=5
  CH="v4"
  do_sweep
}

function sweep_vcc3() {
  SWEEP="vcc"
  VALS=$( octave --quiet --eval "for v=0:0.25:3; disp(v); end" )
  TO=5
  CH="v4"
  do_sweep
}

function fullchar() {
  sweep_vcc
  send_cmd "v6(15)"
  read -t $TO N && break
  send_cmd "v5(15)"
  read -t $TO N && break
  send_cmd "v3(15)"
  read -t $TO N && break

  if false; then
  set_sweep "tftroVsweep"
  VALS="0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2 2.5 3 3.5 4 4.5 5 6 7 8"
  do_sweep yes
  read -t $TO N && break
  fi

  if true; then
  send_cmd "node[2].smub.source.func=smub.OUTPUT_DCAMPS"
  read -t $TO N && break
  set_sweep "tftroIsweep"
  VALS="0 1E-6 3E-6 1E-5 3E-5 1E-4 3E-4 1E-3"
  CH="i4"
  GET_COLUMN=$(( 3 + 2*(4-1) ))
  do_sweep_getval yes
  read -t $TO N && break
  send_cmd "i4(0)"
  read -t $TO N && break
  send_cmd "node[2].smub.source.func=smub.OUTPUT_DCVOLTS"
  read -t $TO N && break
  fi

  send_cmd "v3(0)"
  read -t $TO N && break
  send_cmd "v5(0)" 
  read -t $TO N && break

  if true; then
  sweep_glfull
  send_cmd "v4(3)"
  read -t $TO N && break
  do_sweep yes
  read -t $TO N && break
  send_cmd "v4(0)"
  read -t $TO N && break
  fi
 
  sweep_vcc3
  send_cmd "v5(15)"
  read -t $TO N && break
  do_sweep yes
  read -t $TO N && break
  send_cmd "v5(0)" 
  read -t $TO N && break
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

