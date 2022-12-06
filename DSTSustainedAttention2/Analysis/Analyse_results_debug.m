clear
clc
close all

%% Set directories
direct.data = 'C:\Users\uqarento\OneDrive\DSTR\Pilots\Pilot3\Results\';
direct.results = 'C:\Users\uqarento\OneDrive\DSTR\Pilots\Pilot3\Results\';
direct.data_eeg = 'C:\Users\uqarento\OneDrive\DSTR\Pilots\Pilot3\Results\eeg\';

%% Add toolboxes
addpath('C:\Users\uqarento\Documents\toolboxes\fieldtrip-20180422')

%% Load data. 

% load([direct.data 'BEHAVE_11-Nov-2021 09-56.mat'])
load([direct.data 'BEHAVE_08-Dec-2021 11-56'])

DATA(:,Dkey.VBLTimestamp) = DATA(:,Dkey.VBLTimestamp) - DATA(1,Dkey.VBLTimestamp);
DATA(:,Dkey.FlipTimestamp) = DATA(:,Dkey.FlipTimestamp) - DATA(1,Dkey.FlipTimestamp);

settings = set;
settings.n.blocks = 4;

DATA(DATA(:,Dkey.BLOCK)>4,:) = [];
clear set;

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
targetwise.switchduration = DATA(targetonsetframes,Dkey.switchduration);

% Assign response properties
responsewise.resptype = NaN(length(responses_idx), 1); % for tracking false alarms
responsewise.time = responses_idx(:,2); % for tracking false alarms
responsewise.BLOCK =  DATA(responses_idx(:,1),Dkey.BLOCK); % for tracking false alarms
responsewise.switchduration =  DATA(responses_idx(:,1),Dkey.switchduration); % for tracking false alarms

% Assign response types and timing contraints
resp.miss = 0; resp.hitCorrect = 1; resp.hitIncorrect =2; resp.falsealarm=3;
s.resptimeframe = 2; %2 seconds to respond to each target.

% Loop through responses. 
for ii_resp = 1:length( responses_idx )
    resp_val =  responses_idx(ii_resp, 3);
    resp_time = responses_idx(ii_resp, 2);

    % find any targets this response might be to.
    resptimeframe = [resp_time - 3, resp_time-0.15]; % valid timeframe
    valid = targets_idx(:,2)>resptimeframe(1) & targets_idx(:,2)<resptimeframe(2);
    
    if any(valid)% Assign valid responses (hits)
        idx = find(valid);
        if targets_idx(idx, 3) == resp_val %correct
            responsewise.resptype(ii_resp) = resp.hitCorrect;
            targetwise.resptype(idx) = resp.hitCorrect;
            targetwise.RT(idx) = resp_time - targets_idx(idx, 2);
            
        else %incorrect
            responsewise.resptype(ii_resp) =resp.hitIncorrect;
            targetwise.resptype(idx) = resp.hitIncorrect;
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
    
    plot(tmp, DATA(Didx(:,ii_block), Dkey.switchduration)./settings.mon.ref - 1, '-b', 'linewidth', 2)
end

legend({'fase alarm' 'correct' 'incorrect' 'miss' 'target duration'})

saveas(h, [direct.results 'behaveoverview.png'])

%% Reaction time over time

h = figure; 
plot(targetwise.targtime(targetwise.resptype==resp.hitCorrect), targetwise.RT(targetwise.resptype==resp.hitCorrect), '-x')
ylabel('RT (s)')
xlabel('Time (mins)')
title('RT over time')

saveas(h, [direct.results 'RToverview.png'])

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
    bar(1:settings.n.blocks, Bwise.(bwisefields{ii_measure})*100, 'facecolor', 'k')
    if ii_measure >2
        ylabel('%')
    else
        ylabel('ms')
    end
    title(bwisefields{ii_measure})
    xlabel('Block #')
end

