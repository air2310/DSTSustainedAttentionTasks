%% Demo script for DST project paradigm.

% To do
% testout whether rounding stimulus coords speeds up draw loop.
% Try generating flicker according to vbl timestamp!
% trigger onset of flicker cond change only. 

%% Startup
clear
clc
close all
addpath('functions/')
addpath('E:\toolboxes\io64')
input('Hey, have you started the EEG recording? (Enter)')

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

%% Setup experimental data structure to control the experiment
% DATA - Data structure describing the experiment
% Dkey - Key describing what is in DATA.
% Didx - the index of each frame in the DATA matrix for each block - (frames x blocks)

[DATA, Dkey, Didx] = setupExperimentalData(set, stim);

%% Setup coordinates for motion
% stim - stimulus properties now contain coordinate data

[stim] = setupMotion(options, set, stim);

%% Setup identidy for each stimulus and allocate switches (target and distractor) across time and stimuli.
%  ID - ID structure describing each of the individual objects:
%    state - what state are they in, i.e. what letter are they
%    representing?

[ID, DATA, Dkey] = setupSwitches(set, stim, DATA, Didx, Dkey, options);

%% Triggering
% set - settings for the experiment structure, with new structure:
%   trig: Triggers and trigger settings.

if options.trigger
    [set, DATA] = setupTriggers(set, DATA, Didx, Dkey, options);
end

%% In case of emergency, stop eyetracking triggers

%     options.eyetracking = 0;

%% Setup Psychtoolbox
%  windowPtr - Pointer to the psychtoolbox window
%  texture - textures fro sprites

[windowPtr, texture] = setupPsychtoolbox(options, set);

%% Preassign trial variables
% trialvars - Variables used in the trial loop.

[trialvars] = setupTrialvars();

%% Run!

for ii_block = 1:set.n.blocks % Loop through blocks
    % Break before block begins
    displayBlockbreak

    for ii_frame = 1:set.f.block % Loop through frames in block
        % Display the task
        displayTask

        % Check for responses
        checkResponses     

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

%% Task complete

displayEndscreen

%% Quit

% Close Screen
Screen('CloseAll')
% sca

% Plot flip timing
figure;
plot(diff(DATA(:, Dkey.VBLTimestamp)));
ylim([0.008 0.009])
title('Loop flip timing')

% figure;
% plot(DATA(:, Dkey.FlipTimestamp)-DATA(:, Dkey.VBLTimestamp));
% title('Actual flip timing')
% ylim([0.0 0.002])

%% Preliminary analysis

% prelim_analyse(DATA, Dkey, Didx, set)
sca
