clear('all');
close('all');
fclose('all');

run('./mlibs/mlibsys/mlibsInit.m');

g3x.comm=G3ExtSelCommIface('MBUART');
g3x.comm.tempfile='./tmp/g3xuartcommands.txt';
g3x.comm.iface='/dev/ttyUSB0';


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
%meas_description
setup.LOCATION='Argus Building, Electronics Lab';
setup.HOSTNAME='simwork'; % hostname of computer running this script
%setup.G3_system='2of9-vanilla';
setup.G3_system='2of9-vanilla';
%setup.G3_interface='a2-V20-20100408'; % serial number - hardware version - bitfile version
setup.G3_interface='a1-V20-20100316'; % serial number - hardware version - bitfile version
%setup.G3_adcCards='a1-a2-00-00-00-00-00-00'; % On G3 ADC Board, they are labeled ADC8-...-1
setup.G3_adcCards='m2-00-00-00-00-00-00-00'; % On G3 ADC Board, theyare labeled ADC8-...-1


setup.POWER_G3='Built-in';
setup.POWER_ADC='BKPRECISION1761#2_AND_AGILENT_E3612A';

setup.POWER_ADCCHAR=[ setup.HOSTNAME '_BK_9130_005004156568001055_V1.69' ];
setup.POWERMEAS.FILEPREFIX='../measurements/environment/';
setup.POWERMEAS.FILENAME{1}=[ 'measADC_' setup.POWER_ADCCHAR ];
%setup.POWERMEAS.FILENAME{2}=[ 'meas_simwork_HEWLETT-PACKARD_34401A_0_7-5-2' ];
setup.POWERMEAS.FILENAME{2}=[ 'meas_simwork_Keithley_Instruments_Inc.__Model_2636A__1299494__2.1.6' ];
setup.POWERMEAS.V.VADCm={setup.POWERMEAS.FILENAME{1},'text_env1',5};   % Power Measurements: file or db descriptor, file format, data channel
setup.POWERMEAS.V.VADCp={setup.POWERMEAS.FILENAME{1},'text_env1',6};
setup.POWERMEAS.V.V5p = {setup.POWERMEAS.FILENAME{1},'text_env1',7};
setup.POWERMEAS.I.VADCm={setup.POWERMEAS.FILENAME{1},'text_env1',9};
setup.POWERMEAS.I.VADCp={setup.POWERMEAS.FILENAME{1},'text_env1',10};
setup.POWERMEAS.I.V5p = {setup.POWERMEAS.FILENAME{1},'text_env1',11};
setup.POWERMEAS.V.dVADC={setup.POWERMEAS.FILENAME{2},'text_env1',5};


setup.ARRAYTYPE='PSI-1';
setup.WAFERCODE='DACCHAR';
setup.PLATFORM='DACCHAR';
setup.PF_dataCards='00'; % PSI-3 only has one dataCard
setup.PF_dataCardDIPs='0000000000'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='n/a'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='00';
setup.PF_analogCard='d1';
setup.PF_arrayLogic='n/a'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
setup.PF_CrossCable='n/a';
setup.PF_globalReset='all';
setup.special='dpot_9_10';
setup.battery=false;
%setup.special='_ADCch1_set1'; 
% setup.ADCtype='normal';
% setup.ADCconnected='a2';
setup.ADCtype='+-20V';
setup.ADCconnected='m2';
%setup.Dpottoch=[8 7 6 5 4 3 2 1 9 10]; %vector which contains the channels the digipots are connected to starting from digipot1. If not connected to any channel - 0;
setup.Dpottochpair=[4 0 5 1 13 0 6 2 12 0 11 16 10 15 7 0 9 14 8 3]; %vector which contains the channels
%the digipots are connected to starting from digipot1. If not connected to
%any channel - 0, make sure that only the 2nd channel is 0
setup.Dpotconn='d1';
setup.HPdp2monitor=[9 10];

