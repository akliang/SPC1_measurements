
%
% Array and Platform Description
%   (the physical setup of the experiment, things that are FIXED for the whole experiment)
%
% $HeadURL$
% $Id$
%
% Notes:
% 1) other scripts call meas_description.m (no _svn), so rename this file before usage!
% 2) call svn_commit_helper.sh to create a meas_description_svn.m from this file
%    with all 'disabled' block comments 'activated' (i.e. everything commented)
% 3) do not use block comments for anything but marking sections (see point 2)
%



%
% Location-Specific Settings and Information
%

%{
setup.LOCATION='Argus Building, Optics Lab';
setup.HOSTNAME='Pion'; % hostname of computer running this script
setup.G3_system='9of9-vanilla';
setup.G3_interface='a2-V20-20100408'; % serial number - hardware version - bitfile version
%setup.G3_interface='a1-V20-20100316'; % serial number - hardware version - bitfile version
setup.G3_adcCards='a1-a2-00-00-00-00-00-00'; % On G3 ADC Board, they are labeled ADC8-...-1

setup.POWER_G3='Built-in';
setup.POWER_ADC='BKPRECISION1761#2_AND_AGILENT_E3612A';
setup.POWER_ARRAY=[ setup.HOSTNAME '_BK_9130_005004156568001055_V1.69' ];
setup.POWER_PSI = [ setup.HOSTNAME '_BK_9130_005004156568001055_V1.69' ];
setup.POWERMEAS.V.V24m={setup.POWER_PSI,'text_env1',5};   % Power Measurements: file or db descriptor, file format, data channel
setup.POWERMEAS.V.V24p={setup.POWER_PSI,'text_env1',6};
setup.POWERMEAS.V.V5p ={setup.POWER_ARRAY,'text_env1',7};
setup.POWERMEAS.I.V24m={setup.POWER_PSI,'text_env1',9};
setup.POWERMEAS.I.V24p={setup.POWER_PSI,'text_env1',10};
setup.POWERMEAS.I.V5p ={setup.POWER_ARRAY,'text_env1',11};
%}


%{
setup.LOCATION='Argus Building, RF Lab';
setup.HOSTNAME='Driftwood'; % hostname of computer running this script
setup.G3_system='5of9-vanilla';
setup.G3_interface='a4-V20-20100408'; % serial number - hardware version - bitfile version
setup.G3_adcCards='a3-a4-a5-a6-00-00-00-00'; % On G3 ADC Board, they are labeled ADC8-...-1

setup.POWER_G3='Built-in';
setup.POWER_ADC='ArrayAndADCPower#2';
setup.POWER_ARRAY=[ setup.HOSTNAME '_BK_9130_005004156568001088_V1.69' ];
setup.POWER_PSI = [ setup.HOSTNAME '_BK_9130_005004156568001088_V1.69' ];
setup.POWERMEAS.V.V24m={setup.POWER_PSI,'text_env1',5};   % Power Measurements: file or db descriptor, file format, data channel
setup.POWERMEAS.V.V24p={setup.POWER_PSI,'text_env1',6};
setup.POWERMEAS.V.V5p ={setup.POWER_ARRAY,'text_env1',7};
setup.POWERMEAS.I.V24m={setup.POWER_PSI,'text_env1',9};
setup.POWERMEAS.I.V24p={setup.POWER_PSI,'text_env1',10};
setup.POWERMEAS.I.V5p ={setup.POWER_ARRAY,'text_env1',11};
setup.TEMPMEAS.ARRAY={ 'TEMP_Driftwood_RMS300A_N1', 'text_env_tempwos1', 'sensor2' };
%}


