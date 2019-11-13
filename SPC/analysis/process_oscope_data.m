
% analysis folder
ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20191111T172723';  % test run for script dev

% clean the oscope data to make it matlab-friendly
% also, compute the gain and settling time for each measurement point
%clean_and_analyze_oscope_data(ana_folder);

% generate the visual colormap of the overall results
[m2b m4b gain outV]=generate_colormap(ana_folder);


function clean_and_analyze_oscope_data(ana_folder)

    dir_files = dir([ana_folder '/meas*']);

    for fidx=1:numel(dir_files)
        if (mod(fidx,10)==0)
            fprintf(1,'Progress: %d/%d\n',fidx,numel(dir_files));
        end

        % clean the data and extract SMU data points
        measdir=[ana_folder '/' dir_files(fidx).name];
        [xx odat]=system(sprintf('./process_oscope_data_helper.sh %s',measdir));
        % remove last character from odat (newline)
        odat=odat(1:end-1);

        % derive count-rate metrics
        [ampin ampout settling_time]=analyze_oscope_amp(measdir);

        % output to results file
        resfile = [ana_folder '/results.txt' ];
        fid = fopen(resfile,'a');
        fprintf(fid,"%s\t%f\t%f\t%f\n",odat,ampin,ampout,settling_time);
        fclose(fid);

        % debug info
        if false; odat, ampin, ampout, settling_time, end

    end
  
end % function clean_oscope_data()


function [amplifier_input,amplifier_output,settling_time]=analyze_oscope_amp(measdir)
  % copied from b02_analyze_oscope_amp on 2019-11-13

  % assuming input and output csv files
  incsv=[measdir '/math1.csv.clean'];
  if(~exist(incsv))
    incsv=[measdir '/ch1.csv.clean'];
  end
  outcsv=[measdir '/math2.csv.clean'];

  in=load(incsv);
  out=load(outcsv);
  
  invals=in(:,2);
  outtime=out(:,1);
  outvals=out(:,2);

  % examine only the falling-edge part of the data
  % find the idx of the falling edge
  invals_mean=mean(invals);
  invals_binary=(invals>invals_mean);
  invals_diff=diff(invals_binary);
  % find the falling and rising edges
  in_falling_idx = find(invals_diff == -1);
  if (numel(in_falling_idx) > 1)
      %warning('More than 1 falling edge found, taking the first one');
      in_falling_idx=in_falling_idx(1);
  end
  in_rising_idx = find(invals_diff == 1);
  if (numel(in_rising_idx) > 1)
      %warning('More than 1 rising edge found, taking the first one');
      in_rising_idx=in_rising_idx(1);
  end
  % truncate the signal
  idx_range = in_falling_idx-10 : in_rising_idx-10;
  invals=invals(idx_range);
  outtime=outtime(idx_range);
  outvals=outvals(idx_range);
  

  % find the index where invals is largest
  [tmp idx]=max(abs(diff(invals)));
  idx=idx-1;  % try to shift back a little bit to find the true start

  % figure out the input size
  % note: this is assuming the input pulse steps downwards
  amplifier_input=in(idx,2)-min(in(:,2));
  
  % average the output up to idx to find the baseline
  baseV=mean(out(1:idx,2));
  maxV=max(out(:,2));
  amplifier_output = maxV-baseV;
  
  % settling time
  % first attempt... smooth with 1/75th width sliding window
  smooth_span = round(numel(outvals)/75);
  outvals_smooth = movmean(outvals,smooth_span);
  % define the threshold (absoluve value)
  settling_time_threshold = abs(amplifier_output*0.05);
  % the find point where it crosses above/below the threshold
  crossAbove = find(outvals_smooth > (baseV+settling_time_threshold) );
  crossBelow = find(outvals_smooth < (baseV-settling_time_threshold) );
  % note: both variables SHOULD contain an array of index values, but if
  % could also return empty, so ensure they always have a value
  if (numel(crossAbove) == 0); crossAbove=1; end
  if (numel(crossBelow) == 0); crossBelow=1; end
  % take the right-most value of the two
  if (crossAbove(end) > crossBelow(end))
    settling_idx = crossAbove(end);
  else
    settling_idx = crossBelow(end);
  end
  settling_time = outtime(settling_idx) - outtime(idx);

  % plot stuff
  if false
    plot(outtime,outvals)
    hold on
    plot(outtime,invals,'y')
    plot(outtime,outvals_smooth,'r')
    plot([outtime(1) outtime(end)],[baseV+settling_time_threshold baseV+settling_time_threshold],'b')
    plot([outtime(1) outtime(end)],[baseV-settling_time_threshold baseV-settling_time_threshold],'g')
    if (numel(crossAbove)>0); plot(outtime(crossAbove) , outvals_smooth(crossAbove) , 'bo'); end
    if (numel(crossBelow)>0); plot(outtime(crossBelow) , outvals_smooth(crossBelow) , 'gx'); end
    plot(outtime(idx),outvals_smooth(idx),'ks')
    hold off
    legend('outvals','invals','outvals smooth','threshold lower','threshold higher','values above','values below','idx point')
    title(sprintf('inval at idx: %f ; inval min: %f ; outval baseV: %f ; outval maxV: %f',in(idx,2),min(in(:,2)),mean(out(1:idx,2)),max(out(:,2))));
  end

  % output results to terminal
  %fprintf(1,'amp_input: %f\tamp_output: %f\tsettling_time: %e\tcount_rate: %g\n',amplifier_input,amplifier_output,settling_time,1/settling_time);
  
