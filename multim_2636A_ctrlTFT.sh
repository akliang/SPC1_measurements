#!/bin/bash

# $HeadURL$
# $Id$

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

TOFINAL=1
function do_sweep() { # performs a defined sweep
  echo
  echo "Sweep $SWEEP: CH=$CH, TO=$TO, VALS=( " $VALS " )"
  if [ "$1" == "" ]; then echo "Sweep info completed."; return; fi
  V1=""
  for V in $VALS; do
      send_cmd "$CH($V)"
      if [ "$V1" == "" ]; then 
          V1=$V
          echo $SWEEP >"$DATACTRLFILE"
      fi
      read -t $TO N && break
  done
  rm "$DATACTRLFILE"
  V=$V1
  send_cmd "$CH($V)"
      read -t $TOFINAL N && break
  echo "Sweep completed."
}
function do_sweep_dual() { # performs a defined sweep on two channels
  echo
  echo "Sweep $SWEEP: CHX=$CHX, CHY=$CHY, TO=$TO, VALS=( " $VALS " )"
  if [ "$1" == "" ]; then echo "Sweep info completed."; return; fi
  V1=""
  for V in $VALS; do
      send_cmd "$CHX($V) $CHY($V)"
      if [ "$V1" == "" ]; then 
          V1=$V
          echo $SWEEP >"$DATACTRLFILE"
      fi
      read -t $TO N && break
  done
  rm "$DATACTRLFILE"
  V=$V1
  send_cmd "$CHX($V) $CHY($V)"
      read -t $TOFINAL N && break
  echo "Sweep completed."
}
function do_sweep_pulsed() { # performs a defined pulsed sweep
  echo
  echo "Sweep $SWEEP: CH=$CH, TON=$TON, TOFF=$TOFF, VALS=( " $VALS " )"
  if [ "$1" == "" ]; then echo "Sweep info completed."; return; fi
  V1=""
  for V in $VALS; do
      send_cmd "$CH($V)"
      if [ "$V1" == "" ]; then 
          V1=$V
          echo $SWEEP >"$DATACTRLFILE"
      fi
      read -t $TON N && break
      send_cmd "$CH($V1)"
      read -t $TOFF N && break
  done
  rm "$DATACTRLFILE"
  V=$V1
  send_cmd "$CH($V)"
      read -t $TOFINAL N && break
  echo "Sweep completed."
}
function do_sweep_fixrange() { # performs a defined sweep, fixing channel current ranges after a settling time
  echo
  echo "Sweep $SWEEP: CH=$CH, TSET=$TSET, TO=$TO, VALS=( " $VALS " )"
  if [ "$1" == "" ]; then echo "Sweep info completed."; return; fi
  V1=""
  for V in $VALS; do
      send_cmd "$CH($V)"
      if [ "$V1" == "" ]; then 
          V1=$V
          echo $SWEEP >"$DATACTRLFILE"
      fi
      read -t $TSET N && break
      send_cmd "ar1=autorangei1(smua.AUTORANGE_OFF) ar2=autorangei2(smua.AUTORANGE_OFF) ar3=autorangei3(smua.AUTORANGE_OFF)"
      read -t $TO N && break
      send_cmd "autorangei1(ar1) autorangei2(ar2) autorangei3(ar3)"

      # gm step added on 2015-07-17 by Liang
      TGM=60
      V2=$( echo "$V -0.02" | gawk '{ print $1+$2 }' )
      send_cmd "$CH($V2)"
      read -t $TGM N && break
      V2=$( echo "$V +0.02" | gawk '{ print $1+$2 }' )
      send_cmd "$CH($V2)"
      read -t $TGM N && break
      V2=$( echo "$V -0.1" | gawk '{ print $1+$2 }' )
      send_cmd "$CH($V2)"
      read -t $TGM N && break
      send_cmd "$CH($V)"
      read -t $TGM N && break
      V2=$( echo "$V +0.1" | gawk '{ print $1+$2 }' )
      send_cmd "$CH($V2)"
      read -t $TGM N && break
      V2=""
      TGM=""
      # end gm step
      
  done
  rm "$DATACTRLFILE"
  V=$V1
  send_cmd "$CH($V)"
      read -t $TOFINAL N && break
  echo "Sweep completed."
}
function do_sweep_manypulsed_fixed() { # performs a defined, repeated pulse sweeps at fixing current ranges in first ON time
  echo
  echo "Sweep $SWEEP: CH=$CH, TON=$TON, TOFF=$TOFF, REPS=$REPS, VALS=( " $VALS " )"
  if [ "$1" == "" ]; then echo "Sweep info completed."; return; fi
  V1=""
  for V in $VALS; do
      if [ "$V1" == "" ]; then 
          V1=$V
          echo $SWEEP >"$DATACTRLFILE"
      fi

      R=0
      while [[ $R -lt $REPS ]]; do
        send_cmd "$CH($V)"
        read -t $TON N && break
        [[ $R -eq 0 ]] && send_cmd "ar1=autorangei1(smua.AUTORANGE_OFF) ar2=autorangei2(smua.AUTORANGE_OFF) ar3=autorangei3(smua.AUTORANGE_OFF)"
        send_cmd "$CH($V1)"
        read -t $TOFF N && break
        R=$(( $R + 1 ))
      done
      send_cmd "autorangei1(ar1) autorangei2(ar2) autorangei3(ar3)"
  done
  rm "$DATACTRLFILE"
  V=$V1
  send_cmd "$CH($V)"
      read -t $TOFINAL N && break
  echo "Sweep completed."
}

