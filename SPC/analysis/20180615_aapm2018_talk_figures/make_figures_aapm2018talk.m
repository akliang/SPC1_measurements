
% note: requires export_fig function (found on Matlab website)
% export_fig requires a new-ish version of matlab to work (2011b crashes, 2018a OK)
addpath('/Volumes/ArrayData/MasdaX/2018-01/scriptmeas/SPC/analysis/matlab_functions/altmany_export_fig_bb6c842');


datdir='../../../measurements/20180306T221754';
meas={ % id m2b m3b m4b
'meas286',1.1,1.5,2.5 % used for AAPM2018 talk
%'meas336',1.3,1.5,2.5
%'meas386',1.5,1.5,2.5
%'meas436',1.7,1.5,2.5
%'meas486',1.9,1.5,2.5
%'meas536',2.1,1.5,2.5
'meas586',2.3,1.5,2.5 % used for AAPM2018 talk

'meas290',1.1,1.5,3.5 % used for AAPM2018 talk
%'meas340',1.3,1.5,3.5
%'meas390',1.5,1.5,3.5
%'meas440',1.7,1.5,3.5
%'meas490',1.9,1.5,3.5
%'meas540',2.1,1.5,3.5
'meas590',2.3,1.5,3.5 % used for AAPM2018 talk

'meas294',1.1,1.5,4.5 % used for AAPM2018 talk
%'meas344',1.3,1.5,4.5
%'meas394',1.5,1.5,4.5
%'meas444',1.7,1.5,4.5
%'meas494',1.9,1.5,4.5
%'meas544',2.1,1.5,4.5
'meas594',2.3,1.5,4.5 % used for AAPM2018 talk

% special figures used in AAPM2018 talk
% the large image used for demo purposes to show gain
'meas586',2.3,1.5,2.5
% the large image used for demo purposes to show settling time
'meas1013',2.3,1.5,4.5
% the ideal bias identified at end of script
'meas914',2,1.5,0
};
datfile = 'math2.csv.clean';
gain_colormap_csv = './data/20180306T221754_2_sorted.dat';

%% create the mini-plots of amplifier output

% scan through all the files to find the min-max of the axes
% (only care about y-axis min-max though)
v=[-Inf Inf Inf -Inf];
for i=1:size(meas,1)
  close all
  figure('Position',[0 0 100 100])
  q=load([datdir '/' meas{i,1} '/' datfile]);
  plot(q(:,1),q(:,2),'y','LineWidth',1)
  v2=axis;
  % clip time window to shortest found
  if (v2(1) > v(1)); v(1)=v2(1); end
  if (v2(2) < v(2)); v(2)=v2(2); end
  % clip voltage window to largest found
  if (v2(3) < v(3)); v(3)=v2(3); end
  if (v2(4) > v(4)); v(4)=v2(4); end
end
% hard-coded fix to make AAPM2018 look nicer
v(3)=-1.5;

% read the dat file in each folder
for i=1:size(meas,1)
  close all
  figure('Position',[0 0 100 100])
  q=load([datdir '/' meas{i,1} '/' datfile]);
  plot(q(:,1),q(:,2),'y','LineWidth',1)
  %v2=axis;
  %v2(3)=v(3); v2(4)=v(4);
  %axis(v2);
  axis(v);
  
  set(gca,'XTick',[],'YTick',[])
  set(gca,'XMinorTick','off','YMinorTick','off')
  set(gca,'XTickLabel',[],'YTickLabel',[]);
  
  set(gca,'Color','none')
  set(gca,'XColor','white')
  set(gca,'YColor','white')
  set(gca,'Position',[0 0 0.98 0.98])
  set(gca,'LineWidth',1)  % sets axis line width
  
  % have to specify a magnification factor or else figure is blurry
  export_fig(sprintf('%s.png',meas{i,1}),'-m3','-transparent')
  
  if (i==size(meas,1)-2) || (i==size(meas,1)-1) || (i==size(meas,1))
    close all
    figure('Position',[0 0 250 250])
    q=load([datdir '/' meas{i,1} '/' datfile]);
    plot(q(:,1),q(:,2),'y','LineWidth',1)
    %v2=axis;
    %v2(3)=v(3); v2(4)=v(4);
    %axis(v2);
    axis(v);
      
    set(gca,'XTick',[],'YTick',[])
    set(gca,'XMinorTick','off','YMinorTick','off')
    set(gca,'XTickLabel',[],'YTickLabel',[]);
  
    set(gca,'Color','none')
    set(gca,'XColor','white')
    set(gca,'YColor','white')
    set(gca,'Position',[0 0 0.98 0.98])
    set(gca,'LineWidth',1)  % sets axis line width
    export_fig(sprintf('%s_large.png',meas{i,1}),'-m3','-transparent')
    
    % report voltage stats of the special large images
    fprintf(1,'Max voltage is %f\n',max(q(:,2))-q(1,2));
    %fprintf(1,'Settling time is %f\n',0);
  end
  
  if i==1    
    % make a special blank placeholder for presentation
    close all
    figure('Position',[0 0 100 100])
    q=load([datdir '/' meas{i,1} '/' datfile]);
    plot(q(:,1),q(:,2),'Color','none','LineWidth',1)
    %v2=axis;
    %v2(3)=v(3); v2(4)=v(4);
    %axis(v2);
    axis(v);
  
    set(gca,'XTick',[],'YTick',[])
    set(gca,'XMinorTick','off','YMinorTick','off')
    set(gca,'XTickLabel',[],'YTickLabel',[]);
  
    set(gca,'Color','none')
    set(gca,'XColor','white')
    set(gca,'YColor','white')
    set(gca,'Position',[0 0 0.98 0.98])
    set(gca,'LineWidth',1)  % sets axis line width
    export_fig('blank_plot.png','-m3','-transparent')
  end
  
