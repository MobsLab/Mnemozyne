function trajzone = fCumulOccup(beh,id_Sess,varargin)
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
%   OPTIONAL (VARARGIN)
%       cond                        conditionning session (1/0)
%                                   default -> 1 
%
%   OUTPUT
%       trajzone                    cumulative occupancy by zone
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

%var init
trajzone{length(beh),3,8}=nan;
for imouse=1:length(beh)
    for isess=1:3
        if ~(~cond && isess>2)
            for itrial=1:length(id_Sess{isess,imouse})
                % get number of zones
                nzones = size(beh{imouse}.behavResources(id_Sess{isess,imouse}(itrial)).ZoneIndices,2)-2;
                for izone=1:nzones
                    if izone<6  % old tracking scripts had only 5 zones (2 additional zones are at the end+2)
                        trajzone_dat(beh{imouse}.behavResources(id_Sess{isess,imouse}(itrial)).ZoneIndices{izone}) = izone;
                    else
                        trajzone_dat(beh{imouse}.behavResources(id_Sess{isess,imouse}(itrial)).ZoneIndices{izone+2}) = izone;
                    end
                    trajzone_temp_id{izone} = find(trajzone_dat(:)==izone);
                    trajzone_temp(izone,trajzone_temp_id{izone}) = 1;  
                end
                trajzone_cumul = cumsum(trajzone_temp');
                trajzone{imouse,isess,itrial} = trajzone_cumul ./ sum(trajzone_cumul,2);

                % re-order in a linear pattern for visualization
                if nzones == 7
                    trajzone{imouse,isess,itrial} = trajzone{imouse,isess,itrial}(:,[1 4 6 3 7 5 2]);
                elseif nzones == 5
                    trajzone{imouse,isess,itrial} = trajzone{imouse,isess,itrial}(:,[1 4 3 5 2]);
                end 
            end
        end
    end
end