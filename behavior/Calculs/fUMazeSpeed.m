function Speed = fUMazeSpeed(beh,id_Sess)
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
%       Speed.data                  Speed in each umaze's zone
%       Speed.sessavg               Averaged speed by session 
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 20/05/2021
% github.com/samlaventure

for imouse=1:length(beh)
    for isess=1:2
        for itrial=1:length(id_Sess{isess,imouse})
            tmp = CalculateSpeedZone(a{imouse}.behavResources(id_Sess{isess,imouse}(itrial)));
            Speed.data(imouse,isess,itrial,1:length(tmp)) = tmp;  % all zones
        end
        Speed.sessavg(imouse,isess,1:length(tmp)) = squeeze(mean(Speed.data,3));
        clear tmp
    end
end