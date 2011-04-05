clear all;
close all;

createhtm=0; % 1 -creates html result file 0- does not
casenum=2; % select case number you want to plot (case 1: Vref=Vminus, case 2 : Vref=Vminus +VdV) 
channel=1;%Select channel

R={
    %'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T154531_ADCCHAR_ADCch10_1'
%'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T154622_ADCCHAR_ADCch10_2'
'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T154653_ADCCHAR_ADCch10_3'
%'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T151748_ADCCHAR_ADCch07_1'  
%'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T151215_ADCCHAR_ADCch07_1'
%'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T151254_ADCCHAR_ADCch07_2'
%'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T151326_ADCCHAR_ADCch07_3'
%'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T142913_ADCCHAR_ADCch11_1'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T142956_ADCCHAR_ADCch11_2'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T143027_ADCCHAR_ADCch11_3'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T143153_ADCCHAR_ADCch01_1'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T143229_ADCCHAR_ADCch01_2'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T143256_ADCCHAR_ADCch01_3'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T143403_ADCCHAR_ADCch05_1'
%'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T143437_ADCCHAR_ADCch05_2'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T143516_ADCCHAR_ADCch05_3'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T143633_ADCCHAR_ADCch15_1'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T143710_ADCCHAR_ADCch15_2'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T143741_ADCCHAR_ADCch15_3'  
%'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T140303_ADCCHAR_ADCch07_1'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T140405_ADCCHAR_ADCch07_2'
%'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T140436_ADCCHAR_ADCch07_3'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T140702_ADCCHAR_ADCch04_1'
%'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T140821_ADCCHAR_ADCch04_2'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T140857_ADCCHAR_ADCch04_3'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T141024_ADCCHAR_ADCch02_1'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T141113_ADCCHAR_ADCch02_2'
% 'MasdaX	2010-08-13	measurements	PSI-1_ADCCHAR	20100813T141149_ADCCHAR_ADCch02_3'
%'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T180700_ADCCHAR_ADCch11_1'
% 'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T180739_ADCCHAR_ADCch11_2'
% 'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T180820_ADCCHAR_ADCch11_3'
% 'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T181007_ADCCHAR_ADCch01_1'
% 'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T181047_ADCCHAR_ADCch01_2'
% 'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T181121_ADCCHAR_ADCch01_3'
% 'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T182221_ADCCHAR_ADCch05_1'
% 'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T182303_ADCCHAR_ADCch05_2'
% 'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T182339_ADCCHAR_ADCch05_3'
% 'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T182504_ADCCHAR_ADCch15_1'
% 'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T182541_ADCCHAR_ADCch15_2'
% 'MasdaX	2010-08-12	measurements	PSI-1_ADCCHAR	20100812T182613_ADCCHAR_ADCch15_3'
%'MasdaX	2010-08-06	measurements	PSI-1_ADCCHAR	20100806T163237_ADCCHAR'
%'MasdaX	2010-08-06	measurements	PSI-1_ADCCHAR	20100806T163906_ADCCHAR'
%'MasdaX	2010-07-29	measurements	PSI-1_ADCCHAR	20100729T144340_ADCCHAR'
%'MasdaX	2010-07-29	measurements	PSI-1_ADCCHAR	20100729T111901_ADCCHAR'    
%'MasdaX	2010-07-28	measurements	PSI-1_ADCCHAR	20100728T132939_ADCCHAR'    
%'MasdaX	2010-07-13	measurements	PSI-1_ADCCHAR	20100713T151406_ADCCHAR'
%'MasdaX	2010-07-16	measurements	PSI-1_ADCCHAR	20100716T145903_ADCCHAR'
%'MasdaX	2010-07-16	measurements	PSI-1_ADCCHAR	20100716T152637_ADCCHAR'
%'MasdaX	2010-07-22	measurements	PSI-1_ADCCHAR	20100722T105516_ADCCHAR'        
% 'MasdaX	2010-05-28	measurements	PSI-1_ADCCHAR	20100528T155739_ADCCHAR_ADCch1_set1'
};


