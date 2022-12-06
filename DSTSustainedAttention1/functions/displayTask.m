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

% Display objects
for ii_stim = 0:4
    trialvars.idx_stimtype = ID.state(:,ii_frame, ii_block) == ii_stim; % find out if any of this stimulus type is active this frame.
    if any(trialvars.idx_stimtype)
        trialvars.col = ID.colours(:, trialvars.idx_stimtype, ii_frame, ii_block);
        trialvars.coord = [stim.COORDS_X(ID.state(:,ii_frame, ii_block) == ii_stim, ii_frame, ii_block)'; stim.COORDS_Y(ID.state(:,ii_frame, ii_block) == ii_stim, ii_frame, ii_block)'];
        PsychDrawSprites2D(windowPtr, texture.stim(ii_stim+1),  trialvars.coord, stim.scale, 0,  trialvars.col)  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
    end
end

% Display Frame
Screen('DrawTexture', windowPtr, texture.frame, [0 0 1920 1080], [0 0 1920 1080]);

% Draw targets
PsychDrawSprites2D(windowPtr, texture.stim(2),  [960-50 1080-44], 0.5, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
PsychDrawSprites2D(windowPtr, texture.stim(3),  [960+50 1080-44], 0.5, 0, stim.colours(set.stim.target,:))  %[, spriteScale=1][, spriteAngle=0][, spriteColor=white][, center2D=[0,0]][, spriteShader]);
