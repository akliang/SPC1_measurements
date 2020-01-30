#!/bin/bash

INDIR=$1

# clean the data (needed for matlab scripts)
for F in $( ls -1d $INDIR/*.csv ); do
  sed -e '1,6d' -e "s/,,,//g" "$F" > "$F.clean"
done

# grab voltage values from environment script
MEASID=$( echo "$INDIR" | sed -e "s/.*meas//" -e "s/\([0-9]*\).*/\1/" )
SMUDAT=$( head -n 1 $INDIR/environment.txt | awk '{ printf "%0.2f\t%0.2f\t%0.2f\t%0.2f\t%0.2f\t%0.2f", $4,$6,$8,$10,$12,$14 }' )

# this is disabled because c01 calls it explicitly
#AMPDAT=$( echo "b02_analyze_oscope_amp('$F')" | octave -qH )
#AMPDAT=$( echo "b02_analyze_oscope_amp('$F')" | matlab )

# echo the values for c01 to grab
#echo -e "$MEASID\t$SMUDAT\t$AMPDAT"
echo -e "$MEASID\t$SMUDAT"

