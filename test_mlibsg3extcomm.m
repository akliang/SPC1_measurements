
clear('all');
close('all');
fclose('all');

run('./mlibs/mlibsys/mlibsInit.m');

g3x.comm=G3ExtSelCommIface('MBUART');
g3x.comm.tempfile='./tmp/g3xuartcommands.txt';
g3x.comm.iface='/dev/ttyUSB0';
g3x.struct_dp=G3extDigipotInit(g3x.comm);

%g3x.dpvalues=round(rand(10,1)*1023);
g3x.dpvalues=[1023 1023 1023 1023 1023 1023 1023 1023 1023 1023];
%g3x.dpvalues=[1023 1023 0 1023 1023 1023 1023 1023 1023 1023];
G3extDigipotSetVal(g3x.comm, g3x.struct_dp, g3x.dpvalues);
