
% Check on responses
[~, ~, trialvars.keyCode, ~] = KbCheck();
if trialvars.keyCode( set.key.response)
     DATA(ii_frame, Dkey.responsepressed) =1;
end

% get precise frame that responses happend on
if ii_frame > 1
    DATA(ii_frame, Dkey.responseonset) = (DATA(ii_frame, Dkey.responsepressed)  - DATA(ii_frame-1, Dkey.responsepressed))>0 ;
end

% Has there been a response?
if DATA(ii_frame, Dkey.responseonset) 
   % Define the requisite pre-response period?
   targetsearchperiod = (ii_frame - f.resptime +1) : (ii_frame - set.f.minrt);
   targetsearchperiod = targetsearchperiod(targetsearchperiod>0); % Correct for very early responses in the block

   % Has there been a target in the requisite pre-response period?
   targetpresence = DATA(targetsearchperiod, Dkey.target_isonsetframe);

   % Store response data
   if any(targetpresence) % yes?           
        DATA(ii_frame, Dkey.responseacc) = 1; % it's a hit
        targetloc = find(targetpresence);
        DATA(targetsearchperiod(targetloc), Dkey.responseacc) = nan; % it's not a miss!             
   else % No?
        DATA(ii_frame, Dkey.responseacc) = 2; % it's a false alarm
   end

   % Display feedback
   feedbackframes = ii_frame:(ii_frame + f.tick); % display feedback for 1 sec
   feedbackrames = feedbackframes(feedbackframes<f.task); % correct for late responses
   if  DATA(ii_frame, Dkey.responseacc) == 1
       DATA(feedbackrames , Dkey.goodresp_displayed) = 1;
   else
       DATA(feedbackrames , Dkey.badresp_displayed) = 1;
   end

end