env.V=[];
env.V(end+1)=  0.0  ; id.AVoff   =numel(env.V);                             % Test Point near to Gate Card
env.V(end+1)=  0.0  ; id.Von     =numel(env.V);                             % Test Point near to Gate Card
env.V(end+1)=  0.0  ; id.Vout10  =numel(env.V);   id.RevBias =numel(env.V); % Vn.Vout10=0.0;  %PSI3: Vn.RevBias=-2.5;         % Vout10
env.V(end+1)=  0.0  ; id.Vout9   =numel(env.V);   id.Vreset  =numel(env.V); % Vn.Vout9=0.0;   %PSI3: Vn.Vreset=15.0;          % Vout9
env.V(end+1)=  0.0  ; id.Vout8   =numel(env.V);   id.Vcc     =numel(env.V); % Vn.Vout8=0.0;   %PSI3: Vn.Vcc=8;                % Vout8
env.V(end+1)=  0.0  ; id.Vguard2 =numel(env.V);   id.Tbias   =numel(env.V); % Vn.Vguard2=0.0; %PSI3: Vn.Tbias=5.5;            % Vout7
env.V(end+1)=  0.0  ; id.Vguard1 =numel(env.V);   id.Vgnd    =numel(env.V); % Vn.Vguard1=0.0; %PSI3: Vn.Vgnd=1.0;             % Vout6
env.V(end+1)=  0.0  ; id.Vbias2  =numel(env.V);   id.MuxHigh =numel(env.V); % Vn.Vbias2=0.0 ; %PSI3: Vn.Mux_High=15.0;        % Vout5
env.V(end+1)=  0.0  ; id.Vbias   =numel(env.V);                   % Vn.Vbias=-3.0;   env.V(end+1)=env.V(id.Vgnd)   env.V(id.Vreset)  % Vout4
env.V(end+1)=  0.0  ; id.VQinj   =numel(env.V);                              % Vn.Qinj=2.0; % toggle between 1 and 2 V         % Vout3
env.V(end+1)=  0.0  ; id.Vref    =numel(env.V);                             % Vn.Vref=0.856; 2.303  for PSI2/3 cards  %   usually generated by R/R on Masda-R card
env.V(end+1)=  env.V(id.RevBias)  ; id.DLrstGate =numel(env.V);                  % env.V(id.Vguard2)
env.V(end+1)=  0    ; id.DLrstGnd   =numel(env.V);                           % hard-wired to Analog Ground on PSI-2
env.V(end+1)=  env.V(id.AVoff)    ; id.SRCommon   =numel(env.V);                           

env.I.V24m=0.000;  % Current in amperes on the BK PRECISION -24V power supply
env.I.V24p=0.000;  % Current in amperes on the BK PRECISION +24V power supply


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
    %geo.extra_gatelines=128;
    %geo.extra_gatelines=64;
    geo.extra_gatelines=0;
end
if ts(1,2,3)==2; % PSI-2 settings and calculations
    geo.extra_gatelines=0;
end
if ts(1,2,3)==3; % PSI-3 settings and calculations
    %geo.extra_gatelines=128;
    %geo.extra_gatelines=64;
    geo.extra_gatelines=0;
end


%
% Array-Type dependent settings & calculations
%

if ts(1,2,3)==1; % PSI-1 settings and calculations
    geo.G3_SORTMODE=10;
    geo.GL=256+geo.extra_gatelines;%+32; do NOT use 256+32 (288) or 256+128 ! with pre-2010-03 interface card firmwares!
    geo.GL=32+geo.extra_gatelines;
    geo.G3GL=geo.GL-1; % for regular arrays - PSI2/3 arrays have different values
    %geo.DL=384;
    geo.DL=256;
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
% Multi-Sequence-Setup
%

meas.DUT=[ setup.ARRAYTYPE '_' setup.WAFERCODE ];

% technically, not only R's can be changed in multi-sequence mode - 
% is RMATRIX an inappropriate name?

meas.MeasCond='DACCHAR'; multi.R22=0;%14;
multi.RMATRIX=[];

if(strcmp(setup.ADCtype,'normal'))
%{
  Vref =1.373;
     VdV =1.2;
multi.RMATRIX(end+1,:)=[
   %R1    R26   R27   R11    R13    R14       VADCdV     VADCminus
   500     0     50     0      1      1       VdV         Vref
];
   
%}

