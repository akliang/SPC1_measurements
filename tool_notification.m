function [success error] = tool_notification(on,u,p,j,recipient,msg)
% XMPP network notification tool to help monitor script progress
% "on" is a flag to send a message
% "sender" is a 1x3 row vector containing ['username';'password';'server']
% "recipient" is a row vector containing recipients (['(--chatroom) user@server.com'])
% "msg" is a string message (for now)

if (on == 1)
    system(['echo ' msg ' | sendxmpp -u ' u ' -p ' p ' -j ' j ' ' recipient]);
end