%{
setup.LOCATION='Argus Building, Mammo Lab';
setup.HOSTNAME='hellboy'; % hostname of computer running this script
setup.G3_system='3of9-vanilla';
setup.G3_interface='a6-V20-20080108'; % serial number - hardware version - bitfile version
setup.G3_adcCards='a7-a8-00-00-00-00-00-00'; % On G3 ADC Board, they are labeled ADC8-...-1

setup.POWER_G3='Built-in';
setup.POWER_ADC='ArrayAndADCPower#3';
setup.POWER_ARRAY=[ setup.HOSTNAME '_BK_9130_005004156568001062_V1.69' ];
setup.POWER_PSI = [ setup.HOSTNAME '_BK_9130_005004156568001062_V1.69' ];
setup.POWERMEAS.V.V24m={setup.POWER_PSI,'text_env1',5};   % Power Measurements: file or db descriptor, file format, data channel
setup.POWERMEAS.V.V24p={setup.POWER_PSI,'text_env1',6};
setup.POWERMEAS.V.V5p ={setup.POWER_ARRAY,'text_env1',7};
setup.POWERMEAS.I.V24m={setup.POWER_PSI,'text_env1',9};
setup.POWERMEAS.I.V24p={setup.POWER_PSI,'text_env1',10};
setup.POWERMEAS.I.V5p ={setup.POWER_ARRAY,'text_env1',11};
setup.TEMPMEAS.ARRAY={ 'TEMP_hellboy_RMS300A_N1', 'text_env_tempwos1', 'sensor1' };
%}


%%{
setup.LOCATION='Argus Building, Electronics Lab';
setup.HOSTNAME='simwork'; % hostname of computer running this script
setup.G3_system='1of9-vanilla';
setup.G3_interface='a6-V20-20080108'; % serial number - hardware version - bitfile version
setup.G3_adcCards='u3-u4-00-00-00-00-00-00'; % On G3 ADC Board, they are labeled ADC8-...-1

setup.POWER_G3='G3Power#1';
setup.POWER_ADC='ArrayAndADCPower#5';
setup.POWER_ARRAY=[ setup.HOSTNAME '_BK_9130_005004156568001088_V1.69' ];
setup.POWER_PSI = [ setup.HOSTNAME '_BK_9130_005004156568001088_V1.69' ];
setup.POWERMEAS.V.V24m={setup.POWER_PSI,'text_env1',5};   % Power Measurements: file or db descriptor, file format, data channel
setup.POWERMEAS.V.V24p={setup.POWER_PSI,'text_env1',6};
setup.POWERMEAS.V.V5p ={setup.POWER_ARRAY,'text_env1',7};
setup.POWERMEAS.I.V24m={setup.POWER_PSI,'text_env1',9};
setup.POWERMEAS.I.V24p={setup.POWER_PSI,'text_env1',10};
setup.POWERMEAS.I.V5p ={setup.POWER_ARRAY,'text_env1',11};
setup.TEMPMEAS.ARRAY={ '/mnt/wos1/DATA/TH/Data/realtimelog.txt', 'text_env_tempwos1', 'sensor1' };
%}



%
% Array- and Platform Specific Settings and Information:
%

setup.arrdefcnt=0; % initialize counter which keeps track of how many arrays got defined


%%{
setup.ARRAYTYPE='Gen2_TAA';
setup.WAFERCODE='29B1-X';
setup.PLATFORM='PF-G2-11-X';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='xx-xx-xx'; % first is the outermost, last is the innermost
setup.PF_dataCardDIPs='1111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='0.86'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='01000000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardJumper='JP1=Vbias1';
setup.PF_gateCards='xx-xx';
setup.PF_analogCard='PNCV1#04';
setup.PF_arrayLogic='G3only';
setup.PF_arrayLogicDIPs='0'; % no array logic, i.e. no dips
setup.special='_InitialTest';
%}


if (setup.arrdefcnt~=1);
	error('Multiple or no array selected!');
end


%add actual array geometry to binary userdata? -> along with 'gate pattern' later... ?
%add more verbose setup information to .amd file... ?

%
% Experimental Environment Description:
%   (physical setup during experiment, might be changed by script or external events)
%


%%%% THINGS TO CHECK BEFORE RUNNING EXP %%%%
% 1. Is the array/platform/glue-logic data recorded correctly?
%    - PSI-1, 2, or 3
%    - gate card order
% 2. Are the cables hooked up correctly? (if applicable)
%    - Cross-over cable with all pins connected
%    - Vrst shorted to Vbias if applicable
%    - +Q adapter for ADCs (for PSI-2 or PSI-3)
% 3. Are all the voltages correct?
%    - Vrst
%    - Qinj
%    - Vref
% 4. Did you record the current from the BK PRECISION?
%%% /THINGS TO CHECK BEFORE RUNNING EXP %%%%


