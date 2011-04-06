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

function sweep_vcc() {
  SWEEP="vcc"
  VALS=$( octave --quiet --eval "for v=0:0.5:8; disp(v); end" )
  TO=5
  CH="v4"
  do_sweep
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

