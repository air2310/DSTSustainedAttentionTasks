function [set, options] = setupSettingsPreNF(set, options)
%setupSettings: Setup the settings for sustained attention task

options.preNF = 1;
set.direct.NFstring = 'PreNF';

%% Experiment structure
set.n.blocks = 1; % 1 x 10 minute blocks

%% Timing
set.s.block = 60*10; % 20 minute blocks
set.s.switchduration_block = set.s.block/set.n.switchlives; 

set.f.block = set.s.block*set.mon.ref;
set.f.switchduration_block  = set.s.switchduration_block*set.mon.ref;

if options.instructions
   options.flicker = 0; 
end
end







