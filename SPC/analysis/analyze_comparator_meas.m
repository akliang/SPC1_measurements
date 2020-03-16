
global best_vbias;
global best_vthresh;
global input_type;
% running an explicit clear since the normal clear does not clear globals
clear global input_type
global fign
fign = 0;

%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200122T164209_29D1-8_WP5_2-4-3_schmitt';  % first full acq of comparator
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200127T171505_29D1-8_WP5_2-4-3_schmitt';  % second full acq of comparator
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200129T173850_29D1-8_WP5_2-4-3_schmitt';  best_vbias = 0.5; best_vthresh=0; % third full acq of comparator
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200309T123730_29D1-8_WP5_2-4-3_schmitt';  best_vbias = 1; best_vthresh=3; % fourth full acq of comparator, 100 khz, improper load termination
ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200309T150149_29D1-8_WP5_2-4-3_schmitt';  best_vbias = 1; best_vthresh=3; % fourth full acq of comparator, 100 khz, fixed load termination
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200311T161607_29D1-8_WP5_2-4-3_schmitt';  best_vbias = NaN; best_vthresh=NaN;  % count rate sweep at vbias(1) and vthresh(3)
ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200312T170353_29D1-8_WP5_2-4-3_schmitt';  best_vbias = 1; best_vthresh=3;  % full acq with ramp 0-4.5V so hystersis curve looks more symmetrical

addpath('./helper_functions');
% clean the oscope data to make it matlab-friendly
clean_oscope_data(ana_folder);
% load the vbias data
vb_dat = load([ana_folder '/vbiases.txt']);

%%{
% walk through every meas and analyze
global waveform_save;
waveform_save={};
ana_res_all = zeros([size(vb_dat,1) 7]);
for fidx=1:size(vb_dat,1)
    if (mod(fidx,10)==0)
        fprintf(1,'Progress: Analyzing meas %d/%d\n',fidx,size(vb_dat,1));
    end

    measdir=sprintf('%s/meas%04d',ana_folder,vb_dat(fidx,1));
    [minout, maxout, deltaout, rising_thresh, falling_thresh, hysteresis, frequency] = analyze_comparator_oscope_data(measdir);
    ana_res_all(fidx,:) = [minout, maxout, deltaout, rising_thresh, falling_thresh, hysteresis, frequency];
end

% concat vbiases and ana results and write the results file
alldat = [vb_dat ana_res_all];
resfile = [ana_folder '/results.txt' ];
csvwrite(resfile,alldat);
%}

close all; generate_colormap(ana_folder);

