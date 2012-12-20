run('./mlibs/mlibsys/mlibsInit.m' )

paFB=0.83*1E-12; % pre-amp FeedBack cap 0.75pF / ADC
ppitch=150*1E-6; % 150 um pixel pitch, 130 um pd area?

%{
F='../measurements/Gen2_PSI1_29B1-1/20120509T233727_DarkLeak_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120509T233727_DarkLeak_Vbias-1V0_Voff-4V0';
%Gen2_PSI1_29B1-1/20120509T165804_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120509T165804_LED_Vbias-2V0_Voff-4V0
%Gen2_PSI1_29B1-1/20120509T171526_LED_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120509T171526_LED_Vbias-1V0_Voff-4V0
%Gen2_PSI1_29B1-1/20120509T174144_LED_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120509T174144_LED_Vbias-1V0_Voff-4V0 % no variation in LED level
%Gen2_PSI1_29B1-1/20120510T111644_LED_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120510T111644_LED_Vbias-1V0_Voff-4V0 % LED not on
F='../measurements/Gen2_PSI1_29B1-1/20120510T114010_LED_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120510T114010_LED_Vbias-1V0_Voff-4V0';
pCperADC=(1*paFB) / 3400 * 1E12; % pC per ADC
FL=200; LL=300;
DLroi=5+(0:20);
GLroi=17+(0:10);
%}

%{
F='../measurements/Gen2_PSI1_29B1-6/20120509T113925_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120509T113925_LED_Vbias-2V0_Voff-4V0';
FL=20; LL=70;
pCperADC=(1*paFB) / 9000 * 1E12; % pC per ADC
DLroi=17+(0:5);
GLroi=53+(0:5);
%DLroi=17+(0:5);
%GLroi=105+(0:5);
%}

%{
%F='../measurements/Gen2_PSI1_29B1-6/20120510T175828_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120510T175828_LED_Vbias-2V0_Voff-4V0';
%F='../measurements/Gen2_PSI1_29B1-6/20120511T084913_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120511T084913_LED_Vbias-2V0_Voff-4V0';
%F='../measurements/Gen2_PSI1_29B1-6/20120511T102335_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120511T102335_LED_Vbias-2V0_Voff-4V0';
 F='../measurements/Gen2_PSI1_29B1-6/20120514T101119_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120514T101119_LED_Vbias-2V0_Voff-4V0';
FL=200; LL=300;
pCperADC=(1*paFB) / 9000 * 1E12; % pC per ADC
DLroi=85:90;
GLroi=30:35;
DLroi=20:30;
GLroi=40:50;
%}
DLS=192;
GLS=128;
foffs=5;

%{
F='../measurements/PSI-1_29A32-5/20120515T092213_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120515T092213_LED_Vbias-2V0_Voff-4V0'; sigsat=3.91945; Vbias=-2;
pCperADC=(1*paFB) / 3400 * 1E12; % pC per ADC
FL=200; LL=300;
DLroi=25+(0:10);
GLroi=115+(0:10);
DLS=384;
GLS=256;
foffs=1;
%}

%%{
%F='../measurements/Gen2_PSI-1_29B3-2/20120523T125644_LED_Vbias-3V0_Von15V0_Voff-4V0_VQinj1V0/20120523T125644_LED_Vbias-3V0_Voff-4V0'; sigsat=3.60835; Vbias=-3; DLroi= 165+(-5:5); GLroi=40+(-5:5); % center of LED 
F='../measurements/Gen2_PSI-1_29B3-2/20120521T163701_LED_Vbias-2V0_Von15V0_Voff-4V0_VQinj1V0/20120521T163701_LED_Vbias-2V0_Voff-4V0'; sigsat=2.793614; Vbias=-2;
%F='../measurements/Gen2_PSI-1_29B3-2/20120521T192146_LED_Vbias-1V0_Von15V0_Voff-4V0_VQinj1V0/20120521T192146_LED_Vbias-1V0_Voff-4V0'; sigsat=1.779589; Vbias=-1;
%F='../measurements/Gen2_PSI-1_29B3-2/20120521T212647_LED_Vbias0V0_Von15V0_Voff-4V0_VQinj1V0/20120521T212647_LED_Vbias0V0_Voff-4V0';
pCperADC=(1*paFB) / 9597 * 1E12; % pC per ADC
FL=200; LL=300;
DLroi= 24+(-5:5); GLroi=73+(-5:5); % center of LED 
%DLroi= 50+(-5:5); GLroi=73+(-5:5); % somewhat off LED
%DLroi=140+(-5:5); GLroi=32+(-5:5); % far away from LED
foffs=8;
%}


