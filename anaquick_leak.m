clear all % for now, to test struct changes
run('./mlibs/mlibsys/mlibsInit.m' )

% Default settings for all the variables
S.paFB=0.83*1E-12; % pre-amp FeedBack cap, nominal 0.75pF, Qihua characterization 0.83pF
S.Cpere=1.6022E-19; % elementary charge, Coloumb per electron (absolute)
S.ppitch=150*1E-6; % 150 um pixel pitch, 130 um pd area?
S.colors={'b','r','g','c','b','r','g','c','b','r','g','c'}; % order of colors for plot
S.coffs=0; % charge offset
S.DLS=192; S.GLS=128; % geometry in .bin or .bin.cropped
S.DLroi=20:30; S.GLroi=30:40; % pixel region-of-interest for analysis
S.DLroi=50:70; S.GLroi=50:70;
S.pCperADC=0; % pC per ADC
S.F=''; % actual binfile name
S.VQinj=NaN; %VQinj, where applicable

Sdef=S; % store away a default S
Fs={};
%{
S.DLS=384;
S.GLS=256;
S.pCperADC=(1*S.paFB) / 9000 * 1E12; % pC per ADC
S.ppitch=90*1E-6;
S.F='../measurements/PSI-1_29A32-5/20120514T205704_DarkLeak_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120514T205704_DarkLeak_Vbias-2V0_Voff-4V0';
%S.F='../measurements/PSI-1_29A32-5/20120514T222845_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120514T222845_LED_Vbias-2V0_Voff-4V0';
Fs{end+1}=S;
%}

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

%%{
S.DLroi=50:70; S.GLroi=50:70;
S.pCperADC=(1*S.paFB) / 9597 * 1E12; % pC per ADC
S.ppitch=150*1E-6 * 0.65; % PD area (pitch * FF)
%S.coffs=-0.12;
S.F='../measurements/Gen2_PSI-1_29B3-2/20120523T112730_DarkLeak_Vbias-3V0_Von15V0_Voff-4V0_VQinj1V0/20120523T112730_DarkLeak_Vbias-3V0_Voff-4V0';
Fs{end+1}=S;

%S.F='../measurements/Gen2_PSI-1_29B3-2/20120521T144815_DarkLeak_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120521T144815_DarkLeak_Vbias-2V0_Voff-4V0';
S.F='../measurements/Gen2_PSI-1_29B3-2/20120522T112435_DarkLeak_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120522T112435_DarkLeak_Vbias-2V0_Voff-4V0';
Fs{end+1}=S;

S.F='../measurements/Gen2_PSI-1_29B3-2/20120521T195319_DarkLeak_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120521T195319_DarkLeak_Vbias-1V0_Voff-4V0';
Fs{end+1}=S;

S.F='../measurements/Gen2_PSI-1_29B3-2/20120521T215821_DarkLeak_Vbias0V0_Von15V0_Voff-4V0_VQinj1V0/20120521T215821_DarkLeak_Vbias0V0_Voff-4V0';
Fs{end+1}=S;

S.DLroi=1:4; S.GLroi=2:4; % No-PIN pixels
Fs{end+1}=S;
%}

%{
% first simple Gain calibration analysis
S.pCperADC=(1*S.paFB) / 9597 * 1E12; % pC per ADC
S.DLroi=50:70; S.GLroi=50:70;
S.F='../measurements/Gen2_PSI-1_29B3-2/20120521T191337_Qinj_Vbias-2V0_Von15V0_Voff-4V0_VQinj2V0/20120521T191337_Qinj_Vbias-2V0_Voff-4V0';
S.VQinj=2.0;
Fs{end+1}=S;
S.F='../measurements/Gen2_PSI-1_29B3-2/20120521T191444_Qinj_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V5/20120521T191444_Qinj_Vbias-2V0_Voff-4V0';
S.VQinj=1.5;
Fs{end+1}=S;
S.F='../measurements/Gen2_PSI-1_29B3-2/20120521T191648_Qinj_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120521T191648_Qinj_Vbias-2V0_Voff-4V0';
S.VQinj=1.0;
Fs{end+1}=S;
S.F='../measurements/Gen2_PSI-1_29B3-2/20120521T191208_Qinj_Vbias-2V0_Von15V0_Voff-4V0_VQinj0V0/20120521T191208_Qinj_Vbias-2V0_Voff-4V0';
S.VQinj=0.0;
%Fs{end+1}=S;
%}

