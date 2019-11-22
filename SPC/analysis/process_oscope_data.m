
% analysis folder
global gainfac;  % temporary patch for mis-atten data, delete after 20191119T101410 is no longer needed
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191111T172723'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191113T165352'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191114T100721'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191115T105635'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191118T101600'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191119T101410'; gainfac=10;  % scope acq = 300; script acq = 300
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/attic/20191120T135534'; gainfac=1;   % scope acq = 400; script acq = 400 (mistake!)
ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20191121T161359'; gainfac=1;

% clean the oscope data to make it matlab-friendly
clean_oscope_data(ana_folder);

% compute the gain and settling time for each measurement point
analyze_oscope_data(ana_folder);

% generate the visual colormap of the overall results
[m2b, m4b, gain, outV]=generate_colormap(ana_folder);

% debug code
%[amplifier_input,amplifier_output,settling_time]=analyze_oscope_amp([ana_folder '/meas0336'])






%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    analysis functions    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clean_oscope_data(ana_folder)

    resfile = [ana_folder '/vbiases.txt' ];
    if (exist(resfile,'file'))
        fprintf(1,'Found existing resfile (%s)... skipping clean_oscope_data\n',resfile);
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
        [xx odat]=system(sprintf('./process_oscope_data_helper.sh %s',measdir));
        % remove last character from odat (newline)
        % and save into the all cell
        odat_all{fidx}=odat(1:end-1);
    end
    
    % save odat_all to a file
    fid = fopen(resfile,'w');
    fprintf(fid,'%s\n',odat_all{:});
    fclose(fid);
  
end % end-function clean_oscope_data


function analyze_oscope_data(ana_folder)

    % load the vbias data
    vb_file = [ana_folder '/vbiases.txt'];
    vb_dat = load(vb_file);

    % walk through every meas and analyze
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
   
end % end-function analyze_oscope_data


function [amplifier_input,amplifier_output,settling_time]=analyze_oscope_amp(measdir)

  debug=false;
  
  % assuming input and output csv files
  incsv=[measdir '/math1.csv.clean'];
  if(~exist(incsv,'file'))
    incsv=[measdir '/ch1.csv.clean'];
  end
  outcsv=[measdir '/math2.csv.clean'];
  % load the files
  in=load(incsv);
  out=load(outcsv);
  % define signal variables
  invals=in(:,2);
  outtime=out(:,1);
  outvals=out(:,2);

  % method: examine only the falling-edge part of the data
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
  
  % truncate the signal to a single waveform
  idx_range = in_falling_idx(2)-30 : in_falling_idx(3)-10;
  invals_single=invals(idx_range);
  outtime_single=outtime(idx_range);
  outvals_single=outvals(idx_range);
 
  % find the index where invals is largest
  [~, idx]=max(abs(diff(invals_single)));
  idx=idx-1;  % try to shift back a little bit to find the true start

  % figure out the input size
  amplifier_input = max(invals_single) - min(invals_single);
  % calculate starting base V by averaging all points up to the input pulse
  baseV = mean(outvals_single(1:idx));
  % figure out the output size (normalized to baseV)
  amplifier_output = max(outvals_single) - baseV;
  
  
  % calculate settling time
  % first attempt... smooth with 1/20th width sliding window
  % note: this makes amp-max very inaccurate.
  %       do not use outvals_smooth to derive amp-max!!
  smooth_span = round(numel(outvals_single)/20);
  outvals_smooth = movmean(outvals_single,smooth_span);
  % define the threshold (absolute value)
  settling_time_threshold = abs(amplifier_output*0.05);
  % the find point where it crosses above/below the threshold
  crossAbove = find(outvals_smooth > (baseV+settling_time_threshold) );
  crossBelow = find(outvals_smooth < (baseV-settling_time_threshold) );
  % note: both variables SHOULD contain an array of index values, but if
  % could also return empty, so ensure they always have a value
  % perhaps this should throw an error instead?
  if (numel(crossAbove) == 0); crossAbove=1; end
  if (numel(crossBelow) == 0); crossBelow=1; end
  % take the right-most value of the two
  if (crossAbove(end) > crossBelow(end))
    settling_idx = crossAbove(end);
  else
    settling_idx = crossBelow(end);
  end
  settling_time = outtime_single(settling_idx) - outtime_single(idx);

  
  if debug
      close all
      figure(7)
      plot(invals,'b')
      hold on
      plot(outvals,'r')
      plot(in_falling_idx,invals(in_falling_idx),'kx')
      plot(in_falling_idx(2)-10,invals(in_falling_idx(2)-10),'ro')
      plot(in_falling_idx(3)-10,invals(in_falling_idx(3)-10),'go')
      legend('invals','outvals','falling idx all','falling idx start','falling idx end')
      hold off
  
      figure(8)
      plot(outtime,outvals,'b')
      hold on
      plot(outtime_single,outvals_smooth,'r')
      plot([outtime(1) outtime(end)],[baseV baseV],'k')
      plot([outtime(1) outtime(end)],[baseV+settling_time_threshold baseV+settling_time_threshold],'c')
      plot([outtime(1) outtime(end)],[baseV-settling_time_threshold baseV-settling_time_threshold],'c')
      plot(outtime_single(crossAbove),outvals_smooth(crossAbove),'go')
      plot(outtime_single(crossBelow),outvals_smooth(crossBelow),'kx')
      plot(outtime_single(idx),outvals_smooth(idx),'rs')
      legend('outvals','outvals smooth','threshold mean','threshold upper','threshold lower','values above','values below','inval_start')
      hold off
  end
  
