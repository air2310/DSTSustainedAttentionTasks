% function [DATA, trialvars] = checkResponses(DATA, Didx, Dkey, set, trialvars, ii_block, ii_frame)
% %checkResponses: Check keyboard for responses
% %   Inputs:
% %       DATA - updated DATA
% %       Didx - indices of frames in blocks
% %       Dkey - Key for columns in DATA
% %       set - settings for the experiment structure
% %       trialvars - Variables that shift frame to frame
% %       ii_block - block index
% %       ii_frame - frame index
% %
% %   Outputs:
% %       DATA - Add data for any responses people might have made
% %       trialvars - allow escape


% Check for responses
[~, ~, trialvars.keyCode, ~] = KbCheck();
DATA(Didx(ii_frame, ii_block), Dkey.response) = trialvars.keyCode( set.key.response);

% % play sound
% if ii_frame > 1
%     tmp = DATA(Didx(ii_frame, ii_block), Dkey.response)  - DATA(Didx(ii_frame-1, ii_block), Dkey.response) ;
%     if tmp(1)>0
%         sound(texture.sound.y, texture.sound.freq)
%     elseif tmp(2)>0
%         sound(texture.sound.y, texture.sound.freq*1.5)
%     end
% end
    
    
% Escape
if find(trialvars.keyCode) == set.key.esc
    trialvars.escaper = true;
end

% Pause
if find(trialvars.keyCode) == set.key.pause
    pause(0.4)
    trialvars.pauser = true;
    while trialvars.pauser
        [~, ~, trialvars.keyCode, ~] = KbCheck();
        if find(trialvars.keyCode) == set.key.pause
            pause(0.4)
            trialvars.pauser = false;
        end
    end
end

% end