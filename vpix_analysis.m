clear all

init_constants

cArray={'b','r','g','m','c','k','y', 'b','r','g','m','c','k','y', 'b','r','g','m','c','k','y'};


%%{
figure(2)
clf
leg2Str={};
fig2idx=0;
fig2lbr='';

figure(3)
clf
leg3Str={};
fig3idx=0;

%figure(4)
%clf
%leg4Str={};
%fig4idx=0;
%}

%GLs={'GL03','GL04','GL05','GL06','GL07'};
%GLs={'GL11'};
%GLs={'GL11','GL12'};
%GLs={'GL11','GL12','GL13','GL14','GL15','GL16'};
%{
DataSets={
DDIR='../../2011-04-14/measurements/environment/'
'test05_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL02HI_simwork_'
'test05_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL03HI_simwork_'
'test05_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL04HI_simwork_'
'test05_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL05HI_simwork_'
'test05_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL06HI_simwork_'
'test06_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL07HI_simwork_'
'test06_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL08HI_simwork_'
'test06_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL09HI_simwork_'
};
%}
DDIR='../../2011-04-14/measurements/environment/'
DataSets={
 'test06_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL10HI_simwork_'
 'test03_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL11HI_simwork_'
%'test06_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL11HI_simwork_'
 'test03_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL12HI_simwork_'
%'test06_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL12HI_simwork_'
%'test03_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL13HI_simwork_' % To repeat - offset in calibration
 'test05_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL13HI_simwork_' % repetition does not suffer offset
 'test03_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL14HI_simwork_'
 'test03_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL15HI_simwork_'
%'test04_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL15HI_simwork_' % both are good
 'test04_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL16HI_simwork_'
 'test05_TAA-29B1-1_ch1=GlobRST_ch2=DL04_ch3=Vreset_ch4=Vcc_ch5=Vbias_ch6=GL01HI_simwork_' % different array location - look different!
};
%%{
DDIR='../measurements/environment/'
DataSets={
 'test01_TAA-29B1-1_ch1=GlobRST_ch2=DL06_ch3=Vreset_ch4=DL03_ch5=Vbias_ch6=DL11_GL13HI_simwork_'
 %'test01_TAA-29B1-1_ch1=GlobRST_ch2=DL08_ch3=Vreset_ch4=DL02_ch5=Vbias_ch6=DL10_GL13HI_simwork_' % Problem on DLpcb 02 !
 %'test01_TAA-29B1-1_ch1=GlobRST_ch2=DL02_ch3=Vreset_ch4=DL10_ch5=Vbias_ch6=DL08_GL13HI_simwork_' % DL02 still troubled!
 %'test01_TAA-29B1-1_ch1=GlobRST_ch2=DL08_ch3=Vreset_ch4=DL02_ch5=Vbias_ch6=DL10_GL13HI_simwork_' % DL02 troubled
 'test01_TAA-29B1-1_ch1=GlobRST_ch2=DL07_ch3=Vreset_ch4=DL04_ch5=Vbias_ch6=DL09_GL13HI_simwork_'
 %'test01_TAA-29B1-1_ch1=GlobRST_ch2=DL16_ch3=Vreset_ch4=DL01_ch5=Vbias_ch6=DL13_GL13HI_simwork_' % DL01 troubled
 'test01_TAA-29B1-1_ch1=GlobRST_ch2=DL15_ch3=Vreset_ch4=DL05_ch5=Vbias_ch6=DL14_GL13HI_simwork_'
 'test01_TAA-29B1-1_ch1=GlobRST_ch2=DL12_ch3=Vreset_ch4=DL13_ch5=Vbias_ch6=DL06_GL13HI_simwork_'
 %'test01_TAA-29B1-1_ch1=GlobRST_ch2=DL02_ch3=Vreset_ch4=DL10_ch5=Vbias_ch6=DL08_GL13HI_simwork_' % Problem with ref on DL02
 'test01_TAA-29B1-1_ch1=GlobRST_ch2=DL08_ch3=Vreset_ch4=DL10_ch5=Vbias_ch6=DL03_GL13HI_simwork_'
 'test01_TAA-29B1-1_ch1=GlobRST_ch2=DL16_ch3=Vreset_ch4=DL10_ch5=Vbias_ch6=DL03_GL13HI_simwork_'
};
%}
%DataSets={
% 'test02_TAA-29B1-1_ch1=GlobRST_ch2=DL16_ch3=Vreset_ch4=DL10_ch5=Vbias_ch6=DL03_GL13HI_simwork_'
%}

