function prelim_analyse(DATA, Dkey, Didx, set)


DATA(:,Dkey.VBLTimestamp) = DATA(:,Dkey.VBLTimestamp) - DATA(1,Dkey.VBLTimestamp);
DATA(:,Dkey.FlipTimestamp) = DATA(:,Dkey.FlipTimestamp) - DATA(1,Dkey.FlipTimestamp);

settings = set;
% settings.n.blocks = 5;

DATA(DATA(:,Dkey.BLOCK)>settings.n.blocks,:) = [];
clear set;


%% Extract responses for HMM
resptimes = [];
respdiffs = [];
respstates = [];
targtimes = [];
targdiffs = [];
targstates = [];

for ii_block = 1:settings.n.blocks
    % Block variables
    idx = Didx(:,ii_block);
    
    % get indices of responses
    respindices = sort([find(diff([0 ; DATA(idx,Dkey.response(1))])>0); find(diff([0 ; DATA(idx,Dkey.response(2))])>0)]);
    
    % assign responses
    resptimes = [resptimes; DATA(idx(respindices),Dkey.VBLTimestamp)];
    respdiffs = [respdiffs; 6; diff( DATA(idx(respindices),Dkey.VBLTimestamp))];
    respstates = [respstates; DATA(idx(respindices),Dkey.HMMstates)];
    
    % Get indices of targets
    targindices = sort(find(DATA(idx,Dkey.target_isonsetframe)));
    
    % assign targets
    targtimes = [targtimes; DATA(idx(targindices),Dkey.VBLTimestamp)];
    targdiffs = [targdiffs; 6; diff(DATA(idx(targindices),Dkey.VBLTimestamp))];
    targstates = [targstates; DATA(idx(targindices),Dkey.HMMstates)];
    
end

figure; subplot(2,1,1); plot(targstates); subplot(2,1,2); plot(targdiffs)
figure; subplot(2,1,1); plot(respstates); subplot(2,1,2); plot(respdiffs)

% save([direct.results 'HMMResponses2.mat'], 'targdiffs', 'targtimes', 'respdiffs', 'resptimes')
%% Extract responses

% get indices of responses
responses_idx = []; % response frame, response time, response type
for ii_resptype = 1:2
    responseframes = find(diff([0 ; DATA(:,Dkey.response(ii_resptype))])>0);
    responses_idx = [responses_idx; responseframes DATA(responseframes,Dkey.VBLTimestamp) ones(length(responseframes),1).*ii_resptype];
end


%% Loop through  events. 

% Get targets
targetonsetframes = find(DATA(:,Dkey.target_isonsetframe));
targets_idx = [targetonsetframes DATA(targetonsetframes,Dkey.VBLTimestamp) DATA(targetonsetframes,Dkey.target_type) ]; % response frame, response time, response type
 
% Assign target properties
targetwise.resptype = zeros(length(targets_idx), 1); % 0 = miss, 1 = hit- correct, 2 = hit - incorrect, 3 = false alarm. 
targetwise.targtime = DATA(targetonsetframes,Dkey.VBLTimestamp) ; % 0 = miss, 1 = hit- correct, 2 = hit - incorrect, 3 = false alarm. 
targetwise.BLOCK = DATA(targetonsetframes,Dkey.BLOCK) ; % 0 = miss, 1 = hit- correct, 2 = hit - incorrect, 3 = false alarm. 
targetwise.RT = NaN(length(targets_idx), 1);
targetwise.saturation = DATA(targetonsetframes,Dkey.saturation);
targetwise.speed = DATA(targetonsetframes,Dkey.target_speed);
targetwise.xcoord = DATA(targetonsetframes,Dkey.target_coordsx);
targetwise.ycoord = DATA(targetonsetframes,Dkey.target_coordsy);
targetwise.HMMstate = DATA(targetonsetframes,Dkey.HMMstates);

% Assign response properties
responsewise.resptype = NaN(length(responses_idx), 1); % for tracking false alarms
responsewise.time = responses_idx(:,2); % for tracking false alarms
responsewise.BLOCK =  DATA(responses_idx(:,1),Dkey.BLOCK); % for tracking false alarms
responsewise.HMMstate =  DATA(responses_idx(:,1),Dkey.HMMstates);

% Assign response types and timing contraints
resp.miss = 0; resp.hitCorrect = 1; resp.hitIncorrect =2; resp.falsealarm=3;
s.resptimeframe = 2; %2 seconds to respond to each target.

