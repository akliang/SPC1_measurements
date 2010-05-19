
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
setup.G3_adcCards='a1-00-00-00-00-00-00-00'; % On G3 ADC Board, they are labeled ADC8-...-1

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
%}


%
% Array- and Platform Specific Settings and Information:
%

setup.arrdefcnt=0; % initialize counter which keeps track of how many arrays got defined


%{
setup.ARRAYTYPE='PSI-1';
setup.WAFERCODE='29A31-11';
setup.PLATFORM='PF-G1-10-4';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='ad-a2-a6'; % first is the outermost, last is the innermost
setup.PF_dataCardDIPs='1111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='0.86'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_gateCards='a4-a2';
setup.PF_analogCard='V1N1';
setup.PF_arrayLogic='none';
setup.PF_arrayLogicDIPs='0'; % no array logic, i.e. no dips
%}

%{
setup.ARRAYTYPE='PSI-3';
setup.WAFERCODE='29A20-6';
setup.PLATFORM='PF-G1-05-6';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 only has one dataCard
setup.PF_dataCardDIPs='0011111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='c1';
setup.PF_analogCard='V2N7';
%setup.PF_arrayLogic='N2-V30-PSI3-20100101'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_arrayLogicDIPs='11000000000000';
setup.PF_arrayLogic='V30-N1-PSI3-20100412'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000001'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='special, regular reset';
%setup.PF_globalReset='001';
setup.PF_CrossCable='special, always reset & Vgnd shorted to Vbias1';
setup.PF_globalReset='all';
setup.special='';
%}


%{
setup.ARRAYTYPE='PSI-3';
setup.WAFERCODE='29A31-9';
setup.PLATFORM='PF-G1-10-8';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 only has one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='c2';
setup.PF_analogCard='V2N7';
%setup.PF_arrayLogic='N2-V30-PSI3-20100101'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_arrayLogicDIPs='11000000000000';
setup.PF_arrayLogic='V20-N1-PSI3-20060404'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000001'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
%setup.PF_globalReset='001';
%setup.PF_CrossCable='special, regular reset';
%setup.PF_globalReset='001';
setup.PF_CrossCable='special, always reset';
setup.PF_globalReset='all';
setup.special='_AlMilerVGND';
%}


%{
setup.ARRAYTYPE='PSI-3';
setup.WAFERCODE='29A31-8';
setup.PLATFORM='PF-G1-10-9';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 only has one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='c2';
setup.PF_analogCard='V2N7';
%setup.PF_arrayLogic='N2-V30-PSI3-20100101'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_arrayLogicDIPs='11000000000000';
setup.PF_arrayLogic='V20-N1-PSI3-20060404'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000001'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
%setup.PF_globalReset='001';
%setup.PF_CrossCable='special, regular reset';
%setup.PF_globalReset='001';
setup.PF_CrossCable='special, always reset';
setup.PF_globalReset='all';
%setup.PF_CrossCable='special, no reset';
%setup.PF_globalReset='non';
setup.special='';
%}


%{
setup.ARRAYTYPE='PSI-3';
setup.WAFERCODE='29A30-6';
setup.PLATFORM='PF-G1-10-6';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 only has one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='c2';
setup.PF_analogCard='V2N7';
%setup.PF_arrayLogic='N2-V30-PSI3-20100101'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_arrayLogicDIPs='11000000000000';
setup.PF_arrayLogic='V20-N1-PSI3-20060404'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000001'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
%setup.PF_globalReset='001';
setup.PF_CrossCable='special, regular reset';
setup.PF_globalReset='001';
%setup.PF_CrossCable='special, always reset';
%setup.PF_globalReset='all';
%setup.PF_CrossCable='special, no reset';
%setup.PF_globalReset='non';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A3-5';
setup.PLATFORM='PF-G1-05-4';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_dataBoardJumper='JP2=RevBias';
setup.PF_gateCards='a2-a6'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V10-N5-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_analogCard='V2N2';
%setup.PF_arrayLogic='V10-N2-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A11-5';
setup.PLATFORM='PF-G1-05-1';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='a4-a2'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V10-N1-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vbias';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A11-4';
setup.PLATFORM='PF-G1-04-4';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c2'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='a4-a2'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V10-N1-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
%setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vbias';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A23A-8';
setup.PLATFORM='PF-G1-06-6';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c2'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='a4-a2'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V10-N1-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
setup.PF_CrossCable='normal';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A23A-7';
setup.PLATFORM='PF-G1-06-8';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='a4-a2'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V10-N1-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
setup.PF_CrossCable='normal';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A30-6';
setup.PLATFORM='PF-G1-10-7';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.2'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_dataBoardJumper='JP2=RevBias';
setup.PF_gateCards='a1-a5'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V30-N4-PSI2-20100412'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_analogCard='V2N2';
%setup.PF_arrayLogic='V10-N2-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A31-8';
setup.PLATFORM='PF-G1-06-6';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='a1-a5'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V30-N4-PSI2-20100412'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='ShiftReg_shorted_to_Voff';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A31-9';
setup.PLATFORM='PF-G1-06-8';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c2'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='a2-a3'; %v card1, card2
setup.PF_analogCard='V2N4';
setup.PF_arrayLogic='V30-N2-PSI2-20100412'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_analogCard='V2N2';
%setup.PF_arrayLogic='V10-N2-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
setup.PF_CrossCable='';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='';
%}


