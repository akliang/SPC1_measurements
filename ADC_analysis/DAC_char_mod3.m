clear all;
close all;

R={
    
'MasdaX	2010-12-22	measurements	PSI-1_DACCHAR	20101222T152602_DACCHARdpot_1_2'
'MasdaX	2010-12-22	measurements	PSI-1_DACCHAR	20101222T160115_DACCHARdpot_7_8'
'MasdaX	2010-12-22	measurements	PSI-1_DACCHAR	20101222T162112_DACCHARdpot_9_10'
'MasdaX	2010-12-22	measurements	PSI-1_DACCHAR	20101222T153900_DACCHARdpot_3_4'
'MasdaX	2010-12-22	measurements	PSI-1_DACCHAR	20101222T154949_DACCHARdpot_5_6'

%'MasdaX	2010-12-21	measurements	PSI-1_DACCHAR	20101221T154308_DACCHARCh_1_2'
%'MasdaX	2010-12-21	measurements	PSI-1_DACCHAR	20101221T150018_DACCHARCh_1_2'    
%'MasdaX	2010-12-21	measurements	PSI-1_DACCHAR	20101221T143419_DACCHARCh_1_2'
    
%'MasdaX	2010-12-21	measurements	PSI-1_DACCHAR	20101221T112250_DACCHARCh_1_2'

% 'MasdaX	2010-12-17	measurements	PSI-1_DACCHAR	20101217T170358_DACCHARCh_1_2'
% 'MasdaX	2010-12-17	measurements	PSI-1_DACCHAR	20101217T172245_DACCHARCh_3_4'
% 'MasdaX	2010-12-17	measurements	PSI-1_DACCHAR	20101217T174936_DACCHARCh_5_6'
% 'MasdaX	2010-12-17	measurements	PSI-1_DACCHAR	20101217T180824_DACCHARCh_7_8'
% 'MasdaX	2010-12-17	measurements	PSI-1_DACCHAR	20101217T182725_DACCHARCh_9_10'

% 'MasdaX	2010-12-13	measurements	PSI-1_DACCHAR	20101213T141912_DACCHARCh_1_2'
% 'MasdaX	2010-12-13	measurements	PSI-1_DACCHAR	20101213T150948_DACCHARCh_3_4'
% 'MasdaX	2010-12-13	measurements	PSI-1_DACCHAR	20101213T153341_DACCHARCh_5_6'
% 'MasdaX	2010-12-13	measurements	PSI-1_DACCHAR	20101213T160202_DACCHARCh_7_8'
% 'MasdaX	2010-12-13	measurements	PSI-1_DACCHAR	20101213T162329_DACCHARCh_9_10'
%     
%'MasdaX	2010-11-19	measurements	PSI-1_DACCHAR	20101119T173905_DACCHAR'

% 'MasdaX	2010-10-29	measurements	PSI-1_DACCHAR	20101029T164653_DACCHAR'
% 'MasdaX	2010-10-29	measurements	PSI-1_DACCHAR	20101029T170213_DACCHAR'
% 'MasdaX	2010-10-29	measurements	PSI-1_DACCHAR	20101029T171059_DACCHAR'
% 'MasdaX	2010-10-29	measurements	PSI-1_DACCHAR	20101029T171802_DACCHAR'
% 'MasdaX	2010-10-29	measurements	PSI-1_DACCHAR	20101029T172626_DACCHAR'
% 'MasdaX	2010-10-29	measurements	PSI-1_DACCHAR	20101029T173919_DACCHAR'
% 'MasdaX	2010-10-29	measurements	PSI-1_DACCHAR	20101029T174834_DACCHAR'
% 'MasdaX	2010-10-29	measurements	PSI-1_DACCHAR	20101029T175742_DACCHAR'
% 'MasdaX	2010-10-29	measurements	PSI-1_DACCHAR	20101029T180630_DACCHAR'
% 'MasdaX	2010-10-29	measurements	PSI-1_DACCHAR	20101029T181424_DACCHAR'
%     
%Dpot 1 to 10 in order 1 - first(earlier timestamp)    

% 'MasdaX	2010-10-22	measurements	PSI-1_DACCHAR	20101022T104646_DACCHAR' %
% 'MasdaX	2010-10-22	measurements	PSI-1_DACCHAR	20101022T105751_DACCHAR'
% 'MasdaX	2010-10-22	measurements	PSI-1_DACCHAR	20101022T110713_DACCHAR'
% 'MasdaX	2010-10-22	measurements	PSI-1_DACCHAR	20101022T112102_DACCHAR'
% 'MasdaX	2010-10-22	measurements	PSI-1_DACCHAR	20101022T112813_DACCHAR'
% 'MasdaX	2010-10-22	measurements	PSI-1_DACCHAR	20101022T113603_DACCHAR'
% 'MasdaX	2010-10-22	measurements	PSI-1_DACCHAR	20101022T114839_DACCHAR'
% 'MasdaX	2010-10-22	measurements	PSI-1_DACCHAR	20101022T115540_DACCHAR'
% 'MasdaX	2010-10-22	measurements	PSI-1_DACCHAR	20101022T120259_DACCHAR'
% 'MasdaX	2010-10-22	measurements	PSI-1_DACCHAR	20101022T121000_DACCHAR'

%    'MasdaX	2010-08-12	measurements	PSI-1_DACCHAR	20100812T102844_DACCHAR'
%    'MasdaX	2010-08-11	measurements	PSI-1_DACCHAR	20100811T105833_DACCHAR'
%'MasdaX	2010-08-10	measurements	PSI-1_DACCHAR	20100810T162506_DACCHAR'
};

