function Dir = PathForExperimentsERC(experimentName)

% "Umaze": ["1199", "906", "1168", "905", "1182"],

%% Groups PAG expe

% Concatenated - small zone (starting with 797)
LFP = 6:21; % Good LFP
Neurons = [6 7 8 10 12:21]; % Good Neurons
ECG = [6 9 10 14 15]; % Good ECG
OB_resp = [6:10 13 14 16:21];
OB_gamma = [6:8 10 11 13 14 16:20];
PFC = [6:14 16:18 21];

% Concatenated - big and small zone
LFP_All = 1:21; % Good LFP
Neurons_All = [1 6 7 8 10 12:21]; % Good Neurons
ECG_All = [1 3 5 6 9 10 14 15]; % Good ECG

%%
a=0;
%%

%% Currently used mice 28/05/2025
% -----------------------------------------------------------------------------------------------
% |      Known       |        MFB         |        UMazePAG        |    Reversal     |   Novel   |
% -----------------------------------------------------------------------------------------------
% |  M1336_known     |  M1336_MFB         |  M1186                 |  M1199_reversal | M1230_Novel |
% |  M1230_Known     |  M1117             |  M1199_PAG             |                 |             |
% |                  |  M1281_MFB         |  M1182                 |                 |             |
% |                  |  M1168MFB          |  M994_PAG              |                 |             |
% |                  |  M1239MFB          |  M1239_PAG             |                 |             |
% |                  |  M1162_MFB         |  M1162_PAG             |                 |             |
% |                  |  M1199_MFB         |                        |                 |             |
% -----------------------------------------------------------------------------------------------


% Define experiment categories - Don't forget to update this AND the dict
MFB_keys = {'m1336_mfb', 'm1117', 'm1281_mfb', 'm1168MFB', 'm1239_MFB','m1162_mfb','m1199_mfb'};
UMazePAG_keys = {'m1186', 'm1199_pag', 'm1182', 'm994_PAG', 'm1239_PAG', 'm1162_PAG'};
Reversal_keys = {'m1199_reversal'};
Known_keys = {'m1336_known',  'm1230_Known'};
Novel_keys = {'m1230_Novel'}
% Novel_keys = TODO

% pathdir = '/home/mickey/Documents/Theotime/DimaERC2';
pathdir = '/media/mickey/DataTheotime210/DimaERC2'


% Define the first dictionary
python_dict = containers.Map({...
    'm1336_mfb', 'm1336_known', 'm1186', 'm1199_pag', 'm1199_reversal', ...
    'm1117', 'm1281_mfb', 'm1168MFB', 'm1182', 'm994_PAG', 'm1239_MFB', ...
    'm1199_mfb', 'm1239_PAG', 'm1162_PAG', 'm1230_Known', 'm1230_Novel'}, ...
    {...
    'neuroencoders_1021/_work/M1336_MFB/Final_results_v3/', ... % MFB
    'neuroencoders_1021/_work/M1336_known/Final_results_v2/', ... % Known
    'neuroencoders_1021/_work/M1186/Final_results_v2/', ... % U-Maze PAG
    'neuroencoders_1021/_work/M1199_PAG/Final_results_v3/', ... % U-Maze PAG
    'neuroencoders_1021/_work/M1199_reversal/Final_results_v3/', ... % Reversal
    'neuroencoders_1021/_work/M1117_MFB/Final_results/', ... % MFB
    'neuroencoders_1021/_work/M1281_MFB/Final_results_v2/', ... % MFB
    'neuroencoders_1021/_work/M1168_MFB/test', ... % MFB
    'neuroencoders_1021/_work/M1182_PAG/test/', ... % PAG
    'neuroencoders_1021/_work/M994_PAG/Final_results_v3/', ... % PAG
    'neuroencoders_1021/_work/M1239_MFB/Final_results_v3/', ... % MFB
    'neuroencoders_1021/_work/M1199_MFB/test/', ... % MFB
    'neuroencoders_1021/_work/M1239_PAG/test/', ... % PAG
    'neuroencoders_1021/_work/M1162_PAG/test/', ... % PAG
    'neuroencoders_1021/_work/M1230_Known/test/', ... % Known
    'neuroencoders_1021/_work/M1230_Novel/test/', ... % Novel
    });
