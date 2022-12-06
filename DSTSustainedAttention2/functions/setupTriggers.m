function  [set, DATA]  = setupTriggers(set, DATA, Didx, Dkey, options)
%setupTriggers: Setup the trigger settings and values
%
%   Inputs:
%       set - settings for the experiment structure
%       DATA - updated DATA
%       Didx - indices of frames in blocks
%       Dkey - Key for columns in DATA
%
%   Outputs:
%        set - settings for the experiment structure, with new structure:
%               trig: Triggers and trigger settings. 
disp('Setting up Triggers')

%% Generic triggers
trig.stopRecording = 254;
trig.startRecording = 255;

trig.startblock = 7;
trig.endblock = 8;

%% Triggers by frame

trig.flick = [1 2]; % Hz1, Hz2
trig.targ = [3 4; 5 6]; %[Hz, Targ], 

for ii_block = 1:set.n.blocks
    %set up triggers
    tmptrigs = zeros(set.f.block,1);
    tmptrigs_eye = zeros(set.f.block,1);

    %flickonsets
    flickonsets = 1:60:set.f.block;
    flicks = DATA(Didx(flickonsets, ii_block),Dkey.flicker_cond); 

    %flickonsets
    for ii_trig = 1:length(flickonsets)
        idx = flickonsets(ii_trig): flickonsets(ii_trig)+3;
        idx_eye = flickonsets(ii_trig);
        
        % correct for block trigs. 
        if DATA(Didx(idx(1),ii_block),Dkey.FRAME) == 1
            idx = 6:10;
            idx_eye = 2;
        end
        tmptrigs(idx) = trig.flick(flicks(ii_trig));
%       tmptrigs_eye(idx_eye) = trig.flick(flicks(flickonsets(ii_trig)));
    end
    
    %targonsets
    targs = DATA(Didx(:, ii_block),Dkey.target_type);
    targs(isnan(targs)) = 0;
    targonsets = find([0; diff(targs)]>0);
    
    for ii_trig = 1:length(targonsets)
        idx = targonsets(ii_trig): targonsets(ii_trig)+3;
        idx_eye = targonsets(ii_trig);
        
%         if any(tmptrigs((idx(1)-2):(idx(end)+2)))
%              disp('target overlaps with freq switch, not triggering')
%         end
        
        if any(tmptrigs((idx(1)-2):(idx(2))))
            idx = idx + 5;
        elseif any(tmptrigs((idx(3)):(idx(end)+2)))
            idx = idx - 5;
        end
            
        tmptrigs(idx) = trig.targ(targs(targonsets(ii_trig)), DATA(Didx(targonsets(ii_trig), ii_block),Dkey.flicker_cond));
        tmptrigs_eye(idx_eye) = trig.targ(targs(targonsets(ii_trig)),DATA(Didx(targonsets(ii_trig), ii_block),Dkey.flicker_cond));
    end

    
    % set as triggers for the block
    tmptrigs(1:4) = trig.startblock;
    tmptrigs(end-4:end-1) = trig.endblock;
    % set zeros
    
    tmptrigs_eye(1) = trig.startblock;
    tmptrigs_eye(end) = trig.endblock;
    
    DATA(Didx(:, ii_block), Dkey.trigger) = tmptrigs;
    DATA(Didx(:, ii_block), Dkey.eyetracktrigs) = tmptrigs_eye;
end


%% Trigger settings
PCuse = 1;
trig.ioObj = io64;
trig.status = io64(trig.ioObj);

switch PCuse
    case 1
        trig.options.port = { 'D010'  'D030' };
    case 3
        trig.options.port = { 'D050'  'D050' };
    case 4
        trig.options.port = { '21'  '2FF8' };
    case 5
        trig.options.port = { 'F0D7'  'F0C3' };
end
n.ports = length(trig.options.port);
trig.address = NaN(n.ports,1);

%% Initialise triggers and start recording
for AA = 1:n.ports
    trig.address(AA) = hex2dec( trig.options.port{AA} );
    io64(trig.ioObj, trig.address(AA), 0);
end

% for AA = 1:n.ports
%     disp('port #')
%     disp(AA)
%     for tt = 1:255
%         io64(trig.ioObj, trig.address(AA), tt);
%         pause(0.01)
%         a=io64(trig.ioObj, trig.address(AA));
%         disp(a)
%     end
% end
% 1 = biopac, 2 = EEG
% io64(trig.ioObj, trig.address(1), trig.startRecording);

%% tcpip eye tracking triggers

if options.eyetracking
    trig.eyeportip='10.50.72.50';
    trig.eyeport = tcpip(trig.eyeportip,1972, 'Networkrole','client');
    fopen(trig.eyeport)
end

%% Feedback connection
% UDPport for Neurofeedback

set.nf.port = udp('10.50.74.64', 'RemotePort', 1980, 'LocalPort', 1980);
fopen(set.nf.port);
set.nf.feedback = 50;



%% Exort in settings

set.trig = trig;

end