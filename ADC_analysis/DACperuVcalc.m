clear all;
close all;

addpath('../');
R={ 
'MasdaX	2010-10-01	measurements	PSI-1_DACCHAR	20101001T165305_DACCHAR'
'MasdaX	2010-10-01	measurements	PSI-1_DACCHAR	20101001T165623_DACCHAR'
'MasdaX	2010-10-01	measurements	PSI-1_DACCHAR	20101001T170037_DACCHAR'
'MasdaX	2010-10-01	measurements	PSI-1_DACCHAR	20101001T170305_DACCHAR'
'MasdaX	2010-10-01	measurements	PSI-1_DACCHAR	20101001T170551_DACCHAR'
'MasdaX	2010-10-01	measurements	PSI-1_DACCHAR	20101001T170838_DACCHAR'
'MasdaX	2010-10-01	measurements	PSI-1_DACCHAR	20101001T171103_DACCHAR'
'MasdaX	2010-10-01	measurements	PSI-1_DACCHAR	20101001T171304_DACCHAR'
'MasdaX	2010-10-01	measurements	PSI-1_DACCHAR	20101001T171508_DACCHAR'
'MasdaX	2010-10-01	measurements	PSI-1_DACCHAR	20101001T171741_DACCHAR'

% 'MasdaX	2010-09-30	measurements	PSI-1_DACCHAR	20100930T172243_DACCHAR'
% 'MasdaX	2010-09-30	measurements	PSI-1_DACCHAR	20100930T172622_DACCHAR'
% 'MasdaX	2010-09-30	measurements	PSI-1_DACCHAR	20100930T172918_DACCHAR'
% 'MasdaX	2010-09-30	measurements	PSI-1_DACCHAR	20100930T173133_DACCHAR'
% 'MasdaX	2010-09-30	measurements	PSI-1_DACCHAR	20100930T173543_DACCHAR'
% 'MasdaX	2010-09-30	measurements	PSI-1_DACCHAR	20100930T173746_DACCHAR'
% 'MasdaX	2010-09-30	measurements	PSI-1_DACCHAR	20100930T174156_DACCHAR'
% 'MasdaX	2010-09-30	measurements	PSI-1_DACCHAR	20100930T174409_DACCHAR'
% 'MasdaX	2010-09-30	measurements	PSI-1_DACCHAR	20100930T174628_DACCHAR'
% 'MasdaX	2010-09-30	measurements	PSI-1_DACCHAR	20100930T175226_DACCHAR'

};


for ind_R=1:numel(R)
    curr_R=R{ind_R};
    tmp=regexp(R{ind_R},'\t'); 
    r4{ind_R}=curr_R(tmp(end)+1:end);
    MEASDIR=['../../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/' curr_R(tmp(3)+1:tmp(4)-1) '/'];
    file1=['../../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/environment/meas_simwork_HEWLETT-PACKARD_34401A_0_7-5-2'];  
end

timestamp=R{1}(tmp(4)+1:tmp(4)+15);

fid1=fopen(file1);
C1=textscan(fid1,'%s%s%f64%s%f32%f32%f32%f32');
fclose(fid1);

    V.dVADC=[C1{5} C1{6} C1{7} C1{8}];
    V.dVADC_mean=mean(V.dVADC,2);
    V.timeStamp=C1{3};

if(exist('../../../ADCchar_results','dir')~=7)
         mkdir('../../../ADCchar_results' );
end

tmp=findstr(MEASDIR,'/');
titleArray=MEASDIR(tmp(end-1)+1:end-1);
tmp=findstr(titleArray,'_');
titleArray1=[titleArray sprintf('\n All channels');];


for i=1:numel(r4)
    DDIR=[r4{i} '/'];
    D=dir([MEASDIR DDIR '*.mat']);
    r=struct2cell(D);
    r2=r(1,:);
    for j=1:numel(r2)
        matfile=[MEASDIR DDIR r2{j}];
        load (matfile);
        MATSET.multi =multi; 
        MATSET.setup=setup;
        MATSET.meas=meas;
        diff=V.timeStamp-str2num(MATSET.meas.dpotlasttime);
        samples=5;
        I = find(diff<0,samples,'last');
        
            datadVADC_mean(j,i)=mean2(V.dVADC(I:I+samples-1,:));
            datadVADC_std(j,i)=std2(V.dVADC(I:I+samples-1,:));
            dpot(i)=MATSET.setup.HPdp2monitor;
            DACvalmat(j,i)=MATSET.multi.DAC(dpot(i));  
    end
     
end


x = [0.7698 0.5851];
y = [0.3593 0.5492];

for k=1:numel(dpot)
    potnum=dpot(k);
    figure(k);
    plot(DACvalmat(:,k),datadVADC_mean(:,k)); 
    p1{potnum}=polyfit(DACvalmat(:,k),datadVADC_mean(:,k),1);
    f1{potnum}=polyval(p1{potnum},DACvalmat(:,k));
    Dpot{potnum}.VperDAC =(f1{potnum}(end)-f1{potnum}(1))/(DACvalmat(end,k)-DACvalmat(1,k));
    Dpot{potnum}.offset=polyval(p1{potnum},0);   
    plot(DACvalmat(:,k),f1{potnum},'og');
    xlabel('DAC','fontsize',15,'fontweight','bold');
    ylabel('Volts ','fontsize',15,'fontweight','bold');
    title(sprintf('Digipot # %d',potnum));
    arrowstr=sprintf('%0.2f V/DAC',Dpot{potnum}.VperDAC);
    annotation('textarrow',x,y,'String',arrowstr,'FontSize',14);
end

if(exist('../../../DACchar_results','dir')~=7)
         mkdir('../../../DACchar_results' );
end

filenamestr=['../../../DACchar_results/' timestamp '_'  MATSET.setup.Dpotconn '.mat'];
save(filenamestr,'Dpot');


