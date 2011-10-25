
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
meas_desc_gen2g3


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

if strcmp(setup.ARRAYTYPE,'Gen2_TAA'); % TAA definitions for timing, more like psi-2
    ts=@(psi1_value,psi2_value,psi3_value) (psi2_value);
end

%
% Array- and Measurement-Type dependent settings
%

    geo.extra_gatelines=32+64;


%
% Array-Type dependent settings & calculations
%
switch setup.ARRAYTYPE
  case {'PSI-1'}  % PSI-1 settings and calculations
    geo.G3_SORTMODE=10;
    geo.GL=256+geo.extra_gatelines;%+32; do NOT use 256+32 (288) or 256+128 or 96 ! with pre-2010-03 interface card firmwares!
    geo.G3GL=geo.GL-1; % for regular arrays - PSI2/3 arrays have different values
    geo.DL=384;
    geo.G3DL=ceil((geo.DL+1)/512)*512/2 -1;
  case {'Gen2_TAA'}
    geo.G3_SORTMODE=10;
    geo.GL=32+geo.extra_gatelines;
    geo.G3GL=geo.GL-1; 
    geo.DL=64;
    geo.G3DL=ceil((geo.DL+1)/512)*512/2 -1;
end



%
% Multi-Measurement Setup (experimental)
%


% Set up the desired voltage sweep range
multi.MMATRIX=[];

% Sweep  Vout3  (VQinj) to verify gain
% Toggle Vout11 (DataLogicHI) to see difference between addressed and non-addressed array
% Add CW / CCW scanning direction to description

%%{
% Qinj sweep
for VQinj=[0:0.5:2];
    for VRst=[0];
multi.MMATRIX(end+1,:)=[
   %VDatLHI %VRst %VQinj
   VRst  VRst   VQinj
];
    end
end

% another sweep with VQinj=1V and VDatLHI 0 and 7 V
for VQinj=[1];
    for VDatLHI=[0 7];
multi.MMATRIX(end+1,:)=[
   %VDatLHI %VRst %VQinj
   VDatLHI  VRst   VQinj
];
    end
end
%}

flag.first_run=true;
multi.mnrofacq=size(multi.MMATRIX,1);
for mmid=1:multi.mnrofacq; multi.mmid=mmid;
%multi.R13=multi.MMATRIX(multi.mmid,1);
%multi.R14=multi.MMATRIX(multi.mmid,2);

multi.VDatLHI=multi.MMATRIX(multi.mmid,1);
multi.VRst =multi.MMATRIX(multi.mmid,2);
multi.VQinj=multi.MMATRIX(multi.mmid,3);


% TODO: adopt for SMU scenario 
env.V(id.Vreset)= multi.VRst;
env.V(id.VDatLHI) = multi.VDatLHI;
env.V(id.VQinj) = multi.VQinj;

% Communicate with multim_2636A_quad.sh :
if ~flag.dryrun;
   % write voltfile, will be picked up by shell script controlling SMUs
   multi.VOLTFILE='./commtemp/2636_command.scpi';
   smu.chan_is_set=nan(max(smu.vid2ch),1);
   fid=fopen([ multi.VOLTFILE '.tmp' ],'w');
     for vid=1:numel(smu.vid2ch);
        if smu.vid2ch(vid)==0; disp(sprintf('Vout%d is not mapped to SMU.',vid)); continue; end
        if ~isnan(smu.chan_is_set(smu.vid2ch(vid))); 
          if smu.chan_is_set(smu.vid2ch(vid)) ~= env.V(vid);
              disp(sprintf( 'Vout%d already set to %.3f by smu_ch%d',vid,smu.chan_is_set(smu.vid2ch(vid)),smu.vid2ch(vid) ));
          end
          continue;
        end 
       fwrite(fid, sprintf('v%d(%.5f)\n', smu.vid2ch(vid), env.V(vid) ) );
       smu.chan_is_set(smu.vid2ch(vid)) = env.V(vid);
   end
   fclose(fid);
   system(sprintf('mv %s.tmp %s',multi.VOLTFILE,multi.VOLTFILE));
end   

% 
% Multi-Sequence-Setup
%

meas.DUT=[ setup.ARRAYTYPE '_' setup.WAFERCODE ];

%%{
meas.MeasCond='Gen2PNC4Test'; multi.R22=0;
multi.RMATRIX=[
   %R1    R26   R27   R11    R13    R14  R22
    1     0     400    0      1      1   14
    1     0     400    0      1      1   2
%    1     0     400    0      2      2
   100    0     200    0      1      1   2
%   100    0     200    0      2      2
];
%}

%{
meas.MeasCond='TwinDark'; multi.R22=0;
%meas.MeasCond='TwinFlood'; multi.R22=0;
multi.RMATRIX=[
   %R1    R26   R27   R11    R13    R14
    1     20    10     0      1      1
    1     10    10     0      2      2
   1000   10    10     0      1      1
   1000   10    10     0      2      2
];
%}