% Loop through responses. 
for ii_resp = 1:length( responses_idx )
    resp_val =  responses_idx(ii_resp, 3);
    resp_time = responses_idx(ii_resp, 2);

    % find any targets this response might be to.
    resptimeframe = [resp_time - 1.5, resp_time-0.5]; % valid timeframe
    valid = targets_idx(:,2)>resptimeframe(1) & targets_idx(:,2)<resptimeframe(2);
    
    if any(valid)% Assign valid responses (hits)
        idx = find(valid);
        if targets_idx(idx, 3) == resp_val %correct
            responsewise.resptype(ii_resp) = resp.hitCorrect;
            targetwise.resptype(idx) = resp.hitCorrect;
            targetwise.RT(idx) = resp_time - targets_idx(idx, 2);
            
        else %incorrect
            responsewise.resptype(ii_resp) =resp.hitCorrect;
            targetwise.resptype(idx) = resp.hitCorrect;
            targetwise.RT(idx) = resp_time - targets_idx(idx, 2);
        end
    else % Assign invalid responses (falsealarms). 
        responsewise.resptype(ii_resp) = resp.falsealarm;
    end
end

%% Plot targetonsets
dat = diff(targetwise.targtime)
dat = diff(responsewise.time)
dat(dat>200) = [];
dat(dat<-200) = [];
figure;
hist(dat)
% xlim([0 10])
% 
% dat = normrnd(8, 1,1000,1);
% figure;
% hist(dat)
% xlim([0 10])

%% Plot responses over time (stem plot)

