function message = g3_startacq( host, port, R, AcqFile, SORTMODE, nuke, wait4end )
    
    if nargin<6
        nuke=true;
    end
    if nargin<7
        wait4end=false;
    end

    

    import java.net.Socket
    import java.io.*

    number_of_retries=1;
    %if (nargin < 3)
    %    number_of_retries = 20; % set to -1 for infinite
    %end
    
    retry        = 0;
    my_socket    = [];
    message      = [];

    while true

        retry = retry + 1;
        if ((number_of_retries > 0) && (retry > number_of_retries))
            fprintf(1, 'Too many retries\n');
            break;
        end
        
        %try
            fprintf(1, 'Retry %d connecting to %s:%d\n', ...
                    retry, host, port);

            % throws if unable to connect
            my_socket = Socket(host, port);
            fprintf(1, 'Connected to server\n');

            % get a buffered data input stream from the socket
            fprintf(1, 'Input stream connected\n');
            input_stream   = my_socket.getInputStream;
            d_input_stream = DataInputStream(input_stream);

            
            fprintf(1, 'Output stream connected\n');
            output_stream   = my_socket.getOutputStream;
            d_output_stream = DataOutputStream(output_stream);
            %d_output_stream.writeBytes(char(48,50));
            %d_output_stream.writeBytes(char(32:127));
            
            % send G3 reset (nuke command queue?)
            if nuke;
            send_uint( [ 1201 0 ], 32 );            
            read_response();
            end

            % suspend queue processing (pause queue)
            %send_uint( [ 1202 0 ], 32 );
            %read_response();
            
            
            %set data sorting
            %SORTMODE
            send_uint( [ 1003 4 SORTMODE ], 32 );
            read_response();
            
            
            %set filename            
            send_uint( [ 1001 numel(AcqFile) ], 32 );
            send_uint( AcqFile, 8 );
            read_response();


            % set user payload
            PAYLOAD='blubber_blubber hi john!';
            send_uint( [ 1002 numel(PAYLOAD) ], 32 );
            send_uint( PAYLOAD, 8 );
            read_response();

            % enable or disable flags/parameters
            % enable send_eof
            send_uint( [ 1004 8 ], 32 );
            send_uint( [1 1], 32 );
            read_response();
            
            % NEW JJA PARAMETER: Save image file
            send_uint( [ 1004 8 ], 32 );
            send_uint( [7 1], 32 );
            read_response();

            % set G3 parameters and start acquisition
            send_uint( [ 1102 numel(R)*2 ], 32 );
            send_uint( R, 16 );                       
            read_response();
            
            %send_uint( [ 1102 numel(R)*2 ], 32 );
            %send_uint( R, 16 );
            %read_response();
            
            
            %isClosed = my_socket.isClosed()
            %isConnected = my_socket.isConnected()
            
            message = char(message);            
            
            read_response();
            %pause
            %read_response();
            %pause
            %read_response();
            
            
            
            % resume queue processing
            send_uint( [ 1203 0 ], 32 );
            read_response();


            % wait for end of current acquisition
            if wait4end;
            %send_uint( [ 1203 0 ], 32 );
            sprintf('\nWaiting for end of acquisition...\n');
            wait_for_response();
            end

            % cleanup
            my_socket.close;
            break;
            
        %catch
        %    fprintf(1, '\nCatched!\n', bytes_available);
        %    if ~isempty(my_socket)
        %        my_socket.close;
        %    end

            % pause before retrying
        %    pause(1);
   %end
    end
   
    function send_uint( valxx, bitwidth )
        for snrxx=1:numel(valxx);
            xx=double(valxx(snrxx));
            %fprintf(1,'%3d/%3d:  %7d\t',snrxx,numel(valxx),xx);
            if bitwidth>16;
            xxb4=bitshift( bitand( xx, bitshift(255,24) ), -24);
            xxb3=bitshift( bitand( xx, bitshift(255,16) ), -16);
            d_output_stream.write(xxb4); fprintf(1,' %3d',xxb4);
            d_output_stream.write(xxb3); fprintf(1,' %3d',xxb3);
            end
            if bitwidth>8;
            xxb2=bitshift( bitand( xx, bitshift(255, 8) ),  -8);
            d_output_stream.write(xxb2); fprintf(1,' %3d',xxb2);
            end
            xxb1=bitshift( bitand( xx, bitshift(255, 0) ),  -0);
            d_output_stream.write(xxb1); fprintf(1,' %3d',xxb1);
            %fprintf(1,'\n');
        end
    end
    
    function read_response()
            pause(0.2);
            bytes_available = input_stream.available;
            fprintf(1, ' <Reading %d bytes:\t', bytes_available);
            
            message = zeros(1, bytes_available, 'uint8');
            for i = 1:bytes_available/4
                b=d_input_stream.readInt;
                fprintf(1,'%6d\t',b);
            end
            fprintf(1, '\n');
    end


    function wait_for_response()
            pause(0.2);
            bytes_available = 8;%input_stream.available;
            fprintf(1, ' <Reading %d bytes:\t', bytes_available);
            
            message = zeros(1, bytes_available, 'uint8');
            for i = 1:bytes_available/4
                b=d_input_stream.readInt;
                fprintf(1,'%6d\t',b);
            end
            fprintf(1, '\n');
    end



end


% 8 byte, 2 32bit integers, network: big endian
% 0: packet type (5 types one can send, 2 response types: ack/frame)
% 1: length of remaining packet in bytes



% set filename:
% type: 1001, length: filename (non-zero-terminated)
% payload: filename
% response: no response / new version: send ack!