for ind_R=1:numel(R)
    curr_R=R{ind_R};
    tmp=regexp(R{ind_R},'\t'); 
    r4{ind_R}=curr_R(tmp(end)+1:end);
    MEASDIR=['../../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/' curr_R(tmp(3)+1:tmp(4)-1) '/'];
    %file1=['../../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/environment/meas_simwork_HEWLETT-PACKARD_34401A_0_7-5-2']; 
    file1=['../../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/environment/meas_simwork_Keithley_Instruments_Inc.__Model_2636A__1299494__2.1.6']; 
end


timestamp=R{1}(tmp(4)+1:tmp(4)+15);

fid1=fopen(file1);
%C1=textscan(fid1,'%s%s%f64%s%f32%f32%f32%f32');
C1=textscan(fid1,'%s%s%f64%s%f32%f32%s%f32%f32');
fclose(fid1);


%Extracting V,I for channel A and B

%V.dVADC=[C1{5} C1{6} C1{7} C1{8}];
%V.dVADC_mean=mean(V.dVADC,2);
V.dV1ADC_mean=C1{5};
V.dV2ADC_mean=C1{6};
V.I1ADC_mean=C1{8};
V.I2ADC_mean=C1{9};
V.timeStamp=C1{3};


if(exist('../../../DACchar_results','dir')~=7)
         mkdir('../../../DACchar_results' );
end

tmp=findstr(MEASDIR,'/');
titleArray=MEASDIR(tmp(end-1)+1:end-1);
tmp=findstr(titleArray,'_');
titleArray=[titleArray(1:tmp-1) ' ' titleArray(tmp+1:end)];
titleArray2=[titleArray sprintf('\n All channels');];

perchannel=true; 
dataImage=[];  dataImage_mean=[];  dataMeanFilter={}; datadVADC={};    

