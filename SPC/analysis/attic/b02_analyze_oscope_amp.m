function [amplifier_input,amplifier_output,settling_time]=b02_analyze_oscope_amp(measdir)

  %measdir='/Volumes/ArrayData/MasdaX/2018-01/measurements/20180306T185749/meas001/';
  %measnum=regexprep(measdir,'.*meas','');
  %measnum=regexprep(measnum,'/$','');

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
  if (numel(in_falling_idx) > 1); warning('More than 1 falling edge found, taking the first one'); in_falling_idx=in_falling_idx(1); end
  in_rising_idx = find(invals_diff == 1);
  if (numel(in_rising_idx) > 1); warning('More than 1 rising edge found, taking the first one'); in_rising_idx=in_rising_idx(1); end
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
  
end % end-function
