function [error] = tool_notification(on,env,meas,multi,finished,flags)
% XMPP network notification tool to help monitor script progress
% "on" activates this function
% "finished" is a string of what the sentence should say
% "flags" = [Rvars volts]


if (on == 1)
    % begin constructing the msg string
    msg = ['MATLAB: ' meas.MFile ' (' meas.MeasCond ')'];
    
    % R variables
    if (flags(1)==1)
        msg_temp = strrep(meas.BaseName,meas.DirName,'');
        msg_temp = strrep(msg_temp,meas.MeasID,'');
        msg = [msg ' \n ' msg_temp];
    end
    
    % voltage variables
    if (flags(2)==1)  % remember, the array elements are strings
        msg_temp = strrep(meas.MeasDetails,meas.MeasCond,'');
        msg = [msg ' \n ' msg_temp];
    end

    msg = [msg sprintf(' %s',finished)];
    
    
    % get the computer's name (needed for xmpp)
    % IN THE FUTURE: get from env struct
    [ret username] = system('hostname');
    username = strtrim(lower(username));
    username = sprintf('%s.ubuntu',username);
    msg = [username '/' msg]
    
    system(['echo -e "' msg '" | sendxmpp -u ' username ' -p masda -j jabber.imager.umro --chatroom argus@conference.jabber.imager.umro']);
end
