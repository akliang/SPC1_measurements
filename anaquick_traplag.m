run('./mlibs/mlibsys/mlibsInit.m' )

paFB=0.83*1E-12; % pre-amp FeedBack cap 0.75pF / ADC
ppitch=150*1E-6; % 150 um pixel pitch, 130 um pd area?

F='../measurements/Gen2_PSI1_29B1-1/20120509T233727_DarkLeak_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120509T233727_DarkLeak_Vbias-1V0_Voff-4V0';
%Gen2_PSI1_29B1-1/20120509T165804_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120509T165804_LED_Vbias-2V0_Voff-4V0
%Gen2_PSI1_29B1-1/20120509T171526_LED_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120509T171526_LED_Vbias-1V0_Voff-4V0
%Gen2_PSI1_29B1-1/20120509T174144_LED_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120509T174144_LED_Vbias-1V0_Voff-4V0 % no variation in LED level
%Gen2_PSI1_29B1-1/20120510T111644_LED_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120510T111644_LED_Vbias-1V0_Voff-4V0 % LED not on
F='../measurements/Gen2_PSI1_29B1-1/20120510T114010_LED_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120510T114010_LED_Vbias-1V0_Voff-4V0';
pCperADC=(1*paFB) / 3400 * 1E12; % pC per ADC
FL=200; LL=300;
FOI=-2;
DLroi=5+(0:20);
GLroi=17+(0:10);


%{
%F='../measurements/Gen2_PSI1_29B1-6/20120510T182344_DarkLeak_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120510T182344_DarkLeak_Vbias-2V0_Voff-4V0';
%F='../measurements/Gen2_PSI1_29B1-6/20120510T125632_DarkLeak_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120510T125632_DarkLeak_Vbias-1V0_Voff-4V0';
F='../measurements/Gen2_PSI1_29B1-6/20120510T155744_DarkLeak_Vbias0V0_Von15V0_Voff-4V0_VQinj1V0/20120510T155744_DarkLeak_Vbias0V0_Voff-4V0';
pCperADC=(1*paFB) / 9000 * 1E12; % pC per ADC
FOI=-2;
DLroi=20:30;
GLroi=30:40;


F='../measurements/Gen2_PSI1_29B1-6/20120509T113925_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120509T113925_LED_Vbias-2V0_Voff-4V0';
FL=20; LL=70;
DLroi=17+(0:5);
GLroi=53+(0:5);
%DLroi=17+(0:5);
%GLroi=105+(0:5);
%}

%{
F='../measurements/Gen2_PSI1_29B1-6/20120510T175828_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120510T175828_LED_Vbias-2V0_Voff-4V0';
F='../measurements/Gen2_PSI1_29B1-6/20120511T084913_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120511T084913_LED_Vbias-2V0_Voff-4V0';
%F='../measurements/Gen2_PSI1_29B1-6/20120511T102335_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120511T102335_LED_Vbias-2V0_Voff-4V0';
FL=200; LL=300;
DLroi=85:90;
GLroi=30:35;
%}

FOI=[FL+(-18:18) LL+(-18:18) ];
FOSI=[ FL-FOI(1)+[0 1] numel(FOI)+(LL-1-FOI(end))+[0 1] ];


fmds=read_fmd_complete([ F '.fmd' ], true, true);

fid=fopen([ F '.bin.cropped'], 'r');

img=[];
data=[];
val=[];
DLS=192;
GLS=128;
for aid=1:numel(fmds);
  %fpos=(fmds{aid}.alf-2) * DLS * GLS * 2;
  for f=1:numel(FOI);
  fpos=(fmds{aid}.aff+FOI(f)-1) * DLS * GLS * 2;
  fseek(fid,fpos-1,'bof');
  if feof(fid); break; end
  img(aid,f,:,:)=fread(fid,[ DLS GLS ],'uint16');
  %fpos=fpos+(DLS*38+68)*2;
  %val=fread(fid,1,'uint16');
  val(f)=squeeze(mean(mean(img(aid,f,DLroi,GLroi))));
  end
  data(aid,:)=[ 1/fmds{aid}.fps val ];
end

fclose(fid);

colors={'b','r','g','c','b','r','g','c','b','r','g','c'};

figure(3)
hold off; for aid=1:numel(fmds);
   pdata=data(aid,2:end)*pCperADC;
   plot(pdata,[ colors{aid} '-' ]); hold on;
   plot(FOSI,pdata(FOSI),[ colors{aid} '*' ]); hold on;
end
title(F,'Interpreter','none')
xlabel('Selected Frames')
ylabel('Pre-amp Charge Readout (pC)')

figure(4)
hold off; for aid=1:numel(fmds);
   pdata=(data(aid,2:end)-mean(data(aid,2:15))) *pCperADC;
   plot(pdata,[ colors{aid} '-' ]); hold on;
   plot(FOSI,pdata(FOSI),[ colors{aid} '*' ]); hold on;
end
title(F,'Interpreter','none')
xlabel('Selected Frames')
ylabel('Charge Readout (pC), offset by pre-LED level')

figure(5)
hold off; for aid=1:numel(fmds);
   pfit=polyfit(FOI(1:14),data(aid,2:15),1);
   pdata=( data(aid,2:end)-polyval(pfit, FOI) ) *pCperADC;
   plot(pdata,[ colors{aid} '-' ]); hold on;
   plot(FOSI,pdata(FOSI),[ colors{aid} '*' ]); hold on;
end
title(F,'Interpreter','none')
xlabel('Selected Frames')
ylabel('Charge Readout (pC), detrended by pre-LED linear fit')

return

% plotting
figure(1)
pid=(data(:,1)<2);
pid=(data(:,1)~=0);
plot(data(pid,1),data(pid,2)*pCperADC,'*-')
title(F,'Interpreter','none')
xlabel('Frame time (s)')
ylabel('ADC counts')
ylabel('Charge Readout (pC)')

figure(2)
pid=(data(:,1)<2);
pid=find((data(:,1)~=0));
negslopers=find(diff(data(pid,1))<0.2);
pid=pid(negslopers(end)+1:end);
ileak=(data(pid(2:end),2)-data(pid(1:end-1),2)) ./ (data(pid(2:end),1)-data(pid(1:end-1),1));
plot(data(pid(2:end),1), ileak*pCperADC/(ppitch*1000)^2,'*-');
%ylim( [ min(ileak), min(abs(ileak))*10 ] );
title(F,'Interpreter','none')
xlabel('Frame time (s)')
ylabel('Idark (pA/mm^2)')

