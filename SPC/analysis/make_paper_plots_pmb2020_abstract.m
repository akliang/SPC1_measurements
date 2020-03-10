
function make_paper_plots_pmb2020_abstract()

amp_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200217T170121_29D1-5_WP5_1-1-1_amp3st1bw/';
amp_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200219T104707_29D1-5_WP5_1-1-1_amp3st1bw/';
comp_folder = '/Volumes/ArrayData/MasdaX/2018-01/measurements/20200129T173850_29D1-8_WP5_2-4-3_schmitt';

global width height;
iptsetpref('ImshowBorder','loose');
iptsetpref('ImshowAxesVisible','on');
close all;

% pretty plot settings (source: https://dgleich.github.io/hq-matlab-figs/)
width = 4;
height = 4;
alw = 1.5;    % AxesLineWidth
fsz = 72;      % Fontsize
lw = 1;      % LineWidth
msz = 8;       % MarkerSize
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

plotFigure1(amp_folder)
plotFigure2(comp_folder)

end % end-function-header


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIGURE 1 - Amplifier
function plotFigure1(ana_folder)

global width height;
cvec={'k-s','k-x','k-d','k-o'};
png_folder = [ana_folder '/paper_figures'];
if ~exist(png_folder)
    mkdir(png_folder);
end

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
outvals_single = outvals_single - outvals_single(1);
% shift invals to be slightly higher than outvals
invals_single = invals_single + 1.1*max(outvals_single);

fh=figure(1);
plot(outtime_single, outvals_single,'r','LineWidth',2)
hold on
%plot(outtime_single, invals_single,'r')
%plot(outtime_single(1:numel(outvals_smooth)), outvals_smooth,'g')
hold off
v=axis;
v(2)= 3e-4;
% give the top/bottom 0.5V of breathing room
v(3) = v(3)-0.5;
v(4) = v(4)+0.5;
axis(v);
set(gca,'XColor','k')
set(gca,'YColor','k')
set(gca,'LineWidth',2)
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
v=axis;
cv=caxis;
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure1_amp_waveform';
saveas(fh,[png_folder '/' sprintf('%s.pdf',fkey)]);
fid = fopen([png_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('caxis = [%f %f]\n',cv));
fclose(fid);
csvwrite([png_folder '/' sprintf('%s.csv',fkey)],[outtime_single invals_single outvals_single]);


% plot colormap of absolute voltage
fh=figure(2);
m2b = q.m2b;
m4b = q.m4b;
outV = q.outV;
imagesc(m4b,m2b,outV); c=colorbar;
set(gca,'YDir','normal');
colormap jet
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
fkey = 'figure1_amp_outV';
saveas(fh,[png_folder '/' sprintf('%s.pdf',fkey)]);
fid = fopen([png_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('caxis = [%f %f]\n',cv));
fprintf(fid,sprintf('outV = %f\n',xval));
fprintf(fid,sprintf('m2b = %f\n',m2b(q.opt_r)));
fprintf(fid,sprintf('m3b = %f\n',q.m3b));
fprintf(fid,sprintf('m4b = %f\n',m4b(q.opt_c)));
fclose(fid);
csvwrite([png_folder '/' sprintf('%s.csv',fkey)],outV);


% plot colormap of settling time
fh=figure(3);
settling_time = q.settling_time;
imagesc(m4b,m2b,settling_time); c=colorbar;
set(gca,'YDir','normal');
colormap jet
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
fkey = 'figure1_amp_settling_time';
saveas(fh,[png_folder '/' sprintf('%s.pdf',fkey)]);
fid = fopen([png_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('caxis = [%f %f]\n',cv));
fprintf(fid,sprintf('settling_time = %f\n',xval));
fprintf(fid,sprintf('m2b = %f\n',m2b(q.opt_r)));
fprintf(fid,sprintf('m3b = %f\n',q.m3b));
fprintf(fid,sprintf('m4b = %f\n',m4b(q.opt_c)));
fclose(fid);
csvwrite([png_folder '/' sprintf('%s.csv',fkey)],settling_time);

end % end-plotFigure1-function-header



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIGURE 2 - Comparator
function plotFigure2(ana_folder)

global width height;
cvec={'k-s','k-x','k-d','k-o'};
png_folder = [ana_folder '/paper_figures'];
if ~exist(png_folder)
    mkdir(png_folder);
end

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
vbias = q.vbias;
vthresh=  q.vthresh;

% start everything from time 0
time = time-time(1);


fh=figure(4);
plot(time, invals,'r','LineWidth',2)
hold on
plot(time, outvals,'b','LineWidth',2)
hold off
set(gca,'XColor','k')
set(gca,'YColor','k')
set(gca,'LineWidth',2)
set(gca,'XMinorTick','off','YMinorTick','off')
set(gca,'XTickLabel',[],'YTickLabel',[]);
v=axis;
% save the figures
set(gcf,'PaperSize',[width height]);
set(gcf, 'PaperPosition',[-0.4 -0.4 width+0.6 height+0.6]);
fkey = 'figure2_comp_waveform';
saveas(fh,[png_folder '/' sprintf('%s.pdf',fkey)]);
fid = fopen([png_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('measID = %d\n',q.measID));
fprintf(fid,sprintf('vbias = %f\n',vbias(q.opt_r)));
fprintf(fid,sprintf('vthresh = %f\n',vthresh(q.opt_c)));
fprintf(fid,sprintf('deltaout = %f\n',deltaout_measID));
fprintf(fid,sprintf('hysteresis = %f\n',hysteresis_measID));
fclose(fid);
csvwrite([png_folder '/' sprintf('%s.csv',fkey)],[time, invals, outvals]);


% plot colormap of deltaout
fh=figure(5);
deltaout = q.deltaout;
imagesc(vthresh,vbias,deltaout); c=colorbar;
set(gca,'YDir','normal');
colormap jet
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
fkey = 'figure2_comp_deltaout';
saveas(fh,[png_folder '/' sprintf('%s.pdf',fkey)]);
fid = fopen([png_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('caxis = [%f %f]\n',cv));
fprintf(fid,sprintf('deltaout = %f\n',xval));
fprintf(fid,sprintf('vbias = %f\n',vbias(q.opt_r)));
fprintf(fid,sprintf('vthresh = %f\n',vthresh(q.opt_c)));
fclose(fid);
csvwrite([png_folder '/' sprintf('%s.csv',fkey)],deltaout);

% plot colormap of hysteresis
fh=figure(6);
hysteresis = q.hysteresis;
imagesc(vthresh,vbias,hysteresis); c=colorbar;
set(gca,'YDir','normal');
colormap jet
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
fkey = 'figure2_comp_hysteresis';
saveas(fh,[png_folder '/' sprintf('%s.pdf',fkey)]);
fid = fopen([png_folder '/' sprintf('%s.txt',fkey)],'w');
fprintf(fid,sprintf('axis = [%f %f %f %f]\n',v));
fprintf(fid,sprintf('caxis = [%f %f]\n',cv));
fprintf(fid,sprintf('hysteresis = %f\n',xval));
fprintf(fid,sprintf('vbias = %f\n',vbias(q.opt_r)));
fprintf(fid,sprintf('vthresh = %f\n',vthresh(q.opt_c)));
fclose(fid);
csvwrite([png_folder '/' sprintf('%s.csv',fkey)],hysteresis);


end % end-plotFigure2-function-header


