function [ MATSET ] = read_matsettings( xxfname, ignore_errata_errors )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


    if nargin<2; ignore_errata_errors=false; end

    [ xxfpath, xxfbasename, xxfext ] = fileparts(xxfname);
    load( [xxfpath '/' xxfbasename '.settings.mat'] );    
    if exist([xxfpath '/errata.m'],'file');
        try
            run([xxfpath '/errata.m']);
        catch exception
            if ~ignore_errata_errors;
                rethrow(exception);
            end
            disp(['  Overriding error thrown in ' xxfpath '/errata.m']);
        end
    end



    clear('MATSET');
%  compsys      1x1             222466  struct                       
%  env          1x1               1200  struct                       
%  flag         1x1                531  struct                       
%  geo          1x1               1104  struct                       
%  id           1x1               3680  struct                       
%  meas         1x1               4108  struct                       
%  mid          1x1                  8  double                       
%  multi        1x1               2216  struct                       
%  setup        1x1               4222  struct

% detect if it is the "old" version of mat settings
if exist('Comment','var') % this field is uniq to the old file
    disp('Old settings file detected... converting...');
    settings_mat_to_struct
end

    MATSET.setup = setup;
    MATSET.env = env;
    MATSET.id = id;
    MATSET.geo = geo;
    MATSET.meas = meas;
    MATSET.multi = multi;

end