for dlid=2;%1:1;%:1;

%for glid=1:numel(GLs);
for glid=1:size(DataSets,1);

for mode=1%1:-1:0%1:-1:0;%0:1; 

if mode;
pol=-1; yChOffset=+1; Vrefmult=1; yAxis='DL current (A)';
%fileArray =dir([DDIR 'test03*DL04*' GLs{glid} '*_.vcc*voltage']);
%fileArray2=dir([DDIR 'test03*DL04*' GLs{glid} '*_.Vreset6*voltage']);
fileArray =dir([DDIR DataSets{glid} '.vcc*voltage']);
fileArray2=dir([DDIR DataSets{glid} '.Vreset6*voltage']);
else
pol= 1; yChOffset=+0; Vrefmult=0; yAxis='DL voltage (V)';
%fileArray= dir([DDIR 'test03*DL04*' GLs{glid} '*_.vcc*_idl-1E-7_*current']);
%fileArray2=dir([DDIR 'test03*DL04*' GLs{glid} '*_.Vreset6*-1E-7current']);
fileArray =dir([DDIR DataSets{glid} '.vcc*idl-1E-7_*currentLONG']);
fileArray2=dir([DDIR DataSets{glid} '.Vreset6*-1E-7current']);
end

folderName=pwd();
K=findstr(folderName,'MasdaX');
folderName=folderName(K:end);
legStr={};

figure(1)
clf

FITPs=[];
FITPinvs=[];

%{
Vcc	ch4	
Vbias	ch5	
Vreset	ch3
GlobRST	ch1
DLgnd	f
DLrst12	AGND
DLcap	f
SFBgnd	AGND
SFBgate	AGND
GLclamp	AGND
TFTrd12 ch6	HI
GLyy	ch6	HI 
DLxx	ch2
%}

