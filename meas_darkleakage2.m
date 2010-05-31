
clear all
close all
fclose('all');

%{ 
   Matlab Controlled G3 Measurements

   Current Guiding Principles:
    - a single (not anymore) MATLAB-script controls the acquisition
        - why script and not function? -> debugging easier. if a function bails out in production, all internal states are lost.
    - concise, compact, not convoluted
    - try to use all variables as part of a struct to clarify their scope
%}

% flag.dryrun true will neither create folders nor talk to jjam
flag.dryrun=true;
flag.dryrun=false;

% flag.jabber is to turn on/off chat notification
flag.jabber=false;
flag.jabber=true;



% Setup descriptions in external file now
% (too many arrays, and too many different measurement scripts made this necessary)
meas_description


%
% Experimental Environment Description, part 2:
%   heavily measurement-type dependent settings
%

%env.G3ExtClock=100000; env.UseExtClock=1;
env.G3ExtClock=1000000; env.UseExtClock=0;


%
% Array-Type dependent definitions
%

if strcmp(setup.ARRAYTYPE,'PSI-1'); % PSI-1 definitions
    ts=@(psi1_value,psi2_value,psi3_value) (psi1_value);
end
if strcmp(setup.ARRAYTYPE,'PSI-2'); % PSI-2 definitions
    ts=@(psi1_value,psi2_value,psi3_value) (psi2_value);
end
if strcmp(setup.ARRAYTYPE,'PSI-3'); % PSI-3 definitions
    ts=@(psi1_value,psi2_value,psi3_value) (psi3_value);
end


%
% Array- and Measurement-Type dependent settings
%

if ts(1,2,3)==1; % PSI-1 settings and calculations
    geo.extra_gatelines=128;
    geo.extra_gatelines=64;
end
if ts(1,2,3)==2; % PSI-2 settings and calculations
    geo.extra_gatelines=0;
end
if ts(1,2,3)==3; % PSI-3 settings and calculations
    geo.extra_gatelines=128;
    geo.extra_gatelines=64;
end


%
% Array-Type dependent settings & calculations
%

if ts(1,2,3)==1; % PSI-1 settings and calculations
    geo.G3_SORTMODE=10;
    geo.GL=256+geo.extra_gatelines;%+32; do NOT use 256+32 (288) or 256+128 ! with pre-2010-03 interface card firmwares!
    geo.G3GL=geo.GL-1; % for regular arrays - PSI2/3 arrays have different values
    geo.DL=384;
    geo.G3DL=ceil((geo.DL+1)/512)*512/2 -1;
end

if ts(1,2,3)==2; % PSI-2 settings and calculations
    geo.G3_SORTMODE=11;
    geo.GL=256+geo.extra_gatelines;
    geo.G3GL=16*geo.GL-1;
    %GL=G3GL+1; % for cyclops data sorting, i.e. SORTMODE 10
    geo.DL=384;
    geo.G3DL=ceil((geo.DL/16+1)/512)*512/2 -1;
end

if ts(1,2,3)==3; % PSI-3 settings and calculations
    geo.G3_SORTMODE=12;
    geo.GL=128+geo.extra_gatelines;
    geo.G3GL=9*geo.GL-1;
    %GL=G3GL+1; % for cyclops data sorting, i.e. SORTMODE 10
    geo.DL=128;
    geo.G3DL=ceil((geo.DL/8+1)/512)*512/2 -1;
end

%
% Voltage Setting capability (if available)
%
multi.VBias=0;
multi.VRst=6;
multi.VQinj=1;

env.V(id.Vreset)= multi.VRst;
env.V(id.Vbias) = multi.VBias;
env.V(id.VQinj) = multi.VQinj;

   % write voltfile, will be picked up by shell script controlling power supply
   multi.VOLTFILE='./commtemp/arraySweep_volts.scpi';
   system(sprintf('echo "APP:VOLT %.3f,%.3f,%.3f" >%s.tmp',...
       multi.VRst-multi.VBias,multi.VRst,multi.VQinj,multi.VOLTFILE));
   system(sprintf('mv %s.tmp %s',multi.VOLTFILE,multi.VOLTFILE));



   