% i - measurement index
for i=1:numel(r4)
    DDIR=[r4{i} '/'];
    D=dir([MEASDIR DDIR '*.bin']);
    r=struct2cell(D);
    r2=r(1,:);
    
    
    k1=0;k2=0;k3=0;
    for j=1:numel(r2)
        currind=findstr(r2{j},'_');
        
        curr = str2double(r2{j}(currind(end)+1:end-6));
        
        %k- index for categorizing currents
        %k1- index for -1mA category readings %k2 - 0mA , %k3 - 1mA
        %kk - common variable to avoid redundant code
        
        %classify according to current 
        switch curr 
            case -1 
                k=1;
                k1=k1+1;
                kk=k1;
            case 0
                k=2;
                k2=k2+1;
                kk=k2;
            case 1
                k=3;
                k3=k3+1;
                kk=k3;
        end
        
        
        %Read fmd file
        file=[MEASDIR DDIR r2{j}];
        settingFile=[file(1:numel(file)-3),'fmd'];
        fmds=read_fmd_complete(settingFile);
        MATSET = read_matsettings(settingFile);
        fmd=fmds{1};
      
      
        
        image_length=fmd.dataLength;
        image_width=fmd.dataWidth;
        image_size=image_length*image_width;
       
        dataFile=fopen(file);
        fseek(dataFile,0,'eof');
        flen=ftell(dataFile);
        fnum = flen/(image_size*2);
               
        Totalframes=fnum;
        frm_numused=20;
        fseek(dataFile,image_size*2*(Totalframes-frm_numused),'bof');
        
        
        %Extract last 20 frames 
        dataImage1=fread(dataFile,[image_width,image_length]*frm_numused,'ushort','b');
        dataImage1=reshape(dataImage1,image_width,image_length,frm_numused);
         
        
        %---Find out which adc cards were connected during this acquisition
        
        g3=MATSET.setup.G3_system;        
        adcconn=MATSET.setup.ADCconnected;
        adctemp=MATSET.setup.G3_adcCards;
        adccards={};
        while(~isempty(adctemp))
            [t adctemp]=strtok(adctemp,'-');
            if(strcmp(t,'00'))
                continue;
            end
            adccards={adccards{:},t};
        end

        numofadccards=numel(adccards);
        adccards{2}='na';
        numofadccards=2;

        %---Take the image data of the ADC card used for the DAC testing
        %purpose alone
        
        step=image_width/numofadccards;
        i1=1;
        for i2=numofadccards:-1:1
            if (strcmp(MATSET.setup.ADCconnected,adccards{i2}))
                dataImage=dataImage1((step*(i1-1)+1):(step*(i1-1)+step),:,:);       
            end
            i1=i1+1;
        end

        dataImage_mean = mean(dataImage,3);
        fclose(dataFile);
 
       
        %Selecting last 5 samples
        diff=V.timeStamp-fmd.ffpt*1e-3;
        samples=5;
        I = find(diff<0,samples,'last');
        
        %Calculate the ADC value mean for each channel
        if perchannel==true
                for l=1:16
                    dataMeanFilterch{k}(kk,i,l)=mean2(dataImage_mean((l-1)*16+1:(l-1)*16+16,:));
                end
        end
            
           
            
            %Extracting V1,I1(channel A)
            datadV1ADC_mean{k}(kk,i)=mean2(V.dV1ADC_mean(I:I+samples-1));
            dataI1ADC_mean{k}(kk,i)=mean2(V.I1ADC_mean(I:I+samples-1));
            datadV1ADC_std{k}(kk,i)=std2(V.dV1ADC_mean(I:I+samples-1));
            
            %dpot connected to channel A
            dpot1(i)=MATSET.setup.HPdp2monitor(1);
            
            %DAC value of the Dpot connected
            DACvalmat1{k}(kk,i)=MATSET.multi.DAC(dpot1(i));
            
            datadV2ADC_mean{k}(kk,i)=mean2(V.dV2ADC_mean(I:I+samples-1));
            dataI2ADC_mean{k}(kk,i)=mean2(V.I2ADC_mean(I:I+samples-1));
            datadV2ADC_std{k}(kk,i)=std2(V.dV2ADC_mean(I:I+samples-1));
            
            %dpot connected to channel A
            dpot2(i)=MATSET.setup.HPdp2monitor(2);
            
            %DAC value of the Dpot connected
            DACvalmat2{k}(kk,i)=MATSET.multi.DAC(dpot2(i));  
            
            %tot - total number of measurements per current setting
            tot=kk;
                                 
    end
     