for ind_R=1:numel(R)
    curr_R=R{ind_R};
    tmp=regexp(R{ind_R},'\t'); 
    r4{ind_R}=curr_R(tmp(end)+1:end);
    MEASDIR=['../../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/' curr_R(tmp(3)+1:tmp(4)-1) '/'];
  %  file1=['../../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/environment/measADC_Pion_BK_9130_005004156568001055_V1.69'];
    file2=['../../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/environment/meas_simwork_HEWLETT-PACKARD_34401A_0_7-5-2'];
end

timestamp=R{1}(tmp(4)+1:tmp(4)+15);
V={};  I={};

%fid1=fopen(file1);
%C1=textscan(fid1,'%s%s%f64%s%f32%f32%f32%s%f32%f32%f32');
%fclose(fid1);

 %   V.Vminus=C1{5}; 
 %   V.VdV=C1{6};
 %   I1.Vminus=C1{9};
 %   I1.VdV=C1{10};
 %   V.timeStamp=C1{3};

fid2=fopen(file2);
C2=textscan(fid2,'%s%s%f64%s%f32%f32%f32%f32');
fclose(fid2);

    V.dVADC=[C2{5} C2{6} C2{7} C2{8}];
    V.dVADC_mean=mean(V.dVADC,2);
    V.timeStamp2=C2{3};


if(exist('../../../ADCchar_results','dir')~=7)
         mkdir('../../../ADCchar_results' );
end

tmp=findstr(MEASDIR,'/');
titleArray=MEASDIR(tmp(end-1)+1:end-1);
tmp=findstr(titleArray,'_');
titleArray=[titleArray(1:tmp-1) ' ' titleArray(tmp+1:end)];
titleArray1=[titleArray sprintf('\n   Channel #%d', channel);];
titleArray2=[titleArray sprintf('\n All channels');];

firstend=0;    perchannel=true;   firstcase=true; 

dataImage=[];  dataImage_mean=[]; dataImage_std=[]; dataMeanFilter={}; dataADC_std={};
dataVminus={}; dataVdV={};        datadVADC={};     dataIADCp={};      dataVminus2={};
dataVdV2={};   Vrefmat={};


