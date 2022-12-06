function [stim] = setupMotion(options, set, stim)
%setupMotion: Setup the parameters for object motion

%   Inputs:
%       options - Options for how the experiment is run
%       stim - stimulus properties
%       set - settings for the experiment structure
%
%   Outputs:
%       stim - updated stimulus properties

%% Extract settings for this function
mon = set.mon;
n = set.n;
f = set.f;
disp('Setting up motion dynamics')
%% Stimulus starting positions

% stim.bounds = [10 10 mon.res(1)-10 mon.res(2)-85];
stim.bounds = [200 10 mon.res(1)-200 mon.res(2)-85];
boundry = stim.truewidth;

bounds_x = [stim.bounds(1) + boundry , stim.bounds(3) - boundry];
bounds_y = [stim.bounds(2) , stim.bounds(4) - boundry];

x_stream_options = round(linspace(bounds_x(1), bounds_x(2), n.objs_total));%bounds_x(1):stimprops.truewidth+3:bounds_x(2);

startingcoords = round([randsample(x_stream_options, n.objs_total, false); randsample(bounds_y(1):bounds_y(2), n.objs_total, false)]);
%check that no two stimuli are touching.
for STIM = 1:n.objs_total
    otherstim = 1:n.objs_total;
    otherstim(STIM) = [];
    
    distance = sqrt((startingcoords(1,STIM) - startingcoords(1,otherstim)).^2 + (startingcoords(2,STIM) - startingcoords(2,otherstim)).^2);
    
    while any(distance < stim.height*1.5) % Don't let any get too close to each other.
        startingcoords(2,STIM) = round(randsample(bounds_y(1):bounds_y(2),1, false));
        distance = sqrt((startingcoords(1,STIM) - startingcoords(1,otherstim)).^2 + (startingcoords(2,STIM) - startingcoords(2,otherstim)).^2);
    end
    
end

%% Set up motion profiles for the task.

% get tmpcoords for non-variable motion:
spawnspot = stim.bounds(2)-stim.trueheight;
XALL = bounds_x(1): bounds_x(2);
tmpcoords = NaN(2,length(XALL));
tmpcoords(1,:) = XALL;
tmpcoords(2,:) = spawnspot;


% Preallocate
COORDS_X = NaN(n.objs_total, f.block, n.blocks);
COORDS_Y = NaN(n.objs_total, f.block, n.blocks);

% Loop to allocate coordinates for the experiment.
for BLOCK = 1:n.blocks
    % Set starting point for each block;
    if BLOCK == 1
        COORDS_X(:, 1, BLOCK) = startingcoords(1,:)';
        COORDS_Y(:, 1, BLOCK) = startingcoords(2,:)';
    else
        COORDS_X(:, 1, BLOCK) = COORDS_X(:, 1, BLOCK-1);
        COORDS_Y(:, 1, BLOCK) = COORDS_Y(:, 1, BLOCK-1);
    end
    
    % Setup movement
    for FRAME = 2:f.block
        COORDS_X(:, FRAME, BLOCK) = COORDS_X(:, FRAME - 1, BLOCK);
        COORDS_Y(:, FRAME, BLOCK) = COORDS_Y(:, FRAME - 1, BLOCK) + stim.speed';
        
        % Detect offscreen
        offscreen =  COORDS_Y(:, FRAME, BLOCK) > stim.bounds(4) + stim.trueheight/2;
        
        if any(offscreen)
            offscreenidx = find(offscreen);
            
            %calculate which one's we won't hit.
            if options.variablespeed
                for jj = 1: length(offscreenidx)
                    ii = offscreenidx(jj);
                    
                    % algebraicly calculated meeting points:
                    spawnspot = stim.bounds(2)-stim.trueheight;
                    s2_s1 = stim.speed ./ stim.speed(ii);
                    
                    Y_meet = (s2_s1*spawnspot - COORDS_Y(:, FRAME, BLOCK)') ./ (s2_s1 - 1 );
                    Y_meet_b = (s2_s1*(spawnspot + stim.trueheight) - (COORDS_Y(:, FRAME, BLOCK)' - stim.trueheight)) ./ (s2_s1 - 1 );
                    Y_meet_t = (s2_s1*(spawnspot - stim.trueheight) - (COORDS_Y(:, FRAME, BLOCK)' + stim.trueheight)) ./ (s2_s1 - 1 );
                    
                    % Find ineligivle x streams
                    distance = abs(spawnspot-COORDS_Y(:, FRAME, BLOCK)');
                    ineligiblepos = (Y_meet < stim.bounds(4)*2 | Y_meet_b <  stim.bounds(4)*2 | Y_meet_t <  stim.bounds(4)*2 | distance < stim.trueheight); %& Y_meet > - stim.bounds(4);
                    options_x = ~ismember(x_stream_options, COORDS_X(ineligiblepos, FRAME, BLOCK));
                    
                    % reset coords
                    
                    COORDS_X(ii, FRAME, BLOCK) = randsample(x_stream_options(options_x), 1);
                    COORDS_Y(ii, FRAME, BLOCK) = spawnspot;
                end
            else % unvariable speed
                for jj = 1: length(offscreenidx)
                    ii = offscreenidx(jj);
                    distance = sqrt((COORDS_X(:, FRAME, BLOCK) - tmpcoords(1,:)).^2 + (COORDS_Y(:, FRAME, BLOCK) - tmpcoords(2,:)).^2);
                    ineligiblepos = any(distance<(stimprops.trueheight*2));
                    
                    % reset coords
                    COORDS_X(ii, FRAME, BLOCK) = randsample(XALL(~ineligiblepos), 1);
                    COORDS_Y(ii, FRAME, BLOCK) = spawnspot;
                end
            end
        end
    end
  
end

%% Plot coords to make sure they're evenly distributed
% h = figure;
% hist(COORDS_X(:)', 15)
% plot(1:f.block, COORDS_X(:,:,1))

% hist(COORDS_Y(:)', 15)
% figure; plot(unique(COORDS_X), 'x')

stim.COORDS_X = COORDS_X;
stim.COORDS_Y = COORDS_Y;

end