end

%% create the amplifier gain color maps

caxislim=[0 2];

[outV,m2b,m4b] = b03_generate_colormap(gain_colormap_csv);
close all
figure('Position',[0 0 300 250])
imagesc(m4b,m2b,outV); colorbar
set(gca,'YDir','normal');
xlabel('')
ylabel('')
set(gca,'XTick',[],'YTick',[])
caxis(caxislim)
colormap jet
set(colorbar,'Ticks',[])
export_fig('gain_colormap_measurement.png','-m3','-transparent')

% export the simulation gain colormap
q=load('./20161221T165736_three_stage_standard_dp_1bw_colormap_variables.mat');
figure('Position',[0 0 250 250])
imagesc(q.m4bvals,q.m2bvals,q.Tmat); colorbar
set(gca,'YDir','normal');
xlabel('')
ylabel('')
set(gca,'XTick',[],'YTick',[])
caxis(caxislim)
colormap jet
colorbar('off')
export_fig('gain_colormap_simulation.png','-m3','-transparent')

%% create the settling time color maps

% ---- colormap for settling time ---- %
% used this script to generate settling time values
%{
amplifier_input=zeros([1 1525]);
amplifier_output=zeros([1 1525]);
settling_time=zeros([1 1525]);

for i=1:1525
  close all
  %sprintf('%03d',i)
  [amplifier_input(i),amplifier_output(i),settling_time(i)]=b02_analyze_oscope_amp(['../../../measurements/20180306T221754/meas' sprintf('%03d',i)]);
  %pause
end
%}

q=load('./20161221T165736_three_stage_standard_dp_1bw_settlingtime_variables.mat');
% sanity check that the gainmap matches (no funny baseV offset or reshape
% problems)
%{
amplifier_output=reshape(q.amplifier_output,[numel(m4b) numel(m2b)]);
amplifier_output=amplifier_output';
close all
figure('Position',[0 0 300 250])
imagesc(m4b,m2b,amplifier_output); colorbar
set(gca,'YDir','normal');
xlabel('')
ylabel('')
%set(gca,'XTick',[],'YTick',[])
caxis([0 2])
colormap jet
pause
%}
% more sanity check - report Vout and settling time for the big figures
for meastemp=1:size(meas,1)
  measnum=str2num(strrep(meas{meastemp,1},'meas',''));
  fprintf(1,'Meas %d Vout is %f and settling time is %f\n',measnum,q.amplifier_output(measnum),q.settling_time(measnum));
end
% borrowed this code from b03_generate_colormap
settling_time=reshape(q.settling_time,[numel(m4b) numel(m2b)]);
settling_time=settling_time';  % transpose to match the orientation of the simulations
close all
figure('Position',[0 0 300 250])
imagesc(m4b,m2b,1./settling_time); colorbar
set(gca,'YDir','normal');
xlabel('')
ylabel('')
set(gca,'XTick',[],'YTick',[])
caxis([0 10000])
colormap jet
set(colorbar,'Ticks',[])
export_fig('settlingtime_colormap_measurement.png','-m3','-transparent')

%% find the bias points where gain and settling time intersect

% find the best point where gain is sufficient and count rate is highest
bestidx=find(outV >= 1.25);
[a b]=max(1./settling_time(bestidx));
% find the m2b and m4b at the point b
[r c]=find(outV == (outV(bestidx(b))));
fprintf(1,'Best point: m2b=%f , m4b=%f , outV = %e , count_rate = %g\n',m2b(r),m4b(c),outV(bestidx(b)),1./settling_time(bestidx(b)));