%%% ACHTUNG: M1239 has no clean data (only NaN).


% Define the second dictionary
subpython_REAL = containers.Map({...
    'm1336_mfb', 'm1336_known', 'm1186', 'm1199_pag', 'm1199_reversal', ...
    'm1117', 'm1281_mfb', 'm1168UMFB', 'm1182', 'm994_PAG', 'm1239_MFB', ...
    'm1199_mfb', 'm1239_PAG', 'm1162_PAG', 'm1230_Known', 'm1230_Novel'}, ...
    {...
    '/media/nas7/ProjetERC1/StimMFBWake/M1336/', ...
    '/media/nas7/ProjetERC1/Known/M1336/', ...
    '/media/nas6/ProjetERC2/Mouse-K186/20210409/_Concatenated/', ...
    '/media/nas6/ProjetERC2/Mouse-K199/20210408/_Concatenated/', ...
    '/media/nas6/ProjetERC3/M1199/Reversal/', ...
    '/media/nas5/ProjetERC1/StimMFBWake/M1117/', ...
    '/media/nas7/ProjetERC1/StimMFBWake/M1281/', ...
    '/media/nas5/ProjetERC1/StimMFBWake/M1168/', ...
    '/media/nas6/ProjetERC2/Mouse-K182/20200301/_Concatenated/', ...
    '/media/nas5/ProjetERC2/Mouse-994/20191013/PagExp/_Concatenated/', ...
    '/media/nas6/ProjetERC1/StimMFBWake/M1239/Exp2/', ...
    '/media/nas5/ProjetERC1/StimMFBWake/M1162/', ...
    '/media/nas6/ProjetERC1/StimMFBWake/M1199/exp1/', ...
    '/media/nas7/ProjetERC2/Mouse-K239/2021110/_Concatenated/', ...
    '/media/nas5/ProjetERC2/Mouse-K162/20210121/_Concatenated/', ...
    '/media/nas6/ProjetERC1/Known/M1230/', ...
    '/media/nas6/ProjetERC1/Novel/M1230/', ...
    });
%%% ACHTUNG: M1239 has no clean data (only NaN).

% Select the appropriate set of keys
switch experimentName
    case 'SubMFB'
        selected_keys = MFB_keys;
    case 'SubMFBReal'
        selected_keys = MFB_keys;
    case 'SubPAG'
        selected_keys = UMazePAG_keys;
    case 'SubPAGReal'
        selected_keys = UMazePAG_keys;
    case 'SubReversal'
        selected_keys = Reversal_keys;
    case 'SubReversalReal'
        selected_keys = Reversal_keys;
    case 'SubKnown'
        selected_keys = Known_keys;
    case 'SubKnownReal'
        selected_keys = Known_keys;
    case 'SubNovel'
        selected_keys = Novel_keys;
    case 'SubNovelReal'
        selected_keys = Novel_keys;
    case 'Sub'
        selected_keys = [MFB_keys, UMazePAG_keys, Reversal_keys, Known_keys];
    case 'SubReal'
        selected_keys = [MFB_keys, UMazePAG_keys, Reversal_keys, Known_keys];
    otherwise
        warning('Not a subtype. Will choose from general MFB, UMazePAG, or Reversal (no ann).');
end

Dir.path = {}; % Initialize a cell array for paths
Dir.ExpeInfo = {}; % Initialize a cell array for ExpeInfo
a = 0; % Initialize counter