end
colors={'-*r','-sg','-ob','-*k','-dm','-py','-hr','-^g'};

%dpot2chseq=MATSET.setup.Dpottoch;
dpot2chpair = MATSET.setup.Dpottochpair;

x = [0.7698 0.5851];
y = [0.3593 0.5492];
  


%ADC characterization
ind=0;

    for k=1:numel(r4)%numel(dpot2chseq)
        
        %Obtaining the Dpot to channel mapping for the 2 Dpots connected to
        %Channel A and B
        sel_chs1=dpot2chpair(2*dpot1(k)-1:2*dpot1(k));
        sel_chs2=dpot2chpair(2*dpot2(k)-1:2*dpot2(k));
        
        for in=1:2
            ch1=sel_chs1(in); 
            ch2=sel_chs2(in);
            if(ch1~=0) %If 0 its not connected to a channel (Note : sel_chs1(2) can be 0  or a channel)
                ind=ind+1;
                ch=ch1;
                figure(ind);
                
                %throwing out 'range'  number of elements from the first
                %and the last
                range=1;
                
                %plotting V versus ADC and linearizing using polyfit
                plot(datadV1ADC_mean{2}(:,k), dataMeanFilterch{2}(:,k,ch), 'r*');   
                hold on;
                p{ch}=polyfit(datadV1ADC_mean{2}(range:end-range,k),dataMeanFilterch{2}(range:end-range,k,ch),1);
                f{ch}=polyval(p{ch},datadV1ADC_mean{2}(:,k));
                
                %Calculating V/ADC and the offset
                Channel_det{ch}.offset=polyval(p{ch},0);
                Channel_det{ch}.VperADC= (datadV1ADC_mean{2}(end-range,k)-datadV1ADC_mean{2}(range,k))/(f{ch}(end-range)-f{ch}(range));  
                
                plot(datadV1ADC_mean{2}(:,k),f{ch},'g');
                title(sprintf('Channel # %d',ch));
                arrowstr=sprintf('%0.2f uV/ADC',Channel_det{ch}.VperADC*1e6);
                annotation('textarrow',x,y,'String',arrowstr,'FontSize',14);
                xlabel('Volts'); ylabel('ADC');
                hold off;
                
                %Saving all the points (x,y) for future reference
                Channel_det{ch}.xval_dV=datadV1ADC_mean{2}(:,i);
                Channel_det{ch}.yval_ADC=dataMeanFilterch{2}(:,i,ch);
            end
            
            if(ch2~=0) %If 0 its not connected to a channel (Note : sel_chs2(2) can be 0  or a channel)
                ch=ch2;
                ind=ind+1;
                figure(ind);
                
                %throwing out 'range'  number of elements from the first
                %and the last
                range=1;
                
                %plotting V versus ADC and linearizing using polyfit
                plot(datadV2ADC_mean{2}(:,k), dataMeanFilterch{2}(:,k,ch),'r*');   
                hold on;
                p{ch}=polyfit(datadV2ADC_mean{2}(range:end-range,k),dataMeanFilterch{2}(range:end-range,k,ch),1);
                f{ch}=polyval(p{ch},datadV2ADC_mean{2}(:,k));
                
                %Calculating V/ADC and the offset
                Channel_det{ch}.offset=polyval(p{ch},0);
                Channel_det{ch}.VperADC= (datadV2ADC_mean{2}(end-range,k)-datadV2ADC_mean{2}(range,k))/(f{ch}(end-range)-f{ch}(range)); 
                
                plot(datadV2ADC_mean{2}(:,k),f{ch},'g');
                title(sprintf('Channel # %d',ch));
                xlabel('Volts'); ylabel('ADC');
                arrowstr=sprintf('%0.2f uV/ADC',Channel_det{ch}.VperADC*1e6);
                annotation('textarrow',x,y,'String',arrowstr,'FontSize',14);
                hold off;
                
                %Saving all the points (x,y) for future reference
                Channel_det{ch}.xval_dV=datadV2ADC_mean{2}(:,i);
                Channel_det{ch}.yval_ADC=dataMeanFilterch{2}(:,i,ch);
                
            end 
        end
    end
    

    %Saving the ADC characterization 

