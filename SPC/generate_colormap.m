
function generate_colormap(csvfile)

  q=load(csvfile);

  m2b=sort(unique(q(:,1)));
  m3b=sort(unique(q(:,2)));
  m4b=sort(unique(q(:,3)));

  gain=(q(:,12)-q(:,11)) ./ (q(:,10)-q(:,9));
  gain=reshape(gain,[numel(m4b) numel(m2b)]);

  imagesc(m2b,m4b,gain); colorbar
  set(gca,'YDir','normal');
  title('Amp gain in response to sine wave')
  xlabel('m2b (V)')
  ylabel('m4b (V)')

  sprintf('max gain: %0.2f',max(max(gain)))






end % end-function