%
% Multi-Measurement Setup (experimental)
%

% play with all kinds of binning conditions
multi.MMATRIX=[
    %R13 %R14 %R6  %R4  %R3
       1    1 1600 1200 1
  %     1    1  800  600 6
  %     1    1 3200 2800 1
  %     1    2 1600 1200 1
  %{
       1    3
       1    4
       1    6
       1    8
  %}
  %     2    2
  %{     
       2    3
       2    4
       2    6
       2    8

       4    4
       4    6
       4    8

       1    1
       1    2
       1    3
       1    4
       1    6
       1    8
%}
   ];

multi.mnrofacq=size(multi.MMATRIX,1);
for mmid=1:multi.mnrofacq; multi.mmid=mmid;
multi.R13=multi.MMATRIX(multi.mmid,1);
multi.R14=multi.MMATRIX(multi.mmid,2);

multi.R6=multi.MMATRIX(multi.mmid,3);
multi.R4=multi.MMATRIX(multi.mmid,4);
multi.R3=multi.MMATRIX(multi.mmid,5);

% 
% Multi-Sequence-Setup
%

meas.DUT=[ setup.ARRAYTYPE '_' setup.WAFERCODE ];

%{
meas.MeasCond='DarkLeakage'; multi.R22=ts(4,0,0);
meas.MeasCond='FloodLeakage'; multi.R22=ts(4,0,0);
multi.RMATRIX=[
       1     500  20
       2     100  20   % not necessary for PSI-2
       5     100  20   % not necessary for PSI-2
      10     50   10   % not necessary for PSI-2
      20     50   10
      50     50   10
      100    20   10
      200    20   10
      400    20   10
      1000   0    5
      2000   0    5
      4000   0    2
      6000   0    2
      8900   0    2
      11900  0    2
%      15700  0    2
%      19550  0    2    
%      40000  0    2 %added 2010-04-27, mk
%      60000  0    2 %added 2010-04-27, mk
 ];
%}

%%{
meas.MeasCond='FloodLeakageNoise'; multi.R22=ts(4,0,0); multi.R22=2;
meas.MeasCond='DarkLeakageNoise'; multi.R22=ts(4,0,0); multi.R22=2;
multi.RMATRIX=[
   %R1      R26  R27  
       1    200  200 %1000
%       2     0    200   % not necessary for PSI-2
%       5     0   1000   % not necessary for PSI-2
%      10     0    50   % not necessary for PSI-2
      20     0    50
      50     0    50
      100    0    200
      200    0    30
      400    0    100
      1000   0    5
      2000   0    5
      4000   0    2
      6000   0    2
      8900   0    2
      11900  0    2
      15700  0    2
      19550  0    2    
%      40000  0    2 %added 2010-04-27, mk
%      60000  0    2 %added 2010-04-27, mk
 ];
%}


%{
multi.RMATRIX=[ % overnight long run noise measurement
   %R1      R26  R27  
       1    500   500
       2     0    500   % not necessary for PSI-2
       5     0    500   % not necessary for PSI-2
      10     0    200   % not necessary for PSI-2
      20     0    200
      50     0    200
      100    0    200
      200    0    200
      400    0    200
      1000   0    100
      2000   0    100 
      4000   0    100 
      6000   0    50 
      8900   0    50
      11900  0    50
      15700  0    50
      19550  0    50    
      40000  0    50 %added 2010-04-27, mk
      60000  0    50 %added 2010-04-27, mk
 ];
%}

