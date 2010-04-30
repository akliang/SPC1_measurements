function [error] = tool_notification(on,start,user,meas,multi,long)
% XMPP network notification tool to help monitor script progress
% "on" is a flag to send a message
% "start" is a flag to determine if the msg is "started" or "finished"
% "user" is the username of the jabber account to use (note: password is assumed to be default)
% "meas" is the meas.struct
% "multi" is the multi.struct
% "long" is a flag to generate a long or short report

if (on == 1)
    % construct the message
    if (start == 1)
        key = 'started';
    end
    else
        key = 'finished';
    end

    if (long == 0)
    % just the shortest output string
        msg = ['MATLAB: ' meas.MFile ' (' meas.MeasCond ') ' key];
    elseif (long == 1)
    % append the R variables to the output
        % Parse down BaseName to just the R variables of interest
        temp_base = meas.BaseName
        temp_base = strrep(temp_base,meas.DirName,'')
        temp_base = strrep(temp_base,meas.MeasID,'')

        msg = ['MATLAB: ' meas.MFile ' (' meas.MeasCond temp_base ') ' key]
    end

    %system(['echo "' msg '" | sendxmpp -u ' user ' -p masda -j jabber.imager.umro --chatroom argus@conference.imager.umro']);
end
