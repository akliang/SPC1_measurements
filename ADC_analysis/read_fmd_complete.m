function fmds=read_fmd_complete(fname, skip_mat_reading, ignore_errata_errors )

    if nargin<2; skip_mat_reading=false; end
    if nargin<3; ignore_errata_errors=false; end

    fid=fopen(fname,'r','ieee-be');
    fseek(fid,0,'eof'); fsize=ftell(fid); fseek(fid,0,'bof');
    fpos=ftell(fid);
    
    fnr=0; % frame number in .fmd file currently being parsed
    anr=1; % acquisition number within .fmd file
    
    last_aid=uint64(0); % last encountered acquisition ID
    curr_aff=1; % current acquisition's first frame

    
    % new code, reading the corresponding .settings.mat - file
    MATSET={};
    if ~skip_mat_reading;
    MATSET = read_matsettings( fname, ignore_errata_errors );
    end
    
    overrideR14with1=false; % PSI2-20060707 - old CPLD file does not support binning in PSI-2
    if isfield(MATSET,'setup');
    if length(MATSET.setup.PF_arrayLogic)>13;
    if strcmp(MATSET.setup.PF_arrayLogic(end-12:end),'PSI2-20060707');
        overrideR14with1=true;
    end
    end
    end
    
    fmds={};
    
    while fpos<fsize
        
        headlen=fread(fid,1,'uint64');
        if feof(fid); break; end
        fnr=fnr+1;

        if (headlen==1);
            version=1;
            headlen=256-8;
        else
            version=fread(fid,1,'uint64');
        end

        

        if version==1;
            p=fread(fid,10,'uint64');
            p=[version p']';
            fmd.aid=uint64(p(2));
        elseif version>1;
            p=fread(fid,14,'uint64');
            p=[headlen version p']';
            fmd.aid=uint64(p(4));
        end

        
        r=fread(fid,33,'uint16');
        if overrideR14with1;
            r(14)=1;
        end
        if version==1;
            fmd.ast=p(3);  % acquisition start time
            fmd.g3seqnr=p(4); % G3 acquisition sequence number
            fmd.ffpt=p(7); % frame's first packet arrival time
            fmd.flpt=p(8); % frame's last packet arrival time
            fmd.sortmode=p(9); % data sorting mode
            fmd.dataWidth=p(10);
            fmd.dataLength=p(11);
            udata=[]; % version 1 .fmd files do not have any userdata
        elseif version>1;
            fmd.ast=p(5);  % acquisition start time
            fmd.g3seqnr=p(6); % G3 acquisition sequence number
            fmd.ffpt=p(9); % frame's first packet arrival time
            fmd.flpt=p(10); % frame's last packet arrival time
            fmd.sortmode=p(11); % data sorting mode
            fmd.dataWidth=p(12);
            fmd.dataLength=p(13);
            fseek(fid,fpos+200,'bof');
            udata=fread(fid,floor((headlen+8-200)/2)+2,'int16');
        end
        

        fmd.aff=curr_aff; % acquisition's first frame in current .fmd
        fmd.alf=fnr;      % acquisition's last frame in current .fmd
        fmd.anr=anr;
        fmd.r=r;
        fmd.p=p;
        fmd.udata=udata;
        
        fseek(fid,fpos+headlen+8,'bof');
        fpos=ftell(fid);
        if fpos>=fsize; last_fmd=fmd; end        

        if (last_aid==0); last_aid=uint64(fmd.aid); first_fmd=fmd; end
        
        if (fmd.aid~=last_aid) || fpos>=fsize;
            last_fmd.tottime=(last_fmd.flpt-last_fmd.ast)/1000;   % total acquisition time, from reset, incl. ignore cycles, to last packet received
            last_fmd.acqtime=(last_fmd.ffpt-first_fmd.ffpt)/1000; % estimated G3 data cycle time, best guess to derive frame time right now
            last_fmd.framecount=last_fmd.alf-last_fmd.aff+1;
            last_fmd.fps=(last_fmd.framecount-1) / last_fmd.acqtime;
            last_fmd.MATSET=MATSET;
            
            %s=sprintf('Acq. no. %d @ %s: frames %d to %d, total time %.1fs, %.2ffps (frametime %.2fs)', ...
            %    last_fmd.anr, datestr( javaepoch2matlabtime(fmd.ast), 31 ), ...
            %    last_fmd.aff, last_fmd.alf, last_fmd.tottime, last_fmd.fps, 1/last_fmd.fps );
            %display([ '' fname ]);
            s=sprintf('Acq. no. %d: frames %d to %d, total time %.1fs, %.2ffps (frametime %.2fs) %2.0f', ...
                last_fmd.anr, last_fmd.aff, last_fmd.alf, last_fmd.tottime, last_fmd.fps, 1/last_fmd.fps, last_fmd.alf-last_fmd.aff+1);
            display([ '    ' s ]);
            last_aid=fmd.aid;
            curr_aff=fnr;
            fmds{end+1}=last_fmd;
            anr=anr+1;
            first_fmd=fmd;
        end
        
        last_fmd=fmd;
    end
    fclose(fid);
end

%{

 Frame Metadata File: 2010-01-18 (.fmd)
 256 bytes total, all long (8 bytes each):
  1   frame metadata file/header version (version 1)
  2   acquisition ID
  3   acquisition start time (msec since the epoch, when start packet was sent)
  4   acquistion sequence number
  5   frame number
  6   system frame time (not set yet, arbitrary counter units)
  7   first packet time (msec since the epoch, when JJA received first packet)
  8   last packet time  (msec since the epoch, when JJA received last packet)
  9   data sorting mode
 10   saved frame data width
 11   saved frame data length
 12-21  G3 parameters+Flags as shorts (16 bit each, 66 byte total)



Frame Metadata File, implemented on 2010-01-27 22:40, used since: 2010-01-28 11pm (.fmd)
  1   remaining header length in byte (adjusted by JJA)
  2   frame metadata file/header version (version 2)
  3   Minimum User Data Offset (actual address of first user byte written)

  4   acquisition ID [source JJAM, composed of acquisition start time and random number]
  5   acquisition start time (source JJAM, msec since the epoch, when start packet was sent)
  6   acquistion sequence number [source G3 Gbit Interface card, every packet is tagged]
  7   frame number [source G3 Gbit Interface card, every packet is tagged]
  8   system frame time (not set yet, arbitrary counter units from hardware)
  9   first packet time (source JJAM, msec since the epoch, when JJAM received first packet)
 10   last packet time  (source JJAM, msec since the epoch, when JJAM received last packet)
 11   data sorting mode [source: JJAM]
 12   saved frame data width
 13   saved frame data length
 14   number of packets missing in current frame or flag or sth. similar? [source: JJAM, not yet implemented]

 15   reserved long - for future use
 16   reserved long - for future use

 17-25 G3 parameters+Flags as shorts (16 bit each, 66 byte total)

 26: default user data offset (note: 25*8=200)
 31: last long value for default fmd packet size
 


userdata=[
1 % header version
1000*Vn.Von
1000*Vn.AVoff
1000*Vn.Vfet
1000*Vn.DVoff
1000*Vn.Qinj
1000*Vn.Vbias
1000*Vn.Vbias2
1000*Vn.Vguard1
1000*Vn.Vguard2
1000*Vn.Vout8
1000*Vn.Vout9
1000*Vn.Vout10
1000*Vn.Vref
meas.G3Env.Tau1_Clock/(1000) % Tau1_Clock in kHz - to accomodate short
];
userdata=round(userdata);




userdata=[
2 % header version
1000*env.V(1)
1000*env.V(2)
1000*env.V(3)
1000*env.V(4)
1000*env.V(5)
1000*env.V(6)
1000*env.V(7)
1000*env.V(8)
1000*env.V(9)
1000*env.V(10)
1000*env.V(11)
env.G3ExtClock/(1000) % Tau1_Clock in kHz - to accomodate short
bin2dec(setup.PF_dataCardDIPs)   % can be used to derive nominal gain
bin2dec(setup.PF_dataBoardDIPs)  % can be used to derive nominal gain
bin2dec(setup.PF_arrayLogicDIPs) % on classic glue logic, used for PSI3 reset counter
];
userdata=round(userdata);




userdata=[
3 % header version
1000*env.V(1)
1000*env.V(2)
1000*env.V(3)
1000*env.V(4)
1000*env.V(5)
1000*env.V(6)
1000*env.V(7)
1000*env.V(8)
1000*env.V(9)
1000*env.V(10)
1000*env.V(11)
1000*env.V(12) %id.DLrstGate
1000*env.V(13) %id.DLrstGnd 
1000*env.I.V24m % Current in amperes on the BK PRECISION -24V power supply
1000*env.I.V24p % Current in amperes on the BK PRECISION +24V power supply
env.G3ExtClock/(1000) % Tau1_Clock in kHz - to accomodate short
bin2dec(setup.PF_dataCardDIPs)   % can be used to derive nominal gain
bin2dec(setup.PF_dataBoardDIPs)  % can be used to derive nominal gain
bin2dec(setup.PF_arrayLogicDIPs) % on classic glue logic, used for PSI3 reset counter
];


userdata=[
4 % header version
1000*env.V(1)
1000*env.V(2)
1000*env.V(3)
1000*env.V(4)
1000*env.V(5)
1000*env.V(6)
1000*env.V(7)
1000*env.V(8)
1000*env.V(9)
1000*env.V(10)
1000*env.V(11)
1000*env.V(12) %id.DLrstGate
1000*env.V(13) %id.DLrstGnd 
1000*env.I.V24m % Current in amperes on the BK PRECISION -24V power supply
1000*env.I.V24p % Current in amperes on the BK PRECISION +24V power supply
env.G3ExtClock/(1000) % Tau1_Clock in kHz - to accomodate short
bin2dec(setup.PF_dataCardDIPs)   % can be used to derive nominal gain
bin2dec(setup.PF_dataBoardDIPs)  % can be used to derive nominal gain
bin2dec(setup.PF_arrayLogicDIPs) % on classic glue logic, used for PSI3 reset counter
1000*env.V(14) %id.SRCommon
];





env.V=[];
env.V(end+1)= -3.0   ;  id.AVoff   =numel(env.V);         % Test Point near to Gate Card
env.V(end+1)= 15.0   ;  id.Von     =numel(env.V);         % Test Point near to Gate Card
env.V(end+1)= -3.0   ;  id.Vout10  =numel(env.V);   id.RevBias  =numel(env.V); %Vn.Vout10=0.0;  %PSI3: Vn.RevBias=-2.5;         % Vout10
env.V(end+1)=  7.0   ;  id.Vout9   =numel(env.V);   id.Vreset   =numel(env.V); %Vn.Vout9=0.0;   %PSI3: Vn.Vreset=15.0;          % Vout9
env.V(end+1)=  8.0   ;  id.Vout8   =numel(env.V);   id.Vcc      =numel(env.V); %Vn.Vout8=0.0;   %PSI3: Vn.Vcc=8;                % Vout8
env.V(end+1)=  3.5   ;  id.Vguard2 =numel(env.V);     id.Tbias  =numel(env.V); %Vn.Vguard2=0.0; %PSI3: Vn.Tbias=5.5;            % Vout7
env.V(end+1)=  3.5   ;  id.Vguard1 =numel(env.V);     id.Vgnd   =numel(env.V); %Vn.Vguard1=0.0; %PSI3: Vn.Vgnd=1.0;             % Vout6
env.V(end+1)= 15.0   ;  id.Vbias2  =numel(env.V);   id.MuxHigh  =numel(env.V); %Vn.Vbias2=0.0 ; %PSI3: Vn.Mux_High=15.0;        % Vout5
env.V(end+1)=  5.0   ;  id.Vbias   =numel(env.V);                          %Vn.Vbias=-3.0;   env.V(end+1)=env.V(id.Vgnd)                                % Vout4
env.V(end+1)=  0.0   ;  id.VQinj   =numel(env.V);                          %Vn.Qinj=2.0; % toggle between 1 and 2 V         % Vout3
env.V(end+1)=  2.298 ;  id.Vref    =numel(env.V);                          %Vn.Vref=0.856;  %   usually generated by R/R on Masda-R card
env.V(end+1)=  env.V(id.RevBias)  ; id.DLrstGate =numel(env.V); 
env.V(end+1)=  0     ; id.DLrstGnd   =numel(env.V); % hard-wired to Analog Ground on PSI-2

env.I.V24m=0.093;  % Current in amperes on the BK PRECISION -24V power supply
env.I.V24p=0.100;  % Current in amperes on the BK PRECISION +24V power supply

env.G3ExtClock=1000000; env.UseExtClock=0;


together with header version 4:

env.V=[];
env.V(end+1)= -1.0  ; id.AVoff   =numel(env.V);                             % Test Point near to Gate Card
env.V(end+1)=  15.0 ; id.Von     =numel(env.V);                             % Test Point near to Gate Card
env.V(end+1)= -1.0  ; id.Vout10  =numel(env.V);   id.RevBias =numel(env.V); % Vn.Vout10=0.0;  %PSI3: Vn.RevBias=-2.5;         % Vout10
env.V(end+1)=  4.0  ; id.Vout9   =numel(env.V);   id.Vreset  =numel(env.V); % Vn.Vout9=0.0;   %PSI3: Vn.Vreset=15.0;          % Vout9
env.V(end+1)=  8.0  ; id.Vout8   =numel(env.V);   id.Vcc     =numel(env.V); % Vn.Vout8=0.0;   %PSI3: Vn.Vcc=8;                % Vout8
env.V(end+1)=  3.5  ; id.Vguard2 =numel(env.V);   id.Tbias   =numel(env.V); % Vn.Vguard2=0.0; %PSI3: Vn.Tbias=5.5;            % Vout7
env.V(end+1)=  3.5  ; id.Vguard1 =numel(env.V);   id.Vgnd    =numel(env.V); % Vn.Vguard1=0.0; %PSI3: Vn.Vgnd=1.0;             % Vout6
env.V(end+1)=  15.0 ; id.Vbias2  =numel(env.V);   id.MuxHigh =numel(env.V); % Vn.Vbias2=0.0 ; %PSI3: Vn.Mux_High=15.0;        % Vout5
env.V(end+1)=  3.0+0*env.V(id.Vreset);  id.Vbias   =numel(env.V);                   % Vn.Vbias=-3.0;   env.V(end+1)=env.V(id.Vgnd)   env.V(id.Vreset)  % Vout4
env.V(end+1)=  1.0  ; id.VQinj   =numel(env.V);                              % Vn.Qinj=2.0; % toggle between 1 and 2 V         % Vout3
env.V(end+1)=  2.305; id.Vref    =numel(env.V);                             % Vn.Vref=0.856; 2.303  for PSI2/3 cards  %   usually generated by R/R on Masda-R card
env.V(end+1)=  env.V(id.RevBias)  ; id.DLrstGate =numel(env.V);                  % env.V(id.Vguard2)
env.V(end+1)=  0    ; id.DLrstGnd   =numel(env.V);                           % hard-wired to Analog Ground on PSI-2
env.V(end+1)=  env.V(id.AVoff)    ; id.SRCommon   =numel(env.V);                           

env.I.V24m=0.092;  % Current in amperes on the BK PRECISION -24V power supply
env.I.V24p=0.099;  % Current in amperes on the BK PRECISION +24V power supply

meas.MFileDesc=[ mfilename() '.m' ];

%}