%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A23A-9';
setup.PLATFORM='PF-G1-06-9';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_dataBoardJumper='JP2=RevBias';
setup.PF_gateCards='a6-a2'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V10-N1-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A25-2';
setup.PLATFORM='PF-G1-07-3';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c2'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_dataBoardJumper='JP2=RevBias';
setup.PF_gateCards='a4-a2'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V10-N1-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_analogCard='V2N2';
%setup.PF_arrayLogic='V10-N2-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A23A-6';
setup.PLATFORM='PF-G1-06-7';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_dataBoardJumper='JP2=RevBias';
setup.PF_gateCards='a1-a5'; %v card1, card2
%setup.PF_analogCard='V2N5';
%setup.PF_arrayLogic='V10-N5-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_analogCard='V2N2';
setup.PF_arrayLogic='V10-N2-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A10-4';
setup.PLATFORM='PF-G1-04-5';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_dataBoardJumper='JP2=RevBias';
setup.PF_gateCards='a1-a5'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V10-N5-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_analogCard='V2N2';
%setup.PF_arrayLogic='V10-N2-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='';
%setup.special='Datalineresetgate connected to Vguard2';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A31-11';
setup.PLATFORM='PF-G1-07-3';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_dataBoardJumper='JP2=RevBias';
setup.PF_gateCards='a1-a5'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V30-N4-PSI2-20100412'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_analogCard='V2N2';
%setup.PF_arrayLogic='V10-N2-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='_pre-SRCommon';
%}


%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A25-4';
setup.PLATFORM='PF-G1-07-4';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_dataBoardJumper='JP2=RevBias';
setup.PF_gateCards='a1-a5'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V10-N5-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_analogCard='V2N2';
%setup.PF_arrayLogic='V10-N2-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='';
%}


%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A25-5';
setup.PLATFORM='PF-G1-07-5';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_dataBoardJumper='JP2=RevBias';
setup.PF_gateCards='a1-a5'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V10-N5-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_analogCard='V2N2';
%setup.PF_arrayLogic='V10-N2-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A31-10';
setup.PLATFORM='PF-G1-07-5';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c1'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.2'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_dataBoardJumper='JP2=RevBias';
setup.PF_gateCards='a1-a5'; %v card1, card2
setup.PF_analogCard='V2N5';
setup.PF_arrayLogic='V30-N4-PSI2-20100412'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_analogCard='V2N2';
%setup.PF_arrayLogic='V10-N2-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
%setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
%setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vbias1';
setup.special='';
setup.special='_binning23';
%}

%{
setup.ARRAYTYPE='PSI-2';
setup.WAFERCODE='29A31-12';
setup.PLATFORM='PF-G1-07-3';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='c2'; % PSI-3 and PSI-2 only have one dataCard
setup.PF_dataCardDIPs='0111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='2.20'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 NC NC NC NC NC ]
setup.PF_gateCards='a2-a3'; %v card1, card2
setup.PF_analogCard='V2N4';
setup.PF_arrayLogic='V30-N2-PSI2-20100412'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
%setup.PF_analogCard='V2N2';
%setup.PF_arrayLogic='V10-N2-PSI2-20060707'; %V10: CPLD, no DIPS  V20: CPLD, 12 DIPS, V30: FPGA, 12 DIPS
setup.PF_arrayLogicDIPs='000000000000'; % DIPs labelled 12 to 1
setup.PF_CrossCable='';
setup.PF_CrossCable='Vbias1 open, Vbias shorted to Vreset';
setup.special='';
%}


