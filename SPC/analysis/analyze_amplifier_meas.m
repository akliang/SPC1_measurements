
% TODO:
% 1. (DONE) rename this script to analyze_amplifier_meas.m
% 2. (DONE) delete the local clean_oscope_data function and use the one in helper_functions directory
% 3. (DONE) delete the duplicate process_oscope_data_helper.sh script (there is one in the helper_fxns directory too)
% 4. (DONE) vbiases.txt file has been updated to incorporate ALL voltages (so need to update the columns used below accordingly)
% 5. Remove gainfac
% 6. Which settling time percentage to use?  5% or 1%?

% analysis folder
global gainfac;  % temporary patch for mis-atten data, delete after 20191119T101410 is no longer needed
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191111T172723'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191113T165352'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191114T100721'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191115T105635'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191118T101600'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191119T101410'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191120T135534'; gainfac=1;   % scope acq = 400; script acq = 400 (mistake!)
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20191121T161359'; gainfac=1;

if exist('/Volumes/ArrayData/MasdaX','dir')
    pathpre = '/Volumes/ArrayData/MasdaX/2018-01/measurements/';
else
    pathpre = '~/Desktop/ArrayData/MasdaX/2018-01/measurements/';
end

% new data taken with improved acq script and on wafer5
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200212T172727_29D1-5_WP5_1-1-1_amp3st1bw/'; gainfac=1;
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200214T174201_29D1-5_WP5_1-1-1_amp3st1bw/'; gainfac=1;
%ana_folder = [pathpre '20200217T170121_29D1-5_WP5_1-1-1_amp3st1bw/']; gainfac=1;
ana_folder = [pathpre '20200219T104707_29D1-5_WP5_1-1-1_amp3st1bw/']; gainfac=1;

addpath('./helper_functions');
% clean the oscope data to make it matlab-friendly
clean_oscope_data(ana_folder);
vb_dat = load([ana_folder '/vbiases.txt']);

%{
% walk through every meas and analyze
global waveform_save;
waveform_save={};
ana_res_all = zeros([size(vb_dat,1) 3]);
for fidx=1:size(vb_dat,1)
    if (mod(fidx,10)==0)
        fprintf(1,'Progress: Analyzing meas %d/%d\n',fidx,size(vb_dat,1));
    end

    measdir=sprintf('%s/meas%04d',ana_folder,vb_dat(fidx,1));
    [ampin, ampout, settling_time] = analyze_oscope_amp(measdir);
    ana_res_all(fidx,:) = [ampin, ampout, settling_time];
end

% concat vbiases and ana results and write the results file
alldat = [vb_dat ana_res_all];
resfile = [ana_folder '/results.txt' ];
csvwrite(resfile,alldat);
%}


% find optimal point and generate the visual colormaps
[m2b, m4b, gain, outV]=generate_colormap(ana_folder);

% debug line
%[amplifier_input,amplifier_output,settling_time]=analyze_oscope_amp([ana_folder '/meas0345']);