% set user payload:
% type: 1002, length: payload-size (max 2000)
% payload: user payload
% response: ack 2001

% set data sorting mode
% type: 1003
% length: 4
% payload: int
%  0: NO DATA SORTING
%  1: cyclops X
%  2: pagescan Y
%  3: hawkeye  Y
%  4: hoffa   X
%  5: xddi    X
%  6: nd10      Z
%  7: m10       Z
%  8: md88      Z
%  9: m13       Z
% 10: psi1    X
% 11: psi2    (special)
% 12: psi3    (special)


% set JJA parameters:
% type: 1004
% length: 8 (id/value pair)
%  id/name(value):
%     1 send_eof    (over network link,  default: 0)
%     2 append_file (1 append, 0 overwr, default: 1)
%     3 show_image  (default: whatever gui is set to)
%  NEW as of 2010-01-19:
%     4 send_acquisition_metadata (default: 0)
%     5 send_frame_metadata (default: 0)
%     6 send_image_data     (default: 0)
%     7 save_image_data     (default: 0)
%  value: 0 off, 1 on


% stop acquisition (interrupt, for example a continuous acquisition)
% type: 1101
% response: acked by 2001

% start acquisition by dumping parameters:
% type: 1102 (acquire start)
% length: 32x2+2 bytes (flags are just one short, e.g. 16 bit), 66 bytes
% response: acked by 2001
% on regular end of acquistion: no notification right now


% to send a reset: 
% type: 1201, length: 0
% response: ack 2001
% (This command Nukes the queue & hard-resets the G3 & resets JJA to defaults)
% in detail:
%     user file header = nul
%     user file name = nul
%     1 send_eof    (over network link,  default: 0)
%     2 append_file (1 append, 0 overwr, default: 1)
%     4 send_acquisition_metadata (default: 0)
%     5 send_frame_metadata (default: 0)
%     6 send_image_data     (default: 0)
%     7 save_image_data     (default: 0)

% queue pause: 1202 (queued in)
% queue resume: 1203 (piped thru)


% get EOC packet message
% selectively get EOF packets
% 2101: image
% 2102: eof
% 2103: eoc


% nuke command queue
% use the normal G3 reset? yes


%{
 Acquisition Header for automated acquisition as of 2009-01-18 (.amd)
 5000 byte total
 4    (int) total header length
 4    (int) 1 (header version?)
 66   32 16bit R's + 1 16bit F's (as used for acquisition start)
 2    padding 0
 4    (int) state of sorting mode
 8    (long) acquisition starting time in msec since the epoch
 padding to 1000 byte border
 2000 byte file name
 2000 byte user header

 Frame Metadata File: 2010-01-18 (.fmd)
 256 bytes total, all long (8 bytes each):
  1   frame metadata file/header version
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



Frame Metadata File, implemented on 2010-01-27 22:40, planned usage: 2010-01-28 2pm (.fmd)
  1   remaining header length in byte (adjusted by JJA)
  2   frame metadata file/header version
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
 14   number of packets missing in current frame or flag or sth. similar? [source: JJAM]

 15   reserved long - for future use
 16   reserved long - for future use

 17-25 G3 parameters+Flags as shorts (16 bit each, 66 byte total)

 26: default user data offset (note: 25*8=200)
 31: last long value for default fmd packet size
 



2010-01-27 Theoretical Problem with current JJAM software version:
 since receiving packets and image processing are handled by two seperate threads,
 a race condition can occur when the image processing thread lags behind:
 frames currently processed by the image processing thread could store
 R's and other JJAM-generated information from the next acquisition into the fmd structure.
This theoretical problem will most likely be solved in future JJAM versions.


%}




%{
   timing for multi sequences
%}


%{
 high-performance multi-sequence mode
   128! commands can be queued in fpga on gbit interface card, fpga already pretty full
 software-based:
   queue G3-configurations in java acquisition software
   java acquisition software sends commands to G3 en-block once it receives the EOC
      timing non-deterministic, since OS-layers and multiple threads are traversed
   in this high-performance scenario, appending to files could be important again
      (including inter-frame packets)
%}


%{

automatic measurement protocol brainstorming:

verify gain settings of masda-r card:
    vary Qinj? vary Vref?


PSI2:
    quantify noise in usual setup
    quantify noise with Vreset==Vbias
    frame time dependence
    read PSI2 without addressed gatelines (by jumping ahead)

PSI3:
    bumb up gate line count to include electronic noise

    with and without DLreset

    Noise sequence measurements:
    - ADC only (fixed input, includes on-ADC-board opamp)
    (- ADC input with cable, no Masda-R)
    -
 
    Doable on PSI-3:
    - ADC only by not addressing Masda-R (fixed Masda-R output?)
        - sweep Vref to get Masda-R-Out to ADC mapping
    - Masda-R, no MUX addressing (empty input, Qinj produces signal!)
        - sweep Qinj to verify Masda-R-gain
    - Masda-R, MUX addressing, no GL, DLreset active
    - Masda-R, MUX addressing, no GL, DLreset disabled
    - GL addressing, Pixels always in Reset, TFTal off, Vgnd==Vbias==Vcc?
    - GL addressing ...
    - Full Pixel Readout


    Alternative Aquisition Mode (also in PSI-2 with individual GL addressing)
    - Vg-rst to a medium value to allow continious reset
    - fast, continuous readout, average after Peak of read signal
        - no reset noise! - no charge injection (good or bad?) - trap/lag data?
%}


