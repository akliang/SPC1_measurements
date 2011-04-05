clear all;
close all;

addpath([pwd '/ADC_analysis']);

R={
    %'MasdaX	2010-07-29	measurements	PSI-1_ADCCHAR	20100729T144340_ADCCHAR'
    %'MasdaX	2010-07-29	measurements	PSI-1_ADCCHAR	20100729T111901_ADCCHAR'    
    'MasdaX	2010-07-28	measurements	PSI-1_ADCCHAR	20100728T132939_ADCCHAR'    

%    'MasdaX	2010-07-30	measurements	PSI-1_ADCCHAR	20100730T143313_ADCCHAR'
%'MasdaX	2010-07-29	measurements	PSI-1_ADCCHAR	20100729T144340_ADCCHAR'
};


for ind_R=1:numel(R)
    curr_R=R{ind_R};
    tmp=regexp(R{ind_R},'\t'); 
    r4{ind_R}=curr_R(tmp(end)+1:end);
    MEASDIR=['../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/' curr_R(tmp(3)+1:tmp(4)-1) '/'];
    file1=['../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/environment/measADC_Pion_BK_9130_005004156568001055_V1.69'];
    file2=['../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/environment/meas_Pion_HEWLETT-PACKARD_34401A_0_7-5-2'];
end

timestamp=R{1}(tmp(4)+1:tmp(4)+15);
V={};  I={};

fid1=fopen(file1);
C1=textscan(fid1,'%s%s%f64%s%f32%f32%f32%s%f32%f32%f32');
fclose(fid1);

    V.Vminus=C1{5}; 
    V.VdV=C1{6};
    I1.Vminus=C1{9};
    I1.VdV=C1{10};
    V.timeStamp=C1{3};

fid2=fopen(file2);
C2=textscan(fid2,'%s%s%f64%s%f32%f32%f32%f32');
fclose(fid2);

    V.dVADC=[C2{5} C2{6} C2{7} C2{8}];
    V.dVADC_mean=mean(V.dVADC,2);
    V.timeStamp2=C2{3};

    
    for i=1:numel(r4)
    DDIR=[r4{i} '/'];
    D=dir([MEASDIR DDIR '*.bin']);
    r=struct2cell(D);
    r2=r(1,:);
    j1=0;j2=1;j3=1;j4=1;j5=1;
        for j=1:numel(r2)
            file=[MEASDIR DDIR r2{j}];
            settingFile=[file(1:numel(file)-3),'fmd'];
            fmds=read_fmd_complete(settingFile);
            MATSET = read_matsettings(settingFile);
            fmd=fmds{1};
            tmp=findstr(settingFile,'/');
            A=settingFile(tmp(end)+1:end);
            [Voltsperch_cards,adccards]=meas_adctovolts(A,[30,50]);
        
        display('Requested dV');    
        MATSET.multi.VADCdV
        for ind=1:size(Voltsperch_cards,1)
            display(sprintf('\nCard1   %s  :',adccards{ind}));
            for ch=1:size(Voltsperch_cards,2)
                display(sprintf('Channel %d \t %f V',ch,Voltsperch_cards{ind,ch}));
            end
        end
        pause;  
        
        
    end
        end
    