h = figure;
for ii_block = 1:settings.n.blocks
    subplot(2,2,ii_block); hold on;
    tmp = DATA(Didx(:,ii_block), Dkey.VBLTimestamp)./60;
    imagesc(tmp, 0:5, DATA(Didx(:,ii_block), Dkey.saturation)')
    colormap(bone)
    hold on;
    idx_resp = responsewise.BLOCK ==ii_block;
    ii_targ = targetwise.BLOCK == ii_block;
    stem(responsewise.time(responsewise.resptype==3 & idx_resp)./60, responsewise.resptype(responsewise.resptype==3 & idx_resp), 'mo');
    stem(targetwise.targtime(targetwise.resptype==1 &  ii_targ)./60, targetwise.resptype(targetwise.resptype==1 &  ii_targ), 'go');
    stem(targetwise.targtime(targetwise.resptype==2 &  ii_targ)./60, targetwise.resptype(targetwise.resptype==2 &  ii_targ), 'yo');
    stem(targetwise.targtime(targetwise.resptype==0 &  ii_targ)./60, targetwise.resptype(targetwise.resptype==0 &  ii_targ), 'co');
    
    ylim([-1 3.5])
    xlim([tmp(1) tmp(end)])
    xlabel('Time (minutes)')
    ylabel('Response occured')
    title(['Block: ' num2str(ii_block)])
    
    plot(tmp, DATA(Didx(:,ii_block), Dkey.HMMstates).*0.8 - 1, '-b', 'linewidth', 2)
end

legend({'fase alarm' 'correct' 'incorrect' 'miss' 'target duration'})

% saveas(h, [direct.results 'behaveoverview.png'])

%% Reaction time over time

h = figure; 
plot(targetwise.targtime(targetwise.resptype==resp.hitCorrect), targetwise.RT(targetwise.resptype==resp.hitCorrect), '-x')
ylabel('RT (s)')
xlabel('Time (mins)')
title('RT over time')

% saveas(h, [direct.results 'RToverview.png'])


%% Plot results by time in block

num_splits = 5;
Twise.hits = NaN(settings.n.blocks,num_splits);
Twise.incorrect  = NaN(settings.n.blocks,num_splits);
Twise.misses = NaN(settings.n.blocks,num_splits);

for ii_block = 1:settings.n.blocks
    % splitdetails
    idx_block = find(targetwise.BLOCK == ii_block);
    num_targssplit = floor(length(idx_block)/num_splits);
    
    % loop
    for ii_split = 1:num_splits
        idx_split = (1:num_targssplit) + num_targssplit*(ii_split-1);
        idxuse = idx_block(idx_split);

        Twise.hits(ii_block, ii_split) = sum(targetwise.resptype(idxuse)==resp.hitCorrect)/ (sum(targetwise.resptype(idxuse)==resp.miss) + sum(targetwise.resptype(idxuse)==resp.hitCorrect));
        Twise.incorrect(ii_block, ii_split) = sum(targetwise.resptype(idxuse)==resp.hitIncorrect);
        Twise.misses(ii_block, ii_split) = sum(targetwise.resptype(idxuse)==resp.miss);
    end
end

%% Plot time in block
h = figure; 

colors = [0 0 1
%     .4 .4 .8
    .4 .7 .5
%     .7 .7 .4
    .8 .7 .1
%     0 0 1
    .4 .4 .8
%     .4 .7 .5
    .7 .7 .4
    .8 .7 .1];
twisefields = {'hits' 'misses'};
for ii_measure = 1%:length(twisefields)
    subplot(1,1,ii_measure)
    hold on;
    for block = 1:settings.n.blocks
        plot((1:num_splits) + (num_splits*(block-1)), Twise.(twisefields{ii_measure})(block,:)', '-o', 'color', colors(block,:), 'linewidth', 2)% 'facecolor', 'k')
    end
    title(twisefields{ii_measure})
    legend({'block 1' 'block 2' 'block 3' 'block 4'}, 'Location', 'NorthEast')
    xlabel('time in block')
end

% saveas(h, [direct.results 'Behave_bytimeinblock.png'])


%% Plot time in block
h = figure; 

twisefields = {'hits' 'misses'};
for ii_measure = 1:length(twisefields)
    subplot(1,2,ii_measure)

    plot(1:num_splits, mean(Twise.(twisefields{ii_measure}),1), '-o', 'color', colors(1,:), 'linewidth', 2)% 'facecolor', 'k')

    title(twisefields{ii_measure})
    xlabel('Time in block (chunks)')
    ylabel('Count')
end

% saveas(h, [direct.results 'Behave_bytimeinblock_mean.png'])


%% Get Blockwise results

Bwise.RT = NaN(settings.n.blocks,1);
Bwise.RTSTD = NaN(settings.n.blocks,1);
Bwise.hits = NaN(settings.n.blocks,1);
Bwise.incorrect  = NaN(settings.n.blocks,1);
Bwise.misses = NaN(settings.n.blocks,1);
Bwise.falsealarms = NaN(settings.n.blocks,1);

for ii_block = 1:settings.n.blocks
    Bwise.RT(ii_block) = mean(targetwise.RT(targetwise.resptype==resp.hitCorrect & targetwise.BLOCK == ii_block));
    Bwise.RTSTD(ii_block) =std(targetwise.RT(targetwise.resptype==resp.hitCorrect & targetwise.BLOCK == ii_block));
    
    Bwise.hits(ii_block) = sum(targetwise.resptype==resp.hitCorrect & targetwise.BLOCK == ii_block) / sum(targetwise.BLOCK == ii_block);
    Bwise.incorrect(ii_block) = sum(targetwise.resptype==resp.hitIncorrect & targetwise.BLOCK == ii_block)/ sum(targetwise.BLOCK == ii_block);
    Bwise.misses(ii_block) = sum(targetwise.resptype==resp.miss & targetwise.BLOCK == ii_block)/ sum(targetwise.BLOCK == ii_block);
    Bwise.falsealarms(ii_block) = sum(responsewise.resptype==resp.falsealarm & responsewise.BLOCK == ii_block)/ sum(responsewise.BLOCK == ii_block);

end


%% Plot blockwise results
h = figure; 

bwisefields = fields(Bwise);
for ii_measure = 1:length(bwisefields)
    subplot(3,2,ii_measure)
    plot(1:settings.n.blocks, Bwise.(bwisefields{ii_measure})*100, 'k-o')%facecolor', 'k')
    if ii_measure > 2
        ylabel('%')
    else
        ylabel('ms')
    end
    title(bwisefields{ii_measure})
    xlabel('Block #')
end

% saveas(h, [direct.results 'Behave_byblock.png'])

%% Plot effects of saturation

h = figure;
measure = {'saturation' 'speed' 'ycoord' 'xcoord'};

nedges = [6 6 6 6];
for ii_measure = 1:length(measure)
    
    subplot(2,2,ii_measure)
    % hist(targetwise.(measure)(targetwise.resptype==resp.hitCorrect))./hist(targetwise.(measure))
    [N,edges] = histcounts(targetwise.(measure{ii_measure})(targetwise.resptype==resp.hitCorrect),nedges(ii_measure));
    [N2,edges2] = histcounts(targetwise.(measure{ii_measure}), edges);
    tmp = movmean(edges,2);
    plot(tmp(2:end), N./N2, '-ko')%, 'facecolor',  'k')
    xlabel(measure{ii_measure})
    ylabel('number of hits/number of events')
end

% saveas(h, [direct.results 'factor_effects.png'])

%% 2d histogram of coordinates

