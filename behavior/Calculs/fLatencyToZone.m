function StimZLatency = fLatencyToZone(beh,id_Sess)
%
%   INPUT
%       beh                         cell array conainting behavResources for 
%                                   each animal in the anlaysis
%       id_Sess                     cell array with indexes of sessions for
%                                   each mouse
%                                   format -> {mouse1,sess1; 
%                                              mouse2,sess2;
%                                              etc...}
%
%   OUTPUT
%      [StimZLatency - Structure]
%       StimZLatency.data           latency (in sec) to first entry into
%                                   each umaze's zone
%       StimZLatency.sessavg        averaged by session 
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 20/05/2021
% github.com/samlaventure

% get latency data
for imouse=1:length(beh)
    % get trial max time
    en = beh{imouse}.behavResources(id_Sess{1,imouse}(1)).PostMat(end,1);
    st = beh{imouse}.behavResources(id_Sess{1,imouse}(1)).PostMat(1,1);
    tdur = floor(en-st); % in sec 
    % get time of first entry into each zone
    for isess=1:2
        for itrial=1:length(id_Sess{isess,imouse})
            tmp = CalculateFirstEntryZoneTime(beh{imouse}.behavResources(id_Sess{isess,imouse}(itrial)), tdur);
            StimZLatency.data(imouse,isess,itrial,1:length(tmp)) = tmp;
            clear tmp
        end
        for izone=1:size(StimZLatency.data,4)
            StimZLatency.sessavg(imouse,isess,izone) = squeeze(mean(StimZLatency.data(imouse,isess,:,izone)));
        end
    end
end