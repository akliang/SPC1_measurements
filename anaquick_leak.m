run('./mlibs/mlibsys/mlibsInit.m' )

Fs={};
paFB=0.83*1E-12; % pre-amp FeedBack cap 0.75pF / ADC
ppitch=150*1E-6; % 150 um pixel pitch, 130 um pd area?
colors={'r','g','b'};
coffs=[];
%{
Fs{end+1}='../measurements/Gen2_PSI1_29B1-1/20120509T233727_DarkLeak_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120509T233727_DarkLeak_Vbias-1V0_Voff-4V0'; coffs(end+1)=0; colors={'g','k','k'};
pCperADC=(1*paFB) / 3400 * 1E12; % pC per ADC
%}

%{
Fs{end+1}='../measurements/Gen2_PSI1_29B1-6/20120510T182344_DarkLeak_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120510T182344_DarkLeak_Vbias-2V0_Voff-4V0'; coffs(end+1)=0;
Fs{end+1}='../measurements/Gen2_PSI1_29B1-6/20120510T125632_DarkLeak_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120510T125632_DarkLeak_Vbias-1V0_Voff-4V0'; coffs(end+1)=0.55;
Fs{end+1}='../measurements/Gen2_PSI1_29B1-6/20120510T155744_DarkLeak_Vbias0V0_Von15V0_Voff-4V0_VQinj1V0/20120510T155744_DarkLeak_Vbias0V0_Voff-4V0'; coffs(end+1)=0.65;
%Fs{end+1}='../measurements/Gen2_PSI1_29B1-6/20120511T172516_DarkLeak_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120511T172516_DarkLeak_Vbias-2V0_Voff-4V0'; coffs(end+1)=0.4;
pCperADC=(1*paFB) / 9000 * 1E12; % pC per ADC
%}

pCperADC=(1*paFB) / 1870 * 1E12; % pC per ADC
bipolaroffset=pCperADC*2^15;
%Fs{end+1}='../measurements/Gen2_PSI-1_29B1-3/20120514T155233_DarkLeak_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120514T155233_DarkLeak_Vbias-2V0_Voff-4V0'; coffs(end+1)=0.0-bipolaroffset;
Fs{end+1}='../measurements/Gen2_PSI-1_29B1-3/20120514T171324_DarkLeak_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120514T171324_DarkLeak_Vbias-1V0_Voff-4V0'; coffs(end+1)=0.0-bipolaroffset;
Fs{end+1}='../measurements/Gen2_PSI-1_29B1-3/20120514T174931_DarkLeak_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120514T174931_DarkLeak_Vbias-2V0_Voff-4V0'; coffs(end+1)=-1.4-bipolaroffset;


figure(1); hold off;
for fsid=1:numel(Fs);
F=Fs{fsid};

fmds=read_fmd_complete([ F '.fmd' ], true, true);

fid=fopen([ F '.bin.cropped'], 'r');

img=[];
val=[];
data=[];
DLS=192;
GLS=128;
DLroi=20:30;
GLroi=30:40;
DLroi=50:70;
GLroi=50:70;
for aid=1:numel(fmds);
  fpos=(fmds{aid}.alf-2) * DLS * GLS * 2;
  fseek(fid,fpos-1,'bof');
  if feof(fid); break; end
  img(aid,:,:)=fread(fid,[ DLS GLS ],'uint16');
  %fpos=fpos+(DLS*38+68)*2;
  %val=fread(fid,1,'uint16');
  val=mean(mean(img(aid,DLroi,GLroi)));
  data(aid,:)=[ 1/fmds{aid}.fps val ];
end

fclose(fid);

% plotting
figure(1)
%pid=(data(:,1)<3.5);
pid=(data(:,1)~=0);
pid(1)=0; % ignore first acquisition
plot(data(pid,1),data(pid,2)*pCperADC+coffs(fsid),[ colors{fsid} '*-' ])
%ylim([ 0.5 3 ]);
title(F,'Interpreter','none')
xlabel('Frame time (s)')
ylabel('ADC counts')
ylabel('Charge Readout (pC)')
hold on

end

figure(2)
pid=(data(:,1)<3.5);
%pid=find((data(:,1)~=0));
negslopers=find(diff(data(pid,1))<0.2);
pid=pid(negslopers(end)+1:end);
ileak=(data(pid(2:end),2)-data(pid(1:end-1),2)) ./ (data(pid(2:end),1)-data(pid(1:end-1),1));
plot(data(pid(2:end),1), ileak*pCperADC/(ppitch*1000)^2,'*-');
%ylim( [ min(ileak), min(abs(ileak))*10 ] );
title(F,'Interpreter','none')
xlabel('Frame time (s)')
ylabel('Idark (pA/mm^2)')