k=1; %Initialization of number of Vminus 

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
         dataImage_std =std(dataImage,0,3);
        fclose(dataFile);

                
        if j==1
                starttime1 = (fmd.ast*1e-3) -5;
        end
        

        battery=MATSET.setup.battery; %If battery is used set this to true
        if(battery==true)
           % batcase=str2num(R{1}(end)); % 1 for set1 2 for set2
           % casenum=batcase;
            channel=str2num(R{1}(end-3:end-2));
        end
    
        
        %diff=V.timeStamp-fmd.ffpt*1e-3;
        %I =find(diff>0,1,'first');
        
         if (~isfield(MATSET.setup,'ADCtype'))
             MATSET.setup.ADCtype= 'normal';
         end

        
      if(strcmp(MATSET.setup.ADCtype,'normal'))  
        
        if battery==false
             if firstcase==true;
                if(sum(MATSET.multi.RMATRIX(j,7:8))== sum(MATSET.multi.RMATRIX(j+1,7:8)));
                    firstcase=false;
                    firstend=k;
                    secondstart=k+1;
                    stoptime1 = tempstoptime +5;
                    starttime2=(fmd.ast*1e-3)-5;
                end
             end
        
             if firstcase==true
                  if j==1
                      Vrefmat{k}=MATSET.multi.RMATRIX(j,8);
                      j1=0;
               
                  elseif j>1
                      if(MATSET.multi.RMATRIX(j,8)~= MATSET.multi.RMATRIX(j-1,8));
                          k=k+1;
                          j1=0;
                          Vrefmat{k}=sum(MATSET.multi.RMATRIX(j,7:8));
                       end
                  end
            
             else
                  if firstend==k
                        k=k+1;
                        Vrefmat{k}=sum(MATSET.multi.RMATRIX(j,7:8));
                        j1=0;
            
                  elseif k>firstend
                        if(sum(MATSET.multi.RMATRIX(j,7:8))~= sum(MATSET.multi.RMATRIX(j-1,7:8)));
                            k=k+1;
                            j1=0;
                            Vrefmat{k}=sum(MATSET.multi.RMATRIX(j,7:8));                   
                        end
                  end
             end
        
        else
             if batcase==1;
                 Vrefmat{k}=MATSET.multi.RMATRIX(j,8);
             else
                 Vrefmat{k}=sum(MATSET.multi.RMATRIX(j,7:8));
             end
             j1=0;
        end           
     
    
      else
             
            % Vrefmat{k}=MATSET.multi.RMATRIX(j,8);
             starttime2=(fmd.ast*1e-3)-5;
    end
      
        j1=j1+1;
        
        
        diff2=V.timeStamp2-fmd.ffpt*1e-3;
        samples=5;
        I2 = find(diff2<0,samples,'last');
        
        
        if(mod(j,2)~=0)
            timemat(j2)=fmd.ffpt*1e-3-(fmd.framecount/fmd.fps);
            reqV(j2)=MATSET.multi.VADCdV;
            j2=j2+1;
            timemat(j2)=fmd.ffpt*1e-3;
            reqV(j2)=MATSET.multi.VADCdV;
            j2=j2+1;
            reqV(j2)=NaN;
            timemat(j2)=fmd.ffpt*1e-3;
            j2=j2+1;
            mat(j4,:)=V.dVADC_mean(I2:I2+4);
            mattime(j4,:)=V.timeStamp2(I2:I2+4);
            j4=j4+1;
        else
            timemat1(j3)=fmd.ffpt*1e-3-(fmd.framecount/fmd.fps);
            reqV1(j3)=MATSET.multi.VADCdV;
            j3=j3+1;
            timemat1(j3)=fmd.ffpt*1e-3;
            reqV1(j3)=MATSET.multi.VADCdV;
            j3=j3+1;
            reqV1(j3)=NaN;
            timemat1(j3)=fmd.ffpt*1e-3;
            j3=j3+1;
            mat1(j5,:)=V.dVADC_mean(I2:I2+4);
            mattime1(j5,:)=V.timeStamp2(I2:I2+4);
            j5=j5+1;
        end

       
        
           
           
           
            dataMeanFilter{k}(j1,i)=mean2(dataImage_mean);
            dataADC_std{k}(j1,i)=mean2(dataImage_std);
            
            if perchannel==true
                for l=1:16
                    dataMeanFilterch{k}(j1,i,l)=mean2(dataImage_mean((l-1)*16+1:(l-1)*16+16,:));
                    dataADC_stdch{k}(j1,i,l)=mean2(dataImage_std((l-1)*16+1:(l-1)*16+16,:));
                end
            end
            
           
          
            %dataVminus{k}(j1,i)=V.Vminus(I);
            %dataVdV{k}(j1,i)=V.VdV(I);
            %dataIADCp{k}(j1,i)=I1.VdV(I);
            datadVADC_mean{k}(j1,i)=mean2(V.dVADC(I2:I2+samples-1,:));
            datadVADC_std{k}(j1,i)=std2(V.dVADC(I2:I2+samples-1,:));
            %dataVminus2{k}(j1,i)=MATSET.multi.VADCminus;
            dataVdV2{k}(j1,i)=MATSET.multi.VADCdV;
            tempstoptime=(fmd.flpt*1e-3);
            
                   
    end
end

stoptime2 = (fmd.flpt*1e-3) +5;
p={};f={};nonlin={};ind={};ind1={};h=[];


colors={'-*r','-sg','-ob','-*k','-dm','-py','-hr','-^g'};
colors1={'-+m','-+y','-+c','-+r','-db','-*r','-sg','-ob'};
colors2={'-+r','-+g','-+b','-+k','-+m','-+y','-+r','-+g'};
legendtext=[];
filenamestr=[ '../../../ADCchar_results/' timestamp '_' MATSET.setup.ADCconnected '_ch' num2str(channel) '_set' num2str(casenum)];


