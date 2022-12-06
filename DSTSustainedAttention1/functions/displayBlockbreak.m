%% Block starter

% display progress
txt1 = ['BLOCK ' num2str(ii_block) ' OF ' num2str(set.n.blocks)];
disp(txt1)

% set trig to 0
if options.trigger
    io64(set.trig.ioObj, set.trig.address(2), 0)% EEG
    io64(set.trig.ioObj, set.trig.address(1), 0)% biopac
end

blockframes = 0;
while true
    blockframes = blockframes+1;
    
    % Set text
%     txt1 = ['BLOCK ' num2str(ii_block-1) ' OF ' num2str(set.n.blocks) ' COMPLETED'];
    txt2 = 'Please call your experimenter to calibrate the eye tracker';
    txt3 = 'Press [SPACE] when you are ready to continue';
    txt4 = 'Press [SPACE] when you are ready to begin';
    
    % draw block text
    Screen('TextFont',windowPtr, 'Courier New');
    Screen('TextStyle', windowPtr, 0);
    Screen('TextSize',windowPtr, 50);%40
%     Screen('DrawText', windowPtr, txt1, set.mon.res(1)/2-370,  set.mon.res(2)/2-300, uint8([255 255 255]));
    
    % Draw congratulations text
    if ii_block == 1
        Screen('TextSize',windowPtr, 30);%20
        Screen('DrawText', windowPtr, txt4, set.mon.res(1)/2-400,  set.mon.res(2)/2+250, uint8([255 255 255]));
    else
        Screen('TextSize',windowPtr, 30);
        Screen('DrawText', windowPtr, txt2, set.mon.res(1)/2-500,  set.mon.res(2)/2-100, uint8([255 255 255]));
        
        % draw continue text
        if blockframes > set.f.blockbreak
            Screen('TextSize',windowPtr, 30);%40
            [newX,newY,textHeight]=Screen('DrawText', windowPtr, txt3, set.mon.res(1)/2-450,  set.mon.res(2)/2+250, uint8([255 255 255]));
        end
    end
    
    % Display Frame
    Screen('DrawTexture', windowPtr, texture.frame, [0 0 1920 1080], [0 0 1920 1080]);
    
    % Draw targets
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [960-50 1080-44], 0.5, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [960+50 1080-44], 0.5, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    
    % flip
    Screen('Flip', windowPtr);
    
    % get input
    [~, ~, keyCode, ~] = KbCheck();
    if keyCode(set.key.space) && (blockframes > set.f.blockbreak || ii_block == 1) % enforced 5 s break
        break;
    end
    
end

%% connect to eye tracker
if ii_block > 1
    if options.eyetracking
        fclose(set.trig.eyeport)
        set.trig.eyeport = tcpip('10.50.83.239',1972, 'Networkrole', 'client');
        fopen(set.trig.eyeport)
    end
end