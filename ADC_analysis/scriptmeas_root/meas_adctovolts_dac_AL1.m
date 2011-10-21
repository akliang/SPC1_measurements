function [Voltsperch_cards,adccards] = meas_adctovolts_dac_AL1(A, frames,MEASDIR)

%Description of function 
%------------------------
%A - The name of the fmd file to be processed 
%frames -[a,b] where a refers to starting frame and b refers to be the 
%ending frame to be used.

if (exist([pwd '/ADC_analysis']));
    addpath([pwd '/ADC_analysis']);
end
    
% A='20100729T140344_Acq001_00500R1_VADCp0000mV_VADCm1000mV.fmd';
% frames=[20,40];

%Extract fmd and bin file path from the fmd file name provided
%--------------------------------------------------------------
%date=[A(1:4) '-' A(5:6) '-' A(7:8)];
%split=regexp(A,'_');
%timestamp=A(1:split-1);
%MEASDIR=[fileparts(mfilename('fullpath')) '/../../' date '/measurements/PSI-1_DACCHAR/' timestamp '_DACCHAR'];
fmdfile=[MEASDIR '/' A];
binfile=[MEASDIR '/' A(1:end-3) 'bin'];




%Read fmd file and extract the names of the G3 system and ADC cards used
%-----------------------------------------------------------------------

fmd=read_fmd_complete(fmdfile);
fmd=fmd{1};
g3=fmd.MATSET.setup.G3_system;
adc=fmd.MATSET.setup.G3_adcCards;
dpot=fmd.MATSET.setup.dpotconn;
adctemp=adc;
adccards={};
while(~isempty(adctemp))
    [t adctemp]=strtok(adctemp,'-');
    if(strcmp(t,'00'))
        continue;
    end
    adccards={adccards{:},t};
end

%numofadccards=numel(adccards);
numofadccards=1;


ADCDIR=[fileparts(mfilename('fullpath')) '/../../ADCchar_results/'];
Errormsg=['This card has not yet been characterized. Perform ADC characterization for this card using' ...
' meas_adcchar.m or meas_dacchar_mod.m first and then try again'];

%Select the latest mat file with V/ADC data for all cards
%--------------------------------------------------------
persistent matfile;
if(isempty(matfile))
    for k=1:numofadccards
        %searchmat{k}=dir([ADCDIR '*'  '_'  adccards{k} '_' dpot '.mat']);
        searchmat{k}=dir([ADCDIR '*'  '_'  adccards{k} '.mat']);
        searchmat{k}=struct2cell(searchmat{k});
        numofmatches=size(searchmat{k},2);
        matfile{k}=[ADCDIR searchmat{k}{1,1}];
        if(numofmatches>1)
            for k1=1:numofmatches
                dates(k1)=str2num(searchmat{k}{1,k1}([1:8 10:15]));
            end
            [C I]=max(dates);
            matfile{k}=[ADCDIR searchmat{k}{1,I}];
        elseif(numofmatches<1)
            error(['Error:  ' adccards{k} '-' Errormsg]);
            return;
        end
    end
end



%Extract details regarding the size of the image
%-----------------------------------------------

image_length=fmd.dataLength;
image_width=fmd.dataWidth;
image_size=image_length*image_width;



%Read the requested frames and separate the portion of the image catered 
%-----------------------------------------------------------------------
%to by different cards
%-----------------------



fid=fopen(binfile);
fseek(fid,0,'eof');
fsize=ftell(fid);
Total_frames=fsize/(image_size*2);
fseek(fid,image_size*2*frames(1),'bof');
fnum_toread=frames(2)-frames(1);

fulldataImage=fread(fid,image_width*image_length*fnum_toread,'ushort','b');
fulldataImage1=reshape(fulldataImage,image_width,image_length,fnum_toread);
fclose(fid);

numofadccards=2;
step=image_width/numofadccards;

k1=1;

    for k=numofadccards:-1:1
        DataImage{k}=fulldataImage1((step*(k1-1)+1):(step*(k1-1)+step),:,:);
        DataImagemean{k}=mean(DataImage{k},3);
        k1=k1+1;
    end
    
%matfile

%Load the relevant matfiles having details about VperADC for all channels of
%-------------------------------------------------------------------------
%the selected cards
%------------------

numofadccards=1;
persistent Channel_det_cards;
if(isempty(Channel_det_cards))
    for k=1:numofadccards
        load(matfile{k})
        Channel_det_cards{k}=Channel_det;
    end
end


numofchan=16;

%Calculate the volts for each channel for the region corresponding to the
%--------------------------------------------------------------------------
%different cards
%---------------


for ind=1:numofadccards
    for ch=1:numofchan
        dataMeanch_cards{ind,ch}=mean2(DataImagemean{ind}((ch-1)*numofchan+1:(ch-1)*numofchan+numofchan,:));
        Voltsperch_cards{ind,ch}=(dataMeanch_cards{ind,ch}-Channel_det_cards{ind}{ch}.offset)*Channel_det_cards{ind}{ch}.VperADC;
    
    end
end


end