function [minout, maxout, deltaout, rising_thresh, falling_thresh, hysteresis, frequency] = analyze_comparator_oscope_data(measdir)

  global waveform_save;
  global wss;
  global input_type;
  global fign;
  
  debug=false;
  
  % load in and out files
  in_raw=load([measdir '/ch1.csv.clean']);
  if exist([measdir '/math2.csv.clean'])
      out_raw = load([measdir '/math2.csv.clean']);
  else
    out_raw=load([measdir '/ch2.csv.clean']);
  end
  
  
  % one-time detection to try to determine if in_raw is a square wave or ramp
  if (numel(input_type) == 0)
      % draw 2 thresholds and compare results, if similar then it should be square wave
      in_raw_delta = max(in_raw(:,2)) - min(in_raw(:,2));
      in_raw_delta = (in_raw_delta + min(in_raw(:,2))) /2;
      in_test1 = (in_raw(:,2) > in_raw_delta*0.4);
      in_test2 = (in_raw(:,2) > in_raw_delta*0.6);
      
      if debug
          fign = fign+1;
          figure(fign)
          plot(in_raw(:,2))
          hold on
          plot(out_raw(:,2),'r')
          hold off
      end
  
      % noise in the signal can cause the high-low transistions to jitter, use a threshold to detect square waves
      if (abs(sum(in_test1 - in_test2)) < 10)
          fprintf(1,'Square wave detected for in_raw, using ch1 as the trig_raw\n');
          input_type = 'square';
      else
          fprintf(1,'Using ch4 as the trig_raw\n');
          input_type = 'ramp';
      end
  end
  if (strcmp(input_type,'square'))
      trig_raw = in_raw;
  else
      trig_raw=load([measdir '/ch4.csv.clean']);
  end
  trig = trig_raw(:,2);
    
  % segment out a single waveform
  % due to jittery noise, purposely look for pos edge slightly above mean and neg edge slightly below mean
  pos_trig_edges = find(diff(trig > mean(trig)*.6) == 1)';
  neg_trig_edges = find(diff(trig > mean(trig)*.4) == -1)';
  if (strcmp(input_type,'square'))
    % noise in the signal can cause the high-low transistions to jitter
    % make sure the jumps between pos_trig_edges is a true jump and not jitter
    trig_edge_idx_mean = mean(diff(pos_trig_edges));
    % for a normal case, trig_edge_mean will accidentall remove half of the valid points, so set threshold a moderate amount below the mean
    % for jittery cases, this moderate threshold should still detect the jitter since jitter diff is far below the mean
    % for very jittery cases, this could break down if the mean gets dragged down too low
    trig_edge_selector = (diff(pos_trig_edges) > trig_edge_idx_mean*0.75);
    % diff always loses an element, so pad a 1 to the end of the logical
    trig_edge_selector = [trig_edge_selector true];
    % select out the pos_trig_edges using the logical filter
    pos_trig_edges = pos_trig_edges(trig_edge_selector);
    
    % next, extreme jitter can cause a neg_edge to also look like pos_edge
    % so, compared a few points left and right of this point to double-check that its a pos edge
    pos_idx_delta = 10;  % how many idx left and right to look
    % trim off pos_trig_edges that are too close to beginning or end and fall out of the delta range
    if (pos_trig_edges(1) < pos_idx_delta)
        pos_trig_edges = pos_trig_edges(2:end);
    end
    if (pos_trig_edges(end)+pos_idx_delta > numel(trig))
        pos_trig_edges = pos_trig_edges(1:end-1);
    end
    % step through every pos_trig_edge and check that the left side is less than the right side
    for pos_idx = 1:numel(pos_trig_edges)
        if ~(  trig(pos_trig_edges(pos_idx)-pos_idx_delta)  <  trig(pos_trig_edges(pos_idx)+pos_idx_delta)  )
            % false pos edge detected, so mark it to be dropped later
            pos_trig_edges(pos_idx) = NaN;
        end
    end
    % drop all NaN entries
    pos_trig_edges = pos_trig_edges(~isnan(pos_trig_edges));
    
    % finally, pick out the edges to further process
    rampminL = pos_trig_edges(1);
    rampminR = pos_trig_edges(2);
  elseif (strcmp(input_type,'ramp'))
      % find the first rampmin
      [~, rampminL] = min(in_raw(neg_trig_edges(1):neg_trig_edges(2),2));
      rampminL = rampminL+neg_trig_edges(1);
      % find the second rampmin
      [~, rampminR] = min(in_raw(neg_trig_edges(2):neg_trig_edges(3),2));
      rampminR = rampminR + neg_trig_edges(2);
      % find the rampmax between these two points
      [~, rampmax] = max(in_raw(rampminL:rampminR,2));
      rampmax = rampmax + rampminL;
  end
  % finally, segment out the data from one rampmin to the other
  time = out_raw(rampminL:rampminR,1);
  outvals = out_raw(rampminL:rampminR,2);
  invals = in_raw(rampminL:rampminR,2);
  trig = trig_raw(rampminL:rampminR,2);
  
  % find the intersection in the left half (rising edge)
  [~, intersectL] = min(abs(invals(1:round(end/2))-outvals(1:round(end/2))));
  % find the intersection in the right half (falling edge)
  [~, intersectR] = min(abs(invals(round(end/2):end)-outvals(round(end/2):end)));
  intersectR = intersectR + round(numel(invals)/2)-1;  % minus 1 to fix index offset from dividing in half
  
  % output metrics
  minout = min(outvals);
  maxout = max(outvals);
  deltaout = maxout - minout;
  rising_thresh  = invals(intersectL);
  falling_thresh = invals(intersectR);
  hysteresis = abs(rising_thresh - falling_thresh);
  frequency = 1/(time(end) - time(1));
  
  if debug
      fign = fign+1;
      figure(fign)
      plot(time,invals)
      hold on
      plot(time,outvals,'r')
      plot(time,trig,'g')
      plot(time(intersectL),invals(intersectL),'bx')
      plot(time(intersectR),invals(intersectR),'bx')
      hold off
      title(sprintf('%s',measdir))
  end

  % save this data into a master data cell
  [~, measID, ~] = fileparts(measdir);
  measID = str2num(strrep(measID,'meas',''));
  wss.time = 1;
  wss.invals = 2;
  wss.outvals = 3;
  wss.trig = 4;
  wss.deltaout = 5;
  wss.hysteresis = 6;
  wss.rampminL = 7;
  wss.rampminR = 8;
  wss.rampmax = 9;
  wss.intersectL = 10;
  wss.intersectR = 11;
  wss.minout = 12;
  wss.maxout = 13;
  waveform_save{measID} = {time, invals, outvals, trig, deltaout, hysteresis, rampminL, rampminR, rampmax, intersectL, intersectR, minout, maxout};

