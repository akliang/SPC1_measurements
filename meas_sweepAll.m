
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

    Albert addition to this scrit
    - goal was to limit the "editable" variables to the top-half of the script
    - another goal was to decrease the number of variable change locations (increase dependencies between variables)
%}

% flag.dryrun true will neither create folders nor talk to jjam
flag.dryrun=true;
%flag.dryrun=false;

% flag.jabber is to turn on/off chat notification
flag.jabber=false;
%flag.jabber=true;

% flag.BKvoltage is automatically set to true if you define VMATRIX
flag.BKvoltage=false;



% Array and platform description
meas_description

% Additional description information for BK Precision varying experimental voltages
setup.POWER_SWEEP=[ setup.HOSTNAME '_BK_9130_005004156568001013_V1.69' ];
setup.POWERMEAS.V.VBiasVRst={setup.POWER_SWEEP,'text_env1',5};   % Power Measurements: file or db descriptor, file format, data channel
setup.POWERMEAS.V.VRst     ={setup.POWER_SWEEP,'text_env1',6};
setup.POWERMEAS.V.VQinj    ={setup.POWER_SWEEP,'text_env1',7};
setup.POWERMEAS.I.VBiasVrst={setup.POWER_SWEEP,'text_env1',9};
setup.POWERMEAS.I.VRst     ={setup.POWER_SWEEP,'text_env1',10};
setup.POWERMEAS.I.VQinj    ={setup.POWER_SWEEP,'text_env1',11};
setup.SWEEP.VRstGND = '200 ohms';
setup.SWEEP.BKOut1P='Vreset';
setup.SWEEP.BKOut1N='Vbias';
setup.SWEEP.BKOut2P='Vreset';
setup.SWEEP.BKOut2N='AGND';
setup.SWEEP.BKOut3P='Qinj';
setup.SWEEP.BKOut3N='AGND';

%
% Experimental Environment Description, part 2:
%   heavily measurement-type dependent settings
%

% By default, using no external clock, unless explicitly set by measurement condition
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
    geo.GL=256+geo.extra_gatelines;%+32; do NOT use 256+32 or 256+128 with pre-2010-03 interface card firmwares!
    geo.G3GL=geo.GL-1;
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
% Multi-Measurement Setup (experimental)
%


% Set up the desired voltage sweep range
multi.VMATRIX=[];  % [VBias  %VRst  %VQinj]

%{
% QInj/VRst sweep
flag.BKvoltage=true;

    for VQinj=[0:0.5:2];  % Qinj sweep
        multi.VMATRIX(end+1,:)=[0   0   VQinj];
    end

    for VRst=[0:0.5:8];  % VRst sweep for Vbias==Vrst
        multi.VMATRIX(end+1,:)=[VRst   VRst   1];
    end
    for VRst=[0:0.5:8];  % VRst sweep for Vbias 3V below Vrst
        multi.VMATRIX(end+1,:)=[VRst-3   VRst   1];
    end
    meas.MeasDetailsVars={
    'Vbias'     'env'
    'Vreset'    'env'
    'VQinj'     'env'
    'R22'       'multi'
    'special'   'setup'
    };

%}



%{
% Dark Leakage for PSI-2
flag.BKvoltage=true;

    for VBias=[2:0.5:6];
        multi.VMATRIX(end+1,:)=[VBias   6   1];
    end
    meas.MeasDetailsVars={
    'Vbias'     'env'
    'Vreset'    'env'
    'VQinj'     'env'
    'R22'       'multi'
    'special'   'setup'
    };
%}


%{
% Single "static" voltage
flag.BKvoltage=true;
    
    multi.VMATRIX(end+1,:)=[3 5 0.5];
    meas.MeasDetailsVars={
    'Vbias'     'env'
    'Vreset'    'env'
    'VQinj'     'env'
    'R22'       'multi'
    'special'   'setup'
    };
%}



% 
% BEGIN first outer loop
%

