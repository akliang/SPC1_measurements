V=[ % voltages as set by Analog Control Card, from 'left to right' (later: requested by digipots)
    -4.0  %Vn.AVoff=-4.0;                                  % Gate Block TP
    15.0  %Vn.Von=15;                                      % Gate Block TP
    -2.5  %Vn.Vout10=0.0;  %PSI3: Vn.RevBias=-2.5;         % Vout10
    15.0  %Vn.Vout9=0.0;   %PSI3: Vn.Vreset=15.0;          % Vout9
     8.0  %Vn.Vout8=0.0;   %PSI3: Vn.Vcc=8;                % Vout8
     5.5  %Vn.Vguard2=0.0; %PSI3: Vn.Tbias=5.5;            % Vout7    
     1.0  %Vn.Vguard1=0.0; %PSI3: Vn.Vgnd=1.0;             % Vout6
    15.0  %Vn.Vbias2=0.0 ; %PSI3: Vn.Mux_High=15.0;        % Vout5    
    -3.0  %Vn.Vbias=-3.0;                                  % Vout4    
     2.0  %Vn.Qinj=2.0; % toggle between 1 and 2 V         % Vout3
    0.856 %Vn.Vref=0.856;  %   usually generated by R/R on Masda-R card
];

%%
%Vn.Vfet=Vn.AVoff + 5; % not measured anymore    %   derived from Vout2
%Vn.DVoff=Vn.AVoff;                              %   derived from Vout2


Comment=[ MeasCond ' Line mapping Measurement' ];
    WorkDir=pwd();
    cd( '..' );
    BaseDir=pwd();
    cd( WorkDir );  
DirName=[ BaseDir '/measurements/' DUT '/' datestr(now(),30) '_' MeasType '/' ];
mkdir(DirName);

% old R22 explanation:
%Masda-R Preamplifier Gain Setting 1:2.1 2:3.4 4:6.2 8:11.7 16:22.7 32:44.8, only 2,4&8 wired on PSI-boards?