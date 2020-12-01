
global paper_folder;

if exist('/Volumes/ArrayData/MasdaX','dir')
    pathpre = '/Volumes/';
else
    pathpre = '~/Desktop/';
end

paper_folder =    [pathpre 'bongo/Albert/Publications/2020-PCAmeasurement/paper_figures'];
%amp_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200217T170121_29D1-5_WP5_1-1-1_amp3st1bw/'; % why is this one here?
amp_folder =      [pathpre 'ArrayData/MasdaX/2018-01/measurements/20200219T104707_29D1-5_WP5_1-1-1_amp3st1bw/'];
comp_folder =     [pathpre 'ArrayData/MasdaX/2018-01/measurements/20200312T170353_29D1-8_WP5_2-4-3_schmitt'];  best_vbias = 1; best_vthresh=3;
comp_cr_folder =  [pathpre 'ArrayData/MasdaX/2018-01/measurements/20200311T161607_29D1-8_WP5_2-4-3_schmitt'];
%clockgen_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200319T210650_29D1-8_WP8_4-6-10_2SR3inv';
clockgen_folder = [pathpre 'ArrayData/MasdaX/2018-01/measurements/20200722T999999_29D1-5_WP6_3-3-1_2SR3inv_combined'];
counter_folder = [pathpre 'ArrayData/MasdaX/2018-01/measurements/20200903T231310_29D1-5_WP6_3-2-5_diffTFT_50steps'];

global width height;
iptsetpref('ImshowBorder','loose');
iptsetpref('ImshowAxesVisible','on');
close all;

% pretty plot settings (source: https://dgleich.github.io/hq-matlab-figs/)
width = 4;
height = 4;
alw = 2;    % AxesLineWidth
fsz = 72;      % Fontsize
lw = 2;      % LineWidth
msz = 18;       % MarkerSize
set(0,'defaultAxesLineWidth',alw);   % set the default line width to lw
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultAxesFontName','Times New Roman')
set(0,'defaultAxesFontSize',fsz);
set(0,'defaultTextFontName','Times New Roman')
set(0,'defaultTextFontSize',fsz);
% Set the default Size for display
defpos = get(0,'defaultFigurePosition');
set(0,'defaultFigurePosition', [defpos(1) defpos(2) width height]);
set(0,'defaultFigurePosition', [0 0 width height]);
% Set the defaults for saving/printing to a file
set(0,'defaultFigureInvertHardcopy','on'); % This is the default anyway
set(0,'defaultFigurePaperUnits','inches'); % This is the default anyway
%defsize = get(gcf, 'PaperSize');
%left = (defsize(1)- width)/2;
%bottom = (defsize(2)- height)/2;
%defsize = [left, bottom, width, height];
defsize = [0 0 width height];
set(0, 'defaultFigurePaperPosition', defsize);

% set my own custom settings
global color1 color2 color3 color4;
%color1 = [241 163 64]/255;
color1 = [1 0 0];
color2 = [0 0 0]/255;
color3 = [0.3 0.3 0.3];
color4 = [85 117 231]/255;

%plotFigure1(amp_folder)
plotFigure2(comp_folder, comp_cr_folder)
%plotFigure3(clockgen_folder)
%plotFigure4(counter_folder)
close all




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIGURE 1 - Amplifier
function plotFigure1(ana_folder)

global paper_folder;
global width height;
global color1 color2 color3 color4;

% load the data
if exist([ana_folder '/ana_results.mat'])
    q=load([ana_folder '/ana_results.mat']);
else
    error('ana_results.mat file not found in %s... did you run analyze_amplifier_meas?',ana_folder);
end

% plot the waveform of the optimal point
outtime_single = q.waveform_save{q.measID}{q.wss.outtime_single};
invals_single = q.waveform_save{q.measID}{q.wss.invals_single};
outvals_single = q.waveform_save{q.measID}{q.wss.outvals_single};

% shift outtime to start from 0
outtime_single = outtime_single - outtime_single(1);
% shift outvals to start from 0
%outvals_single = outvals_single - outvals_single(1);
outvals_single(1)
% shift invals to be slightly higher than outvals
%invals_single = invals_single + 1.1*max(outvals_single);

fh=figure(1);
plot(outtime_single, outvals_single,'Color',color2)
hold on
%plot(outtime_single, invals_single,'r')
%plot(outtime_single(1:numel(outvals_smooth)), outvals_smooth,'g')
hold off
v=axis;
v(2)= 250e-6;
% give the top/bottom 0.5V of breathing room
v(3) = v(3)-0.5;
v(4) = v(4)+0.5;
axis(v);
set(gca,'XColor','k');
set(gca,'YColor','k');
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
v=axis;
cv=caxis;
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure1a_amp_waveform';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('caxis = [%f %f]\n',cv));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[outtime_single invals_single outvals_single]);


% plot colormap of absolute voltage
fh=figure(2);
m2b = q.m2b;
m4b = q.m4b;
outV = q.outV;
imagesc(m4b,m2b,outV); c=colorbar;
set(gca,'YDir','normal');
colormap parula
cv=caxis;
cv(1)=0;
caxis(cv);
hold on
plot(m4b(q.opt_c),m2b(q.opt_r),'wx')
hold off
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
set(c,'TickLabels',[]);
v=axis;
cv=caxis;
xval=outV(q.opt_r,q.opt_c);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure1b_amp_outV';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('caxis = [%f %f]\n',cv));
fprintf(fid,sprintf('outV = %f\n',xval));
fprintf(fid,sprintf('m2b = %f\n',m2b(q.opt_r)));
fprintf(fid,sprintf('m3b = %f\n',q.m3b));
fprintf(fid,sprintf('m4b = %f\n',m4b(q.opt_c)));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],outV);


