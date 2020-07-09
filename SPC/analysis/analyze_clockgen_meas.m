

global best_vbias;
global best_vthresh;
global input_type;
% running an explicit clear since the normal clear does not clear globals
clear global input_type
global fign
fign = 0;
set(0,'defaultTextInterpreter','none');

%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200318T094629_29D1-8_WP8_4-6-10_2SR3inv_manual';  % first full acq of clockgen (not enough phi1-phi2 pulses for below analysis)
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200319T204404_29D1-8_WP8_4-6-10_2SR3inv'; % second full acq

ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200319T210650_29D1-8_WP8_4-6-10_2SR3inv'; % third acq with wider data frame (more pulses per frame) and higher freq sweep

addpath('./helper_functions');
% clean the oscope data to make it matlab-friendly
clean_oscope_data(ana_folder);
% load the vbias data
vb_dat = load([ana_folder '/vbiases.txt']);

%%{
% walk through every meas and analyze
global waveform_save;
waveform_save={};
ana_res_all = zeros([size(vb_dat,1) 4]);
for fidx=1:size(vb_dat,1)
%for fidx=1
    if (mod(fidx,10)==0)
        fprintf(1,'Progress: Analyzing meas %d/%d\n',fidx,size(vb_dat,1));
    end

    measdir=sprintf('%s/meas%04d',ana_folder,vb_dat(fidx,1));
    [in_freq, phi1_deltaout, phi2_deltaout, phi1_ratio] = analyze_clockgen_oscope_data(measdir);
    ana_res_all(fidx,:) = [in_freq, phi1_deltaout, phi2_deltaout, phi1_ratio];
end

% concat vbiases and ana results and write the results file
alldat = [vb_dat ana_res_all];
resfile = [ana_folder '/results.txt' ];
csvwrite(resfile,alldat);
%}

close all;
calc_and_plot_results(ana_folder);