%{
setup.ARRAYTYPE='PSI-1';
setup.WAFERCODE='29A31-10';
setup.PLATFORM='PF-G1-10-10';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='ad-a2-aa'; % first is the outermost, last is the innermost
setup.PF_dataCardDIPs='1111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='0.86'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardJumper='JP1=Vbias1';
setup.PF_gateCards='a6-a4';
setup.PF_analogCard='V1N2';
setup.PF_arrayLogic='none';
setup.PF_arrayLogicDIPs='0'; % no array logic, i.e. no dips
setup.PF_CrossCable='normal';
%setup.PF_CrossCable='Vbias1 open, Vbias1 left floating';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-1';
setup.WAFERCODE='29A31-12';
setup.PLATFORM='PF-G1-10-11';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='ad-a2-aa'; % first is the outermost, last is the innermost
setup.PF_dataCardDIPs='1111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='0.86'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardJumper='JP1=Vbias1';
setup.PF_gateCards='a6-a4';
setup.PF_analogCard='V1N2';
setup.PF_arrayLogic='none';
setup.PF_arrayLogicDIPs='0'; % no array logic, i.e. no dips
setup.PF_CrossCable='normal';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-1';
setup.WAFERCODE='29A31-9';
setup.PLATFORM='PF-G1-10-3';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='a8-ac-a5'; % first is the outermost, last is the innermost
setup.PF_dataCardDIPs='1111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='0.86'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardJumper='JP1=Vbias1';
setup.PF_gateCards='a4-a6';
setup.PF_analogCard='V1N1';
setup.PF_arrayLogic='none';
setup.PF_arrayLogicDIPs='0'; % no array logic, i.e. no dips
setup.PF_CrossCable='normal';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-1';
setup.WAFERCODE='29A25-5';
setup.PLATFORM='PF-G1-07-7';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='ad-a2-aa'; % first is the outermost, last is the innermost
setup.PF_dataCardDIPs='1111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='0.86'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='00000000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardJumper='JP1=Vbias1';
setup.PF_gateCards='a6-a4';
setup.PF_analogCard='V1N2';
setup.PF_arrayLogic='none';
setup.PF_arrayLogicDIPs='0'; % no array logic, i.e. no dips
setup.PF_CrossCable='normal';
%setup.PF_CrossCable='Vbias1 open, Vbias1 left floating';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-1';
setup.WAFERCODE='29A23A-8';
setup.PLATFORM='PF-G1-06-4';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='ad-a2-aa'; % first is the outermost, last is the innermost
setup.PF_dataCardDIPs='1111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='0.86'; % nominal Vref, set by resistor divider
%setup.PF_dataBoardDIPs='01000000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardDIPs='00100000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardJumper='JP1=Vbias1';
setup.PF_gateCards='a6-a4';
setup.PF_analogCard='V1N2';
setup.PF_arrayLogic='none';
setup.PF_arrayLogicDIPs='0'; % no array logic, i.e. no dips
setup.PF_CrossCable='normal';
%setup.PF_CrossCable='Vbias1 open, Vbias1 left floating';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-1';
setup.WAFERCODE='29A11-5';
setup.PLATFORM='PF-G1-04-3';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='ad-a2-aa'; % first is the outermost, last is the innermost
setup.PF_dataCardDIPs='1111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='0.86'; % nominal Vref, set by resistor divider
%setup.PF_dataBoardDIPs='01000000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardDIPs='00100000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardJumper='JP1=Vbias1';
setup.PF_gateCards='a6-a4';
setup.PF_analogCard='V1N2';
setup.PF_arrayLogic='none';
setup.PF_arrayLogicDIPs='0'; % no array logic, i.e. no dips
setup.PF_CrossCable='normal';
%setup.PF_CrossCable='Vbias1 open, Vbias1 left floating';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-1';
setup.WAFERCODE='29A32-5';
setup.PLATFORM='PF-G1-10-1';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='ad-a2-aa'; % first is the outermost, last is the innermost
setup.PF_dataCardDIPs='1111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='0.86'; % nominal Vref, set by resistor divider
%setup.PF_dataBoardDIPs='01000000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardDIPs='00100000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardJumper='JP1=Vbias1';
setup.PF_gateCards='a6-a4';
setup.PF_analogCard='V1N2';
setup.PF_arrayLogic='none';
setup.PF_arrayLogicDIPs='0'; % no array logic, i.e. no dips
setup.PF_CrossCable='normal';
%setup.PF_CrossCable='Vbias1 open, Vbias1 left floating';
setup.special='';
%}