%{
multi.RMATRIX=[ % overnight long run measurement, aiming for temperature drift
   %R1      R26  R27  
       1    500   500
       2     0    500   % not necessary for PSI-2
       5     0    500   % not necessary for PSI-2
      10     0    200   % not necessary for PSI-2
      20     0    200
      50     0    200
      100    0    200
      200    0    200
      400    0    200
      1000   0    100
      2000   0    100 
      4000   0    100 
      4010   0    100 
      4020   0    100 
      4030   0    100 
      4040   0    100 
      4050   0    100 
      4060   0    100 
      4060   0    100 
      4070   0    100 
      4080   0    100 
      4090   0    100 
      4100   0    100 
      4100   0    100 
      4110   0    100 
      4120   0    100 
      4130   0    100 
      4140   0    100 
      4150   0    100 
      4160   0    100 
      4170   0    100 
      4180   0    100 
      4190   0    100 
      4200   0    100 
      4210   0    100 
      4220   0    100 
      4230   0    100 
      4240   0    100 
      4250   0    100 
      4260   0    100 
      4270   0    100 
      4280   0    100 
      4290   0    100 
      4300   0    100 
 ];
 %}
 
if strcmp(meas.MeasCond(1:5),'Flood');
    multi.RMATRIX=multi.RMATRIX(1:14,:);
end
%}



multi.nrofacq=size(multi.RMATRIX,1);
if strcmp(meas.MeasCond(1:5),'First'); multi.nrofacq=1; end
if strcmp(meas.MeasCond(1:4),'Qinj' ); multi.nrofacq=1; end

meas.MeasDetails=[ sprintf('%s', meas.MeasCond) ...
    sprintf( '_Vbias%s', volt2str(env.V(id.Vbias)) ) ...
    sprintf( '_Vguard2%s', volt2str(env.V(id.Vguard2)) ) ...
    sprintf( '_Von%s', volt2str(env.V(id.Von)) ) ...
    ...sprintf( '_Vrst%s', volt2str(env.V(id.Vreset)) ) ...  not needed for PSI-1
    sprintf( '_Voff%s', volt2str(env.V(id.AVoff)) ) ...    
    ...sprintf( '_Vgnd%s', volt2str(env.V(id.Vgnd)) ) ...
    ...sprintf( '_Tbias%s', volt2str(env.V(id.Tbias)) ) ...
    ...sprintf( '_Vcc%s', volt2str(env.V(id.Vcc)) ) ...
    ...sprintf( '_Voff%s',  volt2str(env.V(id.AVoff)) ) ...    
    sprintf( '_VQinj%s', volt2str(env.V(id.VQinj)) ) ...
    sprintf( '_%02dR22', multi.R22                 ) ...
    ...sprintf( '_RST%s',    setup.PF_globalReset     ) ...
    ...sprintf('_%04dR6', multi.R6)  ...
    ...sprintf('_%04dR4', multi.R4)  ...
    ...sprintf('_%03dR3', multi.R3)  ...
    ...sprintf('_%02dR13', multi.R13)  ...
    ...sprintf('_%02dR14', multi.R14)  ...
    ...sprintf( '_GC%s',    setup.PF_gateCards        ) ...
    ...sprintf( '_DC%s',    setup.PF_dataCards        ) ...
    ...sprintf( '_GL%03d',  geo.GL                    ) ...
    ...sprintf( '_repeat'                 ) ...
    sprintf( '%s',    setup.special     ) ...
  ];


meas.MeasID=datestr(now(),30);
meas.DirName=[ '../measurements/' meas.DUT '/' meas.MeasID '_' meas.MeasDetails '/' ];
meas.MFile=[ mfilename() '.m' ];
if ~flag.dryrun;
    mkdir(meas.DirName);    
    copyfile(meas.MFile,[ meas.DirName meas.MFile ]);
    copyfile(meas.MFileDesc,[ meas.DirName meas.MFileDesc ]);
end;

%
% Multi-Sequence Loop
%

flag.G3_nuke=true;
flag.first_run=true;
flag.finished=false;
for mid=1:multi.nrofacq; multi.mid=mid;

   multi.R1 =multi.RMATRIX(multi.mid,1);
   %multi.R11=multi.RMATRIX(multi.mid,4);
   multi.R11=0; %255-16;
   %multi.R13=multi.RMATRIX(multi.mid,5);
   %multi.R13=1;%2
   %multi.R14=multi.RMATRIX(multi.mid,6);
   %multi.R14=1;%3
   multi.R26=multi.RMATRIX(multi.mid,2);
   multi.R27=multi.RMATRIX(multi.mid,3);

   %multi.R4=multi.RMATRIX(multi.mid,7);
   %multi.R21=multi.RMATRIX(multi.mid,8);
   %multi.R5=multi.RMATRIX(multi.mid,9);
   %multi.R6=multi.RMATRIX(multi.mid,10);

   %multi.R3=multi.RMATRIX(multi.mid,11);
   
   disp(multi);
    

