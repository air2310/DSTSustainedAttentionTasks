%% Setup clock dynamics
function [DATA, Dkey, s, f, set] = setupExperimentalData_macworth(set)
%% Some extra settings

set.standardjump = 3.6; % degrees
set.ptick  = 0.1;

%% Timing settings
s.tick = 1;
s.resptime =1;
s.task = 12*60;


tmp = fields(s); % get monitor refresh resolved timing
for ii = 1:length(tmp)
    f.(tmp{ii}) = round(s.(tmp{ii})*set.mon.ref);
    s.(tmp{ii}) = f.(tmp{ii})/set.mon.ref;
end

%% Initialise DATA and DATAkey. 
% Set keys
Dkey.FRAME = 1;
Dkey.ticknumber = 2;
Dkey.ticktype = 3;
Dkey.clockangle = 4;

Dkey.responsepressed = 5;
Dkey.responseonset = 6;
Dkey.responseacc = 7;

Dkey.goodresp_displayed = 8;
Dkey.badresp_displayed = 9;
Dkey.target_isonsetframe = 10;
Dkey.tickonset = 11;

numcols = 11;
DATA = zeros(f.task, numcols);

%% Simulate sequence of ticks
numticks_all = s.task;
numticks_long = round(numticks_all*set.ptick);

% Randomly choose n percent of ticks to be skips
template = zeros(numticks_all,1);
tickidx=sort(randsample(numticks_all,numticks_long, false));
tickorder=template;
tickorder(tickidx) = 1;

while 1
   if ~any(diff(tickidx)<3)
       break;
   end
   % find the offenders
   tmp = find(diff(tickidx)<3);
   
   % get rid of the offender
   tickorder(tickidx(tmp)) = 0;
   tickidx(tmp) = [];
   
   % resample   
   tickidx = sort([tickidx; randsample(find(tickorder==0),length(tmp), false)]);
   tickorder(tickidx) = 1;
end

tickorder=tickorder+1
% tickorder = ones(numticks_all,1);
% tickorder(tickidx) = 2;

% Iterate clock angles
for tt = 1:numticks_all
    
end

set.numticks_all =numticks_all;
set.numticks_long = numticks_long;
set.numticks_short =set.numticks_all - set.numticks_long ;

%% Setup tick dynamics
% initialise
tickframes = 1:f.tick:f.task;
clockangle = 0;
DATA(:, Dkey.responseacc)  = nan;
% loop through all ticks
for tt = 1:numticks_all
    % get data
    idx = tickframes(tt):tickframes(tt)+f.tick -1;
    clockangle = clockangle + set.standardjump*tickorder(tt);
    if clockangle>=360
        clockangle = 0;
    end
    
    % save tick info 
    DATA(idx, Dkey.FRAME) = idx;
    DATA(idx, Dkey.ticknumber) = tt;
    DATA(idx, Dkey.ticktype) = tickorder(tt);
    DATA(idx, Dkey.clockangle) = clockangle;
    DATA(idx(1), Dkey.tickonset) = 1;
    
    if tickorder(tt)==2
        DATA(idx(1), Dkey.target_isonsetframe ) = 1;
        DATA(idx(1), Dkey.responseacc) = 0;
    end
    
end

