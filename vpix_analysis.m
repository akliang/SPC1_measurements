clear all

init_constants

cArray={'b','r','g','m','k','c','y'};

DDIR='../measurements/environment/'

figure(2)
clf
leg2Str={};
fig2idx=0;

GLs={'GL03','GL04','GL05','GL06','GL07'};

for gl=1:numel(GLs);

for mode=1%1:-1:0%1:-1:0;%0:1; 

if mode;
pol=-1; yCh=i2; Vrefmult=1; yAxis='DL current (A)';
fileArray =dir([DDIR 'test02*DL04*' GLs{gl} '*_.vcc*voltage']);
fileArray2=dir([DDIR 'test02*DL04*' GLs{gl} '*_.Vreset6*voltage']);
else
pol= 1; yCh=v2; Vrefmult=0; yAxis='DL voltage (V)';
fileArray= dir([DDIR 'test02*DL04*' GLs{gl} '*_.vcc*current']);
fileArray2=dir([DDIR 'test02*DL04*' GLs{gl} '*_.Vreset6*current']);
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
    K=findstr(fName,'DL');
    DL=fName(K+2:K+3);
    K=findstr(fName,'GL');
    GL=fName(K+2:K+3);
    K=findstr(fName,'_.');
    fType=fName(K+2:end);
    fSess=fName(1:K-1);

    % matlab ignores errors on converting the first two columns
    % data=load('-ascii',[DDIR fName]);
    % octave needs a 'clean' file:
    system([ 'cat ' DDIR fName ' | sed -e "s/^.*:/-1 /" > tmp.ascii' ]);
    data=load('-ascii','tmp.ascii');
    
    
    Vin=data(:,v3);

    newIndex=find(abs(diff(Vin))>0.3)-2;
    %newIndex=newIndex(2:end);
    [Vinsorted newIndexSorted]=sort(Vin(newIndex));
    newIndex=newIndex(newIndexSorted);
   
    Vin=Vin(newIndex);
    Sout=pol*data(newIndex,yCh);
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
     
    Vref=data(1,v2) * Vrefmult;
    %Vcc=mean(data(:,10));
    Vcc=data(1,v4);
    Vhi=data(1,v6);

    vv=@(vin) round(vin*10)+1; 
    FITPs( :, vv(Vref), vv(Vcc), vv(Vhi) )=P;
    FITPinvs( :, vv(Vref), vv(Vcc), vv(Vhi) )=Pinv;
    disp([ vv(Vref), vv(Vcc), vv(Vhi) ]);
    vpix=   @(v1,v2,v3, x) polyval(    FITPs( :, vv(v1), vv(v2), vv(v3) ), x );
    vpixinv=@(v1,v2,v3, x) polyval( FITPinvs( :, vv(v1), vv(v2), vv(v3) ), x );

    fitS=vpix( Vref, Vcc, Vhi, fitX );

    plot(Vin,Sout,['x' cArray{index}]);
    legStr{end+1}=sprintf('Vref=%2.1fV Vcc=%2.1fV  Vhi=%2.1fV    DL=%s GL=%s', Vref, Vcc, Vhi, DL, GL);
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
    K=findstr(fName,'DL');
    DL=fName(K+2:K+3);
    K=findstr(fName,'GL');
    GL=fName(K+2:K+3);
    K=findstr(fName,'_.');
    fType=fName(K+2:end);
    fSess=fName(1:K-1);

    % matlab ignores errors on converting the first two columns
    % data=load('-ascii',[DDIR fName]);
    % octave needs a 'clean' file:
    system([ 'cat ' DDIR fName ' | sed -e "s/^.*:/-1 /" > tmp.ascii' ]);
    data=load('-ascii','tmp.ascii');

    xtime=data(:,3)-data(1,3);
    Vref=data(:,v2) * Vrefmult;
    Vcc=data(:,v4);
    Vhi=data(:,v6);
    Vrst=data(:,v3);
    Vbias=data(:,v5);
    Vglobrst=data(:,v1);
    Spix=pol*data(:,yCh);
    Vpix=xtime*0;
    for id=1:numel(Vpix);
      Vpix(id)=vpixinv( Vref(id), Vcc(id), Vhi(id), Spix(id) );
    end

    Yoff=0;
    Yoff=Vrst(1);
    %Yoff=Vpix(end);
    fig2idx=fig2idx+1;
    plot(xtime,Vpix-Yoff,['-' cArray{fig2idx}]);
    leg2Str{end+1}=sprintf('Vrst=%2.2fV mode=%d   DL=%s GL=%s', Vrst(1), mode, DL, GL);
    hold on;
    %plot(xtime,Spix,['-' cArray{fig2idx}]);
    %leg2Str{end+1}=sprintf('Vrst=%2.2fV mode=%d   DL=%s GL=%s', Vrst(1), mode, DL, GL);
    xlabel('Time (s)');
    ylabel('Vpix (V)');
    ylabel('dVpix (V)');

    if (index==1) && (gl==1);
    % annotate Voltage changes
    for vid=1:5;
    if vid==1; V=Vcc ; Vname='Vcc';  end
    if vid==2; V=Vrst; Vname='Vrst'; end
    if vid==3; V=Vhi ; Vname='Vhi';  end
    if vid==4; V=Vref; Vname='Vref'; end
    if vid==5; V=Vglobrst; Vname='Vglobrst'; end
    %if vid==5; V=Vbias;Vname='Vbias';end
    VDiff=diff(V);
    idxDiff=abs(diff(V))>0.5;
    for idx=find(idxDiff)';
      text(xtime(idx),-0.4+0.02*vid+VDiff(idx)*0.02,sprintf('d%s\n%+.1fV',Vname,VDiff(idx)));
    end
    end
    end
end
    title(sprintf('%s\n%s',folderName,fName_prefix),'Interpreter','none');
    legend(leg2Str,'location','southeast');

end

end

