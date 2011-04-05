function [channel]=adcnoise(AcqFile)
ind=regexp(AcqFile,'/');
date=AcqFile(ind(6)+1:ind(7)-1);
settingFile=[AcqFile(1:numel(AcqFile)-3),'fmd'];
fmds=read_fmd_complete(settingFile);
MATSET = read_matsettings(settingFile);
fmd=fmds{1};        
image_length=fmd.dataLength;
image_width=fmd.dataWidth;
image_size=image_length*image_width;      
dataFile=fopen(AcqFile);
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
        
         for l=1:16
              channel.ADC(l)=mean2(dataImage_mean((l-1)*16+1:(l-1)*16+16,:));
              channel.std(l)=mean2(dataImage_std((l-1)*16+1:(l-1)*16+16,:));
         end
        
        
        