% plot colormap of settling time
fh=figure(3);
settling_time = q.settling_time;
imagesc(m4b,m2b,settling_time); c=colorbar;
set(gca,'YDir','normal');
colormap parula
cv=caxis;
cv(1)=0;
caxis(cv);
hold on
plot(m4b(q.opt_c),m2b(q.opt_r),'wx')
hold off
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
set(c,'TickLabels',[]);
v=axis;
cv=caxis;
xval=settling_time(q.opt_r,q.opt_c);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure1c_amp_settling_time';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('caxis = [%f %f]\n',cv));
fprintf(fid,sprintf('settling_time = %f\n',xval));
fprintf(fid,sprintf('m2b = %f\n',m2b(q.opt_r)));
fprintf(fid,sprintf('m3b = %f\n',q.m3b));
fprintf(fid,sprintf('m4b = %f\n',m4b(q.opt_c)));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],settling_time);

end % end-plotFigure1-function-header



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIGURE 2 - Comparator
function plotFigure2(ana_folder, cr_ana_folder)

global paper_folder;
global width height;
global color1 color2 color3 color4;

% load the data
if exist([ana_folder '/ana_results.mat'])
    q=load([ana_folder '/ana_results.mat']);
else
    error('ana_results.mat file not found in %s... did you run analyze_comparator_meas?',ana_folder);
end

% plot the waveform of the optimal point
time = q.waveform_save{q.measID}{q.wss.time};
invals = q.waveform_save{q.measID}{q.wss.invals};
outvals = q.waveform_save{q.measID}{q.wss.outvals};
deltaout_measID = q.waveform_save{q.measID}{q.wss.deltaout};
hysteresis_measID = q.waveform_save{q.measID}{q.wss.hysteresis};
% only need rampmax since rampminL is the 0 idx and rampminR is the last idx
rampmax  = q.waveform_save{q.measID}{q.wss.rampmax};
intersectL = q.waveform_save{q.measID}{q.wss.intersectL};
intersectR = q.waveform_save{q.measID}{q.wss.intersectR};
minout = q.waveform_save{q.measID}{q.wss.minout};
maxout = q.waveform_save{q.measID}{q.wss.maxout};
vbias = q.vbias;
vthresh=  q.vthresh;

% start everything from time 0
time = time-time(1);

% plot of measured waveform
fh=figure(4);
plot(time, invals,'Color',color2,'LineWidth',0.5)
hold on
plot(time, outvals,'Color',color1)
hold off
v=axis;
v(4)=8;
axis(v);
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
set(gca,'YTick',[0 2 4 6 8]);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure2a_comp_waveform';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('measID = %d\n',q.measID));
fprintf(fid,sprintf('vbias = %f\n',vbias(q.opt_r)));
fprintf(fid,sprintf('vthresh = %f\n',vthresh(q.opt_c)));
fprintf(fid,sprintf('deltaout = %f\n',deltaout_measID));
fprintf(fid,sprintf('hysteresis = %f\n',hysteresis_measID));
fprintf(fid,sprintf('intersectL = %f\n',invals(intersectL)));
fprintf(fid,sprintf('intersectR = %f\n',invals(intersectR)));
fprintf(fid,sprintf('minout = %f\n',minout));
fprintf(fid,sprintf('maxout = %f\n',maxout));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[time, invals, outvals]);

