
% analysis folder
ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20191111T172723';  % 29D1-8_WP3_2-1-1

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

  close all
  
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
  % find the falling edges
  in_falling_idx = find(invals_diff == -1);
  % remove false positives near invals_mean due to noise
  invals_mean_tol = 1e-3;
  true_points = invals(in_falling_idx) > invals_mean_tol;
  in_falling_idx = in_falling_idx(true_points);
  if (numel(in_falling_idx) < 3)
      error('Less than 3 falling edges found, cannot run analysis');
  end
  
  %{
  figure
  plot(invals,'b')
  hold on
  plot(outvals,'r')
  plot(in_falling_idx,invals(in_falling_idx),'kx')
  plot(in_falling_idx(2)-10,invals(in_falling_idx(2)-10),'ro')
  plot(in_falling_idx(3)-10,invals(in_falling_idx(3)-10),'go')
  hold off
  %}
  
  % truncate the signal
  idx_range = in_falling_idx(2)-30 : in_falling_idx(3)-10;
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
  % first attempt... smooth with 1/20th width sliding window
  % note: this makes amp-max very inaccurate.
  %       do not use outvals_smooth to derive amp-max!!
  smooth_span = round(numel(outvals)/20);
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

  %{
  figure(1)
  plot(outtime,outvals,'b')
  hold on
  plot(outtime,outvals_smooth,'r')
  plot([outtime(1) outtime(end)],[baseV baseV],'k')
  plot([outtime(1) outtime(end)],[baseV+settling_time_threshold baseV+settling_time_threshold],'c')
  plot([outtime(1) outtime(end)],[baseV-settling_time_threshold baseV-settling_time_threshold],'c')
  plot(outtime(crossAbove),outvals_smooth(crossAbove),'go')
  plot(outtime(crossBelow),outvals_smooth(crossBelow),'kx')
  plot(outtime(idx),outvals_smooth(idx),'rs')
  hold off
  %}
  
  
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
  s.settime=7;

  m2b=sort(unique(q(:,s.m2br)));
  m3b=sort(unique(q(:,s.m3br)));
  m4b=sort(unique(q(:,s.m4br)));
  
  inV = reshape( q(:,s.inval),[numel(m4b) numel(m2b)]);
  inV = inV'; % transpose to match the orientation of the simulations
  outV = reshape( q(:,s.outval),[numel(m4b) numel(m2b)]);
  outV = outV'; % transpose to match the orientation of the simulations
  settling_time = reshape(q(:,s.settime),[numel(m4b) numel(m2b)]);
  settling_time = settling_time'; % transpose to match the orientation of the simulations
  
  
  % find the max gain and bias settings
  gain=outV ./ inV;
  maxgain=max(max(gain))
  [r c]=find(gain==maxgain);
  if (numel(r)>1); r=r(1); end
  if (numel(c)>1); c=c(1); end

  
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
  
  % plot settling time
  %%{
  fh=figure(2);
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
  fh=figure(3);
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
  figure(4)
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
  r
  c
  %%{
  measID=meas_to_rc_translator(ana_folder,[r c]);
  figure(5)
  q=load([ana_folder '/meas' sprintf('%04d',measID) '/math2.csv.clean']);
  qin=load([ana_folder '/meas' sprintf('%04d',measID) '/math1.csv.clean']);
  plot(q(:,1),q(:,2))
  hold on
  plot(qin(:,1),qin(:,2),'r')
  hold off
  title(sprintf('Waveform of meas %d (inV = %f; outV = %f; settling time = %f',measID,inV(r,c),outV(r,c),settling_time(r,c)))
  %}

  
end % end-function

function [retval] = meas_to_rc_translator(ana_folder,inval)
% note: this function relies on results.txt

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

    if (numel(inval)==1)
        % translate a meas num into r/c pair
        res = q(q(:,1)==inval,:);
        retval_r = find(m2b == res(2));
        retval_c = find(m4b == res(4));
        retval = [retval_r retval_c m2b(retval_r) m4b(retval_c)];
    else
        % translate an r/c pair into a meas num
        m2b_val = m2b(inval(1));
        m4b_val = m4b(inval(2));
        res = q(   q(:,s.m2br)==m2b_val, : );
        res = res( res(:,s.m4br)==m4b_val, : );
        retval = res(1);
    end
end  % end-function meas_to_rc_translator