saveas(h, [direct.results 'Behave_byblock.png'])

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
    bar(tmp(2:end), N./N2, 'facecolor', 'k')
    xlabel(measure{ii_measure})
    ylabel('number of hits/number of events')
end

saveas(h, [direct.results 'factor_effects.png'])

%% 2d histogram of coordinates

h = figure;
histogram2(targetwise.xcoord(targetwise.resptype==resp.hitCorrect), targetwise.ycoord(targetwise.resptype==resp.hitCorrect), 5, 'FaceColor','b', 'ShowEmptyBins', 'on' )
xlabel('xcoords')
ylabel('ycoords')
set(gca, 'ydir', 'reverse')
% settings(gcf,'view',[90 -90])
saveas(h, [direct.results 'hist.png'])


%% Plot false alarm rate according to switch duration

durations = unique(DATA(:, Dkey.switchduration));

shortswitch = sum(responsewise.resptype(responsewise.switchduration == durations(1))==resp.falsealarm);
longswitch = sum(responsewise.resptype(responsewise.switchduration == durations(2))==resp.falsealarm);

shortswitch = sum(responsewise.resptype(responsewise.switchduration == durations(1))==resp.hitCorrect);
longswitch = sum(responsewise.resptype(responsewise.switchduration == durations(2))==resp.hitCorrect);

shortswitch = sum(responsewise.resptype(responsewise.switchduration == durations(1))==resp.hitIncorrect);
longswitch = sum(responsewise.resptype(responsewise.switchduration == durations(2))==resp.hitIncorrect);

%% Switch duration
switchwise.falsealarms = NaN( settings.n.blocks, 2);
switchwise.hits = NaN( settings.n.blocks, 2);
switchwise.miss = NaN( settings.n.blocks, 2);
switchwise.incorrect = NaN( settings.n.blocks, 2);


for ii_block = 1:settings.n.blocks
    % false alarms
    idx_short = responsewise.BLOCK ==ii_block & responsewise.switchduration ==115;
    idx_long = responsewise.BLOCK ==ii_block & responsewise.switchduration ==216;
    
    switchwise.falsealarms(ii_block,1) = sum(responsewise.resptype(idx_short)==resp.falsealarm)/sum(idx_short);
    switchwise.falsealarms(ii_block,2) = sum(responsewise.resptype(idx_long)==resp.falsealarm)/sum(idx_long);
    
    % hits, misses and incorrect
    idx_short = targetwise.BLOCK ==ii_block & targetwise.switchduration ==115;
    idx_long = targetwise.BLOCK ==ii_block & targetwise.switchduration ==216;
    
    switchwise.hits(ii_block,1) = sum(targetwise.resptype(idx_short)==resp.hitCorrect)/sum(idx_short);
    switchwise.hits(ii_block,2) = sum(targetwise.resptype(idx_long)==resp.hitCorrect)/sum(idx_long);
    
    switchwise.miss(ii_block,1) = sum(targetwise.resptype(idx_short)==resp.miss)/sum(idx_short);
    switchwise.miss(ii_block,2) = sum(targetwise.resptype(idx_long)==resp.miss)/sum(idx_long);
    
    switchwise.incorrect(ii_block,1) = sum(targetwise.resptype(idx_short)==resp.hitIncorrect)/sum(idx_short);
    switchwise.incorrect(ii_block,2) = sum(targetwise.resptype(idx_long)==resp.hitIncorrect)/sum(idx_long);

end

% Plor results
str.switchlife = {'800 ms' '1200 ms'};

h = figure; 
subplot(2,2,1)
errorbar(mean(switchwise.falsealarms), std(switchwise.falsealarms)./sqrt(settings.n.blocks))
xlim([0 3])
set(gca, 'xtick', [1 2], 'xticklabel', str.switchlife)
ylabel('% False alarms')
xlabel('Switch Duration')