%{
setup.ARRAYTYPE='PSI-1';
setup.WAFERCODE='29A30-2';
setup.PLATFORM='PF-G1-10-1';
setup.arrdefcnt=setup.arrdefcnt+1;
setup.PF_dataCards='ad-a2-aa'; % first is the outermost, last is the innermost
setup.PF_dataCardDIPs='1111111100'; % [ ~PG1 ~PG2 ~PG3 ~PG4 ~PG5 ~PG6 BW2-HI BW1-HI 16CH UP ]
setup.PF_dataCardVref='0.86'; % nominal Vref, set by resistor divider
setup.PF_dataBoardDIPs='01000000'; % [ PG3 PG4 PG5 CTRL9 CTRL10 CTRL12 CTRL11 ?? ]
setup.PF_dataBoardJumper='JP1=Vbias1';
setup.PF_gateCards='a6-a4';
setup.PF_analogCard='V1N2';
setup.PF_arrayLogic='none';
setup.PF_arrayLogicDIPs='0'; % no array logic, i.e. no dips
setup.PF_CrossCable='normal';
setup.PF_CrossCable='Vbias1 open, Vbias1 left floating';
setup.special='_VbiasFloating';
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
%    - +Q adapter for ADCs
% 3. Are all the voltages correct?
%    - Vrst
%    - Qinj
%    - Vref
% 4. Did you record the current from the BK PRECISION?
%%% /THINGS TO CHECK BEFORE RUNNING EXP %%%%


env.V=[];
env.V(end+1)= -4.0  ; id.AVoff   =numel(env.V);                             % Test Point near to Gate Card
env.V(end+1)=  15.0 ; id.Von     =numel(env.V);                             % Test Point near to Gate Card
env.V(end+1)=  0.0  ; id.Vout10  =numel(env.V);   id.RevBias =numel(env.V); % Vn.Vout10=0.0;  %PSI3: Vn.RevBias=-2.5;         % Vout10
env.V(end+1)=  0.0  ; id.Vout9   =numel(env.V);   id.Vreset  =numel(env.V); % Vn.Vout9=0.0;   %PSI3: Vn.Vreset=15.0;          % Vout9
env.V(end+1)=  0.0  ; id.Vout8   =numel(env.V);   id.Vcc     =numel(env.V); % Vn.Vout8=0.0;   %PSI3: Vn.Vcc=8;                % Vout8
env.V(end+1)=  0.0  ; id.Vguard2 =numel(env.V);   id.Tbias   =numel(env.V); % Vn.Vguard2=0.0; %PSI3: Vn.Tbias=5.5;            % Vout7
env.V(end+1)=  0.0  ; id.Vguard1 =numel(env.V);   id.Vgnd    =numel(env.V); % Vn.Vguard1=0.0; %PSI3: Vn.Vgnd=1.0;             % Vout6
env.V(end+1)=  0.0  ; id.Vbias2  =numel(env.V);   id.MuxHigh =numel(env.V); % Vn.Vbias2=0.0 ; %PSI3: Vn.Mux_High=15.0;        % Vout5
env.V(end+1)= -3.0  ; id.Vbias   =numel(env.V);                   % Vn.Vbias=-3.0;   env.V(end+1)=env.V(id.Vgnd)   env.V(id.Vreset)  % Vout4
env.V(end+1)=  2.5  ; id.VQinj   =numel(env.V);                              % Vn.Qinj=2.0; % toggle between 1 and 2 V         % Vout3
env.V(end+1)=  0.860; id.Vref    =numel(env.V);                             % Vn.Vref=0.856; 2.303  for PSI2/3 cards  %   usually generated by R/R on Masda-R card
env.V(end+1)=  env.V(id.RevBias)  ; id.DLrstGate =numel(env.V);                  % env.V(id.Vguard2)
env.V(end+1)=  0    ; id.DLrstGnd   =numel(env.V);                           % hard-wired to Analog Ground on PSI-2
env.V(end+1)=  env.V(id.AVoff)    ; id.SRCommon   =numel(env.V);                           

env.I.V24m=0.099;  % Current in amperes on the BK PRECISION -24V power supply
env.I.V24p=0.101;  % Current in amperes on the BK PRECISION +24V power supply

meas.MFileDesc=[ mfilename() '.m' ];

