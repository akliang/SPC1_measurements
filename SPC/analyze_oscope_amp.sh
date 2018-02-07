#!/bin/bash

PDIR="../../measurements"
WDIR="20180207T222252"
DATFILE="$PDIR/$WDIR/results.dat"

FTAGS="math1.csv math2.csv"
# step through each file and append the data to DATFILE
for F in $( find "$PDIR/$WDIR/" -name 'meas*' | sort ); do
  VCC="$( head -n 1 "$F/environment.txt" | gawk '{ print $4 }' )"
  GND="$( head -n 1 "$F/environment.txt" | gawk '{ print $6 }' )"
  M2B="$( head -n 1 "$F/environment.txt" | gawk '{ print $8 }' )"
  M3B="$( head -n 1 "$F/environment.txt" | gawk '{ print $10 }' )"
  M4B="$( head -n 1 "$F/environment.txt" | gawk '{ print $12 }' )"
  M2BR=$( echo $M2B | gawk '{ printf "%0.2f",$1 }' )
  M3BR=$( echo $M3B | gawk '{ printf "%0.2f",$1 }' )
  M4BR=$( echo $M4B | gawk '{ printf "%0.2f",$1 }' )
  DRET=""
  for FTAG in $FTAGS; do 
    FFILE=$( find "$F" -name "$FTAG" )
    # strip off the weird oscilloscope-appended data
    ./clean_csv.sh "$FFILE"
    TMP=$( echo "extract_waveform_values('$FFILE')" | octave -qH )
    if [ "$DRET" == "" ]; then
      DRET="$TMP"
    else
      DRET="$DRET $TMP"
    fi
  done
  OUT="$M2BR $M3BR $M4BR $VCC $GND $M2B $M3B $M4B $DRET"
  echo "$OUT"
  echo "$OUT" >> $DATFILE
done




