% function [DATA] = flipper(set, windowPtr, DATA, Didx, Dkey, options, ii_block, ii_frame)
% %flipper: flip to screen and trigger!
% %
% %   Inputs:
% %       set - settings for the experiment structure
% %       windowPtr - psychtoolbox window pointer
% %       DATA - updated DATA
% %       Didx - indices of frames in blocks
% %       Dkey - Key for columns in DATA
% %       options - so we know whether or not to trigger
% %       ii_block - block index
% %       ii_frame - frame index
% %
% %   Outputs:
% %       DATA - Add data for fliptimes

% Flip
if ii_frame>1
    waitframes = 1;
    tdeadline=DATA(Didx(ii_frame, ii_block), Dkey.VBLTimestamp) * (waitframes - 0.5) * set.mon.ifi;
else
    tdeadline=0;
end
 
[DATA(Didx(ii_frame, ii_block), Dkey.VBLTimestamp), ~, DATA(Didx(ii_frame, ii_block), Dkey.FlipTimestamp)]  = Screen('Flip', windowPtr,tdeadline);

% Trigger
if options.trigger
    trig = DATA(Didx(ii_frame, ii_block),Dkey.trigger);
    io64(set.trig.ioObj, set.trig.address(2), trig) % EEG
%     io64(set.trig.ioObj, set.trig.address(1), trig) % Biopac

end

if options.eyetracking
    eyetrig = DATA(Didx(ii_frame, ii_block), Dkey.eyetracktrigs);
    if any( eyetrig)
        fwrite(set.trig.eyeport, num2str(eyetrig))
    elseif ii_frame == 1
        fwrite(set.trig.eyeport, '7')
    end
end


if options.eyetracking
    if ii_frame == 1
        fwrite(set.trig.eyeport, '1')
    elseif ii_frame == set.f.block
        fwrite(set.trig.eyeport, '2')
    end
end

% Movie
if options.movie
    tmp = Screen('GetImage', windowPtr);
    imageArray(:,:,:,ii_frame) = tmp(1:2:end, 1:2:end,:);
end