end % function analyze_oscope_amp


function [ m2b,m4b,gain,outV ] = generate_colormap(ana_folder)
  % copied from c02_generate_colormap on 2019-11-13

  q=load([ana_folder '/results.txt']);
  q=sortrows(q,1);

  s.measid=1;
  s.m2br=2;
  s.m3br=3;
  s.m4br=4;
  s.inval=5;
  s.outval=6;

  m2b=sort(unique(q(:,s.m2br)));
  m3b=sort(unique(q(:,s.m3br)));
  m4b=sort(unique(q(:,s.m4br)));

  gain=q(:,s.outval)./q(:,s.inval);
  gain=reshape(gain,[numel(m4b) numel(m2b)]);
  gain=gain';  % transpose to match the orientation of the simulations

  % find the max gain and bias settings
  maxgain=max(max(gain))
  [r c]=find(gain==maxgain);

  % prep the abvolute voltage variable
  outV=q(:,s.outval);
  outV=reshape(outV,[numel(m4b) numel(m2b)]);
  outV=outV';

  
  % plot gain
  %%{
  fh=figure(1);
  imagesc(m4b,m2b,gain); colorbar
  set(gca,'YDir','normal');
  xlabel('m4b (V)')
  ylabel('m2b (V)')
  colormap jet
  title(sprintf('Amp gain in response to %0.2e step function (maxgain=%0.2f at m2b=%0.2f and m4b=%0.2f)',mean(q(:,s.inval)),maxgain,m2b(r),m4b(c)))
  % save the figure to a PNG
  %print(fh,sprintf('%s/colormap_gain.png',filepath));
  %}

  % plot absolute voltage output
  %%{
  fh=figure(2);
  imagesc(m4b,m2b,outV); colorbar
  %caxis([0.01 4.25])
  set(gca,'YDir','normal');
  xlabel('m4b (V)')
  ylabel('m2b (V)')
  title('Absolute voltage output')
  colormap jet
  %}

  % plot a grid of sample output curves
  %%{
  figure(3)
  subplot_size_x=6;
  subplot_size_y=6;
  subplot_size=subplot_size_x*subplot_size_y;
  step_size=floor(numel(outV)/subplot_size);
  for F=1:subplot_size
    subplot(subplot_size_x,subplot_size_y,F);
    q=load([ana_folder '/meas' sprintf('%04d',F*step_size) '/math2.csv.clean']);
    plot(q(:,1),q(:,2))
    title(sprintf('meas%04d',F*step_size));
  end
  %}

  % plot a specific meas ID
  %%{
  measID=459;
  figure(4)
  q=load([ana_folder '/meas' sprintf('%04d',measID) '/math2.csv.clean']);
  qin=load([ana_folder '/meas' sprintf('%04d',measID) '/math1.csv.clean']);
  plot(q(:,1),q(:,2))
  hold on
  plot(qin(:,1),qin(:,2),'r')
  hold off
  title(sprintf('Waveform of meas %d',measID))
  %}

  
end % end-function
