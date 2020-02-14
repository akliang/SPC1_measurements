

ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200122T164209_29D1-8_WP5_2-4-3_schmitt';  % first full acq of comparator
%ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200127T171505_29D1-8_WP5_2-4-3_schmitt';  % second full acq of comparator
ana_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200129T173850_29D1-8_WP5_2-4-3_schmitt';  % second full acq of comparator

addpath('./helper_functions');
% clean the oscope data to make it matlab-friendly
clean_oscope_data(ana_folder);
% load the vbias data
vb_dat = load([ana_folder '/vbiases.txt']);

% walk through every meas and analyze
ana_res_all = zeros([size(vb_dat,1) 6]);
for fidx=1:size(vb_dat,1)
%for fidx=50
    if (mod(fidx,10)==0)
        fprintf(1,'Progress: Analyzing meas %d/%d\n',fidx,size(vb_dat,1));
    end

    measdir=sprintf('%s/meas%04d',ana_folder,vb_dat(fidx,1));
    [minout, maxout, deltaout, rising_thresh, falling_thresh, hysteresis] = analyze_comparator_oscope_data(measdir);
    ana_res_all(fidx,:) = [minout, maxout, deltaout, rising_thresh, falling_thresh, hysteresis];
end

% concat vbiases and ana results and write the results file
alldat = [vb_dat ana_res_all];
resfile = [ana_folder '/results.txt' ];
csvwrite(resfile,alldat);

generate_colormap(ana_folder);
plot_specific_meas(ana_folder, [0.5 0])


function [minout, maxout, deltaout, rising_thresh, falling_thresh, hysteresis] = analyze_comparator_oscope_data(measdir)

  % load in and out files
  in_raw=load([measdir '/ch1.csv.clean']);
  if exist([measdir '/math2.csv.clean'])
      out_raw = load([measdir '/math2.csv.clean']);
  else
    out_raw=load([measdir '/ch2.csv.clean']);
  end
  trig_raw=load([measdir '/ch4.csv.clean']);  % use siggen trig, or comp output?
  trig = trig_raw(:,2);
  
  % segment out a single waveform
  pos_trig_edges = find(diff(trig > mean(trig)) == 1)';
  neg_trig_edges = find(diff(trig > mean(trig)) == -1)';
  % create an index anchor is the waveform begins in the low state
  if (neg_trig_edges(1) > pos_trig_edges(1))
      neg_trig_edges = [1 neg_trig_edges];
  end
  % create an index anchor if the waveform ends on the low state
  if (neg_trig_edges(end) < pos_trig_edges(end))
      neg_trig_edges = [neg_trig_edges numel(trig)];
  end
  % find the first rampmin
  [~, rampminL] = min(in_raw(neg_trig_edges(1):pos_trig_edges(1),2));
  rampminL = rampminL+neg_trig_edges(1);
  % find the second rampmin
  [~, rampminR] = min(in_raw(neg_trig_edges(2):pos_trig_edges(2),2));
  rampminR = rampminR + neg_trig_edges(2);
  % segment out the data from one rampmin to the other
  time = out_raw(rampminL:rampminR,1);
  outvals = out_raw(rampminL:rampminR,2);
  invals = in_raw(rampminL:rampminR,2);
  trig = trig_raw(rampminL:rampminR,2);
  
%   figure(1)
%   plot(time,invals)
%   hold on
%   plot(time,outvals,'r')
%   plot(time,trig,'g')
  
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
  

%   plot(time(intersectL),invals(intersectL),'bx')
%   plot(time(intersectR),invals(intersectR),'bx')
%   hold off
%   title(sprintf('%s',measdir))


end

function generate_colormap(ana_folder)

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
  
  vbias=sort(unique(q(:,s.vbias)));
  vthresh=sort(unique(q(:,s.vthresh)));
  
  % this reshape actually covers up the missing SMU data points!
  deltaout = reshape( q(:,s.deltaout),[numel(vthresh) numel(vbias)]);
  hysteresis = reshape( q(:,s.hysteresis),[numel(vthresh) numel(vbias)]);
  
  figure
  imagesc(vbias,vthresh,deltaout); colorbar
  set(gca,'YDir','normal');
  xlabel('Vthresh (V)')
  ylabel('Vbias (V)')
  colormap jet
  title(sprintf('Delta between comparator off and on (%s)', filename))
  caxis([0 8])
  saveas(gcf,[ana_folder '/deltaout.png']);

  
  figure
  imagesc(vbias,vthresh,hysteresis); colorbar
  set(gca,'YDir','normal');
  xlabel('Vthresh (V)')
  ylabel('Vbias (V)')
  colormap jet
  title(sprintf('Hysteresis of comparator (%s)', filename))
  caxis([0 2.5])
  saveas(gcf,[ana_folder '/hysteresis.png']);
  


end



function plot_specific_meas(ana_folder, input)

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

  if (numel(input)==2)
      vbias = input(1)
      vthresh = input(2)
      idx1 = (q(:,s.vbias)==vbias)
      idx2 = (q(:,s.vthresh)==vthresh)
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
  
  figure
  plot(qin(:,1),qin(:,2))
  hold on
  plot(qout(:,1),qout(:,2),'r')
  hold off
  saveas(gcf,[ana_folder sprintf('/meas%04d.png',idx)]);


end