%{
for Vref=1.3472+2.694;
    for VdV=1.3472;
multi.RMATRIX(end+1,:)=[
   %R1    R26   R27   R11    R13    R14       VADCdV       VADCminus
   500     0     50     0      1      1        VdV        Vref-VdV
];
    end
end
%}


%{
for Vref=[1.0 0.8 0.6];
    for VdV=[0:0.05:0.5 0.7:0.2:4.1];
multi.RMATRIX(end+1,:)=[
   %R1    R26   R27   R11    R13    R14       VADCdV        VADCminus
   500     0     50     0      1      1       VdV         Vref
];
    end
end
%}


%{
for Vref=[2.3 2.8 3.3 3.8 4.3];
    for VdV=[0:0.05:0.5 0.7:0.2:Vref];
multi.RMATRIX(end+1,:)=[
   %R1    R26   R27   R11    R13    R14       VADCdV       VADCminus
   500     0     50     0      1      1        VdV        Vref-VdV
];
    end
end
%}
end

if(strcmp(setup.ADCtype,'+-20V'))

    %DACv=[0:64:1023 1023];
    %DACv =[0:7:50 100:200:900 974:7:1023];
    %DACv =[50:-7:0 100:200:900 1023:-7:974];
   % DACv =[1:1:7 100:200:900 1016:1:1023];
   DACv=[100:100:1000];
  for p=1:10
  %DAC(p,:)=[(1+(p-1)*100):50:1000 1:50:(100*(p-1))]; 
  %DAC(p,:)=[(1+(p-1)*100):50:1000 1:50:(100*(p-1))]; 
  DAC(p,:)=[DACv(p:end) DACv(1:p-1)];
  
  end
  
  numofDACsets=size(DAC,2);

    for k=1:numofDACsets
multi.RMATRIX(end+1,:)=[
   %R1    R26   R27   R11    R13    R14        DAC       
   500     0     50     0      1      1       DAC(:,k)'          
   ];
    end

end

multi.Curr(1:3)=[1e-3 0 -1e-3];

multi.nrofacq=size(multi.RMATRIX,1);
multi.nrocurr=size(multi.Curr,2);
if strcmp(meas.MeasCond(1:5),'First'); multi.nrofacq=1; end
if strcmp(meas.MeasCond(1:4),'Qinj' ); multi.nrofacq=1; end

meas.MeasDetails=[ sprintf('%s', meas.MeasCond) ...
    ...sprintf( '_Vbias%s', volt2str(env.V(id.Vbias)) ) ... not needed for PSI-2/3
    ...sprintf( '_Vrst%s', volt2str(env.V(id.Vreset)) ) ... for AP pixels 
    ...sprintf( '_Von%s', volt2str(env.V(id.Von)) ) ... not needed for PSI-2/3
    ...sprintf( '_Voff%s', volt2str(env.V(id.AVoff)) ) ... not needed for PSI-2/3
    ...sprintf( '_Vgnd%s', volt2str(env.V(id.Vgnd)) ) ...
    ...sprintf( '_Tbias%s', volt2str(env.V(id.Tbias)) ) ... PSI-3 specific
    ...sprintf( '_Vcc%s', volt2str(env.V(id.Vcc)) ) ...  for AP pixels 
    ...sprintf( '_Voff%s',  volt2str(env.V(id.AVoff)) ) ...    
    ...sprintf( '_VQinj%s', volt2str(env.V(id.VQinj)) ) ...
    ...sprintf( '_Vref%s',volt2str(env.V(id.Vref)) )...
    ...sprintf( '_%02dR22', multi.R22                 ) ...
    ...sprintf( '_RST%s',    setup.PF_globalReset     ) ... PSI-3 specific
    ...sprintf( '_GC%s',    setup.PF_gateCards        ) ...
    ...sprintf( '_DC%s',    setup.PF_dataCards        ) ...
    ...sprintf( '_DCdips%s',    setup.PF_dataCardDIPs        ) ...
    ...sprintf( '_GL%03d',  geo.GL                    ) ...
    sprintf( '%s',    setup.special     ) ...
    ];