h = figure;
histogram2(targetwise.xcoord(targetwise.resptype==resp.hitCorrect), targetwise.ycoord(targetwise.resptype==resp.hitCorrect), 5, 'FaceColor','b', 'ShowEmptyBins', 'on' )
xlabel('xcoords')
ylabel('ycoords')
% set(gca, 'ydir', 'reverse')
% settings(gcf,'view',[90 -90])
% saveas(h, [direct.results 'hist.png'])


%% Plot false alarm rate according to switch duration

states = [0 1];

shortswitch = sum(responsewise.resptype(responsewise.HMMstate == states(1))==resp.falsealarm);
longswitch = sum(responsewise.resptype(responsewise.HMMstate == states(2))==resp.falsealarm);

shortswitch = sum(responsewise.resptype(responsewise.HMMstate ==  states(1))==resp.hitCorrect);
longswitch = sum(responsewise.resptype(responsewise.HMMstate ==  states(2))==resp.hitCorrect);

%% Switch duration
switchwise.falsealarms = NaN( settings.n.blocks, 2);
switchwise.hits = NaN( settings.n.blocks, 2);
switchwise.miss = NaN( settings.n.blocks, 2);
switchwise.incorrect = NaN( settings.n.blocks, 2);


for ii_block = 1:settings.n.blocks
    % false alarms
    idx_short = responsewise.BLOCK ==ii_block & responsewise.HMMstate ==0;
    idx_long = responsewise.BLOCK ==ii_block & responsewise.HMMstate ==1;
    
    switchwise.falsealarms(ii_block,1) = sum(responsewise.resptype(idx_short)==resp.falsealarm)/sum(idx_short);
    switchwise.falsealarms(ii_block,2) = sum(responsewise.resptype(idx_long)==resp.falsealarm)/sum(idx_long);
    
    % hits, misses and incorrect
    idx_short = targetwise.BLOCK ==ii_block & targetwise.HMMstate ==0;
    idx_long = targetwise.BLOCK ==ii_block & targetwise.HMMstate ==1;
    
    switchwise.hits(ii_block,1) = sum(targetwise.resptype(idx_short)==resp.hitCorrect)/sum(idx_short);
    switchwise.hits(ii_block,2) = sum(targetwise.resptype(idx_long)==resp.hitCorrect)/sum(idx_long);
    
    switchwise.miss(ii_block,1) = sum(targetwise.resptype(idx_short)==resp.miss)/sum(idx_short);
    switchwise.miss(ii_block,2) = sum(targetwise.resptype(idx_long)==resp.miss)/sum(idx_long);
    
    switchwise.incorrect(ii_block,1) = sum(targetwise.resptype(idx_short)==resp.hitIncorrect)/sum(idx_short);
    switchwise.incorrect(ii_block,2) = sum(targetwise.resptype(idx_long)==resp.hitIncorrect)/sum(idx_long);

end

% Plor results
str.switchlife = {'0' '1'};

h = figure; 
subplot(2,2,1)
errorbar(nanmean(switchwise.falsealarms), std(switchwise.falsealarms)./sqrt(settings.n.blocks))
xlim([0 3])
set(gca, 'xtick', [1 2], 'xticklabel', str.switchlife)
ylabel('% False alarms')
xlabel('Switch Duration')

subplot(2,2,2)
errorbar(nanmean(switchwise.miss*100), std(switchwise.miss*100)./sqrt(settings.n.blocks))
xlim([0 3])
set(gca, 'xtick', [1 2], 'xticklabel', str.switchlife)
ylabel('% misses')
xlabel('Switch Duration')

subplot(2,2,3)
errorbar(nanmean(switchwise.hits*100), std(switchwise.hits*100)./sqrt(settings.n.blocks))
xlim([0 3])
set(gca, 'xtick', [1 2], 'xticklabel', str.switchlife)
ylabel('% hits')
xlabel('Switch Duration')

subplot(2,2,4)
errorbar(nanmean(switchwise.incorrect*100), std(switchwise.incorrect*100)./sqrt(settings.n.blocks))
xlim([0 3])
set(gca, 'xtick', [1 2], 'xticklabel', str.switchlife)
ylabel('% incorrect')
xlabel('Switch Duration')

% saveas(h, [direct.results 'switchduration_effects.png'])

% vigilence decrement by block 

h = figure; 
plot(1:settings.n.blocks, switchwise.hits*100, '-x')
set(gca, 'xtick', 1:settings.n.blocks)
ylabel('% Correct')
xlabel('Block #')
title('Hits by block and switchlife')
legend(str.switchlife)
% saveas(h, [direct.results 'switchduration_effectsBW.png'])