meas.BaseName=[ meas.DirName ...
    meas.MeasID ... '_' meas.DUT   ...     
    sprintf('_Acq%03d', multi.mid) ...
 ...'_' meas.MeasDetails ...    
    sprintf('_%05dR1' , multi.R1)   ...
 ...sprintf('_%05dR3' , multi.R3)   ...
 ...sprintf('_%02dR4' , multi.R4)   ...
 ...sprintf('_%02dR21', multi.R21)  ...
 ...sprintf('_%02dR5' , multi.R5)   ...
 ...sprintf('_%02dR6' , multi.R6)   ...
 ...sprintf('_%05dR11', multi.R11)  ...
 ...sprintf('_%05dR13', multi.R13)  ...
 ...sprintf('_%05dR14', multi.R14)  ...
 ...sprintf('_%02dR22', multi.R22)  ...
    sprintf('_%02dR26', multi.R26)  ...
    sprintf('_%02dR27', multi.R27)  ...
   ];

meas.AcqFile=[ pwd() '/' meas.BaseName '.bin' ];
meas.MatFile=[ meas.BaseName '.settings.mat' ];

% Masda-R Gain Setting? How to record them?
% Jumper Configuration?
% G3Ext registers?
% easily switch between sets of values? good visualization?
% more array types...?

