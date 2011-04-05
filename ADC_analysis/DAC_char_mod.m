clear all;
close all;

R={
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
    file1=['../../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/environment/meas_simwork_HEWLETT-PACKARD_34401A_0_7-5-2'];  
end

timestamp=R{1}(tmp(4)+1:tmp(4)+15);

fid1=fopen(file1);
C1=textscan(fid1,'%s%s%f64%s%f32%f32%f32%f32');
fclose(fid1);

V.dVADC=[C1{5} C1{6} C1{7} C1{8}];
V.dVADC_mean=mean(V.dVADC,2);
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

DDIR=[r4{1} '/'];
D=dir([MEASDIR DDIR '*.bin']);
r=struct2cell(D);
r2=r(1,:);
    for j=1:numel(r2)
        file=[MEASDIR DDIR r2{j}];
        settingFile=[file(1:numel(file)-3),'fmd'];
        fmds=read_fmd_complete(settingFile);
        MATSET = read_matsettings(settingFile);
        fmd=fmds{1};
        
        dpot=MATSET.setup.HPdp2monitor;
        dpot2chseq=MATSET.setup.Dpot2chpair;
        
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
 
       

        diff=V.timeStamp-fmd.ffpt*1e-3;
        samples=5;
        I = find(diff<0,samples,'last');
         
        if perchannel==true
                for l=1:16
                    dataMeanFilterch(j,l)=mean2(dataImage_mean((l-1)*16+1:(l-1)*16+16,:));
                end
        end
            
           
            datadVADC_mean(j)=mean2(V.dVADC(I:I+samples-1,:));
            DACvalmat(j,:)=MATSET.multi.DAC;
           
                                 
    end
    
colors={'-*r','-sg','-ob','-*k','-dm','-py','-hr','-^g'};

dpot=MATSET.setup.HPdp2monitor;
dpot2chseq=MATSET.setup.Dpot2chpair;
chp=setup.Dpot2chpair(((dpot-1)*2+1):((dpot-1)*2+2));

    for potnum=dpot
            figure(a);
            ch=chp(1);
            V1{potnum}=(dataMeanFilterch(:,ch)-Channel_det{ch}.offset)*Channel_det{ch}.VperADC;
            plot(DACvalmat(:,potnum),V1{potnum},'*r');
            hold on;
            p1{potnum}=polyfit(DACvalmat(:,potnum),V1{potnum},1);
            f1{potnum}=polyval(p1{potnum},DACvalmat(:,potnum));
            Dpot{potnum}.VperDAC =(f1{potnum}(end)-f1{potnum}(1))/(DACvalmat(end,potnum)-DACvalmat(1,potnum));
            Dpot{potnum}.offset=polyval(p1{potnum},0);   
            plot(DACvalmat(:,potnum),f1{potnum},'og');
            xlabel('DAC','fontsize',15,'fontweight','bold');
            ylabel('Volts ','fontsize',15,'fontweight','bold');
            title(sprintf('Digipot # %d',potnum));
            arrowstr=sprintf('%0.2f V/DAC',Dpot{potnum}.VperDAC);
            annotation('textarrow',x,y,'String',arrowstr,'FontSize',14);
            a=a+1;
    end
  
      figure(a)
      plot(DACvalmat(:,dpot),V1{dpot},'*r');
      hold on;
      plot(DACvalmat(:,dpot),datadVADC_mean,'og');
      title(sprintf('Digipot # %d',10));
      xlabel('DAC','fontsize',15,'fontweight','bold');
      ylabel('Volts ','fontsize',15,'fontweight','bold');
    
       filenamestr1=['../../../ADCchar_results/' timestamp '_'  MATSET.setup.PF_analogCard];
       
       save(filenamestr1, 'Dpot');
    
     
   
    
   