%   filenamestr1=['../../../ADCchar_results/' timestamp '_' adcconn];
%  
%       
%   save (filenamestr1 , 'Channel_det');
    
    
%DAC characterization 

    range=0;
    
    for k=1:numel(dpot1)
    
    %Dpot connected to channel A
    potnum=dpot1(k);
    figure(k+16);
    
    %Plotting the DAC value set to that Dpot versus its voltage reading
    %obtained from the smu
    plot(DACvalmat1{2}(:,k),datadV1ADC_mean{2}(:,k),'*r'); hold on;
    
    %Finding a linear fit
    p1{potnum}=polyfit(DACvalmat1{2}(range+1:end-range,k),datadV1ADC_mean{2}(range+1:end-range,k),1);
    f1{potnum}=polyval(p1{potnum},DACvalmat1{2}(:,k));
    
    %Calculating V/DAC and offset for the Dpot
    Dpot{potnum}.VperDAC =(f1{potnum}(end-range)-f1{potnum}(range+1))/(DACvalmat1{2}(end-range,k)-DACvalmat1{2}(range+1,k));
    Dpot{potnum}.offset=polyval(p1{potnum},0);
    
    plot(DACvalmat1{2}(:,k),f1{potnum},'g');
    xlabel('DAC','fontsize',15,'fontweight','bold');
    ylabel('Volts ','fontsize',15,'fontweight','bold');
    title(sprintf('Digipot # %d',potnum));
    arrowstr=sprintf('%0.2f V/DAC',Dpot{potnum}.VperDAC);
    annotation('textarrow',x,y,'String',arrowstr,'FontSize',14);
    end
     
for k=1:numel(dpot2)
    
    %Dpot connected to channel A
    potnum=dpot2(k);
    figure(k+21);
    
    %Plotting the DAC value set to that Dpot versus its voltage reading
    %obtained from the smu
    plot(DACvalmat2{2}(:,k),datadV2ADC_mean{2}(:,k),'*r'); hold on;
    
    %Finding a linear fit
    p1{potnum}=polyfit(DACvalmat2{2}(range+1:end-range,k),datadV2ADC_mean{2}(range+1:end-range,k),1);
    f1{potnum}=polyval(p1{potnum},DACvalmat2{2}(:,k));
    
    %Calculating V/DAC and offset for the Dpot
    Dpot{potnum}.VperDAC =(f1{potnum}(end-range)-f1{potnum}(range+1))/(DACvalmat2{2}(end-range,k)-DACvalmat2{2}(range+1,k));
    Dpot{potnum}.offset=polyval(p1{potnum},0);   
    
    plot(DACvalmat2{2}(:,k),f1{potnum},'g');
    xlabel('DAC','fontsize',15,'fontweight','bold');
    ylabel('Volts ','fontsize',15,'fontweight','bold');
    title(sprintf('Digipot # %d',potnum));
    arrowstr=sprintf('%0.2f V/DAC',Dpot{potnum}.VperDAC);
    annotation('textarrow',x,y,'String',arrowstr,'FontSize',14);
end

 
%Saving the Dpot characterization in a file

% filenamestr2=['../../../DACchar_results/' timestamp '_' MATSET.setup.Dpotconn];
%        
% save(filenamestr2, 'Dpot');



