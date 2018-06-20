
function a02_generate_colormap(csvfile)

  [filepath,filename,fileext]=fileparts(csvfile);
  q=load(csvfile);

  s.measid=1;
  s.m2br=2;
  s.m3br=3;
  s.m4br=4;
  s.vcc=5;
  s.gnd=6;
  s.m2b=7;
  s.m3b=8;
  s.m4b=9;
  s.math1min=10;
  s.math1max=11;
  s.math2min=12;
  s.math2max=13;

  m2b=sort(unique(q(:,s.m2br)));
  m3b=sort(unique(q(:,s.m3br)));
  m4b=sort(unique(q(:,s.m4br)));

  gain=(q(:,s.math2max)-q(:,s.math2min)) ./ (q(:,s.math1max)-q(:,s.math1min));
  gain=reshape(gain,[numel(m4b) numel(m2b)]);
  gain=gain';  % transpose to match the orientation of the simulations

  fh=figure();
  imagesc(m4b,m2b,gain); colorbar
  set(gca,'YDir','normal');
  xlabel('m4b (V)')
  ylabel('m2b (V)')

  % find the max gain and bias settings
  maxgain=max(max(gain));
  [r c]=find(gain==maxgain);

  % save the figure to a PNG
  title(sprintf('Amp gain in response to sine wave (maxgain=%0.2f at m2b=%0.2f and m4b=%0.2f)',maxgain,m2b(r),m4b(c)))
  print(fh,sprintf('%s/colormap_gain.png',filepath));

end % end-function

