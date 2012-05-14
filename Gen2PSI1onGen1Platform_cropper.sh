#!/bin/bash

echo "Checking for new binfiles..."

while true; do

echo -n "."
DIDCONV=0

for D in ../measurements/Gen2_PSI1*; do

#F="meas004_DarkCloth_NewDC_7_8.bin"
for F in $D/*.bin $D/*/*.bin; do

if [ $F.cropped -ot $F ]; then

#touch $F.cropped # to make sure we don't try to convert it again - even IF octave bails out...
echo
echo "Converting $F..."
sleep 1

echo "
  DLS=[ 128+1:128+64   224+1:224+64   320+1:320+64 ];
  dcount=512;
  F='$F'
  frd=fopen(F,'r');
  fwr=fopen([F '.cropped'],'w');

  while true;
    dd=fread(frd,dcount*128*1024,'uint16=>uint16','ieee-be');
    lcount=size(dd,1)/dcount
    if lcount==0; break; end
    dd=reshape(dd,[dcount lcount]);
    ddd=dd(DLS,:);
    fwrite(fwr,ddd,'uint16','ieee-be');
  end

  fclose(fwr);
  fclose(frd);
" | octave -q --no-history

echo "...done."
DIDCONV=1

fi

done

done

[ "$DIDCONV" == "1" ] && read -t 30 && break
read -t 1 && break

done

echo ""

