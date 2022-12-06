function [DATA, Dkey, Didx] = setupExperimentalData(set, stim)
%setupExperimentalData: Setup the the Data structure to control the
%experiment

%   Inputs:
%       options - Options for how the experiment is run
%       stim - stimulus properties
%       set - settings for the experiment structure
%
%   Outputs:
%       DATA - Data structure describing the experiment
%       Dkey - Key describing what is in DATA. 
%       Didx - the index of each frame in the DATA matrix - (frames x
%       blocks)


%% Extract settings for this function
mon = set.mon;
n = set.n;
f = set.f;
s = set.s;
hz = set.hz; 
disp('Setting up experimental Data')

%% Initialise DATA and DATAkey. 
% Set keys
Dkey.BLOCK = 1;
Dkey.FRAME = 2;
Dkey.saturation = 3;
Dkey.switchduration = 4;

Dkey.target_isonsetframe =5; % start all false
Dkey.target_type = 6;
Dkey.target_ID = 7;
Dkey.target_coordsx= 8;
Dkey.target_coordsy = 9;
Dkey.target_speed = 10;

Dkey.flicker_star = 11;
Dkey.flicker_cond = 12;
Dkey.flicker_target = 13;
Dkey.flicker_distract = 14;
Dkey.flicker_mode = 15;

Dkey.VBLTimestamp = 16;
Dkey.FlipTimestamp = 17;

Dkey.response = 18;
Dkey.responseframe = 19;

Dkey.trigger = 20;
Dkey.eyetracktrigs = 21;

Dkey.HMMstates = 22;

Dkey.target_respdeadlineframe=23;
Dkey.points=24;
Dkey.cumpoints=25;

numcols = 25;
DATA = NaN(f.block*n.blocks, numcols);


%% Setup Data index matrix

Didx = NaN(f.block, n.blocks);
for BLOCK = 1:n.blocks
    Didx(:, BLOCK) =  [1:f.block]' + f.block*(BLOCK-1);
end

%% Setup blocks and frames
for BLOCK = 1:n.blocks
    DATA(Didx(:, BLOCK), Dkey.BLOCK) = BLOCK;
    DATA(Didx(:, BLOCK), Dkey.FRAME) = 1:f.block;
end

%% Saturation

% basics
% s.cycle = round(1/hz.saturation);
% f.cycle = s.cycle*mon.ref;
% cycle = [linspace(stim.minsaturation, stim.maxsaturation, f.cycle/2) linspace(stim.maxsaturation, stim.minsaturation, f.cycle/2)];
% satsig = repmat(cycle, 1, f.block/f.cycle);


% set for each block
for BLOCK = 1:n.blocks
    DATA(Didx(:, BLOCK),Dkey.saturation) = stim.saturation;
end

% plot
% figure;
% t = 0 : 1/mon.ref : s.block - 1/mon.ref;
% plot(t, satsig)

%% Switch Duration

% order of switches for each block
possibilities = perms(1:n.switchlives); % all possibile permutations
n.poss = size(possibilities,1);
startingorder = randperm(n.poss,n.poss); % randomise their order. 
blockoforders = possibilities(startingorder,:);
allorders = repmat(blockoforders, ceil(n.blocks/n.poss), 1); % stack to represent all blocks

% set for each block
for BLOCK = 1:n.blocks
    % duration order for this block
    orderblock = allorders(BLOCK, :);
    
    % set up switchlives
    tmp = [ones(f.switchduration_block, 1).*f.switchlife(orderblock(1));
    ones(f.switchduration_block, 1).*f.switchlife(orderblock(2))
    ];

    DATA(Didx(:, BLOCK),Dkey.switchduration) = tmp;
end

%% Things that should be preallocated as zeros. 

DATA(:, Dkey.target_isonsetframe) = 0; % start all false
DATA(:, Dkey.target_respdeadlineframe) = 0; % start all false
DATA(:, Dkey.responseframe) = 0; 

