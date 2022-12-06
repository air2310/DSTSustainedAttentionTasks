function [options, set, stim] = setupSettings()
%setupSettings: Setup the settings for sustained attention task

%   Inputs:
%
%   Outputs: a number of structures describing the experiment
%       options - Options for how the experiment is run
%       stim - stimulus properties
%       set - structure:
%           seed - random seed used
%           mon - Properties of the monitor used to display the experiment
%           direct - Directories
%           key - psychtoolbox keys
%           n - counts of things like blocks 
%           s - Timing settings in seconds
%           f - Timing settings in frames
          
%% TODO
% express which colour is target and which is distractor. 

%% Subject ID

SUBID = 0;
set.SUBID = SUBID;
disp(['Subject ID: ' num2str(SUBID)])

%% Save random seed
set.seed = rng;

%% Options
options.hideCursor = 1;
options.skipsynctests = 0;
options.variablespeed = 1;
options.movie = 0;
options.trigger = 1;
options.flicker = 1;
options.sound = 0;
options.instructions = 0;
options.eyetracking = 0;

%% Directories
direct.stimuli = 'stimuli/';
direct.functions = 'functions/';
direct.results = ['results/SUB' num2str(set.SUBID) '/'];

%% Monitor properties
mon.res = [1920 1080];%[1920 1080];
mon.ref = 120; %144
mon.use = 0; %0

%% Experiment structure
n.blocks = 4; % 4 x 20 minute blocks

%% Timing
s.block = 60*20; % 20 minute blocks
s.blockbreak = 5;

s.switchlife = [1.0 1.0]; % how long do switches stay on for.
n.switchlives = length(s.switchlife); % are we blocking this? 
s.switchduration_block = s.block/n.switchlives; % If so, how long will one switch duration be on for per block
s.flickerswitchrate = 60; % Switch frequencies once per minute. 

s.preswitchclean = 0.5; % How long should the object have been switch-free for before it can switch again.
s.trial = s.block; % seconds
s.mindistance = 2; %at least 2 seconds between targets.

s.blockonsetbreak = 1;
s.blockoffsetbreak = 1;

s.completescreen = 5;

tmp = fields(s); % get monitor refresh resolved timing
for ii = 1:length(tmp)
    f.(tmp{ii}) = round(s.(tmp{ii})*mon.ref);
    s.(tmp{ii}) = f.(tmp{ii})/mon.ref;
end


%% Counterbalancing

% Cued colour
if mod(SUBID,2)==0 % Even numbers attend pink
    stim.colours = [
    255 0 127.5 % pink target
    0 255 127.5]; %mint-green distractor

    % Set targets
    if mod(SUBID/2,2)==0 %every second even numbered participant gets 2/5 targets
        stim.targchars = {'2' '5'};
        stim.distractchars = {'E' '3'};
    else
        stim.targchars = {'E' '3'};
        stim.distractchars = {'2' '5'};
    end
else % odd numbers attend green
    stim.colours = [
        0 255 127.5 % mint-green target
        255 0 127.5]; %pink distractor
    
    if mod((SUBID + 1)/2,2)==0 %every second even numbered participant gets 2/5 targets
        stim.targchars = {'2' '5'};
        stim.distractchars = {'E' '3'};
    else
        stim.targchars = {'E' '3'};
        stim.distractchars = {'2' '5'};
    end
end


%% Frequency tagging

hz.stars = 20;
hz.objects = [12 15];
hz.saturation = 0.0167/4; % once/ 5 minutes

%% Keys for psychtoolbox
key.left = 162; % left ctrl. left key = 37
key.right = 163; % right ctrl. left right = 39
key.space = 32;
key.response = [key.right key.space];%[key.left key.right];
key.esc = 27;
key.pause = key.left; %(left control). 
key.enter=13;

%% Stimulus properties
% colours

stim.target = 1;
stim.distractor = 2;

n.colours = size(stim.colours,1);

stim.minsaturation = 0.4;
stim.maxsaturation = 0.8; 
stim.saturation = 0.8; 

% Numbers of objects
n.objs_colour = 15; % per colour
n.objs_total = n.objs_colour * n.colours; % per colour

% Sizing
stim.scale = 0.8;

stim.width = 51;
stim.height = 90;

stim.truewidth = round(stim.scale*stim.width);
stim.trueheight = round(stim.scale*stim.height);

% Speed
if options.variablespeed
    % set parameters
    secperscreen = 10;
    range = 2; % 3 s +/- 1 sec to traverse screen. 
    
    % get speeds for traversing the screen (seconds/ screen)
    speeds_secperscreen = linspace(secperscreen-range, secperscreen+range, n.objs_total);
    speeds_secperscreen = speeds_secperscreen(randperm(n.objs_total));
    
    % translate to screens / second
    speeds_screenpersec = 1./speeds_secperscreen;
    
    % translate to pixels / second
    speeds_pixelspersec = speeds_screenpersec*mon.res(2);
    
    % translate to pixes / frame
    speeds_pixelsperframe = speeds_pixelspersec / mon.ref;
    stim.speed =speeds_pixelsperframe;
    
%     stim.speed = rand(1, n.objs_total)*0.42+0.7;%(rand(1, n.objs_total)*0.0167 + 0.0334)*mon.ref;% +2/2.4; %pixels/frame
else
    stim.speed = ones(1, n.objs_total)*2.5; %pixels/frame
end




%% Put it all in settings

set.direct = direct;
set.mon = mon;
set.n = n;
set.s = s;
set.f = f;
set.hz = hz;
set.key = key;
set.stim = stim;

end







