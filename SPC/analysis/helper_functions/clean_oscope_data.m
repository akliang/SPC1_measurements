function clean_oscope_data(ana_folder)

    resfile = [ana_folder '/vbiases.txt' ];
    if (exist(resfile,'file'))
        fprintf(1,'Found existing vbias (%s)... skipping clean_oscope_data\n',resfile);
        return
    end

    dir_files = dir([ana_folder '/meas*']);

    odat_all = cell([1 numel(dir_files)]);
    for fidx=1:numel(dir_files)
        if (mod(fidx,10)==0)
            fprintf(1,'Progress: Cleaning meas %d/%d\n',fidx,numel(dir_files));
        end

        % clean the data and extract SMU data points
        measdir=[ana_folder '/' dir_files(fidx).name];
        [xx odat]=system(sprintf('./helper_functions/process_oscope_data_helper.sh %s',measdir));
        % remove last character from odat (newline) and save into the all cell
        odat_all{fidx}=odat(1:end-1);
    end
    
    % save odat_all to a file
    fid = fopen(resfile,'w');
    fprintf(fid,'%s\n',odat_all{:});
    fclose(fid);
  
end % end-function clean_oscope_data