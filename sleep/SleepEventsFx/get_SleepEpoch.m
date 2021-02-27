function [sEpoch subst] = get_SleepEpoch(dirPath,Vtsd)

%==========================================================================
% Details: get sleep stages epochs for SleepEvents analyses
%
% INPUTS:
%       - Vtsd              Vtsd from behavResources (speed in tsd format)
%
% OUTPUT:
%       - sEpoch            Epoch (timestamps) for each sleep/wake stages
%       - subst             Substages done (yes=1; no=0)
%
% NOTES:
%
%   Written by Samuel Laventure - 2020-11/12
%      
%==========================================================================

%% GET SESSION and STAGE EPOCHS
% load sleep scoring
try
    load([dirPath 'SleepSubstages.mat'],'Epoch');
    sEpoch{3,1} = Epoch{7};                   % nrem
    sEpoch{3,2} = Epoch{4};                   % rem
    sEpoch{3,3} = Epoch{5};                   % wake
    sEpoch{3,4} = Epoch{1};                   % n1
    sEpoch{3,5} = Epoch{2};                   % n2
    sEpoch{3,6} = Epoch{3};                   % n3
    sEpoch{3,7} = or(Epoch{4},Epoch{7});      % sleep
    subst = 1;
    clear Epoch
    try
        load([dirPath 'SleepScoring_OBGamma.mat'],'sleep_array');
    catch
        load([dirPath 'SleepScoring_Accelero.mat'],'sleep_array');
    end 
catch
    try
        load([dirPath 'SleepScoring_OBGamma.mat'], 'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch');
    catch
        load([dirPath 'SleepScoring_Accelero.mat'], 'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch');
    end 
    sEpoch{3,1} = SWSEpoch;                   % nrem
    sEpoch{3,2} = REMEpoch;                   % rem
    sEpoch{3,3} = Wake;                       % wake
    sEpoch{3,7} = Sleep;                      % sleep
    subst = 0;
    clear Wake Sleep SWSEpoch REMEpoch
end

% load behavResources (session epochs)
load([dirPath 'behavResources.mat'], 'SessionEpoch','Vtsd');
% restrict to pre/post sessions
for istage=1:7
    if ~(subst) && istage>3 
        istage = 7;
    end
    % speed restriction
    % Locomotion threshold
    immobileEpoch = thresholdIntervals(tsd(Range(Vtsd)...
        ,movmedian(Data(Vtsd),5)),5,'Direction','Below');
    try
        sEpoch{1,istage} = and(and(sEpoch{3,istage},SessionEpoch.BaselineSleep),immobileEpoch);    
    catch
        sEpoch{1,istage} = and(and(sEpoch{3,istage},SessionEpoch.PreSleep),immobileEpoch);    
    end
    sEpoch{2,istage} = and(and(sEpoch{3,istage},SessionEpoch.PostSleep),immobileEpoch);    
end
end