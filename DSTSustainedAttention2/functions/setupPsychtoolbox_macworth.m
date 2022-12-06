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

% RestrictKeysForKbCheck([set.key.response, set.key.esc])
%  RestrictKeysForKbCheck([])
%   
% Enable alpha blending with proper blend-function.
% We need it for drawing of smoothed points and transparency:
Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Initial flip...
Screen('Flip', windowPtr);

%% Load textures

IM = imread([set.direct.stimuli 'instruction.png']);
STIM = uint8(IM);
texture.instruct = Screen('MakeTexture', windowPtr, STIM); %0 = optimise for no rotation, 2 = fastest possible loading.


IM = imread([set.direct.stimuli 'clock_hand.png']);
STIM = uint8(ones(size(IM,1), size(IM,2), 4))*255;
STIM(:,:,1:3) = uint8(IM);
STIM(:,:,4) = IM(:,:,2)*255; %set transparency
texture.clockhand = Screen('MakeTexture', windowPtr, STIM); %0 = optimise for no rotation, 2 = fastest possible loading.

IM = imread([set.direct.stimuli 'clock_circle.png']);
STIM = uint8(IM);
texture.clockcircle = Screen('MakeTexture', windowPtr, STIM); %0 = optimise for no rotation, 2 = fastest possible loading.

end