k1=0; %k1 - number of current readings available, typically 6
I={};
for k=1:numel(dpot1)
    
   %Obtain the dpot to channel mapping for dpot1 and dpot2 
   sel_chs1=dpot2chpair(2*dpot1(k)-1:2*dpot1(k));
   sel_chs2=dpot2chpair(2*dpot2(k)-1:2*dpot2(k));
             
            %If dpot1 was one of the 6 channels where cuurent could be
            %measured calculate the following (Note : sel_chs1(2) = 0 if its not connected at its other
            %end to a channel)
            if(sel_chs1(2)~=0)
                k1=k1+1;
                ch1=sel_chs1(1);
                ch2=sel_chs1(2);
                seldpot(k1)=dpot1(k);
                
                %for all the measurements (tot - number of measurements per
                %current setting)
                for kk=1:tot
                    
                    %for all the currents (p-current)
                    for p=1:3
                        %V1 , V2 - Voltage on either side of the resistor
                        V1{k1}(kk,p)=(dataMeanFilterch{p}(kk,k,ch1)-Channel_det{ch1}.offset)*Channel_det{ch1}.VperADC;
                        V2{k1}(kk,p)=(dataMeanFilterch{p}(kk,k,ch2)-Channel_det{ch2}.offset)*Channel_det{ch2}.VperADC;
                        
                        %difference between the two voltages (Voltage across the resistor)
                        Vdiff{k1}(kk,p) = V1{k1}(kk,p) -V2{k1}(kk,p);
                        
                        %Current through the resistor
                        I{k1}(kk,p) =   dataI1ADC_mean{p}(kk,k);
                    end
                end
            end
            
            %If dpot2 was one of the 6 channels where cuurent could be
            %measured calculate the following (Note : sel_chs1(2) = 0 if its not connected at its other
            %end to a channel)
            if(sel_chs2(2)~=0)
                k1=k1+1;
                ch1=sel_chs2(1);
                ch2=sel_chs2(2);
                seldpot(k1)=dpot2(k);
                
                %for all the measurements (tot - number of measurements per
                %current setting)
                for kk=1:tot
                    
                    %for all the currents (p-current)
                    for p=1:3
                         %V1 , V2 - Voltage on either side of the resistor
                        V1{k1}(kk,p)=(dataMeanFilterch{p}(kk,k,ch1)-Channel_det{ch1}.offset)*Channel_det{ch1}.VperADC;
                        V2{k1}(kk,p)=(dataMeanFilterch{p}(kk,k,ch2)-Channel_det{ch2}.offset)*Channel_det{ch2}.VperADC;
                        
                         %difference between the two voltages (Voltage across the resistor)
                        Vdiff{k1}(kk,p) = V1{k1}(kk,p) -V2{k1}(kk,p);
                        
                        %Current through the resistor
                        I{k1}(kk,p) =   dataI2ADC_mean{p}(kk,k);
                    end
                end
            end
end
   

%for each measurement setting , calculating the resistance (3 current
%values 3 voltage readings , linear fit)
for ind=1:k1
    for kk=1:tot
        VV=Vdiff{ind}(kk,1:3);
        II= I{ind}(kk,1:3);
        Rfit{ind}(kk,:)=polyfit(II,VV,1);
        Rval{ind}(kk,:)=polyval(Rfit{ind}(kk,:),II);
        RR(ind,kk) =(Rval{ind}(kk,end)-Rval{ind}(kk,1))/(II(end)-II(1));
    end
end

seldpot
%Averaging over resistance obtained for different measurements
AvgR=abs(mean(RR,2))'
        

    

%Custom plot - Manual mode
figure;
k1=1; %Index of seldpot which has the dpot under consideration
colors1={'-*r','-*g','-*b'};
colors2={'-or','-og','-ob'};
filnr=1; %Index of dpot in R cell array (filename)

for p=1:3 %currents
    %Vdac - Voltage corresponding to DAC setting (using DAC
    %characterization)
    Vdac=(DACvalmat2{p}(:,filnr))*Dpot{dpot2(1)}.VperDAC + Dpot{dpot2(1)}.offset; %change Dpot{---} where --- depends on seldpot, select corresponding  dpot1/dpot2 index
    
    %voltage at the two ends of the resistors minus Vdac
    plot(Vdac, V1{k1}(:,p)-Vdac,colors1{p});hold on;
    plot(Vdac, V2{k1}(:,p)-Vdac,colors2{p});
end
      