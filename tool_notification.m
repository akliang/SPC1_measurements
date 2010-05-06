function [error] = tool_notification(on,meas,multi,finished,long)
% XMPP network notification tool to help monitor script progress
% "on" is a flag to send a message
%    - set to flag.first_run to notify only once a start of run
%    - set to 1 to notify at every step of the experiment
% "env" is the env.struct
% "meas" is the meas.struct
% "multi" is the multi.struct
% "finished" is flag.finished for msg to say "started" or "finished"
% "long" is a binary-sequence (converted to base10) to control output
%  000 = ['R variables' 'voltage variables']
%  ex. long = 2 = '010' = display R variables
%  ex. long = 5 = '101' = display estimated time and voltage variables


% temporary: not sure if good to implement time estimation
time_step = 0.00062;

if (on == 1)
    % decode the "long" string to determine what user wants
    % vector is "big-endian" (index 1 starts from left -> right)
    % each element of vector is a _STRING_ not _NUMBER_
    long_bin = dec2bin(long);
    
    
    % flip the vector
    % (we are always guaranteed right-side input)
    % (this allows for infinite growth in left-side variables)
    % ex: 000 for 3 variables
    % ex: 00000 for 5 variables
    % but now index-1 reads the 5th var, not the 3rd var
    % so flipping the vector guarantees non-hardcoded growth
    long_bin = fliplr(long_bin);
    
    
    % begin constructing the msg string
    msg = ['MATLAB: ' meas.MFile ' (' meas.MeasCond ')'];
    
    % voltage variables
    if (long_bin(1)=='1')  % remember, the array elements are strings
        msg_temp = strrep(meas.MeasDetails,meas.MeasCond,'');
        msg = [msg ' \n ' msg_temp];
    end
    
    % R variables
    if ((size(long_bin,2)>1) && long_bin(2)=='1')
        msg_temp = strrep(meas.BaseName,meas.DirName,'');
        msg_temp = strrep(msg_temp,meas.MeasID,'');
        msg = [msg ' \n ' msg_temp];
    end

    % determine if it is "start" or "finish"
    if (finished)
        msg = [msg ' finished'];
    else
        msg = [msg ' started'];
        
        % not sure if it's a good idea to implement time_estimation
        %{
        % calculate the estimated time to completion
        time_sum = 0;
        for i=1:multi.nrofacq
            time_sum = time_sum + multi.RMATRIX(i,1)*(multi.RMATRIX(i,2)+multi.RMATRIX(i,3));
        end
        time_sum = time_step * time_sum;
        if (time_sum < 60) % less than 1 min
            time_label = 'secs';
        else
            time_sum = round(time_sum/60);
            time_label = 'mins';
        end
        time_sum = num2str(time_sum);
        msg = [msg ' (' time_sum ' ' time_label ')']
        %}
    end
    
    
    % get the computer's name (needed for xmpp)
    [ret username] = system('hostname');
    username = strtrim(lower(username));
    username = sprintf('%s.ubuntu',username);
    msg = [username '/' msg];
    
    system(['echo -e "' msg '" | sendxmpp -u ' username ' -p masda -j jabber.imager.umro --chatroom argus@conference.jabber.imager.umro']);
end
