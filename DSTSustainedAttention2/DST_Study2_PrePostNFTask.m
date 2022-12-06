%% Script for DST project paradigm.
% This script gathers data for training the ML Classifiers. 

%% udp contingency
try
    fclose(set.nf.port);
    delete(set.nf.port);
catch
    %no worries
end

%% Startup
clear
clc
close all
addpath('functions/')
addpath('E:\toolboxes\io64')
input('Hey, have you started the EEG recording? (Enter)')
input('Seriously, please double check... (Enter)')
input('Last chance... (Enter)')

%% Setup experiment settings
% options - Options for how the experiment is run
% stim - stimulus properties
% set - structure:
%    mon - Properties of the monitor used to display the experiment
%    direct - Directories
%    key - psychtoolbox keys
%    n - counts of things like blocks
%    s - Timing settings in seconds
%    f - Timing settings in frames
%    seed - random seed used

[options, set, stim] = setupSettings();
[set, options] = setupSettingsPreNF(set, options);

%% Setup experimental data structure to control the experiment
% DATA - Data structure describing the experiment
% Dkey - Key describing what is in DATA.
% Didx - the index of each frame in the DATA matrix for each block - (frames x blocks)

[DATA, Dkey, Didx] = setupExperimentalData(set, stim);

%% Setup coordinates for motion
% stim - stimulus properties now contain coordinate data

try
    [stim] = setupMotion(options, set, stim); % Very rarely, the first attempt fails to generate possible coords. 
catch
    print('First attempt at motion dynamics failed, trying again')
    [stim] = setupMotion(options, set, stim);
end

%% Setup identidy for each stimulus and allocate switches (target and distractor) across time and stimuli.
%  ID - ID structure describing each of the individual objects:
%    state - what state are they in, i.e. what letter are they
%    representing?

[ID, DATA, Dkey] = setupSwitches(set, stim, DATA, Didx, Dkey, options);


%% In case of emergency, stop eyetracking triggers

%     options.eyetracking = 0;

%% Triggering
% set - settings for the experiment structure, with new structure:
%   trig: Triggers and trigger settings.

if options.trigger
    [set, DATA] = setupTriggers(set, DATA, Didx, Dkey, options);
end

%% Setup Psychtoolbox
%  windowPtr - Pointer to the psychtoolbox window
%  texture - textures fro sprites

[windowPtr, texture, set] = setupPsychtoolbox(options, set);


%% Preassign trial variables
% trialvars - Variables used in the trial loop.

[trialvars] = setupTrialvars();

%% Run!

for ii_block =1:set.n.blocks % Loop through blocks
    % Break before block begins
    displayBlockbreak

    for ii_frame = 1:set.f.block % Loop through frames in block

        % Display the task
        displayTask

        % Check for responses
        checkResponses     
        CalculateFeedback
        
        % Flip to screen
        flipper

        % Escape!
        if trialvars.escaper; break; end

    end

    if trialvars.escaper; break; end

    % Close eye tracking port
    
    if options.eyetracking
        fclose(set.trig.eyeport);
    end
end

fclose(set.nf.port);
delete(set.nf.port);

%% Task complete

displayEndscreen

%% Quit
Screen('Close')
sca
% Plot flip timing
figure;
dat = diff(DATA(:, Dkey.FlipTimestamp));
dat=dat(~isnan(dat));
t=linspace(0,(length(dat)/set.mon.ref)/(60),length(dat));
plot(t,dat);
ylim([0.016 0.017])
% ylim([0.008 0.009])
xlabel('Time (mins)')
ylabel('Flip interval')
title('Loop flip timing')

% figure;
% plot(DATA(:, Dkey.FlipTimestamp)-DATA(:, Dkey.VBLTimestamp));
% title('Actual flip timing')
% ylim([0.0 0.002])