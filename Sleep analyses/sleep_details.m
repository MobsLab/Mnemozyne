function sleep_details(varargin)
%==========================================================================
% Details: Output details about sleep session
%
% INPUTS:
%       - stim          If stimulations are to be taken off the signal (0 or 1)
%       - recompute     Recompute events (0 or 1)
%       - down          Detect down states (default: 0). Need PFC neurons. 
%       - delta         Detect delta waves (default: 1). Need PFC channel. 
%       - rip           Detect ripples (default: 1). Need HPC rip channel.
%       - spindle       Detect spindles (default: 1). Need PFC spindle channel.
%       - ripthresh     Ripple thresholds (default: [5 7])
% 
% OUTPUT:
%       - figure including:
%           - Neurons
%           - Sleep scoring plot, curves, stage duration
%           - Hypnogram
%           - mean lfp on delta waves
%           - mean ripples
%           - mean spindles
%
% NOTES:
%       - Without LFP in PFC cannot run this script right now
%
%   Written by Samuel Laventure - 02-07-2019
%   Updated 2020-11 SL 
%      
%  see also, FindNREMfeatures, SubstagesScoring, MakeIDSleepData,PlotIDSleepData
%==========================================================================

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'stim'
            stim = varargin{i+1};
            if stim~=0 && stim ~=1
                error('Incorrect value for property ''stim''.');
            end
        case 'recompute'
            recompute = varargin{i+1};
            if recompute~=0 && recompute ~=1
                error('Incorrect value for property ''recompute''.');
            end
        case 'down'
            down = varargin{i+1};
            if down~=0 && down ~=1
                error('Incorrect value for property ''down''.');
            end
        case 'delta'
            delta = varargin{i+1};
            if delta~=0 && delta ~=1
                error('Incorrect value for property ''delta''.');
            end
        case 'rip'
            rip = varargin{i+1};
            if rip~=0 && rip ~=1
                error('Incorrect value for property ''rip''.');
            end
        case 'spindle'
            spindle = varargin{i+1};
            if spindle~=0 && spindle ~=1
                error('Incorrect value for property ''spindle''.');
            end
        case 'ripthresh'
            ripthresh = varargin{i+1};
            if ~isnumeric(ripthresh)
                error('Incorrect value for property ''ripthresh''.');
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
%Is there stim in this session
if ~exist('stim','var')
    stim=0;
end
%recompute?
if ~exist('recompute','var')
    recompute=1;
end
if ~exist('down','var')
    down=0;
end
if ~exist('delta','var')
    delta=1;
end
if ~exist('rip','var')
    rip=1;
end
if ~exist('spindle','var')
    spindle=1;
end
if ~exist('ripthresh','var')
    ripthresh=[5 7];
end


%set folders
[parentdir,~,~]=fileparts(pwd);
pathOut = [pwd '/Figures/'];
if ~exist(pathOut,'dir')
    mkdir(pathOut);
end

%load stim
if stim
    load('behavResources.mat','StimEpoch');
end


%% Sleep event
disp('getting sleep signals')
CreateSleepSignalsSL('recompute',recompute,'scoring','accelero','stim',1, ...
    'down',down,'delta',delta,'rip',rip,'spindle',spindle, ...
    'ripthresh',[2 5]);


%% Substages
disp('getting sleep stages')
[featuresNREM, Namesfeatures, EpochSleep, NoiseEpoch, scoring] = FindNREMfeatures('scoring','accelero');
save('FeaturesScoring', 'featuresNREM', 'Namesfeatures', 'EpochSleep', 'NoiseEpoch', 'scoring')
[Epoch, NameEpoch] = SubstagesScoring(featuresNREM, NoiseEpoch);
save('SleepSubstages', 'Epoch', 'NameEpoch')
end

