disp('Task completed. Wrapping up')

% Initial flip
Screen('TextFont',windowPtr, 'Courier New');
Screen('TextStyle', windowPtr, 0);
Screen('TextSize',windowPtr, 30);
Screen('DrawText', windowPtr, 'Your task is complete, excellent work! :)', set.mon.res(1)/2-400,  set.mon.res(2)/2-200, uint8([255 255 255]));
Screen('DrawTexture', windowPtr, texture.frame, [0 0 1920 1080], [0 0 1920 1080]);
Screen('Flip', windowPtr);


% Save data
timestamp = datestr(datetime('now','Format','dd.MM.yyyy'));
mkdir([pwd '\' set.direct.results])
save([pwd '\' set.direct.results 'BEHAVE_' timestamp(1:14) '-' timestamp(16:17)  '.mat'])

% Display Ending screen
for ii_frame = 1:set.f.completescreen
    
    % Set text
    txt1 = 'Your task is complete, excellent work! :)';
    txt2 = ['This window will close in ' num2str(ceil((set.f.completescreen - ii_frame)./set.mon.ref)) ' seconds'];
    
    % draw text
    Screen('TextFont',windowPtr, 'Courier New');
    Screen('TextStyle', windowPtr, 0);
    Screen('TextSize',windowPtr, 30);
    Screen('DrawText', windowPtr, txt1, set.mon.res(1)/2-400,  set.mon.res(2)/2-200, uint8([255 255 255]));
    Screen('TextSize',windowPtr, 25);
    Screen('DrawText', windowPtr, txt2, set.mon.res(1)/2-350,  set.mon.res(2)/2+200, uint8([255 255 255]));
    
    % Display Frame
    Screen('DrawTexture', windowPtr, texture.frame, [0 0 1920 1080], [0 0 1920 1080]);
    
   
    % flip
    Screen('Flip', windowPtr);
    
    % get input
    [~, ~, keyCode, ~] = KbCheck();
    if keyCode(set.key.esc)
        break;
    end
end