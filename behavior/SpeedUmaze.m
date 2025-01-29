function [xdir ydir vdir speed] = SpeedUmaze(beh,idx)
%==========================================================================
% Details: get speed and trajecories coordinates (x,y) in function of the
% direction to the stim zone (toward vs away from).
%
% You need to have the field DirEpoch within the behavResources variable. 
% If not, first run create_DirLinear.m
%
% INPUTS:
%       - beh               behavResources variable
%       - idx               idx of session within behavResources structure
%
% OUTPUT:
%       - xdir              x coordinates in U-Maze {direction, segments}
%       - ydir              y coordinates in U-Maze {direction, segments}    
%       - vdir              speed for each timepoints
%       - speed             speed by direction (toward vs away)
%
% NOTES:
%
%   Written by Samuel Laventure - 2021-03
%      
%==========================================================================

try
    epochSZ = beh(idx).CleanZoneEpoch{1};
catch
    epochSZ = beh(idx).ZoneEpoch{1};
end
alltime = Range(beh(idx).Vtsd);
allepoch = intervalSet(alltime(1), alltime(end));
allNOSz = allepoch-epochSZ;
for idir=1:3
    st = Start(beh(idx).DirEpoch{idir});
    en = End(beh(idx).DirEpoch{idir});
    % direction + speed
    nbseg(idir)=length(st);
    for iseg=1:length(st)
        ep = intervalSet(st(iseg),en(iseg));
        try
            xdir{idir,iseg} = Data(Restrict(beh(idx).CleanAlignedXtsd,ep));
            ydir{idir,iseg} = Data(Restrict(beh(idx).CleanAlignedYtsd,ep));
        catch
            xdir{idir,iseg} = Data(Restrict(beh(idx).AlignedXtsd,ep));
            ydir{idir,iseg} = Data(Restrict(beh(idx).AlignedYtsd,ep));
        end
        try
            vit = Data(Restrict(beh(idx).CleanVtsd,ep));
        catch
            vit = Data(Restrict(beh(idx).Vtsd,ep));
        end
        if ~(idir==2)
            vdir{idir,iseg} = vit;
        else
            vdir{idir,iseg} = -1.*vit;
        end
        clear ep
    end
    % speed only (for bars)
    speed(idir) = nanmean(Data( ...
                        Restrict( ...
                        Restrict( ...
                            beh(idx).Vtsd, allNOSz), ...
                            beh(idx).DirEpoch{idir} ...
                        )));
    clear st en
end  
