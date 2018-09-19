
function [ m2b,m4b,gain,outV ] = b03_generate_colormap(txtfile)

  [filepath,filename,fileext]=fileparts(txtfile);
  q=load(txtfile);
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

  gain=q(:,s.outval)./q(:,s.inval);
  gain=reshape(gain,[numel(m4b) numel(m2b)]);
  gain=gain';  % transpose to match the orientation of the simulations

  % find the max gain and bias settings
  maxgain=max(max(gain))
  [r c]=find(gain==maxgain);

  % prep the abvolute voltage variable
  outV=q(:,s.outval);
  outV=reshape(outV,[numel(m4b) numel(m2b)]);
  outV=outV';

  
  % plot gain
  %{
  fh=figure();
  imagesc(m4b,m2b,gain); colorbar
  set(gca,'YDir','normal');
  xlabel('m4b (V)')
  ylabel('m2b (V)')
  colormap jet
  % save the figure to a PNG
  title(sprintf('Amp gain in response to %0.2f step function (maxgain=%0.2f at m2b=%0.2f and m4b=%0.2f)',mean(q(:,s.inval)),maxgain,m2b(r),m4b(c)))
  %print(fh,sprintf('%s/colormap_gain.png',filepath));
  %}

  % plot absolute voltage output
  %%{
  fh=figure();
  imagesc(m4b,m2b,outV); colorbar
  caxis([0.05 2])
  set(gca,'YDir','normal');
  xlabel('m4b (V)')
  ylabel('m2b (V)')
  colormap jet
  %}

  % plot a grid of sample output curves
  %{
  figure
  subplot_size_x=6;
  subplot_size_y=6;
  subplot_size=subplot_size_x*subplot_size_y;
  step_size=floor(numel(outV)/subplot_size);
  for F=1:subplot_size
    subplot(subplot_size_x,subplot_size_y,F);
    q=load([filepath '/meas' sprintf('%04d',F*step_size) '/math2.csv.clean']);
    plot(q(:,1),q(:,2))
  end
  %}

  % plot a specific meas ID
  %{
  measID=382;
  figure
  q=load([filepath '/meas' sprintf('%04d',measID) '/math2.csv.clean']);
  plot(q(:,1),q(:,2))
  %}

  
end % end-function

