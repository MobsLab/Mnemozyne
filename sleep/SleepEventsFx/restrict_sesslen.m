function [epoch] = restrict_sesslen(sEpoch,sSession,subst,restrictlen)
% Description: output epoch variable containing epoch of sleep restricted
% to a specific length in sec (restrictlen). Can work with pre/post or baseline 
% sleep session
%
%  OUTPUT: epoch
% 
%       2022 by Samuel Laventure
%       See get_SleepEpoch
%   
%==========================================================================

% make sure there is enough sleep
if restrictlen
    st1=Start(sEpoch{1,7});
    en1=End(sEpoch{1,7});
    tot1=sum(en1-st1)/1e4;
    st2=Start(sEpoch{2,7});
    en2=End(sEpoch{2,7});
    tot2=sum(en2-st2)/1e4;
    if (tot1>restrictlen) && (tot2>restrictlen)
        ok=1;
    else 
        ok=0;
    end
    clear st1 st2 en1 en2 tot1 tot2
else
    ok=1;
end


% check if pre/post or baseline session
if size(sEpoch,1)>1
    nsess = 2;
else
    nsess = 1;
end
% restrict session to length requested
for isess=1:nsess
    if ok
        % set begining and end 
        lenepoch = Data(length(sEpoch{isess,7}))/1e4;
        lenstage = 0;
        if restrictlen
            for iep=1:length(lenepoch)
                if lenstage+lenepoch(iep)<restrictlen
                    lenstage=lenstage+lenepoch(iep);
                else
                    stlast = Start(subset(sEpoch{isess,7},iep));
                    endrest = stlast + restrictlen*1e4 - lenstage*1e4;
                    break
                end
            end
        else
            e=End(sSession{isess});
            endrest=e(end);
        end
        st = Start(sSession{isess});
        islen = intervalSet(st,endrest);
        % restrict to min duration (main sleep stages)
        for irest=1:7
            if irest==4
                irest=7;
            end
            if restrictlen                            
                epoch{isess,irest} = and(sEpoch{isess,irest},islen);
            else
                epoch{isess,irest} = sEpoch{isess,irest};
            end
            if irest==7
                break
            end
        end
        % restrict to min duration (substges)
        if subst
            for irest=4:6
                if restrictlen
                    epoch{isess,irest} = and(sEpoch{isess,irest},islen);
                else
                    epoch{isess,irest} = sEpoch{isess,irest};
                end
            end
        end
    else
        for irest=1:7
            epoch{isess,irest} = nan;
        end
    end
end