end

function generate_colormap(ana_folder)

  global waveform_save;
  global wss;
  global s;
  global best_vbias;
  global best_vthresh;
  global fign;

  [~, filename, ~] = fileparts(ana_folder);
  set(0,'defaultTextInterpreter','none');

  q=load([ana_folder '/results.txt']);
  q=sortrows(q,1);

  s.measid=1;
  s.vcca=2;
  s.gnda=3;
  s.vccd=4;
  s.gndd=5;
  s.vbias=6;
  s.vthresh=7;
  s.minout=8;
  s.maxout=9;
  s.deltaout=10;
  s.rising_thresh=11;
  s.falling_thresh=12;
  s.hysteresis=13;
  s.frequency=14;

  vbias=sort(unique(q(:,s.vbias)));
  vthresh=sort(unique(q(:,s.vthresh)));

  if (numel(vbias)==1)
      fprintf(1,'Count rate run detected, using plotCR instead\n');
      plot_countrate(ana_folder)
      return
  end
  
  % this reshape actually covers up the missing SMU data points!
  deltaout = reshape( q(:,s.deltaout),[numel(vthresh) numel(vbias)]);
  hysteresis = reshape( q(:,s.hysteresis),[numel(vthresh) numel(vbias)]);
  % transpose to the "slower changing" dimension is in the y-direction
  deltaout = deltaout';
  hysteresis = hysteresis';
  
  % create folder to save analysis PNGs
  pngpath = [ana_folder '/analysis_pngs'];
  if ~exist(pngpath,'dir'); mkdir(pngpath); end
  
  % find the "best point" (note: hard-coding opt_r and opt_c instead of using this code)
  % currently defined as hysteresis between 0.25 and 0.5V
  % and then maximum delta out
  valid_idx1 = (hysteresis>0.25);
  valid_idx2 = (hysteresis<0.5);
  valid_idx = valid_idx1 .* valid_idx2;
  valid_deltaout = deltaout .* valid_idx;
  valid_deltaout(valid_deltaout==0) = NaN;
  [opt_r, opt_c] = find(valid_deltaout == max(max(valid_deltaout)));
  fprintf(1,'Number of opt_r = %d ; Number of opt_c = %d\n',numel(opt_r),numel(opt_c));
  opt_r = opt_r(1);  opt_c = opt_c(1);
  % note: opt_r and opt_c algorithm doesnt work well right now, assuming hard coded values
  opt_r = find(vbias == best_vbias);
  opt_c = find(vthresh == best_vthresh);
  
  % find the measID of opt_r and opt_c
  % note: this is using a different method than analyze_amplifier_meas uses
  valid_idx1 = find(q(:,s.vbias)==vbias(opt_r));
  valid_idx2 = find(q(valid_idx1,s.vthresh)==vthresh(opt_c));
  valid_idx = valid_idx1(valid_idx2);
  measID = q(valid_idx,1);
  
  
  fign = fign+1;
  figure(fign)
  % faster changing dimension (vthresh) goes first (x-dir)
  imagesc(vthresh,vbias,deltaout); colorbar
  set(gca,'YDir','normal');
  xlabel('Vthresh (V)')
  ylabel('Vbias (V)')
  colormap jet
  title(sprintf('Delta between comparator off and on (%s)', filename))
  caxis([0 8])
  saveas(gcf,[pngpath '/deltaout.png']);

  fign = fign+1;
  figure(fign)
  imagesc(vthresh,vbias,hysteresis); colorbar
  set(gca,'YDir','normal');
  xlabel('Vthresh (V)')
  ylabel('Vbias (V)')
  colormap jet
  title(sprintf('Hysteresis of comparator (%s)', filename))
  caxis([0 2.5])
  saveas(gcf,[pngpath '/hysteresis.png']);
  
  
  % save the analysis data for make_paper_plots
  vars_to_save = {'vbias','vthresh','q','s', ...
                  'deltaout','hysteresis', ...
                  'opt_r','opt_c', 'measID', ...
                  'waveform_save', 'wss'};
  save([ana_folder '/ana_results.mat'],vars_to_save{:},'-v7');


  % plot_specific_meas depends on ana_result.m existing, so it has to go here
  plot_specific_meas(ana_folder, [vbias(opt_r) vthresh(opt_c)]);

