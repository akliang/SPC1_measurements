#!/bin/bash

PDIR="../../measurements"
WDIR="20180207T213107" # 1V steps, 1kHz sine
WDIR="20180207T222252" # 1V steps, 100Hz sine
WDIR="20180208T220404" # m2(0.1V) and m4(0.25V) steps, 1kHz sine

WDIR="20180209T194639" # bode plot testing
DATFILE="$PDIR/$WDIR/results.dat"

# scan the DATFILE to see which meas number have already been converted
if [ -e "$DATFILE" ]; then
  LASTMEAS="$( tail -n 1 $DATFILE | gawk '{ print $1 }' )"
fi
if [ "$LASTMEAS" == "" ]; then
  LASTMEAS=0
else
  echo "LASTMEAS is $LASTMEAS"
fi

FTAGS="math1.csv math2.csv"
# step through each file and append the data to DATFILE
for F in $( find "$PDIR/$WDIR/" -name 'meas*' | sort ); do
  MEASNUM=$( basename "$F" | sed -e "s/^meas//" )
  if [ $MEASNUM -le $LASTMEAS ]; then continue; fi
  SMUVOLTS="$( head -n 1 "$F/environment.txt" | gawk '{ print $4,$6,$8,$10,$12 }' )"
  VROUND=$( echo $SMUVOLTS | gawk '{ printf "%0.2f %0.2f %0.2f",$3,$4,$5 }' )
  DRET="$MEASNUM $VROUND $SMUVOLTS"
  for FTAG in $FTAGS; do 
    FFILE=$( find "$F" -name "$FTAG" )

    # find the freq and amp of the input signal
    if [ "$FTAG" == "math1.csv" ]; then
      TMPF=$( mktemp )
      ./helper_clean_csv.sh "$FFILE" "$TMPF"
      INVALS=$( echo "helper_find_freq('$TMPF')" | octave -qH )
      rm "$TMPF"
      DRET="$DRET $INVALS"
    fi

    # legacy code for files that had oscope header data stripped
    if [ "$( head -n 1 $FFILE | gawk -F ',' '{ print NF }')" == 2 ]; then
      MINMAX=$( gawk -F "," 'BEGIN{min=9999;max=-9999} {if(($2)<min) min=($2); if(($2)>max) max=($2)}END {print min,max}' $FFILE )
    else
      MINMAX=$( gawk -F "," 'BEGIN{min=9999;max=-9999} {if(($5)<min) min=($5); if(($5)>max) max=($5)}END {print min,max}' $FFILE )
    fi
    DRET="$DRET $MINMAX"
  done
  echo "$DRET"
  echo "$DRET" >> $DATFILE
done

