clear all;
close all;

channel=1;
addpath('../');
R={
'MasdaX	2010-08-18	measurements	PSI-1_DACCHAR	20100818T183527_DACCHAR' % 10 and 12 (aff 2 and 15)
'MasdaX	2010-08-18	measurements	PSI-1_DACCHAR	20100818T183748_DACCHAR' % 9 and 11 (aff 15
'MasdaX	2010-08-18	measurements	PSI-1_DACCHAR	20100818T184031_DACCHAR' % 13 and 15
'MasdaX	2010-08-18	measurements	PSI-1_DACCHAR	20100818T184300_DACCHAR' % 14 and 16
'MasdaX	2010-08-18	measurements	PSI-1_DACCHAR	20100818T184509_DACCHAR' % 7 and 8
'MasdaX	2010-08-18	measurements	PSI-1_DACCHAR	20100818T184721_DACCHAR' % 5 and 6
'MasdaX	2010-08-18	measurements	PSI-1_DACCHAR	20100818T184928_DACCHAR' %3 and 4
'MasdaX	2010-08-18	measurements	PSI-1_DACCHAR	20100818T185143_DACCHAR' %1 and 2 (10 inverted?)

%'MasdaX	2010-08-17	measurements	PSI-1_DACCHAR	20100817T170112_DACCHAR'    
%'MasdaX	2010-08-17	measurements	PSI-1_DACCHAR	20100817T170112_DACCHAR'    
%'MasdaX	2010-08-17	measurements	PSI-1_DACCHAR	20100817T160253_DACCHAR'
%'MasdaX	2010-08-17	measurements	PSI-1_DACCHAR	20100817T150136_DACCHAR'    
%'MasdaX	2010-08-10	measurements	PSI-1_ADCCHAR	20100810T115656_ADCCHAR'   
%'MasdaX	2010-08-09	measurements	PSI-1_ADCCHAR	20100809T155039_ADCCHAR'
%'MasdaX	2010-08-06	measurements	PSI-1_ADCCHAR	20100806T163237_ADCCHAR'
%'MasdaX	2010-08-06	measurements	PSI-1_ADCCHAR	20100806T163906_ADCCHAR'
%'MasdaX	2010-07-29	measurements	PSI-1_ADCCHAR	20100729T144340_ADCCHAR'
%'MasdaX	2010-07-29	measurements	PSI-1_ADCCHAR	20100729T111901_ADCCHAR'    
%'MasdaX	2010-07-28	measurements	PSI-1_ADCCHAR	20100728T132939_ADCCHAR'    
%'MasdaX	2010-07-13	measurements	PSI-1_ADCCHAR	20100713T151406_ADCCHAR'
%'MasdaX	2010-07-16	measurements	PSI-1_ADCCHAR	20100716T145903_ADCCHAR'
%'MasdaX	2010-07-16	measurements	PSI-1_ADCCHAR	20100716T152637_ADCCHAR'
%'MasdaX	2010-07-22	measurements	PSI-1_ADCCHAR	20100722T105516_ADCCHAR'        
%'MasdaX	2010-05-28	measurements	PSI-1_ADCCHAR	20100528T155739_ADCCHAR_ADCch1_set1'
};
% how many frames to read/use
% note: this takes the last X number of frames
frm_numused=20;


% step through each file in the R matrix
% and parse out the desired information
for ind_R=1:numel(R)
    curr_R=R{ind_R};
    % explode the string based on tabs (\t)
    tmp=regexp(R{ind_R},'\t'); 
    % r4 is the filename
    r4{ind_R}=curr_R(tmp(end)+1:end);
    MEASDIR=['../../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/' curr_R(tmp(3)+1:tmp(4)-1) '/'];
    % get the multi-meter measurement datafile from the correct date
    file=['../../../' curr_R(tmp(1)+1:tmp(2)-1) '/measurements/environment/meas_simwork_HEWLETT-PACKARD_34401A_0_7-5-2'];  
end

% timestamp only takes the timestamp of the first file?
% this line of code only works bc the \t structure is compatible between Rs
% technically, the tmp var is the tmp from the LAST R file
% and we are grabbing the timestamp from the FIRST R file
timestamp=R{1}(tmp(4)+1:tmp(4)+15);
V={}; 
a=0;

% open the multimeter data file
% CAUTION!!! this opens the 'last' datafile, this code only works because
% all of the datasets are in the same date folder
% if the script needs to get datafiles from multiple dated folders
% this will fail (and only get the latest data file)
fid=fopen(file);
C=textscan(fid,'%s%s%f64%s%f32%f32%f32%f32');
fclose(fid);

% the multimeter data structure has 4 columns of voltage readings
% the V.dVADC vector loads all 4 columns of volts, then averages them
V.dVADC=[C{5} C{6} C{7} C{8}];
V.dVADC_mean=mean(V.dVADC,2);
V.timeStamp=C{3};


if(exist('../../../ADCchar_results','dir')~=7)
    mkdir('../../../ADCchar_results' );
end

% do a little pre-formatting for the title
% this block 'greps' the array name out of the MEASDIR path
tmp=findstr(MEASDIR,'/');
titleArray=MEASDIR(tmp(end-1)+1:end-1);
% replace the underscores in array name with a space
titleArray=strrep(titleArray,'_',' ');
titleArray1=[titleArray sprintf('\n   Channel #%d', channel);];
titleArray2=[titleArray sprintf('\n All channels');];


% now start the real analysis
% first step through each input file from the R matrix
for i=1:numel(r4)
    DDIR=[r4{i} '/'];
    % grep all the bin files
    D=dir([MEASDIR DDIR '*.bin']);
    r=struct2cell(D);
    % r2 is the name of all the .bin files
    r2=r(1,:);
    
    for j=1:numel(r2)
        file=[MEASDIR DDIR r2{j}];
        % the '.' in the strrep is the make it extension-specific
        % otherwise, it might accidentally replace 'bin' in the filename
        settingFile=strrep(file,'.bin','.fmd');
        fmds=read_fmd_complete(settingFile);
        MATSET=read_matsettings(settingFile);
        fmd=fmds{1};
        
        image_length=fmd.dataLength;
        image_width=fmd.dataWidth;
        image_size=image_length*image_width;
        
        % calculate the number of frames of data contained in the bin file
        dataFile=fopen(file);
        fseek(dataFile,0,'eof');
        % ftell returns the length of the file in BYTES
        % but our data frames are 16-bit packets
        flen=ftell(dataFile);
        flen=flen/2;
        fnum = flen/image_size;
        
        % only take the last frm_numused frames for analysis
        % first, move the cursor to frm_numused away from eof
        fseek(dataFile,image_size*2*(fnum-frm_numused),'bof');
        % then, read in all the frames until the end
        % note: 'b' sets it to big-endian
        dataImage1=fread(dataFile,[image_width,image_length]*frm_numused,'ushort','b');
        % reshape the data from 1 long 2D data stream into
        % discrete frames in a 3D array
        dataImage1=reshape(dataImage1,image_width,image_length,frm_numused);
        fclose(dataFile);
        
        % dpot is which digipot was actually monitored by the HP mmeter
        dpot{i}=MATSET.setup.HPdp2monitor;
        % dpot2chseq contains the 'mapping' from digipot number to ADC chan
        dpot2chseq=MATSET.setup.Dpot2chpair;
        % reshape the dpot2chseq into a 2D array (ind is digitpot #)
        % reshape stuffs the values column-wise into the new array
        % so first we make a 2x8 array, then transpose it
        dpot2chseq2=reshape(dpot2chseq,[2 8])';
        % chp is which ADC channel corresponds to the actively meas'd dpot
        %chp{i}=dpot2chseq(((dpot{i}-1)*2+1):((dpot{i}-1)*2+2))
        chp{i}=dpot2chseq2(dpot{i},:);

        
        % figure out which ADC cards were hooked up in the system
        % and also which specific ADC card was being characterized
        g3=MATSET.setup.G3_system;
        adctemp=MATSET.setup.G3_adcCards;
        adcconn=MATSET.setup.ADCconnected;
        adccards={};
        % step through the ADC string (a4-m1-00-00-...)
        % if encounter '00', then don't append to adccards{}
        while(~isempty(adctemp))
            [t adctemp]=strtok(adctemp,'-');
            if(strcmp(t,'00'))
                continue;
            end
        adccards={adccards{:},t};
        end
        numofadccards=numel(adccards);

        % every ADC card hooked up will append data to the bin file
        % even if it is all black (ie no data bc no cable was connected)
        % the ADC card order is backwards w.r.t. the bin file
        % the first card data is at the 'end' of the frame
        % this loop will determine which card was used, and find the data
        % note: can be improved by simply reversing 'adccards' vector?
        step=image_width/numofadccards;
        i1=1;
        for i2=numofadccards:-1:1
            if (strcmp(MATSET.setup.ADCconnected,adccards{i2}))
                dataImage=dataImage1((step*(i1-1)+1):(step*(i1-1)+step),:,:);       
            end
        i1=i1+1;
        end

        % find the mean value of each pixel across 20 frames
        % this returns a 'mean image' of all 20 frames averaged together
        dataImage_mean = mean(dataImage,3);
        dataImage_std =std(dataImage,0,3);
        % now find the average value of each channel
        for l=1:16
            dataMeanFilterch(j,i,l)=mean2(dataImage_mean((l-1)*16+1:(l-1)*16+16,:));
            dataADC_stdch(j,i,l)=mean2(dataImage_std((l-1)*16+1:(l-1)*16+16,:));
        end

        
        % now we need to know what voltage the multimeter read
        % by subtracting the first frame packet time (ffpt) from 
        % the long list of mmeter data points, we can find when in the
        % data stream the acquisition occurred
        % NOTE: there is a constant "time offset" between G3 time and
        % mmeter time!  this script does not take that into account yet
        diff=V.timeStamp-fmd.ffpt*1e-3;
        % grab 5 samples near the time point of ffpt
        samples=5;
        I = find(diff>0,samples,'first');
        % take the mean of the voltage readings in the 5-sample region
        datadVADC_mean(j,i)=mean2(V.dVADC(I:I+samples-1,:));
        datadVADC_std(j,i)=std2(V.dVADC(I:I+samples-1,:));
        DACvalmat(j,i,:)=MATSET.multi.DAC(dpot{i});

        
        % dataMeanFilter is the mean of the entire frame
        % i is the R-file
        % j is the bin-file
        %%%% IS THIS EVEN USED!? %%%%
        dataMeanFilter(j,i)=mean2(dataImage_mean);
        dataADC_std(j,i)=mean2(dataImage_std);
        
        % this function calculates what voltage was "sent" to each channel
        % of the ADC based on the ADCs measured and a VperADC conversion
        [Voltsperch_cards,adccards] = meas_adctovolts_dac([r2{j}(1:end-3) 'fmd'], [20,40]);

%{
a=1;
figure(a);
plot(datadVADC_mean(j),Voltsperch_cards{chp(1)},'r*');
title([titleArray sprintf('\n Digipot %d',dpot);],'fontsize',15,'fontweight','bold');
xlabel('Measured V','fontsize',15,'fontweight','bold');
ylabel('Calculated V','fontsize',15,'fontweight','bold');

hold on;
a=a+1;
figure(a);
plot(datadVADC_mean(j),Voltsperch_cards{chp(1)}-datadVADC_mean(j),'r*');
hold on;
%}
    end
end



%{
hold off;

figure(a)
title([titleArray sprintf('\n Digipot %d',dpot);],'fontsize',15,'fontweight','bold');
xlabel('Measured V','fontsize',15,'fontweight','bold');
ylabel('Deviation','fontsize',15,'fontweight','bold');
%}

colors={'-*r','-sg','-ob','-*k','-dm','-py','-hr','-^g'};
colors1={'-+m','-+y','-+c','-+r','-db','-*r','-sg','-ob'};
colors2={'-+r','-+g','-+b','-+k','-+m','-+y','-+r','-+g'};

double uVperADCmatrix=[];

% to find the linear region, subsample the dataset to exclude the extremes
for i=1:numel(r4)
    ind{i}=find(datadVADC_mean(:,i)>-14 & datadVADC_mean(:,i)<14);
    ind1{i}=find(datadVADC_mean(:,i)>-17 &datadVADC_mean(:,i)<17);
end
     
% origin for the arrow
x = [0.7698 0.5851];
y = [0.3593 0.5492];

for i=1:numel(r4)
    for ch=1:16
        if(ch==chp{i}(1)||ch==chp{i}(2))
            uVperADCmatrix(ch,1)=ch;
            p=polyfit(datadVADC_mean(ind{i},i),dataMeanFilterch(ind{i},i,ch),1);
            f=polyval(p,datadVADC_mean(:,i));
            VperADCperch = (datadVADC_mean(ind{i}(end),i)-datadVADC_mean(ind{i}(1),i))/(f(ind{i}(end))-f(ind{i}(1)));
            nonlin(ch,:)=f(ind1{i})-dataMeanFilterch(ind1{i},i,ch);
            uVperADCmatrix(ch,2)=VperADCperch*1e6;
            offset_ch{ch}=polyval(p,0);
        end
    end
end
         
    uVperADCmatrix(17,1)=0;
    uVperADCmatrix(17,2)=std(uVperADCmatrix(1:16,2));

 
%{   
    a=a+1;
    for ch=1:16       
           figure(a); 
            hold on;
            plot(datadVADC_mean(ind1),nonlin(ch,:),colors{1});
            title(titleArray2,'fontsize',15,'fontweight','bold');
            xlabel('Measured dV','fontsize',15,'fontweight','bold');
            ylabel('Deviation from linearity (ADC)','fontsize',15,'fontweight','bold');
    end
   
hold off;
 %}       
     

 for i=1:numel(r4)
     for ch=1:16 
         if(ch==chp{i}(1)||ch==chp{i}(2))
            Channel_det_temp{ch}.xval_dV=datadVADC_mean(:,i);
            Channel_det_temp{ch}.yval_ADC=dataMeanFilterch(:,i,ch);
            Channel_det_temp{ch}.VperADC=uVperADCmatrix(ch,2)*1e-6;
            Channel_det_temp{ch}.offset=offset_ch{ch};
         end
     end
 end    
      
%save (filenamestr1 , 'Channel_det');

Channel_det=Channel_det_temp;
 
 %{
    errorADCmat=[];
    if battery==true
        a=a+1;
        h(a)=figure(a);
        hold on;
        for ch=1:16
            errorADCmat(ch,1)=ch;
            plot(datadVADC_mean(ind1),dataADC_stdch(ind1,ch),colors{k1});
            errorADCmat(ch,2)=dataADC_stdch(ind1,ch);
            errorADCmat(ch,3)=dataMeanFilterch(:,ch);
            title(titleArray2,'fontsize',15,'fontweight','bold');
            xlabel('Measured dV','fontsize',15,'fontweight','bold');
            ylabel('ADC error','fontsize',15,'fontweight','bold');
        end
    end         
 %}


%%{
 
    for i=1:numel(r4)
     for ch=1:16 
         if(ch==chp{i}(1)) 
            a=a+1;
            figure(a);
            %Using the first of the channel pairs to calculate the voltage.
            V1{dpot{i}}=(dataMeanFilterch(:,i,ch)-Channel_det{ch}.offset)*Channel_det{ch}.VperADC;
            plot(DACvalmat(:,dpot{i}),V1{dpot{i}},'*r');
            hold on;
            p1{dpot{i}}=polyfit(DACvalmat(:,dpot{i}),V1{dpot{i}},1);
            f1{dpot{i}}=polyval(p1{dpot{i}},DACvalmat(:,dpot{i}));
            Dpot{dpot{i}}.VperDAC =(f1{dpot{i}}(end)-f1{dpot{i}}(1))/(DACvalmat(end,dpot{i})-DACvalmat(1,dpot{i}));
            Dpot{dpot{i}}.offset=polyval(p1{dpot{i}},0);   
            plot(DACvalmat(:,dpot{i}),f1{dpot{i}},'og');
            xlabel('DAC','fontsize',15,'fontweight','bold');
            ylabel('Volts ','fontsize',15,'fontweight','bold');
            title(sprintf('Digipot # %d',dpot{i}),'fontsize',15,'fontweight','bold');
            arrowstr=sprintf('%0.2f V/DAC',Dpot{dpot{i}}.VperDAC);
            annotation('textarrow',x,y,'String',arrowstr,'FontSize',14);
         end
     end
    end
    

    filenamestr1=['../../../ADCchar_results/' timestamp '_'  adcconn '_' MATSET.setup.PF_analogCard];
       
       save(filenamestr1, 'Dpot','Channel_det');
    
%}     
   
    
   