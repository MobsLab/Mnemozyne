function [sEpoch subst sSession] = get_SleepEpoch(dirPath)

%==========================================================================
% Details: get sleep stages epochs for SleepEvents analyses
%
% INPUTS:
%       - dirPath           Path
%
% OUTPUT:
%       - sEpoch            Epoch (timestamps) for each sleep/wake stages
%       - subst             Substages done (yes=1; no=0)
% Optional:
%       - sessdur               Duration of arbitrary BaselineSleep sessions
%
% NOTES:
%
%   Written by Samuel Laventure - 2020-11/12
%      
%==========================================================================

% % Parse parameter list
% for i = 1:2:length(varargin)
%     switch(lower(varargin{i}))
%         case 'sessdur'
%             sessdur = varargin{i+1};
%             if ~isnumeric(sessdur)
%                 error('Incorrect value for property ''sessdur''.');
%             end
%         otherwise
%             error(['Unknown property ''' num2str(varargin{i}) '''.']);
%     end
% end
% 
% %check if exist and assign default value if not
% if ~exist('sessdur','var')
%     sessdur=7200;
% end
sessdur = 7200;

%% GET SESSION and STAGE EPOCHS
% load sleep scoring
warning off
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
catch
    try
        load([dirPath 'SleepScoring_OBGamma.mat'], ...
            'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch','Epoch');
    catch
        load([dirPath 'SleepScoring_Accelero.mat'], ...
            'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch','Epoch');
    end 
    sEpoch{3,1} = SWSEpoch;                   % nrem
    sEpoch{3,2} = REMEpoch;                   % rem
    sEpoch{3,3} = Wake;                       % wake
    sEpoch{3,7} = Sleep;                      % sleep
    subst = 0;
    clear Wake Sleep SWSEpoch REMEpoch
end

% load behavResources (session epochs)
% ugly addition to fix server connection issue (try/catch)
try
    load([dirPath 'behavResources.mat'], 'SessionEpoch','SleepEpochs');
catch
    load([dirPath 'behavResources.mat'], 'SessionEpoch','SleepEpochs');
end

if exist('SessionEpoch','var') % if doesnt exist then it is a Baseline session
    if ~exist('SleepEpochs','var')
        try
            SleepEpochs.pre = SessionEpoch.PreSleep;
        catch
            SleepEpochs.pre = SessionEpoch.Baseline;
        end
        SleepEpochs.post = SessionEpoch.PostSleep;
    else
        % this part will need to be work, right now doesn't enter because
        % of first "if". Need to add optionnal argument
        clear SleepEpochs
        % use specified length 
        SleepEpochs = getBaselineSleep_Sessions(dirPath,sessdur);
    end

    % restrict to pre/post sessions
    for istage=1:7
        if ~(subst) && istage>3 
            istage = 7;
        end
        sEpoch{1,istage} = and(sEpoch{3,istage},SleepEpochs.pre);     
        sEpoch{2,istage} = and(sEpoch{3,istage},SleepEpochs.post);    
    end
    sSession{1} = SleepEpochs.pre;
    sSession{2} = SleepEpochs.post;
else
    sSession{1} = Epoch;
end

end