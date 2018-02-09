
function find_freq(csvfile)

  debug=false;

  q=load(csvfile);


  % find min and max of waveform
  wmax=max(q(:,2));
  wmin=min(q(:,2));

  % find 1-percent envelope of wmax and wmin
  maxenv=(q(:,2)>(wmax*0.95));
  minenv=(q(:,2)<(wmin*0.95));
  maxenvidx=find(maxenv==1);
  minenvidx=find(minenv==1);

  if debug
    plot(q(:,1),q(:,2))
    hold on
    plot(q(maxenv,1),q(maxenv,2),'ro')
    plot(q(minenv,1),q(minenv,2),'go')
    hold off

    figure
    plot(maxenv)

    figure
    plot(diff(maxenv))
  end


  % find biggest gap in the envelopes
  maxgap=max(diff(maxenvidx));


  % assuming the time vector is evenly spaced...
  fprintf(1,"%0.4e %0.4e",1/(q(maxgap+1,1)-q(1,1)),wmax-wmin);





end % end-function