%{
pCperADC=(1*paFB) / 1870 * 1E12; % pC per ADC
bipolaroffset=pCperADC*2^15;
%Fs{end+1}='../measurements/Gen2_PSI-1_29B1-3/20120514T155233_DarkLeak_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120514T155233_DarkLeak_Vbias-2V0_Voff-4V0'; coffs(end+1)=0.0-bipolaroffset;
Fs{end+1}='../measurements/Gen2_PSI-1_29B1-3/20120514T171324_DarkLeak_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120514T171324_DarkLeak_Vbias-1V0_Voff-4V0'; coffs(end+1)=0.0-bipolaroffset;
Fs{end+1}='../measurements/Gen2_PSI-1_29B1-3/20120514T174931_DarkLeak_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120514T174931_DarkLeak_Vbias-2V0_Voff-4V0'; coffs(end+1)=-1.4-bipolaroffset;
%}

figs={};
figure(1); hold off;
figure(2); hold off;
cdata=[];
for fsid=1:numel(Fs);
S=Fs{fsid};
leglabel=regexprep(S.F,{'(^[^/]*)/([^/]*)/([^/]*)/([^/]*)/(.*$)','_'},{'$3 $4',' '});
leglabel=[ '^ ' leglabel{1} ];

fmds=read_fmd_complete([ S.F '.fmd' ], true, true);

fid=fopen([ S.F '.bin.cropped'], 'r');

img=[];
val=[];
data=[];
for aid=1:numel(fmds);
  fpos=(fmds{aid}.alf-2) * S.DLS * S.GLS * 2;
  fseek(fid,fpos-1,'bof');
  if feof(fid); break; end
  img(aid,:,:)=fread(fid,[ S.DLS S.GLS ],'uint16');
  %fpos=fpos+(DLS*38+68)*2;
  %val=fread(fid,1,'uint16');
  val=mean(mean(img(aid,S.DLroi,S.GLroi)));
  data(aid,:)=[ 1/fmds{aid}.fps val ];
end
cdata(fsid,:)=[ S.VQinj val ]; % store last aid's data for potential GAIN calibration

fclose(fid);

if numel(fmds)>1; 
% plotting
figure(1);
%pid=(data(:,1)<3.5);
pid=(data(:,1)~=0);
pid(1)=0; % ignore first acquisition
plot(data(pid,1),data(pid,2)*S.pCperADC+S.coffs,[ S.colors{fsid} '*-' ]);
hold on
figs{gcf}.legstr{fsid}=leglabel;
%ylim([ 0.5 3 ]);
title(S.F,'Interpreter','none')
xlabel('Frame time (s)')
ylabel('ADC counts')
ylabel('Charge Readout (pC)')
legend(figs{gcf}.legstr);


figure(2)
%pid=(data(:,1)<3.5);
pid=find((data(:,1)~=0));
negslopers=find(diff(data(pid,1))<0.2);
pid=pid(negslopers(end)+1:end);
ileak=(data(pid(2:end),2)-data(pid(1:end-1),2)) ./ (data(pid(2:end),1)-data(pid(1:end-1),1));
plot(data(pid(2:end),1), ileak*S.pCperADC/(S.ppitch*1000)^2,[ S.colors{fsid} '*-' ]); hold on;
figs{gcf}.legstr{fsid}=leglabel;
%ylim( [ min(ileak), min(abs(ileak))*10 ] );
ylim( [ -3 3 ] );
title(S.F,'Interpreter','none')
xlabel('Frame time (s)')
ylabel('Idark (pA/mm^2)')
legend(figs{gcf}.legstr,'location','southeast');

end % numel(fmds)>1

end % for fsids

if numel(fmds)==1; 
figure(3); hold off;
plot(cdata(:,1),cdata(:,2),'b*-'); hold on
figs{gcf}.legstr{1}='data';
pp=polyfit(cdata(:,1),cdata(:,2),1);
plot(cdata(:,1),polyval(pp,cdata(:,1)),'r:'); hold on
calib.pCperADC=(1*S.paFB) / pp(1) * 1E12; % pC per ADC
calib.eperADC=calib.pCperADC * 1E-12 / ( S.Cpere ) % electrons per ADC
figs{gcf}.legstr{end+1}=sprintf('fit:\n%.1f ADC/VQinj\n%g pC/ADC\n%.0f e/ADC', \
				        pp(1), calib.pCperADC, calib.eperADC );
xlabel('VQinj');
ylabel('ADCs');
legend(figs{gcf}.legstr,'location','northwest');
end