if contains(experimentName, 'Sub')
    keys = python_dict.keys;
    values = python_dict.values; % Extract values from the dictionary
    idx = 1;
    if contains(experimentName, 'Real')
        keys = subpython_REAL.keys;
        values = subpython_REAL.values;
    end
    for a = 1:numel(values)
        if ismember(keys{a}, selected_keys)
            resultsPath = values{a};
            % Assign path
            try
                currentPath = fullfile(resultsPath, '..');
                Dir.path{idx}{1}=cd(cd(fullfile(pathdir, currentPath)));
                Dir.results{idx}{1}=fullfile(pathdir, resultsPath);
            catch
                currentPath = fullfile(resultsPath);
                Dir.path{idx}{1}=cd(cd(fullfile(currentPath)));
                Dir.results{idx}{1}=fullfile(resultsPath);
            end

            % Load ExpeInfo
            expeInfoFile = fullfile(Dir.path{idx}{1}, 'ExpeInfo.mat');
            if isfile(expeInfoFile)
                load(expeInfoFile);
                Dir.ExpeInfo{idx} = ExpeInfo;
            else
                warning('ExpeInfo.mat not found for %s', currentKey);
            end
            idx = idx + 1;
        end
    end

elseif strcmp(lower(experimentName),lower('UMazePAG'))

    % Mouse711
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetERC2/Mouse-711/17032018/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse712
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetERC2/Mouse-712/12042018/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse714
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetERC2/Mouse-714/27022018/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse742
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetERC2/Mouse-742/31052018/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse753
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetERC2/Mouse-753/17072018/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse797
    a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetERC2/Mouse-797/11112018/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse798
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-798/12112018/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse828
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-828/20190305/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse861
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-861/20190313/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse882
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-882/20190409/PAGexp/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse905
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-905/20190404/PAGExp/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse906
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-906/20190418/PAGExp/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse911
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-911/20190508/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse912
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-912/20190515/PAGexp/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse977
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-977/20190812/PAGexp/Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse994
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-994/20191013/PagExp/_Concatenated/';
    %         a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-994/20191106/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1117
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-K117/20201109/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1124
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-K124/20201120/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1161
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-K161/20201224/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1162
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-K162/20210121/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1168
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC2/Mouse-K168/20210122/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1182
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC2/Mouse-K182/20200301/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1186
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC2/Mouse-K186/20210409/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1199
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC2/Mouse-K199/20210408/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1230
    a=a+1;Dir.path{a}{1}='/media/nas7/ProjetERC2/Mouse-K230/20210927/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/nas7/ProjetERC2/Mouse-K230/20211004/_Concatenated/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1239
    a=a+1;Dir.path{a}{1}='/media/nas7/ProjetERC2/Mouse-K239/2021110/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

elseif strcmp(lower(experimentName),lower('StimMFBWake'))

    % Mouse882
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0882/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse936
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0936/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse941
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0941/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse934
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0934/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse935
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0935/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse863
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0863/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse913
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M0913/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1081
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/StimMFBWake/M1081/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % 8 x 2 min pre and post tests mice

    % Mouse1117
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M1117/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1161
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M1161/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1162
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M1162/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1168
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/StimMFBWake/M1168/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1182
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/StimMFBWake/M1182/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/nas7/ProjetERC1/StimMFBWake/M1182/2/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1199
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/StimMFBWake/M1199/exp1/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/nas6/ProjetERC1/StimMFBWake/M1199/exp2/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1223
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/StimMFBWake/M1223/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1228
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/StimMFBWake/M1228/take2/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1239
    a=a+1;
    Dir.path{a}{1}='/media/nas6/ProjetERC1/StimMFBWake/M1239/Exp1/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/nas6/ProjetERC1/StimMFBWake/M1239/Exp2/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1257
    a=a+1;Dir.path{a}{1}='/media/nas7/ProjetERC1/StimMFBWake/M1257/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1281
    a=a+1;Dir.path{a}{1}='/media/nas7/ProjetERC1/StimMFBWake/M1281/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1317
    % exp 1
    a=a+1;
    Dir.path{a}{1}='/media/nas7/ProjetERC1/StimMFBWake/M1317/1/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % exp 2
    Dir.path{a}{2}='/media/nas7/ProjetERC1/StimMFBWake/M1317/2/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1334
    a=a+1;Dir.path{a}{1}='/media/nas7/ProjetERC1/StimMFBWake/M1334/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1336
    a=a+1;Dir.path{a}{1}='/media/nas7/ProjetERC1/StimMFBWake/M1336/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;