subplot(2,2,2)
errorbar(mean(switchwise.miss*100), std(switchwise.miss*100)./sqrt(settings.n.blocks))
xlim([0 3])
set(gca, 'xtick', [1 2], 'xticklabel', str.switchlife)
ylabel('% misses')
xlabel('Switch Duration')

subplot(2,2,3)
errorbar(mean(switchwise.hits*100), std(switchwise.hits*100)./sqrt(settings.n.blocks))
xlim([0 3])
set(gca, 'xtick', [1 2], 'xticklabel', str.switchlife)
ylabel('% hits')
xlabel('Switch Duration')

subplot(2,2,4)
errorbar(mean(switchwise.incorrect*100), std(switchwise.incorrect*100)./sqrt(settings.n.blocks))
xlim([0 3])
set(gca, 'xtick', [1 2], 'xticklabel', str.switchlife)
ylabel('% incorrect')
xlabel('Switch Duration')

saveas(h, [direct.results 'switchduration_effects.png'])

% vigilence decrement by block 

h = figure; 
plot(1:settings.n.blocks, switchwise.hits*100, '-x')
set(gca, 'xtick', 1:settings.n.blocks)
ylabel('% Correct')
xlabel('Block #')
title('Hits by block and switchlife')
legend(str.switchlife)
saveas(h, [direct.results 'switchduration_effectsBW.png'])

%% ############### EEG data #########################

n.chans = 9;
fs = 1200;

trig.startblock = 200;
trig.endblock = 201;

hz.stars = 17;
hz.objects = [13 15];

%% Load EEG DATA

filename.bids.EEG = 'sub-101_task-AttnNFMotion_day-1_phase-Test_eeg0';

cfg            = [];
cfg.dataset    = [direct.data_eeg filename.bids.EEG '.eeg'];
cfg.continuous = 'yes';
cfg.channel    = 'all';
data           = ft_preprocessing(cfg);

% Assign data
EEG = data.trial{1}(1:n.chans,:)';
TRIG = data.trial{1}(n.chans+1,:)';

% Get Triggers
tmp = [0; diff(TRIG)];
LATENCY_st = find(tmp~=0);
TYPE_st = TRIG(LATENCY_st);

LATENCY = find(tmp>0);
TYPE = TRIG(LATENCY);

% Plot Triggers
h = figure;
hold on;
plot(TRIG)
stem(LATENCY, TYPE)

%% Get start to end and flicker periods. 

% Timing settings
lim.s = [ 0 settings.s.block];
lim.x = lim.s.*fs;

n.s = lim.s(2) - lim.s(1);
n.x = lim.x(2) - lim.x(1);

lim.x(1) = lim.x(1) + 1;

t = lim.s(1) : 1/fs : lim.s(2) - 1/fs;
f = 0 : 1/n.s : fs - 1/n.s;

% Timing settings for flicker periods
lim.s_f = [0 60];
lim.x_f = lim.s_f.*fs;

n.s_f = lim.s_f(2) - lim.s_f(1);
n.x_f = lim.x_f(2) - lim.x_f(1);

lim.x_f(1) = lim.x_f(1) + 1;

t_f = lim.s_f(1) : 1/fs : lim.s_f(2) - 1/fs;
f_f = 0 : 1/n.s_f : fs - 1/n.s_f;


% get triggers
trigsidx = [find(TYPE_st == trig.startblock) find(TYPE == trig.endblock)];

% preallocate
settings.n.hz = 2;
BLOCK_EEG = zeros(n.x, n.chans, settings.n.blocks);
flick_EEG = zeros(n.x_f, n.chans, settings.n.hz, settings.s.block/lim.s_f(2)/settings.n.hz,  settings.n.blocks);

