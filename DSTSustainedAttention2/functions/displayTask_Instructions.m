% function [] = displayTask(DATA, Didx, Dkey, trialvars, stim, texture, ID, windowPtr, options, ii_block, ii_frame)
% %displayTask: Display the task to screen
% %
% %   Inputs:
% %       DATA - updated DATA
% %       Didx - indices of frames in blocks
% %       Dkey - Key for columns in DATA
% %       trialvars - Variables that shift frame to frame.
% %       stim - stimulus properties
% %       texture - psychtoolbox textures
% %       ID - D structure describing each of the individual objects
% %       windowPtr - psychtoolbox window pointer
% %       options - experiment options
% %       ii_block - block index
% %       ii_frame - frame index

% Display stars
if options.flicker
    PsychDrawSprites2D(windowPtr, texture.stars,  set.mon.res/2, 1, 0,  [1 1 1]*255*DATA(Didx(ii_frame, ii_block),Dkey.flicker_star)) %FLICKER(FRAME,3)  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
else
    PsychDrawSprites2D(windowPtr, texture.stars,  set.mon.res/2, 1, 0,  uint8([1 1 1]*255)) %FLICKER(FRAME,3)  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
end

if ismember(page, [1 2 3 13])
    % Display objects
    for ii_stim = 0:4
        trialvars.idx_stimtype = ID.state(:,ii_frame, ii_block) == ii_stim; % find out if any of this stimulus type is active this frame.
        if any(trialvars.idx_stimtype)
            trialvars.col = ID.colours(:, trialvars.idx_stimtype, ii_frame, ii_block);
            trialvars.coord = [-200+1.28*stim.COORDS_X(ID.state(:,ii_frame, ii_block) == ii_stim, ii_frame, ii_block)'; stim.COORDS_Y(ID.state(:,ii_frame, ii_block) == ii_stim, ii_frame, ii_block)'];
            PsychDrawSprites2D(windowPtr, texture.stim(ii_stim+1),  trialvars.coord, stim.scale, 0,  trialvars.col)  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
        end
    end
    
