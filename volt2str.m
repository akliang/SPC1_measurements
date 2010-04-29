function vstr=volt2str( volt )
  vstr=sprintf('%2.1f',volt);
  vstr(end-1)='V';
end