function [in_freq, phi1_deltaout, phi2_deltaout, phi1_ratio] = analyze_clockgen_oscope_data(measdir)

  global waveform_save;
  global wss;
  global fign;
  
  debug=false;
  
  % load in and out files
  in_raw=load([measdir '/ch1.csv.clean']);
  out1_raw=load([measdir '/ch2.csv.clean']);
  out2_raw=load([measdir '/ch3.csv.clean']);
  time = in_raw(:,1);
  
  % set default variable values in case the loop bails out
  phi1_idx = [];
  phi2_idx = [];
  phi1_deltaout = NaN;
  phi2_deltaout = NaN;
  
  % step through the waveforms and derive various metrics
  for idx=1:3
      if (idx==1)
          indat = in_raw(:,2);
      elseif (idx==2)
          indat = out1_raw(:,2);
      else
          indat = out2_raw(:,2);
      end
      
      % universally needed values
      indat_mean = mean([min(indat) max(indat)]);
      % sometimes there is no phi1 or phi2 response whatsoever, so ensure the indat_mean is at least something sensible
      if (indat_mean < 2); indat_mean=2; end
      indat_upper = (indat > indat_mean*1.25);
      indat_lower = (indat < indat_mean*0.75);
      pos_edges_idx = find( diff(indat_upper) == 1 );
      neg_edges_idx = find( diff(indat_upper) == -1);
      % if not enough edges detected, then bail out of this loop
      if (numel(pos_edges_idx) < 2) || (numel(neg_edges_idx) < 2)
          %fprintf(1, 'Not enough phi edges detected, skpping...\n');
          continue
      end
      
      % if the edges are too close to the beginning or end of waveform, then drop it
      idx_delta = 5;
      if (pos_edges_idx(1) < idx_delta); pos_edges_idx = pos_edges_idx(2:end); end
      if (neg_edges_idx(1) < idx_delta); neg_edges_idx = neg_edges_idx(2:end); end
      if (pos_edges_idx(end)+idx_delta > numel(indat)); pos_edges_idx = pos_edges_idx(1:end-1); end
      if (neg_edges_idx(end)+idx_delta > numel(indat)); neg_edges_idx = neg_edges_idx(1:end-1); end
      
      % clean up the edges_idx values (at high frequencies, the edges jitter sometimes)
      % first, make sure the edges are actually a rising or falling edge
      % step through every pos_edges_idx and check that the left side is less than the right side
      for edges_idx = 1:numel(pos_edges_idx)
          if ~(  indat(pos_edges_idx(edges_idx)-idx_delta)  <  indat(pos_edges_idx(edges_idx)+idx_delta)  )
              % false pos edge detected, so mark it to be dropped later
              pos_edges_idx(edges_idx) = NaN;
          end
      end
      % drop all NaN entries
      pos_edges_idx = pos_edges_idx(~isnan(pos_edges_idx));
      % step through every neg_edges_idx and check that the left side is greater than the right side
      for edges_idx = 1:numel(neg_edges_idx)
          if ~(  indat(neg_edges_idx(edges_idx)-idx_delta)  >  indat(neg_edges_idx(edges_idx)+idx_delta)  )
              % false pos edge detected, so mark it to be dropped later
              neg_edges_idx(edges_idx) = NaN;
          end
      end
      % drop all NaN entries
      neg_edges_idx = neg_edges_idx(~isnan(neg_edges_idx));
      
      %{
      % next, sometimes the edges are not sharp and jitter around the threshold
      % remove points that are too close to each other
      pos_edges_idx_mean = mean(diff(pos_edges_idx));
      pos_edges_selector = (diff(pos_edges_idx) > pos_edges_idx_mean*0.75);
      pos_edges_selector = [pos_edges_selector ; true];
      pos_edges_idx = pos_edges_idx(pos_edges_selector);
      neg_edges_idx_mean = mean(diff(neg_edges_idx));
      neg_edges_selector = (diff(neg_edges_idx) > neg_edges_idx_mean*0.75);
      neg_edges_selector = [neg_edges_selector ; true];
      neg_edges_idx = neg_edges_idx(neg_edges_selector);
      %}
      
      % make sure it starts on a pos edge and ends on a neg edge (removes partial pulses)
      if (neg_edges_idx(1) < pos_edges_idx(1))
          neg_edges_idx = neg_edges_idx(2:end);
      end
      if (pos_edges_idx(end) > neg_edges_idx(end))
          pos_edges_idx = pos_edges_idx(1:end-1);
      end
      
      
      % perform calculations based on which waveform it is
      if (idx==1)
          % find the frequency of the input clock
          tmp = time(pos_edges_idx(2)) - time(pos_edges_idx(1));
          in_freq = 1/tmp;
          in_idx = pos_edges_idx;
      else
          % find max deltaout for out1 and out2
          % purely taking min and max will grab points from different pulses (since the raw waveform should contain several pulses)
          % instead, threshold across middle, then get the mean of the upper- and lower-halves then subtract
          % gotta calculate the mean manually since the waveform is heavily weighted towards zero
          indat_upper_mean = mean(indat(indat_upper));
          indat_lower_mean = mean(indat(indat_lower));
          indat_delta = indat_upper_mean - indat_lower_mean;
          deltaout = indat_delta;
          if (idx==2)
              phi1_idx = pos_edges_idx;
              phi1_deltaout = deltaout;
          else
              phi2_idx = pos_edges_idx;
              phi2_deltaout = deltaout;
          end
      end

  end

  % if there are phi1 and phi2 pulses, then do some more processing
  if (numel(phi1_idx) > 0) && (numel(phi2_idx) > 0)
      % make sure the phi1 and phi2 are a pair
      % drop the first phi2 if it starts before phi1
      if (phi2_idx(1) < phi1_idx(1))
          phi2_idx = phi2_idx(2:end);
      end
      % drop the last phi1 if there is not corresponding phi2
      if (phi1_idx(end) > phi2_idx(end))
          phi1_idx = phi1_idx(1:end-1);
      end
      % drop the first phi1-phi2 pair if there is no in_idx before it
      % a very rare case where the oscope capture gets the output but not the full input pulse
      if (phi1_idx(1) < in_idx(1))
          phi1_idx = phi1_idx(2:end);
          phi2_idx = phi2_idx(2:end);
      end
  end
  phi1_ratio = numel(phi1_idx) / numel(in_idx);
  
  if debug
      close all
      figure
      plot(in_raw(:,1),in_raw(:,2),'c.-')
      hold on
      plot(in_raw(in_idx,1),in_raw(in_idx,2)-1,'co--');
      plot(out1_raw(:,1),out1_raw(:,2),'m');
      plot(out1_raw(phi1_idx,1),out1_raw(phi1_idx,2)-1,'mo--');
      plot(out2_raw(:,1),out2_raw(:,2),'g');
      plot(out2_raw(phi2_idx,1),out2_raw(phi2_idx,2)-1,'go--');
      hold off
  end

  % save this data into a master data cell
  [~, measID, ~] = fileparts(measdir);
  measID = str2num(strrep(measID,'meas',''));
  wss.time = 1;
  wss.invals = 2;
  wss.out1vals = 3;
  wss.out2vals = 4;
  wss.in_idx = 5;
  wss.phi1_idx = 6;
  wss.phi2_idx = 7;
  wss.in_freq = 8;
  wss.phi1_deltaout = 9;
  wss.phi2_deltaout = 10;
  wss.phi1_ratio = 11;
  waveform_save{measID} = {time, in_raw(:,2), out1_raw(:,2), out2_raw(:,2), in_idx, phi1_idx, phi2_idx, in_freq, phi1_deltaout, phi2_deltaout, phi1_ratio};