if(strcmp(MATSET.setup.ADCtype,'normal'))
    if battery==true
        start=1;
        finish=1;
        stoptime1=stoptime2; %comment it !
        firstend=k;
        secondstart=1;
        starttime2=starttime1;
        starttime=starttime1;
        stoptime=stoptime1;

    else
        switch(casenum)
       
         case 1   
            
            start=1;
            finish=firstend;
            starttime=starttime1;
            stoptime=stoptime1;
            
   

        case 2
            
            start=secondstart;
            finish=k;
            starttime=starttime2;
            stoptime=stoptime2;
        end
    end
else
    start=1;
    finish=k;
    starttime=starttime1;
    stoptime=stoptime2;
end

pl=start;
in=1;in2=2;
a=0;
double uVperADCmatrix=[];


          
x={};y={};

%{
if(strcmp(MATSET.setup.ADCtype,'normal'))
startn=1;           finishn=firstend; 
startp=secondstart; finishp=k;  
    for k1=startn:finishp
        ind{k1}=find(datadVADC_mean{k1}>0.5 & datadVADC_mean{k1}<2.5);
        ind1{k1}=find(datadVADC_mean{k1}>=0 &datadVADC_mean{k1}<3.6);
        uVperADCmatrix(1,in2)=Vrefmat{k1};
        in2=in2+1;
    end

else
    startn=start; finishp=finish;
    for k1=startn:finishp
         if(datadVADC_mean{1}(2)<0)
                ind{k1}=find(datadVADC_mean{k1}>-18 & datadVADC_mean{k1}<-2);
                ind1{k1}=find(datadVADC_mean{k1}>-20 &datadVADC_mean{k1}<0);
         else
             ind{k1}=find(datadVADC_mean{k1}>2 & datadVADC_mean{k1}<18);
             ind1{k1}=find(datadVADC_mean{k1}>0 &datadVADC_mean{k1}<20);
         end
        in2=in2+1;
        uVperADCmatrix(1,in2)=Vrefmat{k1};
    end
end

in3=1;
for k1=start:finish
        legendtext{in}=sprintf('Vref %0.1fV',Vrefmat{k1});
        in=in+1;
        legendtext{in}=sprintf('linfit %d',in3);
        in3=in3+1;in=in+1;
end

%}
        
x = [0.7698 0.5851];
y = [0.3593 0.5492];

a=0;

uVperADCmatrix(1,in2)=0;

