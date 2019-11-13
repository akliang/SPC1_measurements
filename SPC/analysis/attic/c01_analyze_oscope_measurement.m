
% which folder to monitor for flags?
flagdir = '/Volumes/ArrayData/MasdaX/2018-01/scriptmeas/SPC/analysis/flags';

% check frequency
sleep_time = 3;

% loop infinitely to monitor for jobs to do
while true
  fprintf(1,'Checking for flags...\n');
  flaglist = dir(flagdir);

  for fidx=3:numel(flaglist)
    fpath=[flagdir '/' flaglist(fidx).name];

    % read flag file contents
    fprintf(1,'Current processing flag file %s...\n',flaglist(fidx).name);
    fid = fopen(fpath);
    datdir = textscan(fid,'%s','Delimiter','\n');
    datdir = datdir{1}{1};
    fclose(fid);

    % clean the data
    [xx odat]=system(sprintf('./b01_analyze_oscope_folder.sh %s',datdir));
    % remove last character from odat (newline)
    odat=odat(1:end-1);

    % derive metrics
    [ampin ampout settling_time]=b02_analyze_oscope_amp(datdir);

    % output to results file
    [filepath name ext]=fileparts(datdir);
    resfile = [filepath '/results.txt' ];
    fid = fopen(resfile,'a');
    fprintf(fid,"%s\t%f\t%f\t%f\n",odat,ampin,ampout,settling_time);
    fclose(fid);

    % debug info
    if false;
      odat
      ampin
      ampout
      settling_time
    end

    system(sprintf('rm %s',fpath));
  end


  pause(sleep_time)
end