% Common mapping of Vout1-16 on the PNC Boards:
env.V=[];
env.V(end+1)=  15.0 ; id.Von     =numel(env.V);                             % Gate Line HIGH                                  % Vout1
env.V(end+1)= -1.0  ; id.Voff    =numel(env.V);  id.Vglclamp=numel(env.V);  % Gate Line LOW                                   % Vout2
env.V(end+1)=  1.0  ; id.VQinj   =numel(env.V);                             % for gain test, toggle between 1 and 2 V         % Vout3
env.V(end+1)=  2.303; id.Vref    =numel(env.V);  id.Vdlgnd  =numel(env.V);  % Vref=0.856 for PSI-1; 2.303  for PSI2/3   % Vout4, or generated by R/R on Masda-R card
env.V(end+1)=  3.5  ; id.Vbias   =numel(env.V);                             % Vbias=-3.0 for PSI-1; Vrst/Vgnd - 3V for PSI2/3 % Vout5
env.V(end+1)=  6.0  ; id.Vreset  =numel(env.V);                             % PSI2: Vreset=5;                                 % Vout6
env.V(end+1)=  8.0  ; id.VccCSA  =numel(env.V);                             % PSI3: VccCSA=8;                                 % Vout7
env.V(end+1)=  8.0  ; id.VccSF   =numel(env.V);                             % PSI2/3: VccSF=8;                                % Vout8
env.V(end+1)=  15.0 ; id.VPixLHI =numel(env.V);  id.VglobrstHI=numel(env.V);% Pixel Logic HIGH, e.g.  15V                     % Vout9
env.V(end+1)= -1.0  ; id.VPixLLO =numel(env.V);  id.VglobrstLO=numel(env.V);% Pixel Logic LOW , e.g.  0V                      % Vout10
env.V(end+1)=  15.0 ; id.VDatLHI =numel(env.V);  id.VdlreadHI =numel(env.V);% Data Logic HIGH , e.g.  15V                     % Vout11
env.V(end+1)= -1.0  ; id.VDatLLO =numel(env.V);  id.VdlreadLO =numel(env.V);% Data Logic LOW  , e.g.  0V                      % Vout12
env.V(end+1)=  3.43 ; id.Val     =numel(env.V);  id.Vsfb_gte =numel(env.V); % TAA: Vsfb_gte=-2  %PSI3: Val=5.5;               % Vout13
env.V(end+1)=  1.00 ; id.Vgnd    =numel(env.V);  id.Vsfb_gnd =numel(env.V); % TAA: Vsfb_gnd=0   %PSI3: Vgnd=1.0;              % Vout14
env.V(end+1)=  0.00 ; id.VbiasNO =numel(env.V);  id.VdlgndNO =numel(env.V); % TAA: Vsfb_gte=-2  %PSI3: Val=5.5;               % Vout13
env.V(end+1)=  0.00 ; id.VdlcapNO=numel(env.V);  id.Vsfb_gtNO=numel(env.V); % TAA: Vsfb_gnd=0   %PSI3: Vgnd=1.0;              % Vout14

env.V(end+1)=  0    ; id.DLrstGnd   =numel(env.V);                          % hard-wired to Analog Ground

% SMU-specific mappings:
smu.vid2ch(id.Von)    =1;
smu.vid2ch(id.Voff)   =2;
smu.vid2ch(id.VQinj)  =3;
smu.vid2ch(id.Vbias)  =4;
smu.vid2ch(id.Vreset) =5;
smu.vid2ch(id.VccSF)  =6;
smu.vid2ch(id.VPixLHI)=7;
smu.vid2ch(id.VPixLLO)=2;
smu.vid2ch(id.VDatLHI)=8;
smu.vid2ch(id.VDatLLO)=2;
smu.vid2ch(id.Vsfb_gte)=2;
%id.Val      = id.Voff; id.Vsfb_gte = id.Voff;

env.I.V24m=0.000;  % Current in amperes on the BK PRECISION -24V power supply. Only report when not recorded, e.g. by BK 9130s
env.I.V24p=0.000;  % Current in amperes on the BK PRECISION +24V power supply. Only report when not recorded, e.g. by BK 9130s

meas.MFileDesc=[ mfilename() '.m' ];

