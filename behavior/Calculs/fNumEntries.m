function NumEntries = fNumEntries(beh,id_Sess)
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
%       NumEntries.data             Number of entry into each umaze's zone
%       NumEntries.sessavg          Averaged number of entry by session 
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 20/05/2021
% github.com/samlaventure

for imouse=1:length(beh)
    for isess=1:2
        for itrial=1:length(id_Sess{isess,imouse})
            tmp = CalculateNumEntriesZone(a{imouse}.behavResources(id_Sess{isess,imouse}(itrial)));
            NumEntries.data(imouse,isess,itrial) = tmp(1);  % only the stim zone
        end
        NumEntries.sessavg(imouse,isess) = squeeze(mean(NumEntries.data(imouse,isess,:)));
    end
end