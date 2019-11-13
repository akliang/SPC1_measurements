
function [ outV,m2b,m4b ] = b03_generate_colormap(csvfile)

  % resistor divider?
  gainfac=100;

  [filepath,filename,fileext]=fileparts(csvfile);
  q=load(csvfile);

  s.measid=1;
  s.inval=2;
  s.outval=3;
  s.m2br=4;
  s.m3br=5;
  s.m4br=6;

  m2b=sort(unique(q(:,s.m2br)));
  m3b=sort(unique(q(:,s.m3br)));
  m4b=sort(unique(q(:,s.m4br)));

  gain=q(:,s.outval)./q(:,s.inval);
  gain=reshape(gain,[numel(m4b) numel(m2b)]);
  gain=gain';  % transpose to match the orientation of the simulations
  
  % very special line representing voltage splitter
  gain=gain*gainfac;

  fh=figure();
  imagesc(m4b,m2b,gain); colorbar
  set(gca,'YDir','normal');
  xlabel('m4b (V)')
  ylabel('m2b (V)')

  % find the max gain and bias settings
  maxgain=max(max(gain));
  [r c]=find(gain==maxgain);

  % save the figure to a PNG
  title(sprintf('Amp gain in response to %0.2f step function (maxgain=%0.2f at m2b=%0.2f and m4b=%0.2f)',mean(q(:,s.inval)),maxgain,m2b(r),m4b(c)))
  %print(fh,sprintf('%s/colormap_gain.png',filepath));

  % special plot function to plot absolute output voltage in log scale
  % (directly comparable with PMB2016 paper results)
  fh=figure();
  outV=q(:,s.outval);
  outV=reshape(outV,[numel(m4b) numel(m2b)]);
  outV=outV';
  %imagesc(m4b,m2b,log10(outV)); colorbar
  %caxis([-1 0.5])
  imagesc(m4b,m2b,outV); colorbar
  caxis([0 2])
  set(gca,'YDir','normal');
  xlabel('m4b (V)')
  ylabel('m2b (V)')
  
  colormap jet
  
end % end-function