end

function calc_and_plot_results(ana_folder)

  global waveform_save;
  global wss;
  global s;
  global fign;

  % create folder to save analysis PNGs
  pngpath = [ana_folder '/analysis_pngs'];
  if ~exist(pngpath,'dir'); mkdir(pngpath); end

  q=load([ana_folder '/results.txt']);
  q=sortrows(q,1);

  s.measid=1;
  s.vcca=2;
  s.gnda=3;
  s.vccd=4;
  s.gndd=5;
  s.vbias=6;
  s.vthresh=7;
  s.in_freq=8;
  s.out1_deltaout=9;
  s.out2_deltaout=10;
  s.phi1_ratio=11;
  
  % calculate the maximum count rate
  cr_thresh = 0.95;
  cr_max_idx = find(q(:,s.phi1_ratio) >= cr_thresh);
  cr_max_idx = cr_max_idx(end);
  cr_max = q(cr_max_idx,s.in_freq);
  
  fign = fign+1;
  figure(fign)
  plot(waveform_save{cr_max_idx}{wss.time},waveform_save{cr_max_idx}{wss.invals},'r')
  hold on
  plot(waveform_save{cr_max_idx}{wss.time},waveform_save{cr_max_idx}{wss.out1vals},'b')
  plot(waveform_save{cr_max_idx}{wss.time},waveform_save{cr_max_idx}{wss.out2vals},'g')
  hold off
  

  fign = fign+1;
  figure(fign)
  semilogx(q(:,s.in_freq),q(:,s.phi1_ratio)*100);
  hold on
  v=axis;
  v(4) = 105;
  axis(v);
  plot([cr_max cr_max],[v(3) v(4)],'r--');
  title({'Ratio of output pulses to input pulses', sprintf('Max count rate: %0.2f Hz (thresh: %0.1f%%)',cr_max,cr_thresh*100)});
  xlabel('Frequency');
  ylabel('Output-to-Input Pulse Ratio (%)');
  saveas(gcf,[pngpath '/countrate.png']);
  
  % save the analysis data for make_paper_plots
  vars_to_save = {'q','s', ...
                  'cr_thresh', 'cr_max', 'cr_max_idx', ...
                  'waveform_save', 'wss'};
  save([ana_folder '/ana_results.mat'],vars_to_save{:},'-v7');
end

