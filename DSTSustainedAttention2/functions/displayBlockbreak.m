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
    % Display Frame
    Screen('DrawTexture', windowPtr, texture.frame,  [0 0 1920 1080], [0 0 set.mon.res(1) set.mon.res(2)]);

    % Draw targets
    Screen('TextSize',windowPtr, 40);%20
    % left
    Screen('DrawText', windowPtr, 'TARGETS',  set.mon.res(1)-0.093*set.mon.res(1), set.mon.res(2)-0.95*set.mon.res(2), uint8([255 255 255]));
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [ set.mon.res(1)-0.035*set.mon.res(1), set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [ set.mon.res(1)-0.065*set.mon.res(1),  set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    
    % right
    Screen('DrawText', windowPtr, 'TARGETS',  0.009*set.mon.res(1), set.mon.res(2)-0.95*set.mon.res(2), uint8([255 255 255]));
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [0.065*set.mon.res(1), set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [0.035*set.mon.res(1),  set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    
    % Set text size for bank
    if ~options.preNF  % don't show the bank before NF
        if ii_block == 1
            cashval = DATA(Didx(1, ii_block), Dkey.cumpoints) + 10;
        else
            cashval = DATA(Didx(end, ii_block-1), Dkey.cumpoints) + 10;
        end

        Screen('TextSize',windowPtr, 45);%20
        Screen('DrawText', windowPtr, 'BANK',  set.mon.res(1)-0.077*set.mon.res(1), set.mon.res(2)-0.7*set.mon.res(2), uint8([255 255 255])); %right
        Screen('DrawText', windowPtr, 'BANK', 0.022*set.mon.res(1), set.mon.res(2)-0.7*set.mon.res(2), uint8([255 255 255])); % left
        if cashval < -10 % what if they go real low!
            Screen('TextSize',windowPtr, 35);%20
        else
            Screen('TextSize',windowPtr, 40);%20
        end
        Screen('DrawText', windowPtr, ['$' num2str(cashval, '%06.3f')],  set.mon.res(1)-0.095*set.mon.res(1), set.mon.res(2)-0.64*set.mon.res(2), uint8([255 255 255])); %right
        Screen('DrawText', windowPtr, ['$' num2str(cashval, '%06.3f')],  0.01*set.mon.res(1), set.mon.res(2)-0.64*set.mon.res(2), uint8([255 255 255])); %left
    end
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
        set.trig.eyeport = tcpip(trig.eyeportip ,1972, 'Networkrole', 'client');
        fopen(set.trig.eyeport)
    end
end


