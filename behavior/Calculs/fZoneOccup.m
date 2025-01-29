function Occup = fZoneOccup(beh,id_Sess,varargin)

%   INPUT
%       beh                         cell array conainting behavResources for 
%                                   each animal in the anlaysis
%       id_Sess                     cell array with indexes of sessions for
%                                   each mouse
%                                   format -> {mouse1,sess1; 
%                                              mouse2,sess2;
%                                              etc...}
%   OUTPUT
%       figH                        figure handle
%
%   OPTIONAL (VARARGIN)
%       cond                        conditionning session (1/0)
%                                   default -> 1 
%
%   See: PrgMatlab/CodesMATLAB/WagenaarMBL/hist2.m
%   Note: if problem with hist2 it is because of eeglab hist2 function
%         place it in an another path temprorarly or reload PrgMatlab path)
%
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 20/05/2021
% github.com/samlaventure

% Default values
cond=1;

% Optional Parameters
for i=1:2:length(varargin)    
    switch(lower(varargin{i})) 
        case 'cond'
            cond = varargin{i+1};
            if ~(cond==1) && ~(cond==0)
                error('Incorrect value for property ''cond'' (must be 0 or 1');
            end
    end
end

for imouse=1:length(beh)
    for isess=1:3
        if ~(~cond && isess>2)
            for itrial=1:length(id_Sess{isess,imouse})
                Occup_tmp = CalculateZoneOccupancy(beh{imouse}.behavResources(id_Sess{isess,imouse}(itrial)));
                Occup.data(imouse,isess,itrial,1:length(Occup_tmp)) = Occup_tmp;
                clear Occup_tmp
            end
            for izone=1:size(Occup,4)
                Occup.sessavg(imouse,isess,izone) = squeeze(nanmean(Occup(imouse,isess,:,izone)));         
            end
        end
    end
end
% % get means
% for imouse=1:length(beh)
%     for isess=1:3
%         for izone=1:size(Occup,4)
%             Occup.avgSess(imouse,isess,izone) = squeeze(nanmean(Occup(imouse,isess,:,izone)));         
%         end
%     end
% end