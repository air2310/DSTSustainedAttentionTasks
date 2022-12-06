function [windowPtr, texture,set] = setupPsychtoolbox(options, set)
%setupPsychtoolbox
%
%   Inputs:
%       options - Options for how the experiment is run
%       set - settings for the experiment structure
%
%   Outputs:
%       windowPtr - Pointer to the psychtoolbox window
%       TEXTURE - textures fro sprites
disp('Setting up display')

%% Setup Psychtoolbox

if options.skipsynctests
    Screen('Preference', 'SkipSyncTests', 1)
end

KbCheck;
GetSecs;
% Graphics
AssertOpenGL;

% kPsychUseBeampositionQueryWorkaround
% Screen('Preference', 'ConserveVRAM',4096)

% open the screen
screens=Screen('Screens');
screenNumber = set.mon.use;

PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'UseRetinaResolution');
% PsychImaging('AddTask', 'General', 'UseGPGPUCompute','Auto')
% PsychImaging('AddTask', 'General', 'UseFineGrainedTiming')
PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows')

[windowPtr, rect] = PsychImaging('OpenWindow', screenNumber, 0);
    
% [windowPtr, rect] = Screen('OpenWindow', screenNumber, 0);

% get centre
[set.mon.centre(1), set.mon.centre(2)] = RectCenter(rect);

% get interframe interval
set.mon.ifi=Screen('GetFlipInterval', windowPtr);

% hide cursor
topPriorityLevel = MaxPriority(windowPtr);
Priority(topPriorityLevel);
vbl = Screen('Flip', windowPtr);

if options.hideCursor
    HideCursor;	% Hide the mouse cursor
end


%  RestrictKeysForKbCheck(KbName('ESCAPE'));
  
% Enable alpha blending with proper blend-function.
% We need it for drawing of smoothed points and transparency:
Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Initial flip...
Screen('Flip', windowPtr);


%% Load textures

stimnames = {'8' set.stim.targchars{1} set.stim.targchars{2} set.stim.distractchars{1} set.stim.distractchars{2}};
texture.stim = NaN(length(stimnames));

for SS = 1:length(stimnames)
    IM = imread([set.direct.stimuli stimnames{SS} '.png']);
    STIM = uint8(ones(size(IM,1), size(IM,2), 4))*255;
    STIM(:,:,4) = ~IM(:,:,1)*255; %set transparency
    texture.stim(SS) = Screen('MakeTexture', windowPtr, STIM, 0, 2); %0 = optimise for no rotation, 2 = fastest possible loading.
end

% Frame
IM = imread([set.direct.stimuli 'FRAME.png']);
STIM = uint8(ones(size(IM,1), size(IM,2), 4))*255;
STIM = IM;
STIM(:,:,4) = 255*(IM(:,:,1)~=255); %set transparency
STIM(end, :, :) = []; STIM(:, end, :) = []; %crop
STIM(1,:,1:3) = 0;
texture.frame = Screen('MakeTexture', windowPtr, STIM, 0, 2); %0 = optimise for no rotation, 2 = fastest possible loading.

%starstuddedbackground
n.pixels = round(74016/10); %sum(sum(IM(:,:,1) == 0))*stimprops.scale*40
stars = uint8(zeros(set.mon.res(2), set.mon.res(1), 3));
xs = randsample(1:set.mon.res(1), n.pixels, true);
ys = randsample(1:set.mon.res(2), n.pixels, true);
for SS = 1:n.pixels
    stars(ys(SS), xs(SS), :) = 255;
end
% figure; imshow(stars)
texture.stars = Screen('MakeTexture', windowPtr,  stars, 0, 2); %0 = optimise for no rotation, 2 = fastest possible loading.

%% Instructions

fnames = dir([set.direct.stimuli 'Instructions/*.png']);
for II = 1:10
    IM = imread([fnames(II).folder '\' fnames(II).name]);
    STIM = IM;%uint8(ones(size(IM,1), size(IM,2), 4))*255;
    STIM(:,:,4) = ~(IM(:,:,1)==255 & IM(:,:,2)==255 & IM(:,:,3)==255)*255; %set transparency
    texture.instructions(II) = Screen('MakeTexture', windowPtr, STIM, 0, 2); %0 = optimise for no rotation, 2 = fastest possible loading.
end


%% Movie options
if options.movie
    % Movie
    set.f.block = set.mon.ref*30;
    imageArray = zeros(set.mon.res(2)/2, set.mon.res(1)/2, 3, set.f.trial, 'uint8');
end
end