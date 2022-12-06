%% Script for DST project paradigm - Macworth clock test

%% Startup
clear
clc
close all
addpath('functions/')
addpath('E:\toolboxes\io64')

%% Setup experiment settings
[options, set, stim] = setupSettings();

%% Setup clock dynamics
[DATA, Dkey, s, f, set ] = setupExperimentalData_macworth(set);

%% Setup psychtoolbox
[windowPtr, texture, set] = setupPsychtoolbox_macworth(options, set);

%% Display instructions
instructions_on = 1;
while instructions_on
    % Draw instructions
    Screen('DrawTexture', windowPtr, texture.instruct);
    
    % Check for response
    [~, ~, trialvars.keyCode, ~] = KbCheck();
    if trialvars.keyCode( set.key.response)
        instructions_on = 0;
    end
    
    % Flip
    Screen('Flip', windowPtr);
end

pause(0.3)

%% Display demo 
%32.5 53
instructions_on = 1;
angle = 0;
ii_frame = 0;
fill = 0;
fillframe = 0;
Screen('TextFont',windowPtr, 'Arial');
Screen('TextSize',windowPtr, 30);
Screen('TextStyle', windowPtr, 0);

while instructions_on
    % iterate frame

    ii_frame = ii_frame + 1;
    
    % Display instructions
    Screen('DrawText', windowPtr,'For reference, here is a yellow marker showing what a longer than normal tick looks like.', set.mon.centre(1)-(16.25/53)*set.mon.res(1),  set.mon.centre(2)-300, uint8([200 200 0]));
    Screen('DrawText', windowPtr,'Press space bar to begin the task', set.mon.centre(1)-(6.25/53)*set.mon.res(1),  set.mon.centre(2)+300, uint8([0 255 0]));


    % iterate angle
    if DATA(ii_frame, Dkey.tickonset )
        angle = angle + set.standardjump ;
        
        % double tick
        if rand>0.6 && (fill == 0)
           angle = angle + set.standardjump ;
           fill=1;
           fillframe = ii_frame;
        else
            fill = 0;
        end
        
        % loop around
        if angle >=360
            angle = 0;
        end

    end
    % display clock
    PsychDrawSprites2D(windowPtr, texture.clockcircle, [set.mon.centre(1), set.mon.centre(2)]);
    PsychDrawSprites2D(windowPtr, texture.clockhand, [set.mon.centre(1), set.mon.centre(2)], 1, angle );
    
    if fill ||  (ii_frame - fillframe < f.tick)
        radius=29;
        rectuse = [set.mon.centre(1)-radius, set.mon.centre(2)-radius,set.mon.centre(1)+radius, set.mon.centre(2)+radius];
        Screen('FillOval', windowPtr, uint8([200,200,0]), rectuse)        
    end
     % Flip
    Screen('Flip', windowPtr);
    
     % Check for response
    [~, ~, trialvars.keyCode, ~] = KbCheck();
    if trialvars.keyCode( set.key.response)
        instructions_on = 0;
    end

end
pause(0.3)


%% Display task
% 12 minutes

for ii_frame = 1:f.task
    % display background
    Screen('DrawTexture', windowPtr, texture.clockcircle);
    
    % display clock
    PsychDrawSprites2D(windowPtr, texture.clockhand, [set.mon.centre(1), set.mon.centre(2)], 1, DATA(ii_frame, Dkey.clockangle) );
    
    % check responses
    checkResponses_macworth
    
    % displayfeedback
    radius=29;
    rectuse = [set.mon.centre(1)-radius, set.mon.centre(2)-radius,set.mon.centre(1)+radius, set.mon.centre(2)+radius];
    if DATA(ii_frame, Dkey.goodresp_displayed)       
        Screen('FillOval', windowPtr, uint8([0,180,0]), rectuse)
    elseif DATA(ii_frame, Dkey.badresp_displayed)     
        Screen('FillOval', windowPtr, uint8([180,10,10]), rectuse)
    end

    % Flip
    Screen('Flip', windowPtr);
    
    % Escape if nesc
    if find(trialvars.keyCode) == set.key.esc
        break;
    end
    
end
   

%% Clean up
displayEndscreen_macworth

%% Get accuracy
missrate=sum(DATA(:, Dkey.responseacc)==0)/set.numticks_long;
hitrate = sum(DATA(:, Dkey.responseacc)==1)/set.numticks_long;
FArate = sum(DATA(:, Dkey.responseacc)==2)/set.numticks_short;
disp([hitrate, missrate, FArate])

% calculate timewisefeedback
epochlength =(set.mon.ref*60*4);
idx_start = 1:epochlength:f.task;

perform = [];
for ii = 1:length(idx_start)
    idx = idx_start(ii): (idx_start(ii)+epochlength - 1);
    missrate=sum(DATA(idx, Dkey.responseacc)==0)/set.numticks_long;
    hitrate = sum(DATA(idx, Dkey.responseacc)==1)/set.numticks_long;
    FArate = sum(DATA(idx, Dkey.responseacc)==2)/set.numticks_short;

    perform = [perform; [hitrate, missrate, FArate]];
end


figure();
plot(0:4:11,perform)
xlabel('Time in exp')
ylabel('rate')
legend({'hits', 'misses', 'falsealarms'})