meas.R=[
 %value PSI-1 PSI-2 PSI-3   %name  bits  (default)units        Description
        multi.R1            %R1    16    (512)us   (F9==0)  Tau_1:   Primary Delay between Readouts. R1*512Mhz/tau1_clk ; tau1_clk=(F9==0)?1Mhz:extclock
        0                   %R2    16      (8)us  (F10==0)  Tau_2: Secondary Delay between Readouts, e.g. for LED-Flashing, starts after Tau_1, R2*8/tau2_clk ; tau2_clk=(F10==0)?1Mhz:extclock
        multi.R3                   %R3    16      (8)us  (F11==0)  Tau_3: Delay between Gate Line Groups. R3*8Mhz/tau3_clk ; tau3_clk=(F11==0)?1Mhz:extclock
        multi.R4    %ts( 1200,  300, 1000)   %R4    14      50 ns            Tau_4: preamp integration time (SAFT): R4*50ns ; starts 1.75us after Tau_21 [?? Tint=3.9+0.05(R21+R4-R5) in us]
                     ts(  400,   50,   50)   %R5    12      50 ns            Tau_5: Gate Hold-off, i.e. delay before Gate-On, 0.05us*R5, for non-multiplexed arrays larger than 2.15us+0.05us*R21+1.75us
        multi.R6    %ts( 1600, 2000, 2150)   %R6    16      50 ns            Tau_6: Gate-On-Time, 0.05us*R6, starts after Tau_5
        0                   %R7          N/I
        0                   %R8    12       1 us  (F12==1)  Tau_8: LED HOLD-off delay, i.e. delay between start of Tau_2 and the first flash
        0                   %R9    12       1 us  (F12==1)  Tau_9: LED Delay between flashes (applies only if R25>1?)
        0                   %R10   12       1 us  (F12==1)  Tau10: LED Width of each flash [see also: R8,R9,R25,F12,F13]
        multi.R11           %R11   12    gatelines          Address of 1st selected Gate Line (DO NOT MULTIPLY FOR PSI-2 & PSI-3!)
        geo.G3GL            %R12   12    glgroups           # of Gate Line Groups-1 to be read out
        multi.R13           %R13    8    gatelines          Gate Line Increment:  increment between reads (happens in gl-advance phase, during Tau_3, just before START_ROW)
        multi.R14           %R14    8    gatelines          Gate Line Group Size: simultaniously addressed gate lines (clocked into supertex shift register right after START_FRAME)
        0                   %R15   12    datalines          Address of 1st Data Line - must start at mux boundary, 16 in case of BB-ADC?
        geo.G3DL            %R16   12    datalines          # of Data Lines / 2 -1, multiple of preamp mux (512)
        0                   %R17         N/I
        0                   %R18         N/I
        0                   %R19    8    glgroups  (F8=0)   # of gate line groups between Tau_3 delays
        0                   %R20         N/I 
    ts(  300, 2000, 1000)   %R21   12     (50)ns            Tau21: before-sample integration time (SBEF): R21*50ns; starts 2.15us after START_ROW [ ??0.05*R21-5 in us]
        multi.R22           %R22   12    set by dips        Masda-R Preamplifier Gain Setting 2=PG5(0.725pF) 4=PG4(1.45pF) 8=PG3(2.9pF)
        0                   %R23         N/I
        0                   %R24         N/I
        0                   %R25   12    flashes (F12==1)   # of LED flashes per acquisition cycle (0: really no LED flash)
        multi.R26           %R26   16    cycles             # of Ignore Cycles
        multi.R27           %R27   16    cycles             # of  Data  Cycles (continous if R26==0&&R27==0)
        0                   %R28   12    cycles  (F12==1)   Initial Cycle to start LED flashes, zero-indexed (0: start at first cycle)
        0                   %R29   12    cycles  (F12==1)   # of Data Cycles with LED flashes (R29==0&R28==0: always flashing! R29==0&&R28>0: really no cycle with LED flashes, but still Tau_8,Tau_9&Tau10 Timing during Tau_2?)
        15                  %R30                            FIX # ADC bits -1, fixed to 15. internally a 4-bit register
        0                   %R31         N/I
        0                   %R32         N/I
        sum([
        0       %FO         N/I
        0       %F1         N/I? Cycle Mode: Single Cycle(0) or Continous Cycle(1)
        0       %F2         N/I? Frame Transfer Mode: Continuous vs. Single
        0       %F3         FIX set by acquisition software: Acquisition Request
        0       %F4         FIX set by acquisition software: Data Frame Transfer Request
        0       %F5         UNCOMMON Frame Summing Request
        0       %F6         N/I
        0       %F7         N/I
        0       %F8    readout ctrl for multiple GL groups between Tau_3 delays, see R19
        env.UseExtClock %F9 Tau_1 clock source         (0: internal, 1: External)
        0       %F10   Tau_2 & Tau_8 clock source (0: internal, 1: External)
        0       %F11   Tau_3 clock source         (0: internal, 1: External)
        0       %F12   Master LED Flashing control (see R8,R9,R10,R25,R28,R29,F13)
        0       %F13   Flash LED during ignore cycles (needs F12 as well to be active!)
        0       %F14        N/I
        0       %F15        UNCOMMON Offset Substraction Control
        ]'.*(2.^(0:15)))
      ];

meas.userdata=g3_acquisition_userdata( setup, env );
[compsys.s1 compsys.filedescriptors]=system('find /proc/ -maxdepth 3 -a \( -name cwd -o -name exe -o -regex ''.*/fd/.*'' \) -printf ''%p %l\n''');
[compsys.s2 compsys.psxafuw]=system('ps xafuw');
if ~flag.dryrun;
save(meas.MatFile);
g3_startacq_udata('localhost',9008,...
    meas.R,meas.userdata,meas.AcqFile,geo.G3_SORTMODE,flag.G3_nuke,mid==multi.nrofacq);
end
flag.G3_nuke=false;

% Jabber notification
tool_notification(flag.jabber&&flag.first_run,env,meas,multi,'started',[0 0]);
flag.first_run=false;

end % end for-loop for R (R1, R26, R27) matrix

display('Measurement complete');

end  % end for-loop for R (R13, R14) matrix

% jabber work in progress
flag.finished=true;
tool_notification(flag.jabber,env,meas,multi,'finished',[0 0]);

