#!/bin/bash

INDIR="$1"
if [ "$INDIR" == "" ]; then
  echo "Needs an input folder"
fi


for F in $( ls -1d $INDIR/meas* ); do 
  MEASID=$( echo "$F" | sed -e "s/.*meas//" -e "s/\([0-9]*\).*/\1/" )
  SMUDAT=$( head -n 1 $F/environment.txt | gawk '{ printf "%0.2f\t%0.2f\t%0.2f", $8,$10,$12 }' )
  #AMPDAT=$( echo "b02_analyze_oscope_amp('$F')" | octave -qH )
  AMPDAT=$( echo "b02_analyze_oscope_amp('$F')" | matlab )
  echo -e "$MEASID\t$SMUDAT\t$AMPDAT"
done



