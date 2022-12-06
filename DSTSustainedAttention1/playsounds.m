%% Startup
clear
clc
close all
addpath('functions/')

%% Setup experiment settings

[options, set, stim] = setupSettings();

%% get sound data

wavfilename = [set.direct.stimuli 'phaser.wav'];

% Read WAV file from filesystem:
[texture.sound.y, texture.sound.freq] = psychwavread(wavfilename);

%% Play sounds

while 1
    [~, ~, keyCode, ~] = KbCheck(); 
    if keyCode(set.key.response(2))
        sound(texture.sound.y, texture.sound.freq*1.5)
        
        while keyCode(set.key.response(2)) == 1
            % wait till released
            [~, ~, keyCode, ~] = KbCheck(); 
        end
    end
end