%meas_to_rc_translator(ana_folder,[-.7, .75])
%plot_specific_meas(ana_folder,meas_to_rc_translator(ana_folder,[-.7, .75]));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    analysis functions    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [amplifier_input,amplifier_output,settling_time]=analyze_oscope_amp(measdir)

  debug=false;

  global waveform_save
  global wss

  %settling_time_percent = 0.01;
  settling_time_percent = 0.05;
  
  % assuming input and output csv files
  incsv=[measdir '/math1.csv.clean'];
  if(~exist(incsv,'file'))
    incsv=[measdir '/ch1.csv.clean'];
  end
  outcsv=[measdir '/math2.csv.clean'];
  trigcsv=[measdir '/ch4.csv.clean'];
  % load the files
  in=load(incsv);
  out=load(outcsv);
  trig=load(trigcsv);
  % define signal variables
  invals=in(:,2);
  outtime=out(:,1);
  outvals=out(:,2);
  trigger=trig(:,2);

  % method: examine only the falling-edge part of the data
  % find the idx of the falling edge
  % note: this code was retired on 2020-02-24 in favor of using siggen trigger on ch4
  %{
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
  %}
  trig_mean = mean(trigger);
  % find the places where the signal crosses
  trig_cross = diff(trigger>trig_mean);
  trig_rising_idx = find(trig_cross == 1);
  
  % truncate the signal to a single waveform
  idx_range = trig_rising_idx(2)-30 : trig_rising_idx(3)-10;
  invals_single=invals(idx_range);
  outtime_single=outtime(idx_range);
  outvals_single=outvals(idx_range);
  trigger_single=trigger(idx_range);
 
  % find the index where invals is largest
  [~, idx]=max(abs(diff(invals_single)));
  idx=idx-1;  % try to shift back a little bit to find the true start

  % figure out the input size
  amplifier_input = max(invals_single) - min(invals_single);
  % calculate starting base V by averaging all points up to the input pulse
  baseV = mean(outvals_single(1:idx));
  % figure out the output size (normalized to baseV)
  amplifier_output = max(outvals_single) - baseV;
  amplifier_underswing = abs(min(outvals_single) - baseV);
  
  if (amplifier_underswing > amplifier_output)
      fprintf(1,'  Amplifier underswing larger than amplifier output...\n   skipping %s\n',measdir)
      outvals_smooth = [];
      settling_time = NaN;
  else
      % calculate settling time
      % first attempt... smooth with 1/20th width sliding window
      % note: this makes amp-max very inaccurate.
      %       do not use outvals_smooth to derive amp-max!!
      % 2020-02-18: if amp peak is too sharp, 1/20th wide is too broad, changed to 1/100th
      smooth_span = round(numel(outvals_single)/100);
      outvals_smooth = movmean(outvals_single,smooth_span);
      % 2020-10-16: testing 5-percent baseline and NO smoothing
      outvals_smooth = outvals_single;
      % define the threshold (absolute value)
      settling_time_threshold = abs(amplifier_output*settling_time_percent);
      % the find point where it crosses above/below the threshold
      crossAbove = find(outvals_smooth > (baseV+settling_time_threshold) );
      crossBelow = find(outvals_smooth < (baseV-settling_time_threshold) );
      % note: both variables SHOULD contain an array of index values, but if
      % could also return empty, so ensure they always have a value
      % perhaps this should throw an error instead?
      if (numel(crossAbove) == 0) || (numel(crossBelow) == 0)
          fprintf(1,'  Failed to find settling time for...\n   %s\n', measdir);
          settling_time = NaN;
      else
          % take the right-most value of the two
          if (crossAbove(end) > crossBelow(end))
            settling_idx = crossAbove(end);
          else
            settling_idx = crossBelow(end);
          end
          settling_time = outtime_single(settling_idx) - outtime_single(idx);
      end
  end % if_statement: amplifier_underswing > amplifier_output

  % save this data into a master data cell
  [~, measID, ~] = fileparts(measdir);
  measID = str2num(strrep(measID,'meas',''));
  wss.outtime_single = 1;
  wss.invals_single = 2;
  wss.outvals_single = 3;
  wss.amplifier_input = 4;
  wss.baseV = 5;
  wss.amplifier_output = 6;
  wss.outvals_smooth = 7;
  wss.amplifier_underswing = 8;
  waveform_save{measID} = {outtime_single, invals_single, outvals_single, amplifier_input, baseV, amplifier_output, outvals_smooth, amplifier_underswing};

  if debug
      figure(99)
      plot(outtime_single,invals_single);
      hold on
      plot(outtime_single(idx),invals_single(idx),'bx');
      plot(outtime_single,trigger_single,'c');
      plot(outtime_single,outvals_single,'r');
      %plot(outtime(1:numel(outvals_smooth)),outvals_smooth,'g');
      %plot([outtime_single(1) outtime_single(end)],[baseV+settling_time_threshold baseV+settling_time_threshold],'k');
      %plot([outtime_single(1) outtime_single(end)],[baseV-settling_time_threshold baseV-settling_time_threshold],'k');
      hold off
  end
end % function analyze_oscope_amp


