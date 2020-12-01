
global fign
fign = 0;
set(0,'defaultTextInterpreter','none');

if exist('/Volumes/ArrayData/MasdaX','dir')
    pathpre = '/Volumes/ArrayData/MasdaX/2018-01/measurements/';
else
    pathpre = '~/Desktop/ArrayData/MasdaX/2018-01/measurements/';
end

% attic
%ana_folder = [pathpre 'single_shots/20200816T999999'];  % a collection of single-shot diffRes counter measurements
%ana_folder = [pathpre 'single_shots/20200831T999999_diffTFT_countrate'];  % a collection of single-shot diffTFT counter measurements
%ana_folder = [pathpre 'single_shots/20200831T230338_diffTFT_phitransition'];  % phi locking for diffTFT


ana_folder = [pathpre '20200903T231310_29D1-5_WP6_3-2-5_diffTFT_50steps'];


addpath('./helper_functions');
% clean the oscope data to make it matlab-friendly
clean_oscope_data(ana_folder);
% load the vbias data
vb_dat = load([ana_folder '/vbiases.txt']);

%%{
% walk through every meas and analyze
global waveform_save;
waveform_save={};
ana_res_all = zeros([size(vb_dat,1) 3]);
for fidx=1:size(vb_dat,1)
%for fidx=21:50
    if (mod(fidx,10)==0)
        fprintf(1,'Progress: Analyzing meas %d/%d\n',fidx,size(vb_dat,1));
    end

    measdir=sprintf('%s/meas%04d',ana_folder,vb_dat(fidx,1));
    [in_freq, out1_vdiff, out2_vdiff]=analyze_counter_oscope_data(measdir);
    ana_res_all(fidx,:) = [in_freq, out1_vdiff, out2_vdiff];
end

% concat vbiases and ana results and write the results file
alldat = [vb_dat ana_res_all];
resfile = [ana_folder '/results.txt' ];
dlmwrite(resfile,alldat,'delimiter',',','precision',10);
%}

close all;
calc_and_plot_results(ana_folder);
plot_specific_meas(49)