% rearranged plot to look like hysteresis curve
fh=figure(5);
rise_dat_in  = invals(1:rampmax);
rise_dat_out = outvals(1:rampmax);
fall_dat_in  = invals(rampmax+1:end);
fall_dat_out = outvals(rampmax+1:end);
plot(rise_dat_in, rise_dat_out,'Color',color2,'LineWidth',0.75)
hold on
plot(fall_dat_in, fall_dat_out,'Color',color2,'LineWidth',0.75)
hold off
v=axis;
v(1)=0;
v(4)=8;
axis(v);
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
set(gca,'YTick',[0 2 4 6 8]);
set(gca,'YTickLabels',[]);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure2b_comp_hysteresis_curve';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('measID = %d\n',q.measID));
fprintf(fid,sprintf('vbias = %f\n',vbias(q.opt_r)));
fprintf(fid,sprintf('vthresh = %f\n',vthresh(q.opt_c)));
fprintf(fid,sprintf('deltaout = %f\n',deltaout_measID));
fprintf(fid,sprintf('hysteresis = %f\n',hysteresis_measID));
fclose(fid);
if (numel(rise_dat_in) > numel(fall_dat_in))
    fall_dat_in(end+1:numel(rise_dat_in))=0;
    fall_dat_out(end+1:numel(rise_dat_in))=0;
else
    rise_dat_in(end+1:numel(fall_dat_in))=0;
    rise_dat_out(end+1:numel(fall_dat_in))=0;
end
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[rise_dat_in, rise_dat_out, fall_dat_in, fall_dat_out]);


% plot colormap of deltaout
fh=figure(6);
deltaout = q.deltaout;
imagesc(vthresh,vbias,deltaout); c=colorbar;
set(gca,'YDir','normal');
colormap parula
%caxis([0.01 4.25])
hold on
plot(vthresh(q.opt_c),vbias(q.opt_r),'wx')
hold off
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
set(c,'Ticks',[0 2 4 6 8]);
set(c,'TickLabels',[]);
v=axis;
caxis([0 8]);
cv=caxis;
xval=deltaout(q.opt_r,q.opt_c);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure2c_comp_deltaout_colormap';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('caxis = [%f %f]\n',cv));
fprintf(fid,sprintf('deltaout = %f\n',xval));
fprintf(fid,sprintf('vbias = %f\n',vbias(q.opt_r)));
fprintf(fid,sprintf('vthresh = %f\n',vthresh(q.opt_c)));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],deltaout);

% plot colormap of hysteresis
fh=figure(7);
hysteresis = q.hysteresis;
imagesc(vthresh,vbias,hysteresis); c=colorbar;
set(gca,'YDir','normal');
colormap parula
%caxis([0.01 4.25])
hold on
plot(vthresh(q.opt_c),vbias(q.opt_r),'wx')
hold off
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
set(c,'Ticks',[0 0.5 1 1.5 2]);
set(c,'TickLabels',[]);
v=axis;
caxis([0 2]);
cv=caxis;
xval=hysteresis(q.opt_r,q.opt_c);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure2d_comp_hysteresis_colormap';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('caxis = [%f %f]\n',cv));
fprintf(fid,sprintf('hysteresis = %f\n',xval));
fprintf(fid,sprintf('vbias = %f\n',vbias(q.opt_r)));
fprintf(fid,sprintf('vthresh = %f\n',vthresh(q.opt_c)));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],hysteresis);

% plot the waveform of a square-wave count-rate curve
fh=figure(8);
q=load([cr_ana_folder '/ana_results.mat']);
measID = q.cr_max_idx;
time = q.waveform_save{measID}{q.wss.time};
invals = q.waveform_save{measID}{q.wss.invals};
outvals = q.waveform_save{measID}{q.wss.outvals};
deltaout_measID = q.waveform_save{measID}{q.wss.deltaout};
hysteresis_measID = q.waveform_save{measID}{q.wss.hysteresis};
% start everything from time 0
time = time-time(1);
plot(time, invals,'Color',color2,'LineWidth',0.75)
hold on
plot(time, outvals,'Color',color1,'LineWidth',0.75)
hold off
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
v=axis;
% give the left edge a little room
v(1) = -1e-7;
v(4)=6;
axis(v);
set(gca,'YTick',[0 2 4 6]);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure2e_comp_cr_waveform';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('measID = %d\n',measID));
fprintf(fid,sprintf('deltaout = %f\n',deltaout_measID));
fprintf(fid,sprintf('hysteresis = %f\n',hysteresis_measID));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[time, invals, outvals]);


