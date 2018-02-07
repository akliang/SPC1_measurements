
function extract_waveform_values(csvfile)


  q=load(csvfile);
  fprintf(1,'%0.4f %0.4f',min(q(:,2)),max(q(:,2)))



end  % end-function