elseif strcmp(lower(experimentName),lower('Reversal'))

    % Mouse994
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC3/M994/Reversal/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse 1081
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-K081/20200925/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse 1199
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC3/M1199/Reversal/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

elseif strcmp(lower(experimentName),lower('UMazePAGPCdriven'))

    % Mouse 1115
    a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-K115/20201006/_Concatenated/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

elseif strcmp(lower(experimentName),lower('Novel'))

    %%%% Only hab - 6 mice

    %     % Mouse828
    %     a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-828/20190301/ExploDay/_Concatenated/';
    %     load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    %
    %     % Mouse861
    %     a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-861/20190312/ExploDay/_Concatenated/';
    %     load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    %
    %     % Mouse882 - no spikes
    %     a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC1/M0882/First Exploration/';
    %     load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % %
    % %     % Mouse905
    % %     a=a+1;Dir.path{a}{1}='/media/DataMOBsRAIDN/ProjetERC2/Mouse-714/27022018/_Concatenated/';
    % %     load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    %
    %     % Mouse912
    %     a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-912/20190506/ExploDay/_Concatenated/';
    %     load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    %
    %     % Mouse977
    %
    %     a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-977/20190809/FirstUMaze/_Concatenated/';
    %     load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    %
    %     % Mouse979
    %     a=a+1;Dir.path{a}{1}='/media/nas5/ProjetERC2/Mouse-979/20190828/FirstExplo/_Concatenated/';
    %     load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    %
    %%%%%% PreTests 4 * 2 min, Cond 8 * 4 min, no PostTests - 4 mice

    % MouseK016
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1016/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1081
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1081/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1083
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1083/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1183
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1183/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    %%%%%% PreTests 4 * 2 min, Cond 8 * 4 min, PostTests 4 * 2 min - 2 mice

    % Mouse1116
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1116/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1117
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1117/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    %%%%%% PreTests 8 * 2 min, Cond 8 * 4 min, PostTests 8 * 2 min

    % Mouse1161
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1161/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1162
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1162/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse 1182
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1182/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse1185
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1185/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse 1223
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1223/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse 1228
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1228/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse 1230
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1230/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1281
    a=a+1;Dir.path{a}{1}='/media/nas7/ProjetERC1/Novel/M1281/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1317
    a=a+1;Dir.path{a}{1}='/media/nas7/ProjetERC1/Novel/M1317/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1334 - NO REM
    %     a=a+1;Dir.path{a}{1}='/media/hobbes/DataMOBS163/M1334/Novel/';
    %     load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse1336
    a=a+1;Dir.path{a}{1}='/media/nas7/ProjetERC1/Novel/M1336/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    %%%%%% PreTests 8 * 2 min, Cond 8 * 4 min, no PostTests

    % Mouse1168
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1168/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    %%%%%% PreTests 4 * 4 min, Cond 8 * 4 min, PostTests 4 * 4 min

    % Mouse1239
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/Novel/M1239/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;