% plot the waveform of a square-wave count-rate curve at a too high frequency
fh=figure(9);
q=load([cr_ana_folder '/ana_results.mat']);
measID_err = q.cr_max_idx+4;
time = q.waveform_save{measID_err}{q.wss.time};
invals = q.waveform_save{measID_err}{q.wss.invals};
outvals = q.waveform_save{measID_err}{q.wss.outvals};
deltaout_measID = q.waveform_save{measID_err}{q.wss.deltaout};
hysteresis_measID = q.waveform_save{measID_err}{q.wss.hysteresis};
% start everything from time 0
time = time-time(1);
plot(time, invals,'Color',color2,'LineWidth',0.75)
hold on
plot(time, outvals,'Color',color1,'LineWidth',0.75)
hold off
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
v=axis;
% give the left edge a little room
v(1) = -0.25e-7;
v(4)=6;
axis(v);
set(gca,'YTick',[0 2 4 6]);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure2f_comp_error_waveform';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%e %e %f %f]\n',v));
fprintf(fid,sprintf('measID = %d\n',measID_err));
fprintf(fid,sprintf('deltaout = %f\n',deltaout_measID));
fprintf(fid,sprintf('hysteresis = %f\n',hysteresis_measID));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[time, invals, outvals]);


% plot count rate curve
fh=figure(10);
frequency = q.q(:,q.s.frequency);
deltaout = q.q(:,q.s.deltaout);
cr_max_idx = q.cr_max_idx;
cr_max = q.cr_max;
cr_max_deltaout = q.deltaout_mean;
semilogx(frequency,deltaout, 'Color',color2)
hold on
v=axis;
v(2)=10e6;
v(4)=8;
axis(v);
plot([frequency(cr_max_idx) frequency(cr_max_idx)],[v(3) v(4)],'Color',color2,'LineStyle','--')
plot(frequency(measID),deltaout(measID),'Color',color1,'Marker','o');
plot(frequency(measID_err),deltaout(measID_err),'Color',color1,'Marker','x');
hold off
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
set(gca,'XTick',[1e2 1e3 1e4 1e5 1e6 1e7]);
set(gca,'YTick',[0 2 4 6 8]);
v=axis;
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure2g_countrate';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('cr_max = %f\n',cr_max));
fprintf(fid,sprintf('cr_max_deltaout = %f\n',cr_max_deltaout));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[frequency, deltaout]);

end % end-plotFigure2-function-header


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIGURE 3 - Clock Generator
function plotFigure3(ana_folder)

global paper_folder;
global width height;
global color1 color2 color3 color4;

max_num_idx = 14;

% load the data
if exist([ana_folder '/ana_results.mat'])
    q=load([ana_folder '/ana_results.mat']);
else
    error('ana_results.mat file not found in %s... did you run analyze_comparator_meas?',ana_folder);
end

% plot of standard waveform
fh=figure(11);
cr_max_idx = q.cr_max_idx-16;
time = q.waveform_save{cr_max_idx}{q.wss.time};
invals = q.waveform_save{cr_max_idx}{q.wss.invals};
out1vals = q.waveform_save{cr_max_idx}{q.wss.out1vals};
out2vals = q.waveform_save{cr_max_idx}{q.wss.out2vals};
in_idx = q.waveform_save{cr_max_idx}{q.wss.in_idx};
phi1_deltaout = q.waveform_save{cr_max_idx}{q.wss.phi1_deltaout};
phi2_deltaout = q.waveform_save{cr_max_idx}{q.wss.phi2_deltaout};
% if there are too many in_idx, then limit it so the plot is clearer
if (numel(in_idx) > max_num_idx)
  idx_range = in_idx(1):in_idx(max_num_idx);
else
  idx_range = in_idx;
end
% thin out idx_range so the image isnt so dense
idx_range = 1:6:numel(idx_range);
timevals = time(idx_range);
timevals = timevals - timevals(1);
plot(timevals,out1vals(idx_range),'Color',color1);
hold on
plot(timevals,out2vals(idx_range),'Color',color2);
% plot the input pulses off-set and compressed from the output pulses
plot(timevals,(invals(idx_range)/4)+12,'Color',color3);
hold off
v=axis;
v(2)=80e-6;
v(3)=-0.5;
v(4)=14;
axis(v);
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
set(gca,'XTick',[0 20e-6 40e-6 60e-6 80e-6]);
set(gca,'YTick',[0 2 4 6 8]);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure3a_clockgen_waveform_crmax';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('phi1_deltaout = %f\n',phi1_deltaout));
fprintf(fid,sprintf('phi2_deltaout = %f\n',phi2_deltaout));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[time(idx_range), invals(idx_range), out1vals(idx_range), out2vals(idx_range)]);

