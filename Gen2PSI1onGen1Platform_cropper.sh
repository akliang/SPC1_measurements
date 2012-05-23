#!/bin/bash

echo "Checking for new binfiles..."

while true; do

echo -n "."
DIDCONV=0

#for D in ../measurements/PSI-1*; do # for Gen1 on old PF on kaon
#for D in ../measurements/Gen2_PSI1*; do # for Gen2 on old PF on kaon
#for D in ../measurements/Gen2_PSI-1*; do # for Gen2 on new PF on axion
for D in ../measurements/Gen2_PSI-1*; do # for Gen2 on old PF on kaon, temporarily

#F="meas004_DarkCloth_NewDC_7_8.bin"
for F in $D/*.bin $D/*/*.bin; do

if [ $F.cropped -ot $F ]; then

#touch $F.cropped # to make sure we don't try to convert it again - even IF octave bails out...
echo
echo "Converting $F..."
sleep 1

echo "
  pause(0.1); % to immediately cause that weird warning about 'No X11 forwarding'...
  % Gen1-PSI-1 Array on Gen1 Platform
  %{
  dcount=512; gcount=256; % dimensions as saved by G3
  DLS=[ 1:384 ];
  GLS=1:gcount;
  %}
  % Gen2-PSI-1 Array on Gen1 Platform
  %%{
  dcount=512; gcount=256; % dimensions as saved by G3
  DLS=[ 128+1:128+64   224+1:224+64   320+1:320+64 ];
  GLS=1:gcount;
  %}
  % Gen2-PSI-1 Array on Gen2 Platform UMB1.0
  %{
  dcount=512; gcount=256; % dimensions as saved by G3
  DLS=[ 64+(1:64)   192+(1:64) 320+(1:64) ];
  GLS=[ 0+(1:64)  128+(1:64) ]; % Gate-line sorting matrix
  quadswap=[ 4:4:64 ; 3:4:64 ; 2:4:64 ; 1:4:64 ]
  GLS=GLS( [ quadswap(:) 64+quadswap(:) ] );
  DLS=DLS( [ quadswap(:) 64+quadswap(:) 128+quadswap(:) ] );
  %}

  F='$F'
  frd=fopen(F,'r');
  fwr=fopen([F '.cropped'],'w');

  frcnt=0;
  recnt=0;
  while true;
    fpos=ftell(frd);
    dd=fread(frd,dcount*gcount,'uint16=>uint16','ieee-be');
    lcount=size(dd,1)/dcount;
    if (lcount < gcount);
      recnt=recnt+1; if recnt>50; break; end
      fprintf('w'); pause(1); fseek(frd,fpos,'bof'); continue;
    end
    dd=reshape(dd,[dcount lcount]);
    ddd=dd(DLS,GLS);
    fwrite(fwr,ddd,'uint16','ieee-be');
    fprintf('f');
    frcnt=frcnt+1;
    recnt=0;
  end

  fclose(fwr);
  fclose(frd);
  fprintf('\nCropped %d frames.\n');
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