for ii_block = 1:settings.n.blocks
    
    % get data
    start = LATENCY_st(trigsidx(ii_block,1)) + lim.x(1);
    stop = LATENCY_st(trigsidx(ii_block,1)) + lim.x(2);
    
    % Assign    
    if stop > length(EEG)
        BLOCK_EEG(1:length(EEG( start:end,:)),:,ii_block) = EEG( start:end,:);
    else
        BLOCK_EEG(:,:,ii_block) = EEG( start:stop,:);
    end
    
    % Flicker onsets 
    flick_onsets = find(diff([0; DATA(Didx(:, ii_block),Dkey.flicker_cond)]));
    flick_type = DATA(Didx(flick_onsets, ii_block),Dkey.flicker_cond);
    flick_onsets = round((flick_onsets./settings.mon.ref).*fs) ;
    flick_condduration = unique(diff(flick_onsets ));
    
    
    % assign flicker periods
    for ii_flicktype = 1:2
       start_epochs = flick_onsets(flick_type == ii_flicktype)+ lim.x_f(1)-1;
       stop_epochs = flick_onsets(flick_type == ii_flicktype) + lim.x_f(2)-1;
       
       for ii_epoch = 1:length(start_epochs)-1
            flick_EEG(:,:,ii_flicktype, ii_epoch, ii_block) = BLOCK_EEG(start_epochs(ii_epoch):stop_epochs(ii_epoch),:,ii_block);
       end
    end
end

%% Whole blocks FFT

dat = squeeze(nanmean(nanmean(BLOCK_EEG(:,1:4,:),2),3));

% FFT
tmp = abs( fft(dat ) )/n.x;
tmp(2:end-1,:,:) = tmp(2:end-1,:,:)*2;

% plot results
h = figure;
datplot = tmp;
plot(f, datplot)
xlim([10 20])
xlabel('Frequency (Hz)')
ylabel('Amplitude (uv)')
title('Full trial frequency spectrum')
saveas(h, [direct.results 'fulltrialfreqspectrum.png'])

%% average blockwise
% FFT

dat = squeeze(mean(mean(mean(flick_EEG(:,1:4,:,:,:), 2), 4),5));
tmp = abs( fft(dat ) )/n.x_f;
tmp(2:end-1,:) = tmp(2:end-1,:,:)*2;

% plot results
h = figure;
datplot = tmp;
plot(f_f, datplot)
xlim([10 20])
xlabel('Frequency (Hz)')
ylabel('Amplitude (uv)')
title('periodwise frequency spectrum')
legend({'Attend 12 Hz' 'Attend 14.4 Hz'})
saveas(h, [direct.results 'periodwise freqspectrum.png'])

xlim([11 15])
saveas(h, [direct.results 'periodwise freqspectrum zoom.png'])

%% progression
% FFT

dat = squeeze(mean(mean(flick_EEG(:,1:4,:,:,:), 2),5));
tmp = abs( fft(dat ) )/n.x_f;
tmp(2:end-1,:,:) = tmp(2:end-1,:,:)*2;

% plot results
h = figure;
datplot = squeeze(nanmean(tmp,3));
plot(f_f, datplot)
xlim([10 20])

% get timewise amps
Hz = [12 14.4 18];
for HH = 1:length(Hz)
    [~, idx_hz(HH)] = min(abs(f_f - Hz(HH)))
end

amps = tmp(idx_hz,:,:);

h = figure;
subplot(2, 1, 1)
bar(squeeze(amps(:,2,:))')
set(gca, 'xtick', 1:4)
xlabel('Block')
ylabel('Amplitude (uv)')
legend({'12.0 Hz' '14.4 Hz' 'stars'})
title('Attend 12.0 Hz')

subplot(2, 1, 2)
bar(squeeze(amps(:,1,:))')
set(gca, 'xtick', 1:4)
xlabel('Block')
ylabel('Amplitude (uv)')
legend({'12.0 Hz' '14.4 Hz' 'stars'})
title('Attend 14.4 Hz')

saveas(h, [direct.results 'SSVEPAmps.png'])

%% To come
%- false alarm rates according to switchduration
% Hist2 of x and y coordinates. 

%% Thoughts for next time
% saw pattern on saturation. 