function extract_val() {
  shift $(( $1 + 1 ))
  echo $1
}
function do_sweep_getval() { # performs a defined sweep, retrieving values
  echo "Currently not supported. Needs upgrade to newer SAMPLE REQUEST features."; exit 78
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
  echo "$FUNCLIST" | column -t -s "	";
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

function do_noise_res() { # Resistor noise at specific points
  #for VD in "0.100" "1.000" "5.000"; do
  for VD in "0.000" "0.010" "0.050" "0.100" "0.200" "0.500" "1.000" "5.000"; do
  VG="0.000"
  VS="0.000"
  VD=$( echo $VD $PNTYPE | gawk '{ printf("%.3f", $1*$2) }' )

  SWEEP="TransNoise$MEASNR"_"Vd=$VD"_"Vs=$VS"
  VALS=$( octave --quiet --eval "for v=[ 1 ]; disp(v*$PNTYPE); end" )
  #VALS=$( octave --quiet --eval "for v=[ 1 3 5 10 ]; disp(v*$PNTYPE); end" )
  #VALS=$( octave --quiet --eval "for v=[ 1 2.5 2.9 3.9 10 ]; disp(v); end" )
  [ "$TO" == "" ] && TO=20
  [ "$TSET" == "" ] && TSET=10
  CH="v3"
  send_cmd "v1($VD) v2($VS) v3($VG)"
  do_sweep_fixrange yes

  send_cmd "v1(0) v2(0) v3(0)"
  done
}
function do_noise() { # TFT noise at specific points
  #for VD in "0.100" "1.000" "5.000"; do
  #for VD in "0.000" "0.010" "0.050" "0.100" "0.200" "0.500" "1.000" "5.000"; do
  for VD in "0.100" "0.500" "1.000" "5.000"; do
  VG="0.000"
  VS="0.000"
  VD=$( echo $VD $PNTYPE | gawk '{ printf("%.3f", $1*$2) }' )

  SWEEP="TransNoise$MEASNR"_"Vd=$VD"_"Vs=$VS"
  VALS=$( octave --quiet --eval "for v=[ 1 3 5 10 ]; disp(v*$PNTYPE); end" )
  #VALS=$( octave --quiet --eval "for v=[ 1 2.5 2.9 3.9 10 ]; disp(v); end" )
  [ "$TO" == "" ] && TO=20
  [ "$TSET" == "" ] && TSET=10
  CH="v3"
  send_cmd "v1($VD) v2($VS) v3($VG)"
  do_sweep_fixrange yes

  send_cmd "v1(0) v2(0) v3(0)"
  done
}
function do_noise_pulsed() { # TFT noise at specific points
  for VD in "1.000" "5.000"; do
  VG="0.000"
  VS="0.000"
  VD=$( echo $VD $PNTYPE | gawk '{ printf("%.3f", $1*$2) }' )

  SWEEP="PulsedNoise$MEASNR"_"Vd=$VD"_"Vs=$VS"
  VALS=$( octave --quiet --eval "for v=[ 0 5 10 ]; disp(v*$PNTYPE); end" )
  [ "$TON" == "" ]  && TON=2
  [ "$TOFF" == "" ] && TOFF=2
  [ "$REPS" == "" ] && REPS=10 #1000
  CH="v3"
  send_cmd "v1($VD) v2($VS) v3($VG)"
  do_sweep_manypulsed_fixed yes

  send_cmd "v1(0) v2(0) v3(0)"
  done
}
function do_transfer() { # TFT transfer characteristic, do_transfer FROM STEP TO "VDS1 VDS2 VDS3..."
  for VD in $4; do
  VG="0.000"
  VS="0.000"
  VD=$( echo $VD $PNTYPE | gawk '{ printf("%.3f", $1*$2) }' )

  SWEEP="Transfer$MEASNR"_"Vd=$VD"_"Vs=$VS"
  VALS=$( octave --quiet --eval "for v=$1:$2:$3; disp(v*$PNTYPE); end" )
  [ "$TO" == "" ] && TO=5
  CH="v3"
  send_cmd "v1($VD) v2($VS) v3($VG)"
  do_sweep yes

  send_cmd "v1(0) v2(0) v3(0)"
  done
}
function do_output() { # TFT output characteristic, do_output TO "VGS1 VGS2 VGS3..."
  for VG in $2; do
  VD="0.000"
  VS="0.000"
  VG=$( echo $VG $PNTYPE | gawk '{ printf("%.3f", $1*$2) }' )

  SWEEP="Output$MEASNR"_"Vs=$VS"_"Vg=$VG"
  VALS=$( octave --quiet --eval "for v=[ 0:0.1:1.999 2:0.2:$1 ]; disp(v*$PNTYPE); end;" )
  [ "$TO" == "" ] && TO=2
  CH="v1"
  send_cmd "v1($VD) v2($VS) v3($VG)"
  do_sweep yes

  send_cmd "v1(0) v2(0) v3(0)"
  done
}
function do_sensor_reverse() { # Sensor output characteristic, reverse bias
  VN1="0.000"
  VP1="0.000"
  VN2="0.000"
  VP2="0.000"

  SCANDIR=$1

  SWEEP="reverse$SCANDIR$MEASNR"_"Vn1=$VN1"_"Vn2=$VN2"
  if [ "$SCANDIR" == "ltoh" ]; then
    VALS=$( octave --quiet --eval "for v=[  0:-.5:-6 ]; disp(v); end;" )
  else
    VALS=$( octave --quiet --eval "for v=[ -6:.5:0   ]; disp(v); end;" )
  fi
  [ "$TO" == "" ] && TO=2
  CHX="v1"
  CHY="v3"
  send_cmd "v1($VN1) v2($VP1) v3($VN1) v4($VP2)"
  do_sweep_dual yes

  send_cmd "v1(0) v2(0) v3(0) v4(0)"
}
function do_sensor_forward() { # Sensor output characteristic, forward bias
  VN1="0.000"
  VP1="0.000"
  VN2="0.000"
  VP2="0.000"

  SWEEP="forward$MEASNR"_"Vn1=$VN1"_"Vn2=$VN2"
  VALS=$( octave --quiet --eval "for v=[ 0:.1:1.2 ]; disp(v); end;" )
  [ "$TO" == "" ] && TO=2
  CHX="v1"
  CHY="v3"

  send_cmd "v1($VN1) v2($VP1) v3($VN1) v4($VP2)"
  do_sweep_dual yes

  send_cmd "v1(0) v2(0) v3(0) v4(0)"
}
function do_output_pulsed() { # TFT output characteristic in pulsed mode, do_output TO "VGS1 VGS2 VGS3..."
  for VG in $2; do
  VD="0.000"
  VS="0.000"
  VG=$( echo $VG $PNTYPE | gawk '{ printf("%.3f", $1*$2) }' )

  SWEEP="OutputPulsed$MEASNR"_"Vs=$VS"_"Vg=$VG"
  VALS=$( octave --quiet --eval "for v=[ 0:0.2:$1 ]; disp(v*$PNTYPE); end;" )
  [ "$TO" == "" ] && TO=2
  CH="v3"
  send_cmd "v1($VD) v2($VS) v3($VG)"
  send_cmd "select_ilim_pulse_ch1()"
  send_cmd "select_ilim_pulse_ch2()"
  do_sweep_pulsed yes
  send_cmd "select_ilim_default_ch2()"
  send_cmd "select_ilim_default_ch1()"
  send_cmd "v1(0) v2(0) v3(0)"
  done
}
function do_diode() { # TFT diode characteristic, not implemented yet!
  for VG in "-3.000" "-2.000" "-1.000" "0.000" "1.000" "2.000" "3.000" "5.000" "10.000" "15.000"; do
  VD="0.000"
  VS="0.000"

  SWEEP="Output$MEASNR"_"Vd=$VD"_"Vs=$VS"_"Vg=$VG"
  VALS=$( octave --quiet --eval "for v=[ 0:0.1:1.999 2:0.2:10 ]; disp(v); end;" )
  [ "$TO" == "" ] && TO=2
  CH="v1"
  send_cmd "v1($VD) v2($VS) v3($VG)"
  do_sweep yes

  send_cmd "v1(0) v2(0) v3(0)"
  done
}

function do_tftloop() { # TFT transfer, output and noise characteristics
  # Things to vary:
  # Time between points?
  # Step size?
  MEASNR=1000
  TO=1
  VDSHI=9  VDSMAX=15
  VGSHI=11 VGSMAX=20
  # Initial, quick transfer chars to verify setup
  do_transfer -6 0.2 $VGSHI  "0.100 0.500"

  do_output $VDSHI "0.000 4.000"

  while true; do 
    read -t 0.1 N && break
    MEASNR=$(( $MEASNR + 1 ))
    VGSHI=$(( $VGSHI + 3 )); [ $VGSHI -ge $VGSMAX ] && VGSHI=$VGSMAX;
    VDSHI=$(( $VDSHI + 2 )); [ $VDSHI -ge $VDSMAX ] && VDSHI=$VDSMAX;
    TO=5
    do_transfer -6 0.1 $VGSHI  "0.100 0.000 0.010 0.050 0.200 0.300 0.500 0.101"
    do_transfer -6 0.1 $VGSHI  "1.000 2.000 3.000 5.000 7.000 9.000 0.102"
    TO=2
    do_output $VDSHI "-3.000 -2.000 -1.000 0.000 1.000 2.000 3.000 4.000 5.000 6.000 8.000 10.000 12.000 15.000"
    #TON=0.2 TOFF=3
    #do_output_pulsed $VDSHI "4.000 6.000 8.000 10.000 12.000 15.000"
   
    if false; then 
    kill $(<$PIDFILE); sleep 15
    if [ -e $PIDFILE ]; then
       kill -9 $(<$PIDFILE)
    fi
    sleep 60
    fi
    
    TO=4000
    do_noise
    TON=2 TOFF=0.2 REPS=1500
    do_noise_pulsed
    MEASNR=$(( $MEASNR + 1 ))
    #TO=$(( $MEASNR - 1000 ))
    #do_transfer 
  done
}

function do_resloop() { # Resistor transfer, output and noise characteristics
  MEASNR=1000
  TO=1
  VDSHI=9  VDSMAX=15
  VGSHI=11 VGSMAX=20
  # Initial, quick transfer chars to verify setup
  do_transfer -6 0.2 $VGSHI  "0.100 0.500"

  do_output $VDSHI "0.000 4.000"

  while true; do 
    read -t 0.1 N && break
    MEASNR=$(( $MEASNR + 1 ))
    VGSHI=$(( $VGSHI + 3 )); [ $VGSHI -ge $VGSMAX ] && VGSHI=$VGSMAX;
    VDSHI=$(( $VDSHI + 2 )); [ $VDSHI -ge $VDSMAX ] && VDSHI=$VDSMAX;
    TO=5
    do_transfer -6 0.1 $VGSHI  "0.100 0.010 0.050 0.200 0.500"
    do_transfer -6 0.1 $VGSHI  "1.000 5.000 0.102"
    TO=2
    do_output $VDSHI "-3.000 -2.000 -1.000 0.000 1.000 2.000 3.000 4.000 5.000 6.000 8.000 10.000 12.000 15.000"
    #TON=0.2 TOFF=3
    #do_output_pulsed $VDSHI "4.000 6.000 8.000 10.000 12.000 15.000"
   
    if false; then 
    kill $(<$PIDFILE); sleep 15
    if [ -e $PIDFILE ]; then
       kill -9 $(<$PIDFILE)
    fi
    sleep 60
    fi
    
    TO=4000
    do_noise_res
    TON=2 TOFF=0.2 REPS=1500
    #do_noise_pulsed
    MEASNR=$(( $MEASNR + 1 ))
    #TO=$(( $MEASNR - 1000 ))
    #do_transfer 
  done
}

function do_sensorloop() { # PD sensor sweeps and noise characteristics
  MEASNR=1000
  # Initial, quick transfer chars to verify setup

  while true; do  
  TO=60
  do_sensor_forward  
  TO=1200
  do_sensor_reverse ltoh
  TO=30
  do_sensor_reverse htol

  MEASNR=$(( $MEASNR + 1 ))
  TO=1200
  do_sensor_reverse ltoh
  TO=30
  do_sensor_reverse htol
  MEASNR=$(( $MEASNR + 1 ))
  done
}

# Noise operating points of interest:
# Vgs 15V, Vds very small
# Vgs around Vth, Vds small and large


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
      for VREF in 00; do ##02 01 00; do
        send_cmd "v2($VREF) v4($VREF) v6($VREF)"
        send_cmd "v3(0)"
        read -t $TB N && break
        SWEEP="vcc$VCC"_"vref$VREF"_"vhi$VHI"_"ch2src=voltage"
        do_sweep yes
      done
      ##for VREF in 00; do
      ##  send_cmd "v2($VREF) v4($VREF) v6($VREF)"
      ##  send_cmd "v3(0)"
      ##  read -t $TB N && break
      ##  SWEEP="vcc$VCC"_"vref$VREF"_"vhi$VHI"_"ch2src=voltageLONG"
      ##  TO_=$TO; TO=10
      ##  do_sweep yes
      ##  TO=$TO_
      ##done
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
  RSTLO=3
  RSTLOX=6.1
  RSTHI=15
  for TYPE in 'ResetIsource' 'PreSwitch' 'None' 'CancelInj' 'Vbias' 'ResetP' 'ResetN' 'VresetP' 'VresetN' ; do
  TL=20
  send_cmd "v3($VRST)"
  send_cmd "v1($RSTHI)"
  send_cmd "v5(1)"
  echo "Vreset$VRST"_"pulsing$TYPE"_"ch2src=$SOURCEMODE" >"$DATACTRLFILE"
  read -t $TB N 
  if [ "$TYPE" == "PreSwitch" ]; then
    for SW in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
      send_cmd "v1($RSTLO)"
      send_cmd "v1($RSTHI)"
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
  send_cmd "v1($RSTLO) v5(1.2)"
  elif [ "$TYPE" == "ResetIsource" ]; then
  send_cmd "v1($RSTLOX) v5(2)"
  else
  send_cmd "v1($RSTLO)"
  fi
  read -t $TL N 

  if [ "$TYPE" == "ResetIsource" ]; then
  for P1 in 0 1 2 3 4 5 6 7 8 9; do
  for P2 in 0 1 2 3 4 5 6 7 8 9; do
    send_cmd "v5(2+$P2*0.1+$P1)"
    read -t 2 N 
  done
  done
  else
  # start the pulses
  for PULSES in 1 2 3 4 5 6; do
  if [ "$TYPE" == 'None'    ]; then send_cmd "";            fi
  if [ "$TYPE" == 'Vbias'   ]; then send_cmd "v5(0)";       fi
  if [ "$TYPE" == 'ResetN'  ]; then send_cmd "v1($RSTLO-1)";fi
  if [ "$TYPE" == 'ResetP'  ]; then send_cmd "v1($RSTLO+1)";fi
  if [ "$TYPE" == 'VresetN' ]; then send_cmd "v3($VRST-1)"; fi
  if [ "$TYPE" == 'VresetP' ]; then send_cmd "v3($VRST+1)"; fi
  #send_cmd "v2(1) v4(1) v6(1)"
  #send_cmd "v2(0) v4(0) v6(0)"
  read -t $TL N 
  if [ "$TYPE" == 'None'    ]; then send_cmd "";            fi
  if [ "$TYPE" == 'Vbias'   ]; then send_cmd "v5(1)";       fi
  if [ "$TYPE" == 'ResetN'  ]; then send_cmd "v1($RSTLO)";  fi
  if [ "$TYPE" == 'ResetP'  ]; then send_cmd "v1($RSTLO)";  fi
  if [ "$TYPE" == 'VresetN' ]; then send_cmd "v3($VRST)";   fi
  if [ "$TYPE" == 'VresetP' ]; then send_cmd "v3($VRST)";   fi
  read -t $TL N 
  done
  fi

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