for(index=1:length(fileArray))
    fName=fileArray(index).name;
    K=findstr(fName,'ch1=');
    fName_prefix=fName(1:K-2);
    %K=findstr(fName,'DL');
    %DL=fName(K+2:K+3);
    K=findstr(fName,'GL');
    GL=fName(K+2:K+3);
    gl=str2num(GL);
    K=findstr(fName,'_.');
    fType=fName(K+2:end);
    fSess=fName(1:K-1);
    DL={};
    
    channels=regexp(fName, '(ch([0-9])+=(DL|GL)*([0-9]+)*([^_]*))_', 'tokens');
    ch_vcc=-1;
    ch_vreset=-1;
    ch_reset=-1;
    ch_vbias=-1;
    ch_vhi=-1;
    ch_sout=[];
    %GL='xxx';
    for cid=1:length(channels);
      cnum=str2num(channels{cid}{2});
      switch lower(channels{cid}{3})
        case {'vcc'}              ch_vcc   = chan2vcol( cnum );
        case {'vreset'}           ch_vreset= chan2vcol( cnum );
        case {'reset','globrst'}  ch_reset = chan2vcol( cnum );
        case {'vbias'}            ch_vbias = chan2vcol( cnum );
        case {'dl'}               ch_sout(end+1)= chan2vcol( cnum ) + yChOffset; DL{end+1}=channels{cid}{4};
        case {'gl'}               GL=channels{cid}{4};
                                  if length(channels{cid})>=5;
                                  if strcmp(channels{cid}{5},'HI');
                                  ch_vhi   = chan2vcol( cnum );
                                  end
                                  end
	otherwise
	disp(sprintf('Unknow channel %d: "%s"', cid, channels{cid}{1} ));
      end
    end
    gl=str2num(GL);
    %return

    % matlab ignores errors on converting the first two columns
    % data=load('-ascii',[DDIR fName]);
    % octave needs a 'clean' file:
    system([ 'cat ' DDIR fName ' | sed -e "s/^.*:/-1 /" > tmp.ascii' ]);
    data=load('-ascii','tmp.ascii');
    
    %dl=str2num(DL{dlid});
    Vin=data(:,ch_vreset);

    newIndex=find(abs(diff(Vin))>0.3)-2;
    %newIndex=newIndex(2:end);
    [Vinsorted newIndexSorted]=sort(Vin(newIndex));
    newIndex=newIndex(newIndexSorted);
   
    Vin=Vin(newIndex);
    Sout=pol*data(newIndex,ch_sout(dlid));
    %Sout(Sout<0)=0;

    %vcc=data(1,10); 
    fitIndex=1:numel(Vin);
    fitMin=3.8;
    fitMax=8.2;
    fitX=fitMin:0.1:fitMax;
        fitIndex= Vin>=fitMin & Vin<=fitMax;
    %if vcc<7
    %    fitIndex=I>=10e-6&I<100e-6;
    %else
    %    fitIndex=I>=10e-6&I<500e-6;
    %end
    [P    S]=polyfit(Vin(fitIndex),Sout(fitIndex),3);
    [Pinv S]=polyfit(Sout(fitIndex),Vin(fitIndex),3);
    %fitS=polyval(P,fitX);
     
    Vref=data(1,ch_sout(dlid)-yChOffset) * Vrefmult;
    c2c=@(chan) max(chan, 1); % returns chan for valid channels, 1 otherwise
    c2f=@(chan) sign(chan+1); % returns 1 for valid channels, 0 for chan -1
    c2o=@(chan,ofs) ofs*(1-c2f(chan)); % returns offset for chan -1, zero otherwise
    Vcc=data(1,c2c(ch_vcc))*c2f(ch_vcc)+c2o(ch_vcc,8);
    %Vcc=data(1,ch_vcc);
    Vcc-data(1,1)*0 + 8;
    Vhi=data(1,c2c(ch_vhi))*c2f(ch_vhi)+c2o(ch_vhi,15);

    vv=@(vin) round(vin*10)+1; 
    FITPs( :, vv(Vref), vv(Vcc), vv(Vhi) )=P;
    FITPinvs( :, vv(Vref), vv(Vcc), vv(Vhi) )=Pinv;
    %disp([ vv(Vref), vv(Vcc), vv(Vhi) ]);
    vpix=   @(v1,v2,v3, x) polyval(    FITPs( :, vv(v1), vv(v2), vv(v3) ), x );
    vpixinv=@(v1,v2,v3, x) polyval( FITPinvs( :, vv(v1), vv(v2), vv(v3) ), x );

    fitS=vpix( Vref, Vcc, Vhi, fitX );

    plot(Vin,Sout,['x' cArray{index}]);
    legStr{end+1}=sprintf('Vref=%2.1fV Vcc=%2.1fV  Vhi=%2.1fV    DL=%s GL=%s', Vref, Vcc, Vhi, DL{dlid}, GL);
    hold on;
    %plot(fitX,fitS,[cArray{index}]);
    fitY=Sout(fitIndex);
    fitY=[0:0.01:1].*( (fitY(end)-fitY(1)) ) + fitY(1);
    plot(vpixinv(Vref, Vcc, Vhi, fitY), fitY, [cArray{index}]);
    legStr{end+1}=sprintf('             Fit coefficients: %s', sprintf(' %+.2g', P));

   
    
    xlabel('Vreset==Vpix==Vsfin (V)');
    %ylabel('Vdata (V)');  
    ylabel(yAxis);  
    %axis([0 15 0 1e-3]);
    %title(fName,'Interpreter','none','fontsize',7);
    %annotation('textbox',[0.2,0.15 0.7 0.05],'String',fName,'Interpreter','none','fontsize',7,'LineStyle','none');
    %annotation('rectangle',[.1 .1])