%{

if(battery==false)

%%{
   
    for ch=1:16
        uVperADCmatrix(ch+1,1)=ch;
        in1=2;in4=1;
        for k1=startn:finishp
            p{k1}=polyfit(datadVADC_mean{k1}(ind{k1},1),dataMeanFilterch{k1}(ind{k1},1,ch),1);
            f{k1}=polyval(p{k1},datadVADC_mean{k1});
            offset(in4)=polyval(p{k1},0);
            VperADCperch{k1} = (datadVADC_mean{k1}(ind{k1}(end))-datadVADC_mean{k1}(ind{k1}(1)))/(f{k1}(ind{k1}(end))-f{k1}(ind{k1}(1)));
            nonlin{k1}(ch,:)=f{k1}(ind1{k1})-dataMeanFilterch{k1}(ind1{k1},1,ch);
            uVperADCmatrix(ch+1,in1)=VperADCperch{k1}*1e6;
            in1=in1+1;in4=in4+1;
        end
            offset_ch{ch}=mean(offset);
        uVperADCmatrix(ch+1,in2)=std(uVperADCmatrix(ch+1,2:in2-1));

    end
    
    
    
    uVperADCmatrix(ch+2,1)=0;
    for col=2:in2
    uVperADCmatrix(ch+2,col)=std(uVperADCmatrix(2:ch+1,col));
    end
    
    
    a=a+1;
    for ch=1:16
        for k1=start:finish
            h(a)=figure(1);
            if(k1==pl)   
                hold on;
                plot(datadVADC_mean{k1}(ind1{k1}),nonlin{k1}(ch,:),colors{k1});
                title(titleArray2,'fontsize',15,'fontweight','bold');
                xlabel('Measured dV','fontsize',15,'fontweight','bold');
                ylabel('Deviation from linearity (ADC)','fontsize',15,'fontweight','bold');
            end
            in1=in1+1;
        end
    end
    
    h1=legend(sprintf('Vref %0.1fV',Vrefmat{pl}),'Location','NW');
    set(h1,'Interpreter','none');
    hold off;
        
    if(exist(filenamestr,'dir')~=7)
         mkdir(filenamestr);
    end
    
    result=[filenamestr '/uVperADCchart.txt'];
    fid=fopen(result,'wt');
    sa{1}=size(uVperADCmatrix);
    fprintf(fid,'Ch no.\n/Vref \t');
    fprintf(fid,[repmat('%g\t',1,sa{1}(2)-2) '%g\n'],uVperADCmatrix(1,2:end).');
    fprintf(fid,[repmat('%g\t',1,sa{1}(2)-1) '%g\n'],uVperADCmatrix(2:end,:).');
    fclose(fid);
    
 filenamestr1=['../../../ADCchar_results/' timestamp '_' MATSET.setup.G3_system '_' MATSET.setup.ADCconnected];
 
 
 if(strcmp(MATSET.setup.ADCtype,'normal'))
 
 
 in=1;
    
    for ch=1:16
     for k1=startn:finishp        
            Channel_det{ch}.Vref{k1}.xval_dV=datadVADC_mean{k1};
            Channel_det{ch}.Vref{k1}.yval_ADC=dataMeanFilterch{k1}(:,1,ch);
            Channel_det{ch}.Vref{k1}.Vrefval=Vrefmat{k1};
            Channel_det{ch}.Vref{k1}.VperADC=uVperADCmatrix(ch+1,k1+1)*1e-6;
            
     end
     Channel_det{ch}.VperADC_neg=mean(uVperADCmatrix(ch+1,startn+1:finishn+1))*1e-6;
     Channel_det{ch}.VperADC_pos=mean(uVperADCmatrix(ch+1,startp+1:finishp+1))*1e-6;
     Channel_det{ch}.VperADC=mean(uVperADCmatrix(ch+1,startn+1:finishp+1))*1e-6;
     Channel_det{ch}.offset=offset_ch{ch};
    end
 
 else
     
 in=1;
    
    for ch=1:16
     for k1=startn:finishp        
            Channel_det{ch}.Vref{k1}.xval_dV=datadVADC_mean{k1};
            Channel_det{ch}.Vref{k1}.yval_ADC=dataMeanFilterch{k1}(:,1,ch);
            Channel_det{ch}.Vref{k1}.Vrefval=Vrefmat{k1};
            Channel_det{ch}.Vref{k1}.VperADC=uVperADCmatrix(ch+1,k1+1)*1e-6;
            
     end
     Channel_det{ch}.VperADC=mean(uVperADCmatrix(ch+1,start+1:finish+1))*1e-6;
     Channel_det{ch}.offset=offset_ch{ch};
    end
 
 end
     
save (filenamestr1 , 'Channel_det');
    
if(createhtm==0)
    return;
end
   
%}


%{
    a=a+1;
    for k1=start:finish
        h(a)=figure(2);
        p{k1}=polyfit(datadVADC_mean{k1}(ind{k1}),dataMeanFilter{k1}(ind{k1}),1);
        f{k1}=polyval(p{k1},datadVADC_mean{k1});
        VperADC{k1}=(datadVADC_mean{k1}(ind{k1}(end))-datadVADC_mean{k1}(ind{k1}(1)))/(f{k1}(ind{k1}(end))-f{k1}(ind{k1}(1)));
        plot(datadVADC_mean{k1},dataMeanFilter{k1},colors{k1});
        hold on; 
        plot(datadVADC_mean{k1},f{k1},colors1{k1});
        title(titleArray,'fontsize',15,'fontweight','bold');
        xlabel('Measured dV','fontsize',15,'fontweight','bold');
        ylabel('ADC #','fontsize',15,'fontweight','bold');
    end
    h1=legend(legendtext{1:end},'Location', 'NW');
    set(h1,'Interpreter','none');
    hold off;
    
%}

%{
    a=a+1;
    for k1=start:finish
        h(a)=figure(3);
        hold on;
        p{k1}=polyfit(datadVADC_mean{k1}(ind{k1}),dataMeanFilter{k1}(ind{k1}),1);
        f{k1}=polyval(p{k1},datadVADC_mean{k1});
        nonlin1{k1}=f{k1}(ind1{k1})-dataMeanFilter{k1}(ind1{k1});
        plot(datadVADC_mean{k1}(ind1{k1}),nonlin1{k1},colors{k1});
        title(titleArray,'fontsize',15,'fontweight','bold');
        xlabel('Measured dV','fontsize',15,'fontweight','bold');
        ylabel('Deviation from linearity(ADC)','fontsize',15,'fontweight','bold');
    end

    h1=legend(legendtext{1:2:end},'Location', 'NW');
    set(h1,'Interpreter','none');
    hold off;
%}



%{ 
    a=a+1;
    for ch=channel;
        for k1=start:finish
            h(a)=figure(4);
            %p{k1}=polyfit(datadVADC_mean{k1}(ind{k1}),dataMeanFilterch{k1}(ind{k1},1,ch),1);
            %f{k1}=polyval(p{k1},datadVADC_mean{k1});
            %VperADCperch{k1} = (datadVADC_mean{k1}(ind{k1}(end))-datadVADC_mean{k1}(ind{k1}(1)))/(f{k1}(ind{k1}(end))-f{k1}(ind{k1}(1)))
            plot(datadVADC_mean{k1},dataMeanFilterch{k1}(:,1,ch),colors{k1});
            hold on;
            %plot(datadVADC_mean{k1},f{k1},colors1{k1});
            title(titleArray1,'fontsize',15,'fontweight','bold');
            xlabel('Measured dV','fontsize',15,'fontweight','bold');
            ylabel('ADC # ','fontsize',15,'fontweight','bold');
        end
    end
    arrowstr=sprintf('%0.2f uV/ADC',VperADCperch{k1}*1e6);
    txtar =  annotation('textarrow',x,y,'String',arrowstr,'FontSize',14);
    h1=legend(legendtext{1:2:end},'Location', 'NW');
    set(h1,'Interpreter','none');
    hold off;
%}



%{
    ch=channel;
    a=a+1;
    for k1=start:finish
        h(a)=figure(5);
        hold on;
        p{k1}=polyfit(datadVADC_mean{k1}(ind{k1}),dataMeanFilterch{k1}(ind{k1},1,ch),1);
        f{k1}=polyval(p{k1},datadVADC_mean{k1});
        nonlin{k1}=f{k1}(ind1{k1})-dataMeanFilterch{k1}(ind1{k1},1,ch);
        plot(datadVADC_mean{k1}(ind1{k1}),nonlin{k1},colors{k1});
        title(titleArray1,'fontsize',15,'fontweight','bold');
        xlabel('Measured dV','fontsize',15,'fontweight','bold');
        ylabel('Deviation from linearity (ADC)','fontsize',15,'fontweight','bold');
    end

    h1=legend(legendtext{1:2:end},'Location', 'NW');
    set(h1,'Interpreter','none');
    hold off;
%}


%{
    a=a+1;
    for k1=start:finish
        h(a)=figure(6);
        hold on;
        plot(datadVADC_mean{k1},datadVADC_std{k1},colors{k1});
        title(titleArray,'fontsize',15,'fontweight','bold');
        xlabel('Measured dV','fontsize',15,'fontweight','bold');
        ylabel('dV error','fontsize',15,'fontweight','bold');
    end
    h1=legend(legendtext{1:2:end},'Location', 'NW');
    set(h1,'Interpreter','none');
    hold off;
%}


%{
    a=a+1;
    for k1=start:finish
        h(a)=figure(7);
        hold on;
        plot(datadVADC_mean{k1}(ind1{k1}),dataADC_std{k1}(ind1{k1}),colors{k1});
        title(titleArray,'fontsize',15,'fontweight','bold');
        xlabel('Measured dV','fontsize',15,'fontweight','bold');
        ylabel('ADC error','fontsize',15,'fontweight','bold');
    end

    h1=legend(legendtext{1:2:end},'Location', 'NW');
    set(h1,'Interpreter','none');
    hold off;
%}


%{
    ch=channel;
    a=a+1;
    for k1=start:finish
        h(a)=figure(8);
        hold on;
        plot(datadVADC_mean{k1}(ind1{k1}),dataADC_stdch{k1}(ind1{k1},1,ch),colors{k1});
        title(titleArray1,'fontsize',15,'fontweight','bold');
        xlabel('Measured dV','fontsize',15,'fontweight','bold');
        ylabel('ADC error','fontsize',15,'fontweight','bold');
    end

    h1=legend(legendtext{1:2:end},'Location', 'NW');
    set(h1,'Interpreter','none');
    hold off;
%}




%{
    a=a+1;
    for k1=start:finish
        h(a)=figure(9);
        hold on
        p{k1}=polyfit(datadVADC_mean{k1}(ind1{k1}),dataIADCp{k1}(ind1{k1}),1);
        f{k1}=polyval(p{k1},datadVADC_mean{k1});
        plot(datadVADC_mean{k1},dataIADCp{k1},colors{k1});
        plot(datadVADC_mean{k1},f{k1},colors2{k1});
        title(titleArray,'fontsize',15,'fontweight','bold');
        xlabel('Measured dV','fontsize',15,'fontweight','bold');
        ylabel('I_{ADC}','fontsize',15,'fontweight','bold');
    end

    h1=legend(legendtext{1:end},'Location', 'NW');
    set(h1,'Interpreter','none');
    hold off;
%}

%{ 
    a=a+1;
    for k1=start:finish
        h(a)=figure(10);
        hold on
        plot(dataVdV2{k1},datadVADC_mean{k1},colors{k1});
        title(titleArray,'fontsize',15,'fontweight','bold');
        xlabel('Requested dV','fontsize',15,'fontweight','bold')
        ylabel('Measured dV','fontsize',15,'fontweight','bold')
    end

    h1=legend(legendtext{1:2:end},'Location', 'NW');
    set(h1,'Interpreter','none');
    hold off;
%}

%{
    mat=mat';mattime=mattime';
    mat=mat(:); mattime=mattime(:);
    if (j>1)
       mat1=mat1';mattime1=mattime1';
       mat1=mat1(:); mattime1=mattime1(:);
       secondind1=find(mattime1>=starttime & mattime1<=stoptime);
         secondind2=find(timemat1>=starttime & timemat1<=stoptime);

    end
    firstind=find(V.timeStamp>=starttime & V.timeStamp<=stoptime);
    secondind=find(V.timeStamp2>=starttime & V.timeStamp2<=stoptime);
    firstind1=find(mattime>=starttime & mattime<=stoptime);  
    firstind2=find(timemat>=starttime & timemat<=stoptime);
  

    %%{
        a=a+1;
        h(a)=figure(11);
        hold on;
        A=plot(V.timeStamp2(secondind),V.dVADC_mean(secondind),'-+r');
        [AX,H1,H2]=plotyy(V.timeStamp(firstind),V.Vminus(firstind),V.timeStamp(firstind),I1.Vminus(firstind));
        [AX1,H11,H21]=plotyy(V.timeStamp(firstind),V.VdV(firstind)',V.timeStamp(firstind),I1.VdV(firstind));
        title(titleArray,'fontsize',15,'fontweight','bold');
        xlabel('Time (seconds)','fontsize',15,'fontweight','bold');
        ylabel(AX(1),'Voltage (V)','fontsize',15,'fontweight','bold');
        ylabel(AX(2),'Current (A)','fontsize',15,'fontweight','bold');
        legend([H1 H11 A], 'V.Vminus','V.VdV','V.dVADC','Location', 'NW' );
        legend([H2 H21], 'I.Vminus','I.VdV','Location', 'NE' );
        hold off;
    %}

    %{
        a=a+1;
        h(a)=figure(12);
        hold on;
        plot(V.timeStamp2(secondind),V.dVADC_mean(secondind),'-+r');
        plot(mattime(firstind1),mat(firstind1),'ob');
        plot(timemat(firstind2),reqV(firstind2),'-+b');
        if(j>1)
            plot(mattime1(secondind1),mat1(secondind1),'og');
            plot(timemat1(secondind2),reqV1(secondind2),'-+g');
        end
        title(titleArray,'fontsize',15,'fontweight','bold');
        xlabel('Time (seconds) ','fontsize',15,'fontweight','bold');
        ylabel('Voltage (V) ','fontsize',15,'fontweight','bold');
        hold off;
    %}

%}

%end


%{
if(createhtm==1)
          if(exist(filenamestr,'dir')~=7)
                mkdir(filenamestr);
          end
   
          for ifig=1:a
                saveas(h(ifig), [filenamestr '/fig' num2str(ifig) '_' MATSET.setup.ADCconnected],'png');
          end
  
end
%}
errorADCmat=[];
%{
    
    if battery==true
     a=a+1;
     h(a)=figure(13);
     hold on;
        for ch=1:16
            errorADCmat(ch,1)=ch;
            for k1=start:finish
                plot(datadVADC_mean{k1}(ind1{k1}),dataADC_stdch{k1}(ind1{k1},1,ch),colors{k1});
                errorADCmat(ch,2)=dataADC_stdch{k1}(ind1{k1},1,ch);
                errorADCmat(ch,3)=dataMeanFilterch{k1}(:,1,ch);
                title(titleArray2,'fontsize',15,'fontweight','bold');
                xlabel('Measured dV','fontsize',15,'fontweight','bold');
                ylabel('ADC error','fontsize',15,'fontweight','bold');
            end
        end
        h1=legend(legendtext{1:2:end},'Location', 'NW');
        set(h1,'Interpreter','none');
        hold off;
        
    if(exist(filenamestr,'dir')~=7)
         mkdir(filenamestr);
    end
        
    result=[filenamestr '/errorADCmat.txt'];
    fid=fopen(result,'wt');
    sa{2}=size(errorADCmat);
    fprintf(fid,'Ch no.\tADCStd\t\tADC mean\n');
    fprintf(fid,[repmat('%g\t',1,sa{2}(2)-1) '\t%g\n'],errorADCmat.');
    fclose(fid);
    end
    
    


%}

%%{
    
    if battery==true
     a=a+1;
     h(a)=figure(13);
     hold on;
        for ch=1:16
            errorADCmat(ch,1)=ch;
            for k1=start:finish
                plot(datadVADC_mean{k1}(:),dataADC_stdch{k1}(:,1,ch),colors{k1});
                errorADCmat(ch,2)=dataADC_stdch{k1}(:,1,ch);
                errorADCmat(ch,3)=dataMeanFilterch{k1}(:,1,ch);
                title(titleArray2,'fontsize',15,'fontweight','bold');
                xlabel('Measured dV','fontsize',15,'fontweight','bold');
                ylabel('ADC error','fontsize',15,'fontweight','bold');
            end
        end
%         h1=legend(legendtext{1:2:end},'Location', 'NW');
%         set(h1,'Interpreter','none');
%         hold off;
        
%     if(exist(filenamestr,'dir')~=7)
%          mkdir(filenamestr);
%     end
        
%     result=[filenamestr '/errorADCmat.txt'];
%     fid=fopen(result,'wt');
%     sa{2}=size(errorADCmat);
%     fprintf(fid,'Ch no.\tADCStd\t\tADC mean\n');
%     fprintf(fid,[repmat('%g\t',1,sa{2}(2)-1) '\t%g\n'],errorADCmat.');
%     fclose(fid);
    end
%     
    


%}






%{
if(createhtm==1)
            createhtml_ADC(a,MATSET.setup.ADCconnected,timestamp,filenamestr,battery,sa,uVperADCmatrix,errorADCmat);
                    
end
%}
