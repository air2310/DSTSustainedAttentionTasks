function [ID, DATA, Dkey] = setupSwitches(set, stim, DATA, Didx, Dkey, options)
%setupSwitches: Setup the type and timing of the switches - both target and
%distractor
%
%   Inputs:
%       options - Options for how the experiment is run
%       stim - stimulus properties
%       set - settings for the experiment structure
%       DATA - updated DATA
%       Didx - indices of frames in blocks
%       Dkey - Key for columns in DATA
%       options - optional settings
%
%   Outputs:
%       ID - ID structure describing each of the individual objects:
%           state - what state are they in, i.e. what letter are they
%           representing? what colour are they right now?



%% Extract settings for this function
mon = set.mon;
n = set.n;
f = set.f;
s = set.s;
disp('Setting up transformations')

%% Stimulus colours
Dkey.metadata.objectcolour = repmat([1:n.colours]', n.objs_colour,1);

%% Switches
% TODO: Generate more events to account for too few states 0s. 

switchlist = cell(2,1);
switchlist{1} = [];
switchlist{2} = [];

% Loop through target and distractor colour
for CC = 1:n.colours
    load(['stimuli\HMM_targettimes_col' num2str(CC) '\HMM_targettimes' num2str(set.SUBID) '.mat']);
    n_events = length(HMMstates);
    HMMtargets = cat(2, HMMtargets, HMMtargets);
    HMMdistracts0 = cat(2, HMMdistracts0,HMMdistracts0);
    HMMdistracts1 = cat(2, HMMdistracts1,HMMdistracts1);
    HMMstates = cat(2, HMMstates,HMMstates);
    % Iterate througg=h differences in time between envents to get event times.
    
    targ_times = HMMtargets(1,:);
    distractimes_0  = HMMdistracts0(1,:);
    distractimes_1  =HMMdistracts0(2,:);
    
    for ii_event = 2:n_events
        targ_times = [targ_times; targ_times(ii_event-1,:)+ HMMtargets(ii_event,:)];
        distractimes_0 = [distractimes_0; distractimes_0(ii_event-1,:)+ HMMdistracts0(ii_event,:)];
        distractimes_1 = [distractimes_1; distractimes_1(ii_event-1,:)+ HMMdistracts1(ii_event,:)];
    end
    
    % setup all frames search
    for ii_block = 1:n.blocks
        % Get target times to get states to cut off.
        f_targtimes = targ_times(:,ii_block )*mon.ref;
        idxin = f_targtimes<=(f.block - max(f.switchlife)*2);
        
         % Assign statechanges to DATA structure
        tmpstate = [];
        statechanges = find(diff(HMMstates(idxin, ii_block))~=0);
        startsf = [0;  round(f_targtimes(statechanges))];
        stopsf = [ round(f_targtimes(statechanges)); f.block];
        states = HMMstates([1; statechanges+1], ii_block);
        for ii_change = 1:length(startsf)
           tmpstate = [tmpstate; int32(ones(length(startsf(ii_change):stopsf(ii_change)-1),1))*states(ii_change)];
        end
        DATA(Didx(:,ii_block), Dkey.HMMstates) = tmpstate;
    
        % Get corresponding state changes
        statechanges = find(diff(HMMstates(idxin, ii_block))~=0);
        starts = [0; targ_times(statechanges,ii_block )];
        stops = [targ_times(statechanges,ii_block ); s.block - max(s.switchlife)*2];
        states = HMMstates([1; statechanges+1], ii_block);

        % Iterate through state changes to find corresponding distractors.
        distract_times = [];
        for ii_change = 1:length(starts)
            switch states(ii_change)
                case 1
                    tmp = distractimes_0(distractimes_0(:,ii_block) >= starts(ii_change) & distractimes_0(:,ii_block) < stops(ii_change), ii_block);
                case 0
                    tmp = distractimes_1(distractimes_1(:,ii_block) >= starts(ii_change) & distractimes_1(:,ii_block) < stops(ii_change), ii_block);
            end
            distract_times = [distract_times; tmp];
        end
        
%         % Plot
%         h = figure;
%         subplot(3,1,1)
%         stem(targ_times(idxin, ii_block), ones(length(targ_times(idxin, ii_block)),1), 'b')
%         title('Targets')
%         subplot(3,1,2)
%         stem(distract_times, ones(length(distract_times),1)*0.9, 'r')
%         title('Distractors')
%         subplot(3,1,3)
%         plot(targ_times(idxin, ii_block), HMMstates(idxin,ii_block))
%         title('States')
%         suptitle(['Block: ' num2str(ii_block)])
        
        % assign to switchlist
        % BLOCK, FRAME, VALUE
        n_targs = length(f_targtimes(idxin ));
        targs = [ones(n_targs,1)'.*ii_block, % block number
            round(f_targtimes(idxin ))', % frames
            randsrc(n_targs, 1,[1 2 ; 0.5 0.5])']'; % random choice between the two target types
        
        n_dists = length(distract_times);
        dists = [ones(n_dists,1)'.*ii_block, % block number
            round(distract_times*mon.ref)', % frames
            randsrc(n_dists, 1,[3 4 ; 0.5 0.5])']'; % random choice between the two distractors
        
        switchlist{CC} =  [switchlist{CC}; [targs; dists]];
    end
end

%% Assign the actual switches to stimuli

% Preallocate
ID.state = zeros(n.objs_total, f.block, n.blocks); %0 = mask, 1 = targetA, 2 = targetB, 3 = distractorA, 4 = distractorB.

for CC = 1:n.colours
    subsample = find(Dkey.metadata.objectcolour == CC);
    
    % which object will switch?
    for ii = 1:length(switchlist{CC})
        % Switch timing parameters
        switchTYPE = switchlist{CC}(ii,3);
        switchFRAME = switchlist{CC}(ii,2);
        switchBLOCK = switchlist{CC}(ii,1);
        
        switchDURATION = DATA(Didx(switchFRAME, switchBLOCK),Dkey.switchduration);
        
        switchLIFE = switchFRAME : switchFRAME + switchDURATION -1;
        preswitchclean = (switchFRAME-f.preswitchclean + 1) : switchFRAME;
        preswitchclean(preswitchclean<1) = [];
        
        % Which objects pass out of frame during the switch period (respawn)?
        respawned = any(stim.COORDS_Y(subsample, switchLIFE, switchBLOCK)' < stim.bounds(2) | stim.COORDS_Y(subsample, switchLIFE, switchBLOCK)' > stim.bounds(4));
        
        % Which objects switched during the clean period before the switch?
        % (We can't have things immediately re-switching)
        unclean = any(ID.state(subsample, preswitchclean)'~=0);
        
        % Which objects are eligible to switch?
        try
            eligible = ~respawned & ~unclean;
            % Select from the eligible
            stim2switch = randsample(find(eligible),1);
        catch % If there are no unclean ones, I suppose we can double switch.
            disp('n.b. had to put two events close together in time in the same object')
            eligible = ~respawned ;
            % Select from the eligible
            stim2switch = randsample(find(eligible),1);
        end
        
        %Allocate it!
        ID.state(subsample(stim2switch), switchLIFE, switchBLOCK) = switchTYPE ;
        
        % DATA Structure things
        if CC == 1 && ismember(switchTYPE, [1 2]) % Target
            DATA(Didx(switchFRAME, switchBLOCK), Dkey.target_isonsetframe) = 1;
            DATA(Didx(switchLIFE, switchBLOCK), Dkey.target_type) = switchTYPE;
            DATA(Didx(switchLIFE, switchBLOCK), Dkey.target_ID) = subsample(stim2switch);
            DATA(Didx(switchLIFE, switchBLOCK), Dkey.target_coordsx) = stim.COORDS_X(subsample(stim2switch), switchLIFE, switchBLOCK);
            DATA(Didx(switchLIFE, switchBLOCK), Dkey.target_coordsy) = stim.COORDS_Y(subsample(stim2switch), switchLIFE, switchBLOCK);
            DATA(Didx(switchLIFE, switchBLOCK), Dkey.target_speed) = stim.speed(subsample(stim2switch));

        end
    end
end

%% Saturation manipulation

% assign colours to objects
colours = nan(n.objs_total, 3);
colours(Dkey.metadata.objectcolour==1, :) = repmat(stim.colours(stim.target,:), n.objs_colour,1);
colours(Dkey.metadata.objectcolour==2, :) = repmat(stim.colours(stim.distractor,:), n.objs_colour,1);

% colours in hsv
hsvcols = rgb2hsv(colours./255);

rampup = uint8(linspace(0, 255, mon.ref));
% Manipulate saturation for each frame
ID.colours = NaN(4, n.objs_total, f.block, n.blocks);
for BLOCK = 1:n.blocks
    for FRAME = 1:f.block
        saturation2use = DATA(Didx(FRAME, BLOCK),Dkey.saturation);
        
        hsvcols(:,2) = DATA(Didx(FRAME, BLOCK),Dkey.saturation);
        ID.colours(1:3, :, FRAME, BLOCK) = uint8(hsv2rgb(hsvcols).*255)';
        
    end
    
    % set transparency for block onset and offset
    ID.colours(4, :, :, BLOCK) = 255;
    ID.colours(4, :, 1:mon.ref, BLOCK) = repmat(rampup, n.objs_total,1);
    ID.colours(4, :, f.block-mon.ref+1:f.block, BLOCK) = repmat(fliplr(rampup), n.objs_total,1);
end

%% Set the flicker

if options.flicker
    for BLOCK = 1:n.blocks
        % target
        orig =ID.colours(1:3, Dkey.metadata.objectcolour==1, :, BLOCK);
        mod = permute(repmat(DATA(Didx(:, BLOCK),Dkey.flicker_target), 1, 15, 3), [3 2 1]);
        ID.colours(1:3, Dkey.metadata.objectcolour==1, :, BLOCK) = orig.*mod;
        
        % distractor
        orig =ID.colours(1:3, Dkey.metadata.objectcolour==2, :, BLOCK);
        mod = permute(repmat(DATA(Didx(:, BLOCK),Dkey.flicker_distract), 1, 15, 3), [3 2 1]);
        ID.colours(1:3, Dkey.metadata.objectcolour==2, :, BLOCK) = orig.*mod;
    end
end

%% Perform colour lookup correction
% 
% % Load CLUT 
% load([set.direct.stimuli 'CLUT.mat'], 'CLUT', 'CLUT_idx')
% 
% idx_colval = {[1 2], 3};
% idx_colvalclut = [3 2];
% 
% for BLOCK = 1:n.blocks
%     for FRAME = 1:f.block
%         % target
%         orig = ID.colours(:, Dkey.metadata.objectcolour==1, FRAME, BLOCK);
%         [~,val] = min(abs(CLUT(:,idx_colvalclut(stim.target)) - orig(idx_colval{stim.target}(1),1)));
%         
%         ID.colours(idx_colval{stim.target}, Dkey.metadata.objectcolour==1, FRAME, BLOCK) = val;
%         
%         % distract
%         orig = ID.colours(:, Dkey.metadata.objectcolour==1, FRAME, BLOCK);
%         [~,val] = min(abs(CLUT(:,idx_colvalclut(stim.distractor)) - orig(idx_colval{stim.distractor}(1),1)));
%         
%         ID.colours(idx_colval{stim.distractor}, Dkey.metadata.objectcolour==1, FRAME, BLOCK) = val;
%         
%     end
% end

%% Plot ycoords
% 
% figure; 
% plot( DATA(:, Dkey.target_coordsy))
% xlabel('time')
% ylabel('target y coord')

end