function [ m2b,m4b,gain,outV ] = generate_colormap(ana_folder)
  
  global gainfac;  % todo - remove this and gainfac below when no longer needed
  global waveform_save;
  global wss;

  q=load([ana_folder '/results.txt']);
  q=sortrows(q,1);

  s.measid=1;
  s.vcc=2;
  s.gnd=3;
  s.m2br=4;
  s.m3br=5;
  s.m4br=6;
  s.m5br=7; % note: this is nothing for the amp
  s.inval=8;
  s.outval=9;
  s.settime=10;

  m2b=sort(unique(q(:,s.m2br)));
  m3b=sort(unique(q(:,s.m3br)));
  m4b=sort(unique(q(:,s.m4br)));
  
  inV = reshape( q(:,s.inval),[numel(m4b) numel(m2b)]);
  inV = inV'; % transpose to match the orientation of the simulations
  outV = reshape( q(:,s.outval),[numel(m4b) numel(m2b)]);
  outV = outV'; % transpose to match the orientation of the simulations
  outV = outV*gainfac;  % special patch for older mis-calibrated atten measurements (up to 20191119T101410)
  settling_time = reshape(q(:,s.settime),[numel(m4b) numel(m2b)]);
  settling_time = settling_time'; % transpose to match the orientation of the simulations
  
  % find the max gain and minimum settling time
  gain=outV ./ inV;
  maxgain=max(max(gain));
  [gain_r, gain_c]=find(gain==maxgain);
  if (numel(gain_r)>1); gain_r=gain_r(1); end
  if (numel(gain_c)>1); gain_c=gain_c(1); end
  minsettime=min(min(settling_time));
  [settime_r, settime_c]=find(settling_time==minsettime);
  if (numel(settime_r)>1); settime_r=settime_r(1); end
  if (numel(settime_c)>1); settime_c=settime_c(1); end
  
  % find the optimal operating point
  minV = 1.25;  maxV = 2;
  valid_idx  = (outV>=minV);
  valid_idx2 = (outV<=maxV);
  valid_idx  = valid_idx .* valid_idx2;
  if (sum(valid_idx)==0); error('No valid outV values >= %f found',minV); end
  % use valid_idx to zero-out invalid settling times, then set those values to NaN
  valid_settime = settling_time .* valid_idx;
  valid_settime(valid_settime==0) = NaN;
  [opt_r, opt_c] = find(valid_settime == min(min(valid_settime)));
  fprintf(1,'Number of opt_r = %d ; Number of opt_c = %d\n',numel(opt_r),numel(opt_c));
  % TODO: find the opt_r and opt_c that isnt at edge of sweep range
  opt_r = opt_r(1);  opt_c = opt_c(1);
  
  % plot metrics
  pngpath = [ana_folder '/analysis_pngs'];
  if ~exist(pngpath,'dir'); mkdir(pngpath); end

  % plot - gain
  fh=figure(1);
  plot_colormap(m4b,m2b,gain,[gain_r, gain_c]);
  title(sprintf('Amp gain in response to %0.2e step function (maxgain=%0.2f at m2b=%0.2f and m4b=%0.2f)',mean(q(:,s.inval)),maxgain,m2b(gain_r),m4b(gain_c)))
  saveas(fh,sprintf('%s/gain_colormap.png',pngpath));
  
  % plot - settling time
  fh=figure(2);
  plot_colormap(m4b,m2b,settling_time,[settime_r, settime_c]);
  title(sprintf('Settling time (min time = %f at m2b=%0.2f and m4b=%0.2f)',minsettime, m2b(settime_r), m4b(settime_c)))
  saveas(fh,sprintf('%s/settlingtime_colormap.png',pngpath));

  % plot - absolute voltage output
  fh=figure(3);
  plot_colormap(m4b,m2b,outV,[gain_r, gain_c]);
  %caxis([0.01 4.25])
  title(sprintf('Absolute voltage output (max V = %f at m2b=%0.2f and m4b=%0.2f)', max(max(outV)),m2b(gain_r),m4b(gain_c)))
  saveas(fh,sprintf('%s/outV_colormap.png',pngpath));

  % plot - grid of sample output curves
  fh=figure(4);
  subplot_size_y=3;
  subplot_size_x=3;
  subplot_size=subplot_size_x*subplot_size_y;
  step_size=floor(numel(outV)/subplot_size);
  for F=1:subplot_size
    subplot(subplot_size_x,subplot_size_y,F);
    q=load([ana_folder '/meas' sprintf('%04d',F*step_size) '/math2.csv.clean']);
    plot(q(:,1),q(:,2))
    title(sprintf('meas%04d',F*step_size));
  end
  saveas(fh,sprintf('%s/sample_outputs.png',pngpath));

  % plot - waveform of lowest settling time
  now_r = opt_r;  now_c = opt_c;
  custom_str = sprintf('Waveform of optimal point (minV=%0.2f)',minV);
  measID=meas_to_rc_translator(ana_folder,[now_r now_c]);
  fh=figure(5);
  plot_specific_meas(ana_folder,measID);
  % generate title string
  [~, ana_folder_ID, ~] = fileparts(ana_folder);
  stat_str1 = sprintf('meas %d (m2b = %0.2f ; m4b = %0.2f)',measID,m2b(now_r),m4b(now_c));
  stat_str2 = sprintf('outV = %f; inV = %f; gain = %f; settling time = %f',outV(now_r,now_c),inV(now_r,now_c),gain(now_r,now_c),settling_time(now_r,now_c));
  title({custom_str,sprintf('ana folder: %s',ana_folder_ID),stat_str1,stat_str2})
  saveas(fh,sprintf('%s/settlingtime_waveform.png',pngpath));
  
  % save the analysis data for make_paper_plots
  vars_to_save = {'m2b','m3b','m4b','q','s', ...
                  'inV','outV','settling_time','gain', ...
                  'valid_settime','opt_r','opt_c', 'measID', ...
                  'waveform_save', 'wss'};
  save([ana_folder '/ana_results.mat'],vars_to_save{:},'-v7');
