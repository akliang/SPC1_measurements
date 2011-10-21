%fname='/home/user/Desktop/ArrayData/PSI1/2010-01-22/29A10-4/scriptmeas/PSI129A10-4_20100122T125143_Dark_Voff-4V0_Vbias-2V0_GL383/Dark_Voff-4V0_Vbias-2V0_GL383_00001R1_00100R26_00100R27_.bin.fmd';
fname='/home/user/Desktop/ArrayData/PSI1/2010-01-28/29A30-3/scriptmeas/PSI129A30-3_20100129T000100_DarkLeakage_Voff-2V0_Vbias-4V0_Qinj1V0_GL383_DC143/DarkLeakage_Voff-2V0_Vbias-4V0_Qinj1V0_GL383_DC143_00001R1_00100R26_00200R27_00001R3_00001R13_00000R11.fmd'
fname='/home/user/Desktop/ArrayData/PSI1/2010-01-28/29A30-3/scriptmeas/PSI129A30-3_20100129T005830_DarkLeakage_Voff-2V0_Vbias-4V0_Qinj1V0_GL383_DC143/DarkLeakage_Voff-2V0_Vbias-4V0_Qinj1V0_GL383_DC143_00001R1_00100R26_00200R27_00001R3_00001R13_00000R11.fmd'
fid=fopen(fname,'r','ieee-be');
fnr=0;
anr=0;
last_aid=0;
while ~feof(fid)
fpos=ftell(fid);
headlen=fread(fid,1,'int64');
if feof(fid)
break;
end

if (headlen==1);
    version=1;
    headlen=256-8;
else
    version=fread(fid,1,'int64');
end


if version==1;
p=fread(fid,10,'int64');
p=[version p']';
aid=p(2);
else
p=fread(fid,14,'int64');
p=[headlen version p']';
aid=p(4);
end

r=fread(fid,33,'uint16');
if version>1;
fseek(fid,fpos+200,'bof');
udata=fread(fid,floor((headlen+8-200)/2)+2,'uint16');
end

fnr=fnr+1;
fseek(fid,fpos+headlen+8,'bof');
if p(2)~=last_aid
    headlen
    last_aid=p(2);
    anr=anr+1;
    display(['Acquisition no. ' num2str(anr) ' at frame ' num2str(fnr) ':'])
    p([1:3 5:16]) 
    r
    udata
end



end
fclose(fid);
