% # Situations handled 
% - when there's a response
%       - Was there a target before it? Y/N 
%       - Has this target already been responded to?
% - When there's a target 
%       - Was there no response after it? 

punishval = -1.4;
%% Points calc when there's been a response
if DATA(Didx(ii_frame, ii_block), Dkey.responseframe) % Has there been a response?
    
   % Define the requisite pre-response period?
   targetsearchperiod = (ii_frame - set.f.responsedeadline +1) : (ii_frame - set.f.minrt);
   targetsearchperiod = targetsearchperiod(targetsearchperiod>0); % Correct for very early responses in the block
    
   % Has there been a target in the requisite pre-response period?
   targetpresence = DATA(Didx(targetsearchperiod, ii_block), Dkey.target_isonsetframe);
   
   if any(targetpresence) % yes?
       % has there already been a response since this target happened?
       framessincetarget = targetsearchperiod(find(targetpresence):end);
       prevresponsetotarg = DATA(Didx(framessincetarget, ii_block), Dkey.responseframe);
       
       % If this is the first time the person is responding to this target, give them points!
       if ~any(prevresponsetotarg) 
            DATA(Didx(ii_frame, ii_block), Dkey.points) = 1;
%             disp(['Frame: ' num2str(ii_frame) ' | hit'])
       else % they've already responded to this target! Take there points away!
            DATA(Didx(ii_frame, ii_block), Dkey.points) = punishval;
%             disp(['Frame: ' num2str(ii_frame) ' | another response to same target'])
       end
   else % This is a false alarm, take points away!
        DATA(Didx(ii_frame, ii_block), Dkey.points) = punishval;
%         disp(['Frame: ' num2str(ii_frame) ' | false alarm'])
   end

%% Points calc when there's been a target
elseif DATA(Didx(ii_frame, ii_block), Dkey.target_respdeadlineframe) % Is it the target response deadline?
    
   % Define the requisite post-target period?
   targetsearchperiod = (ii_frame - set.f.responsedeadline +1) : ii_frame;
    
   % Has there been a response in the requisite post-target period?
   if ~any(DATA(Didx(targetsearchperiod, ii_block), Dkey.responseframe)) % ZThis is a miss, take points away
       DATA(Didx(ii_frame, ii_block), Dkey.points) = punishval;
%        disp(['Frame: ' num2str(ii_frame) ' | miss'])
   end
end

%% Calculate cumulative cash

%     while 1
%     if set.nf.port.BytesAvailable > 0
%         [fread(set.nf.port, set.nf.port.BytesAvailable) set.nf.port.BytesAvailable]
%         [A,count] = fread(set.nf.port,inf)
%     end
%     end

while set.nf.port.BytesAvailable > 0
    set.nf.feedback=fread(set.nf.port, set.nf.port.BytesAvailable);
end


    
feedbackval = set.nf.feedback/100;
feedbackval(feedbackval<0.5) = 0.5;
feedbackval = (feedbackval-0.5)/0.5;

if DATA(Didx(ii_frame, ii_block), Dkey.points) < 1
    feedbackval = 1-feedbackval;
end
cashpoints = (DATA(Didx(ii_frame, ii_block), Dkey.points)*feedbackval)/25;

disp([set.nf.feedback, cashpoints])

if ii_frame>1 % Add point differences
     DATA(Didx(ii_frame, ii_block), Dkey.cumpoints) = DATA(Didx(ii_frame-1, ii_block), Dkey.cumpoints) + cashpoints;
elseif ii_block>1 % % get points from the end of last block
     DATA(Didx(1, ii_block), Dkey.cumpoints) =  DATA(Didx(end, ii_block-1), Dkey.cumpoints);
end


%% Present feedback

if ~options.preNF 
    cashval = DATA(Didx(ii_frame, ii_block), Dkey.cumpoints) + 10;

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


    Screen('DrawingFinished', windowPtr);
end

% figure(); hold on;
% plot(DATA(Didx(:, ii_block), Dkey.response) )
% plot(DATA(Didx(:, ii_block), Dkey.responseframe) )
% plot(DATA(Didx(:, ii_block), Dkey.target_respdeadlineframe) )