% plot of error in waveform
fh=figure(12);
% step forward 2 in order to show missed pulses
error_idx = q.cr_max_idx+29;
time = q.waveform_save{error_idx}{q.wss.time};
invals = q.waveform_save{error_idx}{q.wss.invals};
out1vals = q.waveform_save{error_idx}{q.wss.out1vals};
out2vals = q.waveform_save{error_idx}{q.wss.out2vals};
in_idx = q.waveform_save{error_idx}{q.wss.in_idx};
% if there are too many in_idx, then limit it so the plot is clearer
if (numel(in_idx) > max_num_idx)
  idx_range = in_idx(1):in_idx(max_num_idx);
else
  idx_range = in_idx;
end
% thin out idx_range so the image isnt so dense
idx_range = 1:6:numel(idx_range);
timevals = time(idx_range);
timevals = timevals - timevals(1);
plot(timevals,out1vals(idx_range),'Color',color1);
hold on
plot(timevals,out2vals(idx_range),'Color',color2);
% plot the input pulses off-set and compressed from the output pulses
plot(timevals,(invals(idx_range)/4)+12,'Color',color3);
hold off
v=axis;
v(2)=80e-6;
v(3)=-0.5;
v(4)=14;
axis(v);
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
set(gca,'XTick',[0 20e-6 40e-6 60e-6 80e-6]);
set(gca,'YTick',[0 2 4 6 8]);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure3b_clockgen_waveform_errors';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[time(idx_range), invals(idx_range), out1vals(idx_range), out2vals(idx_range)]);

% plot of count rate
fh=figure(13);
in_freq = q.q(:,q.s.in_freq);
phi_ratio = q.q(:,q.s.phi_ratio)*100;
cr_max = q.cr_max;
semilogx(in_freq,phi_ratio,'Color',color2);
hold on
v=axis;
v(4) = 105;
axis(v);
plot([cr_max cr_max],[v(3) v(4)],'--','Color',color2);
plot(in_freq(cr_max_idx),phi_ratio(cr_max_idx),'Color',color1,'Marker','o');
plot(in_freq(error_idx),phi_ratio(error_idx),'Color',color1,'Marker','x');
hold off
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
set(gca,'XTick',[1e4 1e5 1e6]);
set(gca,'YTick',[0 25 50 75 100]);
v=axis;
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure3c_clockgen_countrate';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('cr_max = %d\n',cr_max));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[in_freq, phi_ratio]);


end % end-plotFigure3-function-header


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIGURE 4 - Counter
function plotFigure4(ana_folder)

global paper_folder;
global width height;
global color1 color2 color3 color4;

% load the data
if exist([ana_folder '/ana_results.mat'])
    q=load([ana_folder '/ana_results.mat']);
else
    error('ana_results.mat file not found in %s... did you run analyze_counter_meas?',ana_folder);
end

% plot of standard waveform
fh=figure(14);
% step back a few steps because cr_max_idx is too noisy
cr_now_idx = 17;
time = q.waveform_save{cr_now_idx}{q.wss.time};
out1vals = q.waveform_save{cr_now_idx}{q.wss.out1vals};
out1vals = out1vals - out1vals(1);
out2vals = q.waveform_save{cr_now_idx}{q.wss.out2vals};
out1_pre = q.waveform_save{cr_now_idx}{q.wss.out1_pre};
out1_post = q.waveform_save{cr_now_idx}{q.wss.out1_post};
out2_pre = q.waveform_save{cr_now_idx}{q.wss.out2_pre};
out2_post = q.waveform_save{cr_now_idx}{q.wss.out2_post};
timevals = time - time(1);
plot(timevals,out1vals,'Color',color2,'LineWidth',0.75);
hold on
plot(timevals,out2vals,'Color',color1,'LineWidth',0.75);
hold off
v=axis;
v(2)=250e-6;
% narrow the window to only a single phi pulse
v(1)=110e-6;
v(2)=124e-6;
v(4)=8;
axis(v);
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
%set(gca,'XTick',[0 50e-6 100e-6 150e-6 200e-6 250e-6]);
set(gca,'XTick',[110e-6 115e-6 120e-6]);
set(gca,'YTick',[0 2 4 6 8 10]);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure4a_counter_waveform_crmax';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('out1_pre = %f\n',out1_pre));
fprintf(fid,sprintf('out1_post = %f\n',out1_post));
fprintf(fid,sprintf('out2_pre = %f\n',out2_pre));
fprintf(fid,sprintf('out2_post = %f\n',out2_post));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[time, out1vals, out2vals]);

