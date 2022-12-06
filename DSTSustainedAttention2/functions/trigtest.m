
%% Functions
addpath('E:\toolboxes\io64')
%% Trigger settings
PCuse = 1;
trig.ioObj = io64;
trig.status = io64(trig.ioObj);
trig.options.port = { 'D010'  'D030' };
n.ports = length(trig.options.port);
trig.address = NaN(n.ports,1);

%% Initialise triggers and start recording
for AA = 1:n.ports
    trig.address(AA) = hex2dec( trig.options.port{AA} );
    io64(trig.ioObj, trig.address(AA), 0);
end

%% Trigger blocks
io64(trig.ioObj, trig.address(2), 0);
pause(0.05)
io64(trig.ioObj, trig.address(2), 7);
pause(0.05)
io64(trig.ioObj, trig.address(2), 0);
pause(0.05)

%% Trigger flicker

while 1
    for trigsend = 1:2
        for ii = 1:60
           io64(trig.ioObj, trig.address(2), 0);
           pause(0.5)
           io64(trig.ioObj, trig.address(2), trigsend);
           disp(trigsend)
           pause(1)
        end
    end
end

% io64(trig.ioObj, trig.address(2), 8);
% pause(0.05)
% io64(trig.ioObj, trig.address(2), 0);



% for AA = 1:n.ports
%     disp('port #')
%     disp(AA)
%     for tt = 1:255
%         io64(trig.ioObj, trig.address(AA), tt);
%         pause(0.01)
%         a=io64(trig.ioObj, trig.address(AA));
%         disp(a)
%     end
% end
% 1 = biopac, 2 = EEG
% io64(trig.ioObj, trig.address(1), trig.startRecording);