% if you want just a static voltage run, this will force the outer loop to run once
if (flag.BKvoltage==false); multi.VMATRIX=[1]; end;
flag.first_run=true;
multi.mnrofacq=size(multi.VMATRIX,1);
for mmid=1:multi.mnrofacq; multi.mmid=mmid;
   
   if (flag.BKvoltage==true);
      multi.VBias=multi.VMATRIX(multi.mmid,1);
      multi.VRst =multi.VMATRIX(multi.mmid,2);
      multi.VQinj=multi.VMATRIX(multi.mmid,3);
      env.V(id.Vreset)= multi.VRst;
      env.V(id.Vbias) = multi.VBias ;
      env.V(id.VQinj) = multi.VQinj;

      % write voltfile, will be picked up by shell script controlling power supply
      multi.VOLTFILE='./commtemp/arraySweep_volts.scpi';
      system(sprintf('echo "APP:VOLT %.3f,%.3f,%.3f" >%s.tmp',...
          multi.VRst-multi.VBias,multi.VRst,multi.VQinj,multi.VOLTFILE));
      system(sprintf('mv %s.tmp %s',multi.VOLTFILE,multi.VOLTFILE));
   end
   




% 
% Multi-Sequence-Setup
%


%%{
% For "regular measurements"
 meas.MeasCond='TwinFlood';         meas.RMATvers=2; multi.R22=ts(0,0,0);
%meas.MeasCond='TwinDark';          meas.RMATvers=1; multi.R22=ts(0,0,0);
%meas.MeasCond='FloodLeakageNoise'; meas.RMATvers=1; multi.R22=ts(4,0,0); multi.R22=2;
%meas.MeasCond='DarkLeakageNoise';  meas.RMATvers=1; multi.R22=ts(4,0,0); multi.R22=14;

% call the meas_condition "database"
% right-click and "open selection" to see the database
meas_conditions
%}


% Re-define or add variables to the folder name, if necessary
% Be aware and conscious of the R parameters
% ... not all exist at this point of the measurement yet
% Normally, automatically generated by the MMATRIX settings
%meas.MeasDetailsVars={};



% Re-define or add variables to the file name
% Normally, automatically generated by the meas.MeasCond selection
%meas.BaseNameVars={};






%
%
% NO MORE EDITING NEEDED BEYOND THIS LINE!!
%
%


% look-up tables for all the sprintf calls
multiLUT.R1='_%05dR1';
multiLUT.R3='_%03dR3';
multiLUT.R4='_%04dR4';
multiLUT.R6='_%04dR6';
multiLUT.R11='_%05dR11';
multiLUT.R13='_%03dR13';
multiLUT.R14='_%03dR14';
multiLUT.R22='_%02dR22';
multiLUT.R26='_%02dR26';
multiLUT.R27='_%02dR27';

envLUT.Vbias='_Vbias%s';
envLUT.Vreset='_Vrst%s';
envLUT.VQinj='_VQinj%s';
envLUT.AVoff='_Voff%s';
envLUT.Von='_Von%s';
envLUT.Vgnd='_Vgnd%s';
envLUT.Tbias='_Tbias%s';
envLUT.Vcc='_Vcc%s';
envLUT.Vguard2='_VguardTwo%s';

setupLUT.PF_globalReset='_RST%s';
setupLUT.PF_gateCards='_GC%s';
setupLUT.PF_dataCards='_DC%s';
setupLUT.special='%s';

geoLUT.GL='_GL%03d';



% Create the folder name
meas.MeasDetails=[sprintf('%s', meas.MeasCond)];
for meas_i=1:size(meas.MeasDetailsVars,1);
    if strcmp(meas.MeasDetailsVars{meas_i,2},'env');
        meas.MeasDetails=[meas.MeasDetails sprintf(envLUT.(meas.MeasDetailsVars{meas_i,1}), volt2str(env.V(id.(meas.MeasDetailsVars{meas_i,1}))))];
    elseif strcmp(meas.MeasDetailsVars{meas_i,2},'multi');
        meas.MeasDetails=[meas.MeasDetails sprintf(multiLUT.(meas.MeasDetailsVars{meas_i,1}), multi.(meas.MeasDetailsVars{meas_i,1}))];
    elseif strcmp(meas.MeasDetailsVars{meas_i,2},'setup');
        meas.MeasDetails=[meas.MeasDetails sprintf(setupLUT.(meas.MeasDetailsVars{meas_i,1}), setup.(meas.MeasDetailsVars{meas_i,1}))];
    elseif strcmp(meas.MeasDetailsVars{meas_i,2},'geo');
        meas.MeasDetails=[meas.MeasDetails sprintf(geoLUT.(meas.MeasDetailsVars{meas_i,1}), geo.(meas.MeasDetailsVars{meas_i,1}))];
    else
        error('Undefined LUT parameter detected.');
    end