end
    title(sprintf('%s\n%s',folderName,fName_prefix),'Interpreter','none');
    legend(legStr,'location','northwest');
    %legend('boxoff');
%    epsFileName=['../../analysis/' fName(1:end) '.eps'];
%    print(epsFileName,'-depsc2');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% recalculate voltage at Vpix after reset is turned off
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)

for(index=1:length(fileArray2))
    fName=fileArray2(index).name;
    K=findstr(fName,'ch1=');
    fName_prefix=fName(1:K-2);
    %K=findstr(fName,'DL');
    %DL=fName(K+2:K+3);
    %K=findstr(fName,'GL');
    %GL=fName(K+2:K+3);
    K=findstr(fName,'_.');
    fType=fName(K+2:end);
    fSess=fName(1:K-1);

    pulsing=regexp(fName, '(pulsing[^_]*)_', 'tokens');


    % matlab ignores errors on converting the first two columns
    % data=load('-ascii',[DDIR fName]);
    % octave needs a 'clean' file:
    system([ 'cat ' DDIR fName ' | sed -e "s/^.*:/-1 /" > tmp.ascii' ]);
    data=load('-ascii','tmp.ascii');

    xtime=data(:,3)-data(1,3);
    Vref=data(:,ch_sout(dlid)-yChOffset) * Vrefmult;
    Vcc=data(:,c2c(ch_vcc))*c2f(ch_vcc)+c2o(ch_vcc,8);
    Vhi=data(:,c2c(ch_vhi))*c2f(ch_vhi)+c2o(ch_vhi,15);
    Vrst=data(:,ch_vreset);
    Vbias=data(:,ch_vbias);
    Vglobrst=data(:,ch_reset);
    Spix=pol*data(:,ch_sout(dlid));
    Vpix=xtime*0;
    for id=1:numel(Vpix);
      Vpix(id)=vpixinv( Vref(id), Vcc(id), Vhi(id), Spix(id) );
    end

    Yoff=0;
    Yoff=Vrst(1);
    %Yoff=Vpix(end);
    VpixP=Vpix-Yoff;
    fig2idx=fig2idx+1;
    fig2lbr=sprintf('%s\n',fig2lbr);
    figure(2);
    plot(xtime,VpixP,['-' cArray{fig2idx}]);
    %leg2Str{end+1}=sprintf('Vrst=%2.2fV mode=%d   DL=%s GL=%s', Vrst(1), mode, DL{dlid}, GL);
    leg2Str{end+1}=sprintf('Vrst=%2.2fV mode=%d  %s  DLpcb=%s GLarray=%02d', Vrst(1), mode, pulsing{1}{1}, DL{dlid}, L.GL_Array(ll(gl)) );
    hold on;
    %plot(xtime,Spix,['-' cArray{fig2idx}]);
    %leg2Str{end+1}=sprintf('Vrst=%2.2fV mode=%d   DL=%s GL=%s', Vrst(1), mode, DL{dlid}, GL);
    xlabel('Time (s)');
    ylabel('Vpix (V)');
    ylabel('dVpix (V)');

    dV=Vpix([2:end end])-Vpix([1 1:end-1]);

    ADDR_W=L.ADDR_W(ll(gl));
    ADDR_L=L.ADDR_L(ll(gl));
    SF_W=L.SF_W(ll(gl));
    SF_L=L.SF_L(ll(gl));
    if true; %(fig2idx==1) && (glid==1);
      disp(leg2Str{end});
      % annotate Voltage changes
      Peaks=[];
      Caps=[];
      for vid=1:6;
	PeakTmp=[]; DepName=''; DepVal=1;
        if vid==1; V=Vbias;Vname='Vbias';end % const (Cpd)
        if vid==2; V=Vglobrst; Vname='RESET'; end % const (TFTrst)
        if vid==3; V=Vrst; Vname='Vrst'; end % const( TFTrst)
        if vid==4; V=Vhi ; Vname='Vhi';  DepName=sprintf('ADDR %d/%d', ADDR_W, ADDR_L); DepVal=ADDR_W; end % ADDR
        if vid==5; V=Vref; Vname='Vref'; end % ADDR+SF
        if vid==6; V=Vcc ; Vname='Vcc';  DepName=sprintf(' SF  %d/%d', SF_W  , SF_L  ); DepVal=SF_W; end % SF
        VDiff=diff(V);
        idxDiff=abs(diff(V))>0.5;
        for idx=find(idxDiff)';
        if idx>25; %idx>50; 
          tx=xtime(idx);
          %ty=-0.20-0.05*vid+VDiff(idx)*0.025;
          ty=0.12-0.00*vid;%+VDiff(idx)*0.025;
    	  if (fig2idx==1) && (glid==1);
          text( tx, ty,
                sprintf('%s\n%+.1f V\n', Vname, VDiff(idx) ));
	  line( [tx tx], [ty VpixP(idx)], 'Color', [ 0.7 0.7 0.7 ] );
          end
          text( tx, ty,
                sprintf('\n%s\n%+.0f mV', fig2lbr, dV(idx)*1000 ), 'Color', cArray{fig2idx} );
        end
	if idx>70; %idx>80;
	  PeakTmp(end+1)=abs(dV(idx));
	end
        end
	if numel(PeakTmp)==0; PeakTmp=0; end
        Peaks(vid)=mean(PeakTmp);
	if vid==1;
          Cpix=1/Peaks(1);
	end
	  Caps(vid)=Peaks(vid)*Cpix;
	  disp( sprintf('\tC(%9s)  %.3f\t\t%s\t%d', Vname, Caps(vid), DepName, DepVal ) );
      end
          
	  disp( sprintf('\tC(%9s)  %.3f', '=SUM=', sum(Caps) ) );
	  disp( sprintf('\tC(%9s)  %.3f', '=Cpix=', Cpix ) );
    end

    figure(3);
    %add code for current and Cinj calculations here
    Cpd=1.5E-12; % initial guess of Cinj capacitance
    dVdt_pix=(diff(Vpix))./diff(xtime);
      span=10; 
      window=ones(span,1)/span; 
      Ipix=convn(dVdt_pix,window,'same') * Cpd;
    Imed=median(abs(Ipix));
    plot(xtime(1:end-1),Ipix,['-' cArray{fig2idx}]);
    hold on;
    xlabel('Time (s)');
    ylabel('Ipix (A)');

    %figure(4);
    %plot(xtime(1:end-0)+fig2idx,abs(dV),['-' cArray{fig2idx}]);
    %hold on;

    % maximum peak (or average of largest ones) or Vbias pulses
    % => correspond to 'unity charge injection' (one volt thru 'Cpd')
    % 1/maxpeaks yield relative capacitances of pixel types
    % fraction of 'unity peak' shows overlap capacitances
    % sum of this fractions should correspond to total capacitance
    % WANTED: visualization of capacitances (&tft props?) per pixel type
end
    figure(2);
    title(sprintf('%s\n%s',folderName,fName_prefix),'Interpreter','none');
    legend(leg2Str,'location','southeast');
    figure(3);
    title(sprintf('%s\n%s',folderName,fName_prefix),'Interpreter','none');
    legend(leg2Str,'location','southeast');
    ax=axis(); ax(3)=-Imed*4; ax(4)=+Imed*4; axis(ax);
end

end

end