% plot of error in waveform
fh=figure(15);
% step forward 4 in order to show missed pulses
error_idx = 49;
time = q.waveform_save{error_idx}{q.wss.time};
out1vals = q.waveform_save{error_idx}{q.wss.out1vals};
out1vals = out1vals - out1vals(1);
out2vals = q.waveform_save{error_idx}{q.wss.out2vals};
out1_pre = q.waveform_save{error_idx}{q.wss.out1_pre};
out1_post = q.waveform_save{error_idx}{q.wss.out1_post};
out2_pre = q.waveform_save{error_idx}{q.wss.out2_pre};
out2_post = q.waveform_save{error_idx}{q.wss.out2_post};
timevals = time - time(1);
plot(timevals,out1vals,'Color',color2,'LineWidth',0.75);
hold on
plot(timevals,out2vals,'Color',color1,'LineWidth',0.75);
hold off
v=axis;
v(2)=5e-6;
% narrow the window to only a single phi pulse
v(1)=2e-6;
v(2)=2.7e-6;
v(4)=8;
axis(v);
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
%set(gca,'XTick',[0 2.5e-6 5e-6]);
set(gca,'XTick',[2e-6 2.2e-6 2.4e-6 2.6e-6]);
set(gca,'YTick',[0 2 4 6 8 10]);
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure4b_counter_waveform_errors';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('out1_pre = %f\n',out1_pre));
fprintf(fid,sprintf('out1_post = %f\n',out1_post));
fprintf(fid,sprintf('out2_pre = %f\n',out2_pre));
fprintf(fid,sprintf('out2_post = %f\n',out2_post));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[time, out1vals, out2vals]);

% plot of count rate
fh=figure(16);
% gather statistics for printout later
cr_max_idx = q.cr_max_idx;
cr_max = q.cr_max;
cr_max_out1_vdiff = q.waveform_save{cr_max_idx}{q.wss.out1_vdiff};
cr_max_out2_vdiff = q.waveform_save{cr_max_idx}{q.wss.out2_vdiff};
% plot the count rate vs frequency curve
in_freq = q.q(:,q.s.in_freq);
out1_vdiff = q.q(:,q.s.out1_vdiff);
out2_vdiff = q.q(:,q.s.out2_vdiff);
semilogx(in_freq,out1_vdiff,'Color',color2);
hold on
semilogx(in_freq,out2_vdiff,'Color',color1);
v=axis;
v(2)=40e6;
v(4)=8;
axis(v);
plot(in_freq(cr_now_idx),out1_vdiff(cr_now_idx),'Color',color2,'Marker','o');
plot(in_freq(error_idx),out1_vdiff(error_idx),  'Color',color2,'Marker','x');
plot(in_freq(cr_now_idx),out2_vdiff(cr_now_idx),'Color',color1,'Marker','o');
plot(in_freq(error_idx),out2_vdiff(error_idx),  'Color',color1,'Marker','x');
hold off
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
set(gca,'XTick',[1e5 1e6 1e7]);
set(gca,'YTick',[0 2 4 6 8]);
v=axis;
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure4c_counter_countrate';
saveas(fh,[paper_folder '/' sprintf('%s.pdf',fkey)]);
saveas(fh,[paper_folder '/' sprintf('%s.png',fkey)]);
fid = fopen([paper_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('ana_folder = %s\n',ana_folder));
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('cr_now_idx = %d\n',cr_now_idx));
fprintf(fid,sprintf('error_idx = %d\n',error_idx));
fprintf(fid,sprintf('cr_max_idx = %d\n',cr_max_idx));
fprintf(fid,sprintf('cr_max_out1_vdiff = %d\n',cr_max_out1_vdiff));
fprintf(fid,sprintf('cr_max_out2_vdiff = %d\n',cr_max_out2_vdiff));
fprintf(fid,sprintf('cr_max = %d\n',cr_max));
fclose(fid);
csvwrite([paper_folder '/' sprintf('%s.csv',fkey)],[in_freq, out1_vdiff, out2_vdiff]);


end % end-plotFigure4-function-header