elseif page == 4
    PsychDrawSprites2D(windowPtr, texture.stim(1),  [620 420], 2.5, 0,  [set.stim.colours(1,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);

elseif page == 5 || page == 6 || page == 7
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [520 420], 2.5, 0,  [set.stim.colours(1,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [720 420], 2.5, 0,  [set.stim.colours(1,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);

elseif page == 9
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [520 270], 1.5, 0,  [set.stim.colours(1,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [720 270], 1.5, 0,  [set.stim.colours(1,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    
    PsychDrawSprites2D(windowPtr, texture.stim(4),  [520 600], 1.5, 0,  [set.stim.colours(1,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(5),  [720 600], 1.5, 0,  [set.stim.colours(1,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);

elseif page == 11
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [540 270], 1.0, 0,  [set.stim.colours(1,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [700 270], 1.0, 0,  [set.stim.colours(1,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [420 520], 1.0, 0,  [set.stim.colours(2,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [553 520], 1.0, 0,  [set.stim.colours(2,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(4),  [686 520], 1.0, 0,  [set.stim.colours(2,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(5),  [820 520], 1.0, 0,  [set.stim.colours(2,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);

    PsychDrawSprites2D(windowPtr, texture.stim(4),  [540 680], 1.0, 0,  [set.stim.colours(1,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(5),  [700 680], 1.0, 0,  [set.stim.colours(1,:)'; 255])  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    

end


if page == 8
    % Display objects
    for ii_stim = 0:2
        % objects to draw (only targets)
        trialvars.idx_stimtype = ID.state(:,ii_frame, ii_block) == ii_stim; % find out if any of this stimulus type is active this frame.
        if ii_stim == 0
            trialvars.idx_stimtype = ismember(ID.state(:,ii_frame, ii_block), [0 3 4]); % find out if any of this stimulus type is active this frame.
        end
        % Only target colour
        targetcols = (ID.colours(1, :, ii_frame, ii_block) == 255) == (set.stim.colours(1,1) == 255);
        trialvars.idx_stimtype = trialvars.idx_stimtype & targetcols';
        
        if any(trialvars.idx_stimtype)
            trialvars.col = ID.colours(:, trialvars.idx_stimtype, ii_frame, ii_block);
            trialvars.coord = [-200+1.28*stim.COORDS_X(trialvars.idx_stimtype, ii_frame, ii_block)'; stim.COORDS_Y(trialvars.idx_stimtype, ii_frame, ii_block)'];
            PsychDrawSprites2D(windowPtr, texture.stim(ii_stim+1),  trialvars.coord, stim.scale, 0,  trialvars.col)  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
        end
    end
    
    % Display Frame
    Screen('DrawTexture', windowPtr, texture.frame, [0 0 1920 1080], [0 0 1920 1080]);
    
%     % Draw targets
%     PsychDrawSprites2D(windowPtr, texture.stim(2),  [960-50 1080-44], 0.5, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
%     PsychDrawSprites2D(windowPtr, texture.stim(3),  [960+50 1080-44], 0.5, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    % left
    Screen('TextFont',windowPtr, 'Courier New');
    Screen('TextStyle', windowPtr, 0);
    Screen('TextSize',windowPtr, 40);%20
    
    Screen('DrawText', windowPtr, 'TARGETS',  set.mon.res(1)-0.093*set.mon.res(1), set.mon.res(2)-0.95*set.mon.res(2), uint8([255 255 255]));
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [ set.mon.res(1)-0.035*set.mon.res(1), set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [ set.mon.res(1)-0.065*set.mon.res(1),  set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);

    % right
    Screen('DrawText', windowPtr, 'TARGETS',  0.009*set.mon.res(1), set.mon.res(2)-0.95*set.mon.res(2), uint8([255 255 255]));
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [0.065*set.mon.res(1), set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [0.035*set.mon.res(1),  set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);


end

if page == 10
    % Display objects
    for ii_stim = 0:4
        % objects to draw (only targets)
        trialvars.idx_stimtype = ID.state(:,ii_frame, ii_block) == ii_stim; % find out if any of this stimulus type is active this frame.

        % Only target colour
        targetcols = (ID.colours(1, :, ii_frame, ii_block) == 255) == (set.stim.colours(1,1) == 255);
        trialvars.idx_stimtype = trialvars.idx_stimtype & targetcols';
        
        if any(trialvars.idx_stimtype)
            trialvars.col = ID.colours(:, trialvars.idx_stimtype, ii_frame, ii_block);
            trialvars.coord = [-200+1.28*stim.COORDS_X(trialvars.idx_stimtype, ii_frame, ii_block)'; stim.COORDS_Y(trialvars.idx_stimtype, ii_frame, ii_block)'];
            PsychDrawSprites2D(windowPtr, texture.stim(ii_stim+1),  trialvars.coord, stim.scale, 0,  trialvars.col)  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
        end
    end
    
    % Display Frame
    Screen('DrawTexture', windowPtr, texture.frame, [0 0 1920 1080], [0 0 1920 1080]);
    
    % Draw targets
    Screen('DrawText', windowPtr, 'TARGETS',  set.mon.res(1)-0.093*set.mon.res(1), set.mon.res(2)-0.95*set.mon.res(2), uint8([255 255 255]));
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [ set.mon.res(1)-0.035*set.mon.res(1), set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [ set.mon.res(1)-0.065*set.mon.res(1),  set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);

    % right
    Screen('DrawText', windowPtr, 'TARGETS',  0.009*set.mon.res(1), set.mon.res(2)-0.95*set.mon.res(2), uint8([255 255 255]));
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [0.065*set.mon.res(1), set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [0.035*set.mon.res(1),  set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);

end


if page == 12
    % Display objects
    for ii_stim = 0:4
        % objects to draw (only targets)
        trialvars.idx_stimtype = ID.state(:,ii_frame, ii_block) == ii_stim; % find out if any of this stimulus type is active this frame.
        if any(trialvars.idx_stimtype)
            trialvars.col = ID.colours(:, trialvars.idx_stimtype, ii_frame, ii_block);
            trialvars.coord = [-200+1.28*stim.COORDS_X(trialvars.idx_stimtype, ii_frame, ii_block)'; stim.COORDS_Y(trialvars.idx_stimtype, ii_frame, ii_block)'];
            PsychDrawSprites2D(windowPtr, texture.stim(ii_stim+1),  trialvars.coord, stim.scale, 0,  trialvars.col)  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
        end
    end
    
    % Display Frame
    Screen('DrawTexture', windowPtr, texture.frame, [0 0 1920 1080], [0 0 1920 1080]);
    
    % Draw targets
    Screen('DrawText', windowPtr, 'TARGETS',  set.mon.res(1)-0.093*set.mon.res(1), set.mon.res(2)-0.95*set.mon.res(2), uint8([255 255 255]));
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [ set.mon.res(1)-0.035*set.mon.res(1), set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [ set.mon.res(1)-0.065*set.mon.res(1),  set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);

    % right
    Screen('DrawText', windowPtr, 'TARGETS',  0.009*set.mon.res(1), set.mon.res(2)-0.95*set.mon.res(2), uint8([255 255 255]));
    PsychDrawSprites2D(windowPtr, texture.stim(2),  [0.065*set.mon.res(1), set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    PsychDrawSprites2D(windowPtr, texture.stim(3),  [0.035*set.mon.res(1),  set.mon.res(2)-0.87*set.mon.res(2)], stim.scale*0.6, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);

end