elseif strcmp(lower(experimentName),lower('BaselineSleep'))

    % Mouse 1162 - 1
    a=a+1;
    Dir.path{a}{1}='/media/hobbes/DataMOBs155/M1162/BaselineSleep/1/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1162 - 2
    Dir.path{a}{2}='/media/hobbes/DataMOBs155/M1162/BaselineSleep/2/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse 1168 - 1
    a=a+1;
    Dir.path{a}{1}='/media/hobbes/DataMOBs155/M1168/BaselineSleep/1/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1168 - 2
    Dir.path{a}{2}='/media/hobbes/DataMOBs155/M1168/BaselineSleep/2/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1168 - 3
    Dir.path{a}{3}='/media/hobbes/DataMOBs155/M1168/BaselineSleep/3/';
    load([Dir.path{a}{3},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse 1185
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/BaselineSleep/M1185/20210412/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse 1199
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/BaselineSleep/M1199/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

    % Mouse 1230
    a=a+1;Dir.path{a}{1}='/media/nas6/ProjetERC1/BaselineSleep/M1230/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;

elseif strcmp(lower(experimentName),lower('Known'))
    % Mouse 1230
    a=a+1;
    Dir.path{a}{1}='/media/nas6/ProjetERC1/Known/M1230/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1281
    a=a+1;
    Dir.path{a}{1}='/media/nas7/ProjetERC1/Known/M1281/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1317
    a=a+1;
    Dir.path{a}{1}='/media/nas7/ProjetERC1/Known/M1317/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1334
    a=a+1;
    Dir.path{a}{1}='/media/nas7/ProjetERC1/Known/M1334/1/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    Dir.path{a}{2}='/media/nas7/ProjetERC1/Known/M1334/2/';
    load([Dir.path{a}{2},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;
    % Mouse 1336
    a=a+1;
    Dir.path{a}{1}='/media/nas7/ProjetERC1/Known/M1336/';
    load([Dir.path{a}{1},'ExpeInfo.mat']),Dir.ExpeInfo{a}=ExpeInfo;


end

%% Get mice names
for i=1:length(Dir.path)
    Dir.manipe{i}=experimentName;
    if contains(lower(experimentName),'sub')
        if contains(Dir.ExpeInfo{i}.SessionType, 'UMaze')
            Dir.manipe{i} = 'SubUMazePAG';
        else
            Dir.manipe{i}=strcat('Sub', Dir.ExpeInfo{i}.SessionType);
        end
    end
    temp=strfind(Dir.path{i}{1},'Mouse-');
    if isempty(temp)
        temp=strfind(Dir.path{i}{1},'/M');
        if isempty(temp)
            disp('Error in Filename - No MOUSE number')
        else
            if strcmp(Dir.path{i}{1}(temp(1)+2),'1')
                Dir.name{i}=['Mouse',Dir.path{i}{1}(temp(1)+2:temp+5)];
            elseif strcmp(Dir.path{i}{1}(temp(1)+2),'0')
                Dir.name{i}=['Mouse',Dir.path{i}{1}(temp(1)+3:temp+5)];
            else
                Dir.name{i}=['Mouse',Dir.path{i}{1}(temp(1)+2:temp+4)];
            end
        end
    else
        if strcmp(Dir.path{i}{1}(temp(1)+6), 'K')
            Dir.name{i}=['Mouse1',Dir.path{i}{1}(temp(1)+7:temp(1)+9)];
        else
            Dir.name{i}=['Mouse',Dir.path{i}{1}(temp(1)+6:temp(1)+8)];
        end
    end
end

%% Get mice groups

for i=1:length(Dir.path)
    if strcmp(Dir.manipe{i},'UMazePAG')
        % Allocate
        Dir.group{1} = cell(length(Dir.path),1);
        Dir.group{2} = cell(length(Dir.path),1);
        Dir.group{3} = cell(length(Dir.path),1);
        Dir.group{4} = cell(length(Dir.path),1);
        Dir.group{5} = cell(length(Dir.path),1);
        Dir.group{6} = cell(length(Dir.path),1);

        for j=1:length(LFP)
            Dir.group{1}{LFP(j)} = 'LFP';
        end
        for j=1:length(Neurons)
            Dir.group{2}{Neurons(j)} = 'Neurons';
        end
        for j=1:length(ECG)
            Dir.group{3}{ECG(j)} = 'ECG';
        end
        for j=1:length(OB_resp)
            Dir.group{4}{OB_resp(j)} = 'OB_resp';
        end
        for j=1:length(OB_gamma)
            Dir.group{5}{OB_gamma(j)} = 'OB_gamma';
        end
        for j=1:length(PFC)
            Dir.group{6}{PFC(j)} = 'PFC';
        end
    end

end

end