%{
%meas.MeasCond='FloodLeakageNoise'; multi.R22=ts(4,0,0); multi.R22=2;
meas.MeasCond='DarkLeakageNoise'; multi.R22=ts(4,0,0); multi.R22=14;
multi.RMATRIX=[
   %R1      R26  R27        R11 R13 R14
       1    200  200         0   1   1%1000
%       2     0    200   % not necessary for PSI-2
%       5     0   1000   % not necessary for PSI-2
%      10     0    50   % not necessary for PSI-2
      20     0    50        0   1   1
      50     0    50        0   1   1
      100    0    200        0   1   1
      200    0    30        0   1   1
      400    0    100        0   1   1
      1000   0    5        0   1   1
      2000   0    5        0   1   1
      4000   0    5        0   1   1
      6000   0    5        0   1   1
      8900   0    5        0   1   1
      11900  0    5        0   1   1
      15700  0    5        0   1   1
      19550  0    5           0   1   1 
%      40000  0    2 %added 2010-04-27, mk
%      60000  0    2 %added 2010-04-27, mk
 ];

env.G3ExtClock=100000; env.UseExtClock=1;
%}





multi.nrofacq=size(multi.RMATRIX,1);
if strcmp(meas.MeasCond(1:5),'First'); multi.nrofacq=1; end
if strcmp(meas.MeasCond(1:4),'Qinj' ); multi.nrofacq=1; end

meas.MeasDetails=[ sprintf('%s', meas.MeasCond) ...
    ...sprintf( '_Vbias%s', volt2str(env.V(id.Vbias)) ) ...
    ...sprintf( '_Vguard2%s', volt2str(env.V(id.Vguard2)) ) ...
    ...sprintf( '_Von%s', volt2str(env.V(id.Von)) ) ...
    sprintf( '_Vrst%s', volt2str(env.V(id.Vreset)) ) ...  not needed for PSI-1
    ...sprintf( '_Voff%s', volt2str(env.V(id.AVoff)) ) ...    
    ...sprintf( '_Vgnd%s', volt2str(env.V(id.Vgnd)) ) ...
    ...sprintf( '_Tbias%s', volt2str(env.V(id.Tbias)) ) ...
    ...sprintf( '_Vcc%s', volt2str(env.V(id.Vcc)) ) ...
    ...sprintf( '_Voff%s',  volt2str(env.V(id.AVoff)) ) ...    
    sprintf( '_VQinj%s', volt2str(env.V(id.VQinj)) ) ...
    sprintf( '_VDatLHI%s', volt2str(env.V(id.VDatLHI)) ) ...
    ...sprintf( '_RST%s',    setup.PF_globalReset     ) ...
    ...sprintf('_%04dR6', multi.R6)  ...
    ...sprintf('_%04dR4', multi.R4)  ...
    ...sprintf('_%03dR3', multi.R3)  ...
    ...sprintf('_%02dR13', multi.R13)  ...
    ...sprintf('_%02dR14', multi.R14)  ...
    ...sprintf( '_%02dR22', multi.R22                 ) ...
    ...sprintf( '_GC%s',    setup.PF_gateCards        ) ...
    ...sprintf( '_DC%s',    setup.PF_dataCards        ) ...
    ...sprintf( '_GL%03d',  geo.GL                    ) ...
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
flag.finished=false;
for mid=1:multi.nrofacq; multi.mid=mid;

   multi.R1 =multi.RMATRIX(multi.mid,1);
   multi.R11=multi.RMATRIX(multi.mid,4);
   %multi.R11=0; %255-16;
   multi.R13=multi.RMATRIX(multi.mid,5);
   %multi.R13=1;%2
   multi.R14=multi.RMATRIX(multi.mid,6);
   multi.R22=multi.RMATRIX(multi.mid,7);
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
    sprintf('_%05dR13', multi.R13)  ...
    sprintf('_%05dR14', multi.R14)  ...
    sprintf('_%02dR22', multi.R22)  ...
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
        1                   %R3    16      (8)us  (F11==0)  Tau_3: Delay between Gate Line Groups. R3*8Mhz/tau3_clk ; tau3_clk=(F11==0)?1Mhz:extclock
        ts( 1200,  300, 1000)   %R4    14      50 ns            Tau_4: preamp integration time (SAFT): R4*50ns ; starts 1.75us after Tau_21 [?? Tint=3.9+0.05(R21+R4-R5) in us]
        ts(  400,   50,   50)   %R5    12      50 ns            Tau_5: Gate Hold-off, i.e. delay before Gate-On, 0.05us*R5, for non-multiplexed arrays larger than 2.15us+0.05us*R21+1.75us
        ts( 1600, 2000, 2150)   %R6    16      50 ns            Tau_6: Gate-On-Time, 0.05us*R6, starts after Tau_5
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

