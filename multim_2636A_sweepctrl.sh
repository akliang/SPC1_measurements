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

function do_sweep() { # performs a defined sweep
  echo
  echo "Sweep $SWEEP: CH=$CH, TO=$TO, VALS=( " $VALS " )"
  if [ "$1" == "" ]; then echo "Sweep info completed."; return; fi
  echo $SWEEP >"$DATACTRLFILE"
  V1=""
  for V in $VALS; do
      [ "$V1" == "" ] && V1=$V
      send_cmd "$CH($V)"
      read -t $TO N && break
  done
  V=$V1
  send_cmd "$CH($V)"
      read -t $TO N && break
  rm "$DATACTRLFILE"
  echo "Sweep completed."
}

function extract_val() {
  shift $(( $1 + 1 ))
  echo $1
}
function do_sweep_getval() { # performs a defined sweep, retrieving values
  echo
  echo "Sweep_getval $SWEEP: CH=$CH, TO=$TO, VALS=( " $VALS " )"
  GETVALS=""
  if [ "$1" == "" ]; then echo "Sweep info completed."; return; fi
  shift 1
  echo $SWEEP >"$DATACTRLFILE"
  for V in $VALS; do
      ADD=""; [ "$1" != "" ] && ADD=" + $1"
      send_cmd "$CH($V$ADD)"
      read -t $TO N && break
      NEWVALS="$(<$SCPIFILE.result)"
      GETVAL=$( extract_val $GET_COLUMN $NEWVALS )
      GETVALS="$GETVALS $GETVAL"
      echo "READ<< $GETVAL"
      shift 1
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

function sfchar_singlechan() { # Full SF characterization for 29B-1 TAA
  # This 29B1-1 TAA source-follower characterization assumes the following setup:
  # Vbias   ch5   
  # Vreset  ch3
  # GlobRST ch1
  # DLgnd   f
  # DLrst12 AGND
  # DLcap   f
  # SFBgnd  AGND
  # SFBgate AGND
  # GLclamp AGND
  # TFTrd12 ch6     HI
  # GLyy    ch6     HI 
  # DLxx    ch2

  # Initialization
  I2="-1E-7"
  send_cmd "node[1].smub.source.func=smub.OUTPUT_DCVOLTS"
  send_cmd "node[1].display.smub.measure.func=display.MEASURE_DCAMPS"
  send_cmd "v1(0) v2(0) v3(0) v4(0) v5(0) v6(0)"
  send_cmd "i1(0) i2(0) i3(0) i4(0) i5(0) i6(0)"
  #send_cmd "node[1].smub.source.func=smub.OUTPUT_DCAMPS"
  #send_cmd "node[1].display.smub.measure.func=display.MEASURE_DCVOLTS"
  TB=6 # time between sweeps / parts of characterization
  read -t $TB N && break

  
  VALS=$( octave --quiet --eval "for v=0:1.00:10; disp(v); end" )
  VALS="$VALS "$( octave --quiet --eval "for v=10:-1.00:0; disp(v); end" )
  TO=2
  CH="v3"
  
  #for I2 in 'voltage' '-1E-7' '-1E-6' '-1E-5' ; do
  #for I2 in 'voltage' '-1E-7' '-1E-5' ; do
  for I2 in 'voltage' '-1E-7' ; do
  if [ "$I2" != "voltage" ]; then
    SOURCEMODE=$I2"current"
    send_cmd "i2($I2)"
    send_cmd "node[1].smub.source.func=smub.OUTPUT_DCAMPS"
    send_cmd "node[1].display.smub.measure.func=display.MEASURE_DCVOLTS"
    send_cmd "v4(8)"
    send_cmd "v6(15)"
    send_cmd "v1(15)"
    send_cmd "v3(5)"
    send_cmd "v2(0)"
    send_cmd "v5(0)"
      # Voltage reading / current sinking characterization
      VHI=15
      send_cmd "v6($VHI)"
      for VCC in 10 09 08; do
        send_cmd "v4($VCC)"
        send_cmd "v3(0)"
        read -t $TB N && break
        SWEEP="vcc$VCC"_"idl$I2"_"vhi$VHI"_"ch2src=current"
        do_sweep yes
      done
      for VCC in 08; do
        send_cmd "v4($VCC)"
        send_cmd "v3(0)"
        read -t $TB N && break
        SWEEP="vcc$VCC"_"idl$I2"_"vhi$VHI"_"ch2src=currentLONG"
        TO_=$TO; TO=10
        do_sweep yes
	TO=$TO_
      done
      for VHI in 14; do
        send_cmd "v6($VHI)"
        send_cmd "v4($VCC)"
        send_cmd "v3(0)"
        read -t $TB N && break
        SWEEP="vcc$VCC"_"idl$I2"_"vhi$VHI"_"ch2src=current"
        do_sweep yes
      done
      VHI=15
      send_cmd "v6($VHI)"
      # End of characterization
  else
    SOURCEMODE='voltage'
    VCC=08
    send_cmd "node[1].smub.source.func=smub.OUTPUT_DCVOLTS"
    send_cmd "node[1].display.smub.measure.func=display.MEASURE_DCAMPS"
    send_cmd "v4($VCC)"
    send_cmd "v6(15)"
    send_cmd "v1(15)"
    send_cmd "v3(5)"
    send_cmd "v2(0)"
    send_cmd "v5(0)"
      # Current reading / voltage sourcing characterization
      VHI=15
      send_cmd "v6($VHI)"
      for VREF in 02 01 00; do
        send_cmd "v2($VREF)"
        send_cmd "v3(0)"
        read -t $TB N && break
        SWEEP="vcc$VCC"_"vref$VREF"_"vhi$VHI"_"ch2src=voltage"
        do_sweep yes
      done
      for VREF in 00; do
        send_cmd "v2($VREF)"
        send_cmd "v3(0)"
        read -t $TB N && break
        SWEEP="vcc$VCC"_"vref$VREF"_"vhi$VHI"_"ch2src=voltageLONG"
        TO_=$TO; TO=10
        do_sweep yes
	TO=$TO_
      done
      for VCC in 10 09 08; do
        send_cmd "v4($VCC)"
        send_cmd "v3(0)"
        read -t $TB N && break
        SWEEP="vcc$VCC"_"vref$VREF"_"vhi$VHI"_"ch2src=voltage"
        do_sweep yes
      done
      for VHI in 14; do
        send_cmd "v6($VHI)"
        send_cmd "v4($VCC)"
        send_cmd "v3(0)"
        read -t $TB N && break
        SWEEP="vcc$VCC"_"vref$VREF"_"vhi$VHI"_"ch2src=voltage"
        do_sweep yes
      done
      VHI=15
      send_cmd "v6($VHI)"
      # End of characterization
  fi
  # Load a voltage onto Cpix and mess with it
  #for VRST in 5 6 7; do
  for VRST in  6 ; do
  TL=20
  send_cmd "v3($VRST)"
  send_cmd "v1(15)"
  send_cmd "v5(1)"
  echo "Vreset$VRST"_"pulsing_ch2src=$SOURCEMODE" >"$DATACTRLFILE"
  read -t $TB N 
  # show that reading is not influenced by some switching
  send_cmd "v6(14)"
  read -t $TO N 
  send_cmd "v6(15)"
  read -t $TO N 
  send_cmd "v4(9)"
  read -t $TO N 
  send_cmd "v4(8)"
  read -t $TO N 
  send_cmd "v5(0)"
  read -t $TO N 
  send_cmd "v5(1)"
  read -t $TO N 

  # turn TFTreset OFF and start the interesting pulses
  send_cmd "v1(0)"
  read -t $TL N 
  send_cmd "v1(-1)"
  read -t $TL N 
  send_cmd "v1(0)"
  read -t $TL N 
  send_cmd "v5(0)"
  read -t $TL N 
  send_cmd "v5(1)"
  read -t $TL N 
  send_cmd "v3($VRST-1)"
  read -t $TL N 
  send_cmd "v3($VRST)"
  read -t $TL N 
  send_cmd "v4(9)"
  read -t $TL N 
  send_cmd "v4(8)"
  read -t $TL N 
  send_cmd "v2(1)"
  read -t $TL N 
  send_cmd "v2(0)"
  read -t $TL N 
  send_cmd "v6(14)"
  read -t $TL N 
  send_cmd "v6(15)"
  read -t $TL N 
  send_cmd "v5(0)"
  read -t $TL N 
  send_cmd "v5(1)"
  read -t $TL N 
  send_cmd "v1(-1)"
  read -t $TL N 
  send_cmd "v1(0)"
  read -t $TL N 
  rm "$DATACTRLFILE"

  done # current vs. voltage
  done # various vresets
}

function sfchar_triple() { # Full SF characterization for 29B-1 TAA
  # This 29B1-1 TAA source-follower characterization assumes the following setup:
  # Vbias   ch5   
  # Vreset  ch3
  # GlobRST ch1
  # DLgnd   f
  # DLrst12 AGND
  # DLcap   f
  # SFBgnd  AGND
  # SFBgate AGND
  # GLclamp AGND
  # TFTrd12 ACC     HI
  # GLyy    ACC     HI 
  # DLx1    ch2
  # DLx2    ch4
  # DLx3    ch6

  # Initialization
  I2="-1E-7"
  send_cmd "node[1].smub.source.func=smub.OUTPUT_DCVOLTS"
  send_cmd "node[1].display.smub.measure.func=display.MEASURE_DCAMPS"
  send_cmd "node[2].smub.source.func=smub.OUTPUT_DCVOLTS"
  send_cmd "node[2].display.smub.measure.func=display.MEASURE_DCAMPS"
  send_cmd "node[3].smub.source.func=smub.OUTPUT_DCVOLTS"
  send_cmd "node[3].display.smub.measure.func=display.MEASURE_DCAMPS"
  send_cmd "v1(0) v2(0) v3(0) v4(0) v5(0) v6(0)"
  send_cmd "i1(0) i2(0) i3(0) i4(0) i5(0) i6(0)"
  #send_cmd "node[1].smub.source.func=smub.OUTPUT_DCAMPS"
  #send_cmd "node[1].display.smub.measure.func=display.MEASURE_DCVOLTS"
  TB=6 # time between sweeps / parts of characterization
  read -t $TB N && break

  
  VALS=$( octave --quiet --eval "for v=0:1.00:10; disp(v); end" )
  VALS="$VALS "$( octave --quiet --eval "for v=10:-1.00:0; disp(v); end" )
  TO=2
  CH="v3"
  VHI=15
  VCC=08
  
  #for I2 in 'voltage' '-1E-7' '-1E-6' '-1E-5' ; do
  #for I2 in 'voltage' '-1E-7' '-1E-5' ; do
  for I2 in 'voltage' '-1E-7' ; do
  if [ "$I2" != "voltage" ]; then
    SOURCEMODE=$I2"current"
    send_cmd "i2($I2) i4($I2) i6($I2)"
    send_cmd "node[1].smub.source.func=smub.OUTPUT_DCAMPS"
    send_cmd "node[1].display.smub.measure.func=display.MEASURE_DCVOLTS"
    send_cmd "node[2].smub.source.func=smub.OUTPUT_DCAMPS"
    send_cmd "node[2].display.smub.measure.func=display.MEASURE_DCVOLTS"
    send_cmd "node[3].smub.source.func=smub.OUTPUT_DCAMPS"
    send_cmd "node[3].display.smub.measure.func=display.MEASURE_DCVOLTS"
    ##send_cmd "v4(8)"
    ##send_cmd "v6(15)"
    send_cmd "v1(15)"
    send_cmd "v3(5)"
    send_cmd "v2(0) v4(0) v6(0)"
    send_cmd "v5(0)"
      # Voltage reading / current sinking characterization
      ##VHI=15
      ##send_cmd "v6($VHI)"
      ##for VCC in 10 09 08; do
      ##  send_cmd "v4($VCC)"
      ##  send_cmd "v3(0)"
      ##  read -t $TB N && break
      ##  SWEEP="vcc$VCC"_"idl$I2"_"vhi$VHI"_"ch2src=current"
      ##  do_sweep yes
      ##done
      for VCC in $VCC; do
        ##send_cmd "v4($VCC)"
        send_cmd "v3(0)"
        read -t $TB N && break
        SWEEP="vcc$VCC"_"idl$I2"_"vhi$VHI"_"ch2src=currentLONG"
        TO_=$TO; TO=10
        do_sweep yes
	TO=$TO_
      done
      ##for VHI in 14; do
      ##  send_cmd "v6($VHI)"
      ##  send_cmd "v4($VCC)"
      ##  send_cmd "v3(0)"
      ##  read -t $TB N && break
      ##  SWEEP="vcc$VCC"_"idl$I2"_"vhi$VHI"_"ch2src=current"
      ##  do_sweep yes
      ##done
      ##VHI=15
      ##send_cmd "v6($VHI)"
      # End of characterization
  else
    SOURCEMODE='voltage'
    send_cmd "node[1].smub.source.func=smub.OUTPUT_DCVOLTS"
    send_cmd "node[1].display.smub.measure.func=display.MEASURE_DCAMPS"
    send_cmd "node[2].smub.source.func=smub.OUTPUT_DCVOLTS"
    send_cmd "node[2].display.smub.measure.func=display.MEASURE_DCAMPS"
    send_cmd "node[3].smub.source.func=smub.OUTPUT_DCVOLTS"
    send_cmd "node[3].display.smub.measure.func=display.MEASURE_DCAMPS"
    #send_cmd "v4(8)"
    #send_cmd "v6(15)"
    send_cmd "v1(15)"
    send_cmd "v3(5)"
    send_cmd "v2(0) v4(0) v6(0)"
    send_cmd "v5(0)"
      # Current reading / voltage sourcing characterization
      ##VHI=15
      ##send_cmd "v6($VHI)"
      for VREF in 02 01 00; do
        send_cmd "v2($VREF) v4($VREF) v6($VREF)"
        send_cmd "v3(0)"
        read -t $TB N && break
        SWEEP="vcc$VCC"_"vref$VREF"_"vhi$VHI"_"ch2src=voltage"
        do_sweep yes
      done
      for VREF in 00; do
        send_cmd "v2($VREF) v4($VREF) v6($VREF)"
        send_cmd "v3(0)"
        read -t $TB N && break
        SWEEP="vcc$VCC"_"vref$VREF"_"vhi$VHI"_"ch2src=voltageLONG"
        TO_=$TO; TO=10
        do_sweep yes
	TO=$TO_
      done
      ##for VCC in 10 09 08; do
      ##  send_cmd "v4($VCC)"
      ##  send_cmd "v3(0)"
      ##  read -t $TB N && break
      ##  SWEEP="vcc$VCC"_"vref$VREF"_"vhi$VHI"_"ch2src=voltage"
      ##  do_sweep yes
      ##done
      ##for VHI in 14; do
      ##  send_cmd "v6($VHI)"
      ##  send_cmd "v4($VCC)"
      ##  send_cmd "v3(0)"
      ##  read -t $TB N && break
      ##  SWEEP="vcc$VCC"_"vref$VREF"_"vhi$VHI"_"ch2src=voltage"
      ##  do_sweep yes
      ##done
      ##VHI=15
      ##send_cmd "v6($VHI)"
      # End of characterization
  fi
  if false; then
  # Load a voltage onto Cpix and mess with it
  #for VRST in 5 6 7; do
  for VRST in  6 ; do
  TL=20
  send_cmd "v3($VRST)"
  send_cmd "v1(15)"
  send_cmd "v5(1)"
  echo "Vreset$VRST"_"pulsing_ch2src=$SOURCEMODE" >"$DATACTRLFILE"
  read -t $TB N 
  # show that reading is not influenced by some switching
  ##send_cmd "v6(14)"
  ##read -t $TO N 
  ##send_cmd "v6(15)"
  ##read -t $TO N 
  ##send_cmd "v4(9)"
  ##read -t $TO N 
  ##send_cmd "v4(8)"
  ##read -t $TO N 
  send_cmd "v5(0)"
  read -t $TO N 
  send_cmd "v5(1)"
  read -t $TO N 

  # turn TFTreset OFF and start the interesting pulses
  send_cmd "v1(0)"
  read -t $TL N 
  send_cmd "v1(-1)"
  read -t $TL N 
  send_cmd "v1(0)"
  read -t $TL N 
  send_cmd "v5(0)"
  read -t $TL N 
  send_cmd "v5(1)"
  read -t $TL N 
  send_cmd "v3($VRST-1)"
  read -t $TL N 
  send_cmd "v3($VRST)"
  read -t $TL N 
  ##send_cmd "v4(9)"
  ##read -t $TL N 
  ##send_cmd "v4(8)"
  ##read -t $TL N 
  send_cmd "v2(1) v4(1) v6(1)"
  read -t $TL N 
  send_cmd "v2(0) v4(0) v6(0)"
  read -t $TL N 
  ##send_cmd "v6(14)"
  ##read -t $TL N 
  ##send_cmd "v6(15)"
  ##read -t $TL N 
  send_cmd "v5(0)"
  read -t $TL N 
  send_cmd "v5(1)"
  read -t $TL N 
  send_cmd "v1(-1)"
  read -t $TL N 
  send_cmd "v1(0)"
  read -t $TL N 
  rm "$DATACTRLFILE"

  done # various vresets
  fi

  if true; then
  # Load a voltage onto Cpix and perform multiple different sequences
  VRST=6
  for TYPE in 'PreSwitch' 'None' 'CancelInj' 'Vbias' 'ResetP' 'ResetN' 'VresetP' 'VresetN' ; do
  TL=20
  send_cmd "v3($VRST)"
  send_cmd "v1(15)"
  send_cmd "v5(1)"
  echo "Vreset$VRST"_"pulsing$TYPE"_"ch2src=$SOURCEMODE" >"$DATACTRLFILE"
  read -t $TB N 
  if [ "$TYPE" == "PreSwitch" ]; then
    for SW in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
      send_cmd "v1(0)"
      send_cmd "v1(15)"
    done
  else
  # show that reading is not influenced by some switching
  send_cmd "v5(0)"
  read -t $TO N 
  send_cmd "v5(1)"
  read -t $TO N 
  fi

  # turn TFTreset OFF 
  if [ "$TYPE" == "CancelInj" ]; then
  send_cmd "v1(0) v5(1.2)"
  else
  send_cmd "v1(0)"
  fi
  read -t $TL N 

  # start the pulses
  for PULSES in 1 2 3 4 5 6; do
  if [ "$TYPE" == 'None'    ]; then send_cmd "";            fi
  if [ "$TYPE" == 'Vbias'   ]; then send_cmd "v5(0)";       fi
  if [ "$TYPE" == 'ResetN'  ]; then send_cmd "v1(-1)";      fi
  if [ "$TYPE" == 'ResetP'  ]; then send_cmd "v1(1)";       fi
  if [ "$TYPE" == 'VresetN' ]; then send_cmd "v3($VRST-1)"; fi
  if [ "$TYPE" == 'VresetP' ]; then send_cmd "v3($VRST+1)"; fi
  #send_cmd "v2(1) v4(1) v6(1)"
  #send_cmd "v2(0) v4(0) v6(0)"
  read -t $TL N 
  if [ "$TYPE" == 'None'    ]; then send_cmd "";            fi
  if [ "$TYPE" == 'Vbias'   ]; then send_cmd "v5(1)";       fi
  if [ "$TYPE" == 'ResetN'  ]; then send_cmd "v1(0)";       fi
  if [ "$TYPE" == 'ResetP'  ]; then send_cmd "v1(0)";       fi
  if [ "$TYPE" == 'VresetN' ]; then send_cmd "v3($VRST)";   fi
  if [ "$TYPE" == 'VresetP' ]; then send_cmd "v3($VRST)";   fi
  read -t $TL N 
  done
  rm "$DATACTRLFILE"

  done # various vresets
  fi

  done # current vs. voltage
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