end % function analyze_oscope_amp


function [ m2b,m4b,gain,outV ] = generate_colormap(ana_folder)
  
  global gainfac;  % todo - remove this and gainfac below when no longer needed

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
  outV = outV*gainfac;  % special patch for older mis-calibrated atten measurements (up to 20191119T101410)
  settling_time = reshape(q(:,s.settime),[numel(m4b) numel(m2b)]);
  settling_time = settling_time'; % transpose to match the orientation of the simulations
  
  
%{
  % very special patch to force 0-6V m2b/m4b sweep
  % find index boundaries to slice the data with
  % NOTE: plot_specific_meas does NOT work in this mode! (the rc->meas translation is wrong)
  warning('Artifically shifting data to 0-6V... plot_specific_meas is NOT VALID in this mode!')
  m2b_low  = find(m2b==0);
  m2b_high = find(m2b==4);
  m4b_low  = find(m4b==0);
  m4b_high = find(m4b==4);
  % artificially set the m2b/m4b to the correct ranges
  m2b = 0:0.1:6;
  m4b = 0:0.25:6;
  % pre-alloc the new data
  inV2           = nan([numel(m2b) numel(m4b)]);
  outV2          = nan([numel(m2b) numel(m4b)]);
  settling_time2 = nan([numel(m2b) numel(m4b)]);
  % slice out the data
  inV_slice           = inV(          m2b_low:m2b_high, m4b_low:m4b_high);
  outV_slice          = outV(         m2b_low:m2b_high, m4b_low:m4b_high);
  settling_time_slice = settling_time(m2b_low:m2b_high, m4b_low:m4b_high);
  % stuff it into the array
  inV2(          1:size(inV_slice,1),1:size(inV_slice,2))                     = inV_slice;
  outV2(         1:size(outV_slice,1),1:size(outV_slice,2))                   = outV_slice;
  settling_time2(1:size(settling_time_slice,1),1:size(settling_time_slice,2)) = settling_time_slice;
  inV = inV2;
  outV = outV2;
  settling_time = settling_time2;
%}
  
  
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
  % report the "best" conditions (lowest settling time)
  %best_gain = gain(settime_r,settime_c);
  %best_time = settling_time(settime_r,settime_c);

  
  % plot metrics
  pngpath = [ana_folder '/pngs'];
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

  % plot - waveform of max gain
  measID=meas_to_rc_translator(ana_folder,[gain_r gain_c]);
  fh=figure(5);
  plot_specific_meas(ana_folder,measID);
  title(sprintf('Waveform of max outV (meas %d - outV = %f; gain = %f; settling time = %f',measID,outV(gain_r,gain_c),gain(gain_r,gain_c),settling_time(gain_r,gain_c)))
  saveas(fh,sprintf('%s/gain_waveform.png',pngpath));
  
  % plot - waveform of lowest settling time
  measID=meas_to_rc_translator(ana_folder,[settime_r settime_c]);
  fh=figure(6);
  plot_specific_meas(ana_folder,measID);
  title(sprintf('Waveform of min settling time (meas %d - outV = %f; gain = %f; settling time = %f',measID,outV(settime_r,settime_c),gain(settime_r,settime_c),settling_time(settime_r,settime_c)))
  saveas(fh,sprintf('%s/settlingtime_waveform.png',pngpath));


  
end % end-function generate_colormap






%%%%%%%%%%%%%%%%%%%%%%%%%%
%    helper functions    %
%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    qin=load([ana_folder '/meas' sprintf('%04d',measID) '/math1.csv.clean']);
    plot(q(:,1),q(:,2)-mean(q(:,2)),'LineWidth',1.5)
    hold on
    plot(qin(:,1),qin(:,2)-abs(min(q(:,2)-mean(q(:,2))))-0.015,'r')
    hold off
    legend('output','input')
end  % end-function plot_specific_meas