FOI=[FL+(-18:18) LL+(-18:18) ];
FOSI=[ FL-FOI(1)+[0 1] numel(FOI)+(LL-1-FOI(end))+[0 1] ];

fmds=read_fmd_complete([ F '.fmd' ], true, true);

fid=fopen([ F '.bin.cropped'], 'r');

img=[];
data=[];
val=[];
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

figure(3+foffs)
hold off; for aid=1:numel(fmds);
   pdata=data(aid,2:end)*pCperADC;
   plot(pdata,[ colors{aid} '-' ]); hold on;
   plot(FOSI,pdata(FOSI),[ colors{aid} '*' ]); hold on;
end
title(F,'Interpreter','none')
xlabel('Selected Frames')
ylabel('Pre-amp Charge Readout (pC)')

legstr={};
cdata=[];

figure(4+foffs)
hold off; for aid=1:numel(fmds);
   pdata=(data(aid,2:end)-mean(data(aid,2:15))) *pCperADC;
   flashes=fmds{aid}.r(25);
   sigdark=pdata(FOSI(1)); % zero in here!
   sigrad=pdata(FOSI(2));
   sigflu=pdata(FOSI(3));
   siglag1=pdata(FOSI(4));
   siglag2=pdata(FOSI(4)+1);
   siglag3=pdata(FOSI(4)+2);
   
   cdata(end+1,:)=[ flashes sigdark sigrad sigflu siglag1 siglag2 siglag3 ];
   plot(pdata,[ colors{aid} '-' ]); hold on;
   legstr{end+1}=sprintf('%d LED flashes, Fluoro signal %.3f pC', flashes, sigflu);
   plot(FOSI,pdata(FOSI),[ colors{aid} '*' ]); hold on;
   if flashes>0; 
   legstr{end+1}=sprintf('Trap: %.1f%%  Lag1: %.1f%%  Lag2: %.1f%%', \
                (1-(sigrad/sigflu))*100, (siglag1/sigflu)*100, (siglag2/sigflu)*100 );
   else 
   legstr{end+1}='n/a';
   end
end
title(F,'Interpreter','none')
xlabel('Selected Frames')
ylabel('Charge Readout (pC), offset by pre-LED level')
legend(legstr);

figure(6+foffs); hold off;
legstr={};
plot(cdata(:,1),cdata(:,4),'gx-'); hold on; legstr{end+1}='fluoroscopic response';
plot(cdata(:,1),cdata(:,3),'rx-'); hold on; legstr{end+1}='radiographic response';
xlabel('LED flashes');
ylabel('Signal (pC)');
legend(legstr,'location','southeast');

%sigsat=sigflu; % assuming we reach saturation
figure(7+foffs);
hold off; legstrTL={}; sym='-'; 
plot((cdata(2:end,4)/sigsat)*100,(1-cdata(2:end,3)./cdata(2:end,4))*100,[ 'rx' sym ]); hold on; legstrTL{end+1}=sprintf('Trapping, Vbias %.1f', Vbias);
plot((cdata(2:end,4)/sigsat)*100,(  cdata(2:end,5)./cdata(2:end,4))*100,[ 'bx' sym ]); hold on; legstrTL{end+1}=sprintf('FirstLag, Vbias %.1f', Vbias);
%plot((cdata(2:end,4)/sigsat)*100,(  cdata(2:end,6)./cdata(2:end,4))*100,[ 'gx' sym ]); hold on; legstrTL{end+1}='Lag2';
xlabel('Signal (% of pixel saturation)');
ylabel('Trap/Lag (% of fluoroscopic equilibrium)');
legend(legstrTL,'location','northwest');
title([ F sprintf('\n') 'Trapping and Lag, at around 2 frames per second' ], 'Interpreter', 'none' );
sym='--';



figure(5+foffs)
hold off; for aid=1:numel(fmds);
   pfit=polyfit(FOI(1:14),data(aid,2:15),1);
   pdata=( data(aid,2:end)-polyval(pfit, FOI) ) *pCperADC;
   plot(pdata,[ colors{aid} '-' ]); hold on;
   plot(FOSI,pdata(FOSI),[ colors{aid} '*' ]); hold on;
end
title(F,'Interpreter','none')
xlabel('Selected Frames')
ylabel('Charge Readout (pC), detrended by pre-LED linear fit')

