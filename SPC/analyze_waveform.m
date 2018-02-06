
dtag="20180206T200303_1517947383_spc001_probe12c_29D1-8_WP2_1-3-3_amp1st2T_measdelli"
files={'ch1','ch2','math1','math2'};

for F=1:numel(files)
  system(sprintf('./clean_csv.sh ../../measurements/%s_%s.csv',dtag,files{F}));
end

ch1=load(sprintf('../../measurements/%s_ch1.csv',dtag));
ch2=load(sprintf('../../measurements/%s_ch2.csv',dtag));
math1=load(sprintf('../../measurements/%s_math1.csv',dtag));
math2=load(sprintf('../../measurements/%s_math2.csv',dtag));

tmp=math2*-1;

figure(1)
plot(math1(:,1),math1(:,2))

figure(2)
plot(math2(:,1),math2(:,2))

m1delta = max(math1(:,2))-min(math1(:,2))
m2delta = max(math2(:,2))-min(math2(:,2))
gain = m2delta/m1delta