end % end-function generate_colormap






%%%%%%%%%%%%%%%%%%%%%%%%%%
%    helper functions    %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [retval] = meas_to_rc_translator(ana_folder,inval)
% note: this function relies on results.txt

    q=load([ana_folder '/results.txt']);
    q=sortrows(q,1);

    s.measid=1;
    s.vcc=2;
    s.gnd=3;
    s.m2br=4;
    s.m3br=5;
    s.m4br=6;
    s.m5br=7; % note: this is nothing for the amp
    s.inval=8;
    s.outval=9;
    s.settime=10;

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
        if (   (floor(inval(1))==inval(1))  &&   (floor(inval(2))==inval(2))    )
            % probably an rc index pair
            % translate an r/c pair into a meas num
            m2b_val = m2b(inval(1));
            m4b_val = m4b(inval(2));

        else
            % probably is a specific bias setting
            m2b_val = inval(1);
            m4b_val = inval(2);
        end
        res = q(   q(:,s.m2br)==m2b_val, : );
        res = res( res(:,s.m4br)==m4b_val, : );
        retval = res(1);
    end
end  % end-function meas_to_rc_translator

function plot_colormap(m4b,m2b,data,rc)
    imagesc(m4b,m2b,data); colorbar
    set(gca,'YDir','normal');
    xlabel('m4b (V)')
    ylabel('m2b (V)')
    colormap jet

    if (exist('rc','var'))
        hold on
        plot(m4b(rc(2)),m2b(rc(1)),'wx')
        hold off
    end
end

function plot_specific_meas(ana_folder,measID)
    q=load([ana_folder '/meas' sprintf('%04d',measID) '/math2.csv.clean']);
    if exist([ana_folder '/meas' sprintf('%04d',measID) '/math1.csv.clean'])
        qin=load([ana_folder '/meas' sprintf('%04d',measID) '/math1.csv.clean']);
    else
        qin=load([ana_folder '/meas' sprintf('%04d',measID) '/ch1.csv.clean']);
    end
    plot(q(:,1),q(:,2)-mean(q(:,2)),'-o','LineWidth',1.5)
    hold on
    plot(qin(:,1),qin(:,2)-abs(min(q(:,2)-mean(q(:,2))))-0.015,'r')
    hold off
    legend('output','input')
end  % end-function plot_specific_meas