meas.MeasID=datestr(now(),30);
meas.DirName=[ '../measurements/' meas.DUT '/' meas.MeasID '_' meas.MeasDetails '/' ];
meas.MFile=[ mfilename() '.m' ];
if ~flag.dryrun;
    mkdir(meas.DirName);    
    copyfile(meas.MFile,[ meas.DirName meas.MFile ]);
    if isfield(meas,'MFileDesc');
    copyfile(meas.MFileDesc,[ meas.DirName meas.MFileDesc ]);
    end
end;

%
% Multi-Sequence Loop
%

flag.G3_nuke=true;
flag.first_run=true;
g3x.struct_dp=G3extDigipotInit(g3x.comm);

for currstage = 1:multi.nrocurr
   multi.Current=multi.Curr(currstage);
   multi.CURRFILE='2636_setcurrent.scpi';
   system(sprintf('echo "smub.source.leveli=%f" >%s.tmp1',multi.Current,multi.CURRFILE));
   system(sprintf('echo "smua.source.leveli=%f" >%s.tmp2',multi.Current,multi.CURRFILE));
   system(sprintf('mv %s.tmp1 %s',multi.CURRFILE,multi.CURRFILE));
   pause(5);
   system(sprintf('mv %s.tmp2 %s',multi.CURRFILE,multi.CURRFILE));
for mid=1:multi.nrofacq; multi.mid=mid;

   multi.R1 =multi.RMATRIX(multi.mid,1);
   multi.R11=multi.RMATRIX(multi.mid,4);
   multi.R13=multi.RMATRIX(multi.mid,5);
   multi.R14=multi.RMATRIX(multi.mid,6);
   multi.R26=multi.RMATRIX(multi.mid,2);
   multi.R27=multi.RMATRIX(multi.mid,3);
   
  multi.DAC=multi.RMATRIX(multi.mid,7:16);
 
   disp(multi);

   % write voltfile, will be picked up by shell script controlling power supply
   %{
   multi.VOLTFILE='adchar_volts.scpi';
   system(sprintf('echo "APP:VOLT %.3f,%.3f,0.0" >%s.tmp',multi.VADCminus,multi.VADCdV,multi.VOLTFILE));
   system(sprintf('mv %s.tmp %s',multi.VOLTFILE,multi.VOLTFILE));
    %}
   
   
   g3x.dpvalues=multi.DAC;
   G3extDigipotSetVal(g3x.comm, g3x.struct_dp, g3x.dpvalues);
   [compout1 meas.dpotbegintime]=system('date +%s.%N');
   pause(4);
   [compout2 meas.dpotlasttime]=system('date +%s.%N');
   
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
 ...sprintf('_%02dR26', multi.R26)  ...
 ...sprintf('_%02dR27', multi.R27)  ...
 sprintf('_%02dDAC', multi.DAC)  ...
 sprintf('_%01dmA', round(1000*multi.Current))
 ...   sprintf('_VADCp%04dmV' , round(multi.VADCdV*1000))   ...
 ...   sprintf('_VADCm%04dmV' , round(multi.VADCminus*1000))   ...
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
     meas.R,meas.userdata,meas.AcqFile,geo.G3_SORTMODE,flag.G3_nuke,mid==multi.nrofacq || true);
 end
 flag.G3_nuke=false;
 
 
% Jabber notification
 tool_notification(flag.jabber&&flag.first_run,env,meas,multi,'started',[0 0]);
 flag.first_run=false;

end
end
g3x.dpvalues=repmat(511,1,10);
G3extDigipotSetVal(g3x.comm, g3x.struct_dp, g3x.dpvalues);
system(sprintf('echo "smub.source.leveli=%f" >%s.tmp1',0,multi.CURRFILE));
system(sprintf('echo "smua.source.leveli=%f" >%s.tmp2',0,multi.CURRFILE));
system(sprintf('mv %s.tmp1 %s',multi.CURRFILE,multi.CURRFILE));
pause(5);
system(sprintf('mv %s.tmp2 %s',multi.CURRFILE,multi.CURRFILE));

display('Measurement complete');

% Jabber notification that script is done
tool_notification(flag.jabber,env,meas,multi,'finished',[0 0]);