function [in_freq, out1_vdiff, out2_vdiff]=analyze_counter_oscope_data(measdir)

  global waveform_save;
  global wss;
  global fign;
  
  debug=false;
  
  % load in and out files
  phi_raw =load([measdir '/ch1.csv.clean']);
  out1_raw=load([measdir '/ch2.csv.clean']);
  out2_raw=load([measdir '/ch3.csv.clean']);
  time = phi_raw(:,1);
  
  % set default variable values in case the loop bails out
  % TODO?
  
  % calculate the frequency
  mean_sig = (max(phi_raw(:,2)) - min(phi_raw(:,2)))/2;  % find the mean signal based on min/max
  mean_sig = mean_sig + min(phi_raw(:,2));  % make it an absolute value instead of relative
  idx_above = (phi_raw(:,2) > mean_sig);  % threshold the signal
  pos_edges = find(diff(idx_above)==1)+1;  % add one because diff loses an idx
  neg_edges = find(diff(idx_above)==-1)+1;  % add one because diff loses an idx
  neg_edges = neg_edges+0.1;  % mark which idx are neg edges before sorting
  all_edges = sort([pos_edges ; neg_edges]);
  % make sure the first edge is a falling edge
  if floor(all_edges(1)) == all_edges(1)
      all_edges = all_edges(2:end);
  end
  % walk through the array and subtract each pair of pos and neg edge
  edge_diffs=[];
  for eidx=2:2:numel(all_edges)
      edge_diffs(end+1) = round(all_edges(eidx) - all_edges(eidx-1));
  end
  time_delta = mode(edge_diffs);
  in_freq = time(time_delta) - time(1);
  in_freq = in_freq / 9;  % since the freq calculation actually derives the negative space between pulses, find out what the actual high pulse was
  in_freq = 1/in_freq;  % convert to Hz
  in_freq = in_freq / 2;  % half the frequency since we probably want the max CR with a 50-percent duty cycle pulse
  % note: in_freq calculation above almost works but is buggy if the siggen is bouncing too much
  % a temporary patch is to auto-generate in_freq based on the python script
  freq_vector = logspace(4, 6.5, 50);
  freq_vector = freq_vector * 10;  % because of the 10-percent duty cycle
  in_freq = freq_vector(str2double(regexprep(measdir,'.*meas','')));
  
  % find which idx the out and outbar signal should be switching
  % this one is tricky without the trigger from oscope
  % (TODO: add oscope trigger to ch4?)
  % some settings respond right away to the siggen coming on
  % some only respond when siggen hits 0.5V (siggen starts at 0 V)
  % some dont respond at all because the input is too fast
  % current solution: if out and outbar flip, then use that idx; otherwise find where phi hits 0.5 V (i.e., high) for the first time
  in_idx = find(out1_raw(:,2) > 4);
  if numel(in_idx) ~= 0
      in_idx = in_idx(1);
  else
      in_mean = (max(phi_raw(:,2)) - phi_raw(1,2))/2;
      in_idx = find(phi_raw(:,2) >= in_mean);
      in_idx = in_idx(1);
      [~, in_idx] = min(abs(all_edges - in_idx));
      in_idx = round(all_edges(in_idx));
  end
  
  % calculate the voltage delta of out and outbar
  out1_pre  = mean(out1_raw(1:in_idx,2));
  out1_post = mean(out1_raw(in_idx+1:end,2));
  out1_vdiff = abs(out1_post - out1_pre);
  out2_pre  = mean(out2_raw(1:in_idx,2));
  out2_post = mean(out2_raw(in_idx+1:end,2));
  out2_vdiff = abs(out2_post - out2_pre);
  
  if debug
      %close all
      figure
      plot(phi_raw(:,1),phi_raw(:,2),'m')
      hold on
      plot(phi_raw(in_idx,1),phi_raw(in_idx,2),'mx','MarkerSize',16)
      plot(out1_raw(:,1),out1_raw(:,2),'r');
      plot(out2_raw(:,1),out2_raw(:,2),'b');
      for iii = 1:numel(all_edges)
          if floor(all_edges(iii)) ~= all_edges(iii)
              nowidx=floor(all_edges(iii));
              plot(phi_raw(nowidx,1),phi_raw(nowidx,2),'ro');
          else
              nowidx=all_edges(iii);
              plot(phi_raw(nowidx,1),phi_raw(nowidx,2),'go');
          end
      end
      hold off
  end
  

  % save this data into a master data cell
  [~, measID, ~] = fileparts(measdir);
  measID = str2num(strrep(measID,'meas',''));
  wss.time = 1;
  wss.phivals = 2;
  wss.out1vals = 3;
  wss.out2vals = 4;
  wss.all_edges = 5;
  wss.in_freq = 6;
  wss.out1_vdiff = 7;
  wss.out2_vdiff = 8;
  wss.in_idx = 9;
  wss.out1_pre = 10;
  wss.out1_post = 11;
  wss.out2_pre = 12;
  wss.out2_post = 13;
  waveform_save{measID} = {time, phi_raw(:,2), out1_raw(:,2), out2_raw(:,2), all_edges, in_freq, out1_vdiff, out2_vdiff, in_idx, out1_pre, out1_post, out2_pre, out2_post};
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
  s.vcc=2;
  s.gnd=3;
  s.bias=4;
  s.in=5;
  s.inbar=6;
  s.nothing=7;
  s.in_freq=8;
  s.out1_vdiff=9;
  s.out2_vdiff=10;
  
  % calculate the maximum count rate
  vdiff_thresh = 4;
  cr_max_idx1 = (q(:,s.out1_vdiff) >= vdiff_thresh);
  cr_max_idx2 = (q(:,s.out2_vdiff) >= vdiff_thresh);
  cr_max_idx = find(bitand(cr_max_idx1, cr_max_idx2));
  cr_max_idx = cr_max_idx(end);
  cr_max = q(cr_max_idx,s.in_freq);
  
  %plot_specific_meas(cr_max_idx)
  
  fign = fign+1;
  figure(fign)
  semilogx(q(:,s.in_freq),q(:,s.out1_vdiff), 'ko-');
  hold on
  plot(q(:,s.in_freq),q(:,s.out2_vdiff), 'bo-');
  v=axis;
  plot([cr_max cr_max],[v(3) v(4)],'r--');
  title({'Vidff of out and outbar', sprintf('Max count rate: %0.2f Hz (thresh: %0.1f V)',cr_max,vdiff_thresh)});
  xlabel('Frequency');
  ylabel('Output voltage (V)');
  % mark every 10th point so its easier to know which meas number is going wrong
  for cridx=1:floor(numel(q(:,s.out1_vdiff))/10)
      crnow = cridx*10;
      plot(q(crnow,s.in_freq),q(crnow,s.out1_vdiff),'kx');
  end
  
  saveas(gcf,[pngpath '/countrate.png']);
  
  % save the analysis data for make_paper_plots
  vars_to_save = {'q','s', ...
                  'vdiff_thresh', 'cr_max', 'cr_max_idx', ...
                  'waveform_save', 'wss'};
  save([ana_folder '/ana_results.mat'],vars_to_save{:},'-v7');
end

function plot_specific_meas(measID)
  global fign;
  global waveform_save;
  global wss;
  
  % print some statistics
  fprintf('-----------------\nmeasID: %d\n', measID);

  fign = fign+1;
  figure(fign)
  nowdat = waveform_save{measID};
  time = nowdat{wss.time};
  phivals = nowdat{wss.phivals};
  out1vals = nowdat{wss.out1vals};
  out2vals = nowdat{wss.out2vals};
  plot(time,phivals,'k')
  hold on
  plot(time,out1vals,'r')
  plot(time,out2vals,'g')
  hold off
  %fprintf('numel(in_idx):   %d\n',numel(nowdat{wss.invals}(subidx)));
  
  
  
  
end