DATA(:, Dkey.points) = 0; % start all false
DATA(:, Dkey.cumpoints) = 0; 

%% Flicker mode
% 
% flickermodes = {'freq1' 'freq2' '1minute' '10secs'};
% flickerorder = ones(4, 1)*3;%randperm(4);
% 
% % set for each block
% for BLOCK = 1:n.blocks
%     % set flicker mode. 
%     DATA(Didx(:, BLOCK),Dkey.flicker_mode) = flickerorder(BLOCK);
%     
%     % set attended flicker
%     switch flickerorder(BLOCK)
%         case 1
%             sig = ones(f.block,1)*1;
%         case 2
%             sig = ones(f.block,1)*2;
%         case 3
%             f.flickerswitchrate = mon.ref*60;
%             sig = [ones(f.flickerswitchrate ,1); ones(f.flickerswitchrate ,1)*2];
%         case 4
%             f.flickerswitchrate = mon.ref*10;
%             sig = [ones(f.flickerswitchrate ,1); ones(f.flickerswitchrate ,1)*2];  
%     end
%     numreps = f.block/(length(sig));
%     DATA(Didx(:, BLOCK),Dkey.flicker_cond) = repmat(sig, numreps,1);
% end


flickermodes = {'freq1' 'freq2' '1minute' '10secs'};
flickerorder = [1 2 1 2];
flickerorder = flickerorder(randperm(4));
f.flickerswitchrate = mon.ref*60;

% set for each block
for BLOCK = 1:n.blocks
    % set flicker mode. 
    DATA(Didx(:, BLOCK),Dkey.flicker_mode) = flickerorder(BLOCK);
    
    % set attended flicker
    switch flickerorder(BLOCK)
        case 1
            sig = [ones(f.flickerswitchrate ,1); ones(f.flickerswitchrate ,1)*2];
        case 2
            sig = [ones(f.flickerswitchrate ,1)*2; ones(f.flickerswitchrate ,1)];
    end
    numreps = f.block/(length(sig));
    DATA(Didx(:, BLOCK),Dkey.flicker_cond) = repmat(sig, numreps,1);
end

%% Object flicker

% get base signals
t = 0 : 1/set.mon.ref : s.block - 1/set.mon.ref;
sig = NaN(f.block, length(hz.objects));
for HH = 1:length(hz.objects)
    sig(:,HH) = round(0.5 + 0.5*sin(2*pi*hz.objects(HH)*t )); %figure; plot(sig, '-x')
end

% Set flicker for each block
for BLOCK = 1:n.blocks
%     if ismember(flickerorder(BLOCK), [1 2])
%         attendedfreq = DATA(Didx(1, BLOCK),Dkey.flicker_cond);
%         unattendedfreq = abs(attendedfreq-3);
%         DATA(Didx(:, BLOCK),Dkey.flicker_target) = sig(:, attendedfreq);
%         DATA(Didx(:, BLOCK),Dkey.flicker_distract) = sig(:, unattendedfreq);
%     else
    for FRAME = 1:f.block
        attendedfreq = DATA(Didx(FRAME, BLOCK),Dkey.flicker_cond);
        unattendedfreq = abs(attendedfreq-3);
        DATA(Didx(FRAME, BLOCK),Dkey.flicker_target) = sig(FRAME, attendedfreq);
        DATA(Didx(FRAME, BLOCK),Dkey.flicker_distract) = sig(FRAME, unattendedfreq);
    end
%     end
end

%% Star Flicker!

% Star flicker
t = 0 : 1/set.mon.ref : s.block - 1/set.mon.ref;
sig = 0.5 + 0.5*sin(2*pi*hz.stars*t ); %figure; plot(sig, '-x')

% set for each block
for BLOCK = 1:n.blocks
    DATA(Didx(:, BLOCK),Dkey.flicker_star) = round(sig);
end

end

