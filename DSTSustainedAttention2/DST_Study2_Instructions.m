
%% Startup
clear
clc
close all
addpath('functions/')

% Screen('Preference', 'SkipSyncTests', 1)

%% Setup experiment settings

[options, set, stim] = setupSettings();
options.instructions = 1;
[set, options] = setupSettingsPreNF(set, options);

%% Setup experimental data structure to control the experiment

[DATA, Dkey, Didx] = setupExperimentalData(set, stim);

%% Setup coordinates for motion

try
    [stim] = setupMotion(options, set, stim); % Very rarely, the first attempt fails to generate possible coords. 
catch
    print('First attempt at motion dynamics failed, trying again')
    [stim] = setupMotion(options, set, stim);
end

%% Setup identidy for each stimulus and allocate switches (target and distractor) across time and stimuli.

[ID, DATA, Dkey] = setupSwitches(set, stim, DATA, Didx, Dkey, options);

%% Setup Psychtoolbox

[windowPtr, texture] = setupPsychtoolbox(options, set);

%% Preassign trial variables

[trialvars] = setupTrialvars();


%% Run!
page = 1; 
idx_instruct = [1 2 3 4 5 6 7 NaN 8 NaN 9 NaN 10];
ii_frame = 0;
ii_block = 1;
breaker = 0;
counter = 0;

while 1
    % Iterate counter
    counter = counter + 1;
    
    %% Practice
    if ismember(page, [8 10 12])
        % Set playtime
        if page == 12; playtime = set.mon.ref*1*60; else, playtime = set.mon.ref*30; end
        
        % iterate through frames
        for ii_frame = 1:playtime
            displayTask_Instructions
    
            % Flip to the screen
            Screen('Flip', windowPtr);
            
            % check for keyboard input
            [~, ~, trialvars.keyCode, ~] = KbCheck();
            if any(trialvars.keyCode([37 39 set.key.esc])) && ii_frame > set.mon.ref*0.3
                if trialvars.keyCode(39)% right
                    page = page + 1;
                elseif trialvars.keyCode(37) % left
                    page = page - 1;
                elseif trialvars.keyCode(set.key.esc)
                    breaker = 1;
                end
                break;
            end
        end
        
        % if we havent escaped through other means:
        if ismember(page, [8 10 12])
            page = page + 1;
        end
    end
    
    
    %% Regular instructions
    % iterate
    ii_frame = ii_frame+1;
    
    % Draw asteroids
    displayTask_Instructions
    
    % Display Instruction panel
    Screen('DrawTexture', windowPtr, texture.instructions(idx_instruct(page)), [0 0 1920 1080], [0 0 1920 1080]);
    
    % Flip to the screen
    [VBLTimestamp, ~, FlipTimestamp]  = Screen('Flip', windowPtr);
    
    %% check for keyboard input to move around
    [~, ~, trialvars.keyCode, ~] = KbCheck();
    
    if any(trialvars.keyCode([37 39])) && counter > set.mon.ref*0.3
        counter = 0;
        if trialvars.keyCode(39)% right
            page = page + 1;
        elseif trialvars.keyCode(37) % left
            if page > 2
                page = page - 1;
            end
        end
    end
    if page == 1 && ii_frame > 10*set.mon.ref
        page = 2;
    end
    
    % Leave if we've reached the end.
    if page > 13 || trialvars.keyCode(set.key.esc) || breaker
        break
    end


    
end

% close screen. 
sca
Screen('CloseAll')
