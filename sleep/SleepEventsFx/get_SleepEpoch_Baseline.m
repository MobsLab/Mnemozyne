function [sEpoch sSession subst] = get_SleepEpoch_Baseline(dirPath)

%==========================================================================
% Details: get sleep stages epochs for baseline session 
%
% INPUTS:
%       - dirPath           Path 
%
% OUTPUT:
%       - sEpoch            Epoch (timestamps) for each sleep/wake stages
%       - subst             Substages done (yes=1; no=0)
%
% NOTES:
%
%   Written by Samuel Laventure - 2022
%
%   See: get_SleepEpoch
%      
%==========================================================================

%% GET SESSION and STAGE EPOCHS
% load sleep scoring
warning off
try
    load([dirPath 'SleepSubstages.mat'],'Epoch');
    sEpoch{1,1} = Epoch{7};                   % nrem
    sEpoch{1,2} = Epoch{4};                   % rem
    sEpoch{1,3} = Epoch{5};                   % wake
    sEpoch{1,4} = Epoch{1};                   % n1
    sEpoch{1,5} = Epoch{2};                   % n2
    sEpoch{1,6} = Epoch{3};                   % n3
    sEpoch{1,7} = or(Epoch{4},Epoch{7});      % sleep
    subst = 1;
    clear Epoch
catch
    try
        load([dirPath 'SleepScoring_OBGamma.mat'], 'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch','Epoch');
    catch
        load([dirPath 'SleepScoring_Accelero.mat'], 'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch','Epoch');
    end 
    sEpoch{1,1} = SWSEpoch;                   % nrem
    sEpoch{1,2} = REMEpoch;                   % rem
    sEpoch{1,3} = Wake;                       % wake
    sEpoch{1,7} = Sleep;                      % sleep
    subst = 0;
    clear Wake Sleep SWSEpoch REMEpoch
end
sSession{1} = Epoch;
    
end