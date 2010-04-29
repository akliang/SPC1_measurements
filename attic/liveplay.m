
fprintf(1,'Waiting for output file to exist...\n');
while ~exist(AcqFile,'file'); 
    pause(0.1);
end

fprintf(1,'Reading data from file...\n');
fid=fopen(AcqFile,'r','b');

z=zeros(FRAMECNT,1);
signal_medians=z+0.1;
signal_means=z+0.2;
allframes=zeros(FRAMECNT,GL,DL);
%figure(1)
%h1=subplot(4,4,1);

%h2=figure(2);
xvals=1:FRAMECNT;

%plot(xvals,signal_means,'b');
%linkdata on;


curframe=0;
FILEDL=(G3DL+1)*2;
framesize=GL*FILEDL*2;
offset=5000;
while curframe<FRAMECNT;
    fseek(fid,0,'eof');
    filepos=ftell(fid);
    framepos=offset+(curframe+1)*framesize;
    if (filepos>=framepos);
               
        curframe=curframe+1;
        fprintf(1,'Frame %d available!',curframe);
        fseek(fid,framepos-framesize,'bof');
        framedata=fread(fid,GL*FILEDL,'uint16',0,'b');        
        iframe=reshape( framedata, [FILEDL GL] )';
        iframe=iframe(:,1:DL); % cut away not-used-DL
        allframes(curframe,:,:)=iframe;
        figure(1)
        %subplot(3,3,[1 2 4 5 7 8]);
        subplot(1,2,1);
        %hold on;
        imagesc(iframe);
        %if curframe==1;
            axis('image');
            title('Signal');
            %caxis([0 15000]);
            caxis([0 65000]);
        %    colorbar;
        %end

        signal_medians(curframe)=median(iframe(:));
        signal_means(curframe)=mean(iframe(:));        
        
        if curframe>1000;
            noise=squeeze(std(allframes(curframe-10:curframe,:,:),1));            
            subplot(1,2,2);
            imagesc(noise);
            %if curframe==11;
                axis('image');
                caxis([0 500]);
                title('Noise');
            %    colorbar;
            %end
        end
        %{
        if curframe==1;
            subplot(3,3,3);
            plot(xvals,signal_medians,'YDataSource','signal_medians')
            hold on;
            plot(xvals,signal_means,'YDataSource','signal_means');
            %legend('median','mean');
            %title('signal over time, complete array');
        else
            fprintf(1,'refreshed\n');
            refreshdata;
        end
        %}
        %subplot(3,3,6);        
        %hist(framedata);
        %title('signal histogram');
        
        % real-time plots of interest:
        % signal mean&median (median takes care of outlyers)
        % signal histogram?
        % noise median
        % noise histogram - sliding window?
        
        fprintf(1,'\n');
        drawnow        
        %drawnow expose update
    else
        pause(0.005);
    end
end

fclose(fid);