end

function plot_countrate(ana_folder)
  global s;
  global vbias;
  global vthresh;
  global fign;

  % create folder to save analysis PNGs
  pngpath = [ana_folder '/analysis_pngs'];
  if ~exist(pngpath,'dir'); mkdir(pngpath); end

  q=load([ana_folder '/results.txt']);
  q=sortrows(q,1);

  % find the max count rate
  % first, find the mean of the deltaout when the circuit is functioning
  deltaout_idx = (q(:,s.deltaout) > mean(q(:,s.deltaout)));
  % find the level that's 95-percent of the total
  deltaout_mean = mean(q(deltaout_idx,s.deltaout));
  cr_max_idx = (q(:,s.deltaout) > deltaout_mean*0.95);
  cr_max_idx = find(diff(cr_max_idx)==-1)+1;
  cr_max = q(cr_max_idx,s.frequency);
 
  fign = fign+1; 
  figure(fign)
  semilogx(q(:,s.frequency),q(:,s.deltaout), 'r-o')
  hold on
  plot(q(cr_max_idx,s.frequency),q(cr_max_idx,s.deltaout),'kx')
  hold off
  title(sprintf('Count rate plot - max count rate: %f',cr_max))
  xlabel('Frequency')
  ylabel('Output voltage')
  saveas(gcf,[pngpath '/count_rate.png']);

  % save the analysis data for make_paper_plots
  vars_to_save = {'vbias','vthresh','q','s', ...
                  'deltaout_mean','cr_max','cr_max_idx'};
  save([ana_folder '/ana_results.mat'],vars_to_save{:},'-v7');

end

function plot_specific_meas(ana_folder, input)

  global s;
  global fign;

  [~, filename, ~] = fileparts(ana_folder);
  set(0,'defaultTextInterpreter','none');

  q=load([ana_folder '/results.txt']);
  q=sortrows(q,1);

  if (numel(input)==2)
      vbias = input(1);
      vthresh = input(2);
      idx1 = (q(:,s.vbias)==vbias);
      idx2 = (q(:,s.vthresh)==vthresh);
      idx = find( (idx1 .* idx2) == 1 );
  else
      idx = input;
  end
  
  measdir = [ana_folder '/' sprintf('/meas%04d',idx)];
  qin = load([measdir '/ch1.csv.clean']);
  if (exist([measdir '/math2.csv.clean']))
      qout = load([measdir '/math2.csv.clean']);
  else
      qout = load([measdir '/ch2.csv.clean']);
  end
  
  % waveform plot
  fign = fign+1;
  figure(fign)
  plot(qin(:,1),qin(:,2))
  hold on
  plot(qout(:,1),qout(:,2),'r')
  hold off
  saveas(gcf,[ana_folder sprintf('/analysis_pngs/meas%04d.png',idx)]);

  % hysteresis plot
  qmat = load([ana_folder '/ana_results.mat']);
  qwaveform_save = qmat.waveform_save{idx};
  qrampminL = qwaveform_save{qmat.wss.rampminL};
  qrampminR = qwaveform_save{qmat.wss.rampminR};
  qrampmax  = qwaveform_save{qmat.wss.rampmax};
  fign = fign+1;
  figure(fign)
  plot(qin(qrampminL:qrampminR,1),qin(qrampminL:qrampminR,2))
  hold on
  plot(qout(qrampminL:qrampminR,1),qout(qrampminL:qrampminR,2),'r')
  plot(qin(qrampmax,1),qin(qrampmax,2),'ko');
  hold off
  
  % segment out the rising ramp data from the falling ramp data
  rise_dat_in  = qin(qrampminL:qrampmax,2);
  rise_dat_out = qout(qrampminL:qrampmax,2);
  fall_dat_in  = qin(qrampmax:qrampminR,2);
  fall_dat_out = qout(qrampmax:qrampminR,2);
  
  fign = fign+1;
  figure(fign)
  plot(rise_dat_in,rise_dat_out);
  hold on
  plot(fall_dat_in,fall_dat_out,'r');
  hold off
  
  
  

end