end


meas.DUT=[ setup.ARRAYTYPE '_' setup.WAFERCODE ];
meas.MeasID=datestr(now(),30);
meas.DirName=[ '../measurements/' meas.DUT '/' meas.MeasID '_' meas.MeasDetails '/' ];
meas.MFile=[ mfilename() '.m' ];
if ~flag.dryrun;
    mkdir(meas.DirName);    
    copyfile(meas.MFile,[ meas.DirName meas.MFile ]);
    copyfile(meas.MFileDesc,[ meas.DirName meas.MFileDesc ]);

    %%{
    % write the RMATRIX that was actually used to a file
    rmat_file = fopen([ meas.DirName 'meas_conditions.m'],'w');
    fprintf(rmat_file,'switch meas.MeasCond \n case \''%s\''\n',meas.MeasCond);
    fprintf(rmat_file,'switch meas.RMATvers \n case %d\n',meas.RMATvers);
    
    fprintf(rmat_file,'multi.RMATheader={ \n');
    fprintf(rmat_file,'\''%s\'' ',multi.RMATheader{1,:});
    fprintf(rmat_file,'};\n');
    
    fprintf(rmat_file,'multi.RMATRIX=[\n');
    for rmat_i=1:size(multi.RMATRIX,1);
        fprintf(rmat_file,'%d ',multi.RMATRIX(rmat_i,:));
        fprintf(rmat_file,'\n');
    end
    fprintf(rmat_file,']; \n end \n end');
    fclose(rmat_file);
    %}
    
    % or... write the entire RMATRIX database to file?
    %copyfile(meas.MFileCond,[ meas.DirName meas.MFileCond ]);
end;




%
% BEGIN second outer loop
%

multi.nrofacq=size(multi.RMATRIX,1);
if strcmp(meas.MeasCond(1:5),'First'); multi.nrofacq=1; end
if strcmp(meas.MeasCond(1:4),'Qinj' ); multi.nrofacq=1; end

flag.G3_nuke=true;
for mid=1:multi.nrofacq; multi.mid=mid;
    
    
    % load the R1...R27 variables for measurement
    for header_i=1:size(multi.RMATheader,2);
        multi.(multi.RMATheader{header_i})=multi.RMATRIX(multi.mid,header_i);
    end
    
   
   disp(multi);
    
  

   
   


% Create the BaseName (folder name)
meas.BaseName=[
    meas.DirName meas.MeasID '_' meas.DUT ...
    sprintf('_Acq%03d', multi.mid)
];
for basename_i=1:size(meas.BaseNameVars,2);
    meas.BaseName=[meas.BaseName...
        sprintf(multiLUT.(meas.BaseNameVars{basename_i}),multi.(meas.BaseNameVars{basename_i}));
    ];
end




meas.AcqFile=[ pwd() '/' meas.BaseName '.bin' ];
meas.MatFile=[ meas.BaseName '.settings.mat' ];

% Masda-R Gain Setting? How to record them?
% Jumper Configuration?
% G3Ext registers?
% easily switch between sets of values? good visualization?
% more array types...?

% Make sure commonly manipulated R variables have values
if (~isfield(multi,'R1'));  error('No multi.R1 set!');  end;
if (~isfield(multi,'R11')); error('No multi.R11 set!'); end;
if (~isfield(multi,'R13')); error('No multi.R13 set!'); end;
if (~isfield(multi,'R14')); error('No multi.R14 set!'); end;
if (~isfield(multi,'R22')); error('No multi.R22 set!'); end;
if (~isfield(multi,'R26')); error('No multi.R26 set!'); end;
if (~isfield(multi,'R27')); error('No multi.R27 set!'); end;




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

end % end INNER LOOP

display('Measurement complete');

end  % end OUTER LOOP


% Jabber notification
tool_notification(flag.jabber,env,meas,multi,'finished',[0 0]);


