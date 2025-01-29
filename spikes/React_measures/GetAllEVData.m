%% Main


% parameter to set manually
expe = 'pag';  % 'pag' or 'mfb' or 'novel' or 'known'
sleepType = 'NREM'; % 'NREM' or 'REM'
ReactivationsType = 'RipplesEpoch';
%{
if strcmp(expe, 'PAG')
    ReactivationsType <could be> {'Explo', 'CondMov', 'CondFreeze', 'FullTask', 'RipplesEpoch', 'PostTests'};
elseif strcmp(expe, 'MFB')
    ReactivationsType <could be> {'Explo', 'CondMov', 'FullTask', 'RipplesEpoch', 'PostTests'};
elseif strcmp(expe, 'Novel') || strcmp(expe, 'Known')
    ReactivationsType <could be> {'Explo', 'CondMov', 'FullTask', 'RipplesEpoch'};
end
%}


%% Run 
switch expe
    case 'pag'
        nMice = [797 798 828 861 882 905 906 911 912 977 994 1117 1161 1162 1168 1182 1186 1199 1230 1239];
        % Organize and save all EV data in structure
        GetEVDataPAG(nMice, sleepType, ReactivationsType)
    case 'mfb'
        nMice = [1117 1161 1162 1168 1182 1199 1223 1228 1239 1257 1281 1317 1334 1336];
        % Organize and save all EV data in structure
        GetEVDataMFB(nMice, sleepType, ReactivationsType) 
    case 'novel'
        nMice = [1116 1117 1161 1162 1182  1185 1223 1228 1230 1239 1281 1317 1336];
        % Organize and save all EV data in structure
        GetEVDataNovel(nMice, sleepType, ReactivationsType)
    case 'known'
        nMice = [1230 1281 1317 1334 1336];
       % Organize and save all EV data in structure
        GetEVDataKnown(nMice, sleepType, ReactivationsType)
end


%% Auxiliary functions
% PAG
function GetEVDataPAG(nMice, sleepType, ReactivationsType)
% PAG
[tempEV, tempREV, states_sleep, states_wake, num_mice] = ExplainedVariance_master_DB(MouseNum, 'PAG',...
                                                    'PlotResults', false, 'IsII', false, 'SplitSleep', []);

mice = nMice(num_mice);
mouseNames = cell(length(finalMice), 1);
EV = nan(length(finalMice), 1);
REV = nan(length(finalMice), 1);
for imouse = 1:length(mice)
    idSleep = find(cellfun(@(x)strcmp(x, sleepType), states_sleep));
    idReactivations = find(cellfun(@(x)strcmp(x, ReactivationsType), states_wake));
    
    mouseNames{imouse} = strcat('Mouse', num2str(mice(imouse)));
    EV(imouse) = tempEV{idSleep}{idReactivations}(imouse);
    REV(imouse) = tempREV{idSleep}{idReactivations}(imouse);
end                                             

save('ERC_EVAversive.mat', 'mouseNames', 'EV', 'REV');
end



function GetEVDataMFB(MouseNum, sleepType, ReactivationsType)

if strcmp(ReactivationsType, 'CondFreeze')
    error('Error: CondFreeze is not a valid ReactivationType for MFB expe')
end

% MFB
[tempEV, tempREV, states_sleep, states_wake, num_mice] = ExplainedVariance_master_DB(MouseNum, 'MFB',...
                                                    'PlotResults', false, 'IsII', false, 'SplitSleep', []);

mice = nMice(num_mice);
mouseNames = cell(length(finalMice), 1);
EV = nan(length(finalMice), 1);
REV = nan(length(finalMice), 1);
for imouse = 1:length(mice)
    idSleep = find(cellfun(@(x)strcmp(x, sleepType), states_sleep));
    idReactivations = find(cellfun(@(x)strcmp(x, ReactivationsType), states_wake));
    
    mouseNames{imouse} = strcat('Mouse', num2str(mice(imouse)));
    EV(imouse) = tempEV{idSleep}{idReactivations}(imouse);
    REV(imouse) = tempREV{idSleep}{idReactivations}(imouse);
end                                             

save('ERC_EVAppetitve.mat', 'mouseNames', 'EV', 'REV');
end

function GetEVDataNovel(MouseNum, sleepType, ReactivationsType)

if strcmp(ReactivationsType, 'CondFreeze') || strcmp(ReactivationsType, 'PostTests')
    error(sprintf('Error: %s is not a valid ReactivationType for Novel expe', ReactivationsType))
end

% Novel
[tempEV, tempREV, states_sleep, states_wake, num_mice] = ExplainedVariance_master_DB(MouseNum, 'Novel',...
                                                    'PlotResults', false, 'IsII', false, 'SplitSleep', []);

mice = nMice(num_mice);
mouseNames = cell(length(finalMice), 1);
EV = nan(length(finalMice), 1);
REV = nan(length(finalMice), 1);
for imouse = 1:length(mice)
    idSleep = find(cellfun(@(x)strcmp(x, sleepType), states_sleep));
    idReactivations = find(cellfun(@(x)strcmp(x, ReactivationsType), states_wake));
    
    mouseNames{imouse} = strcat('Mouse', num2str(mice(imouse)));
    EV(imouse) = tempEV{idSleep}{idReactivations}(imouse);
    REV(imouse) = tempREV{idSleep}{idReactivations}(imouse);
end                                             

save('ERC_EVNovel.mat', 'mouseNames', 'EV', 'REV');
end

function GetEVDataKnown(MouseNum, sleepType, ReactivationsType)

if strcmp(ReactivationsType, 'CondFreeze') || strcmp(ReactivationsType, 'PostTests')
    error(sprintf('Error: %s is not a valid ReactivationType for Novel expe', ReactivationsType))
end

% Known
[tempEV, tempREV, states_sleep, states_wake, num_mice] = ExplainedVariance_master_DB(MouseNum, 'Known',...
                                                    'PlotResults', false, 'IsII', false, 'SplitSleep', []);

mice = nMice(num_mice);
mouseNames = cell(length(finalMice), 1);
EV = nan(length(finalMice), 1);
REV = nan(length(finalMice), 1);
for imouse = 1:length(mice)
    idSleep = find(cellfun(@(x)strcmp(x, sleepType), states_sleep));
    idReactivations = find(cellfun(@(x)strcmp(x, ReactivationsType), states_wake));
    
    mouseNames{imouse} = strcat('Mouse', num2str(mice(imouse)));
    EV(imouse) = tempEV{idSleep}{idReactivations}(imouse);
    REV(imouse) = tempREV{idSleep}{idReactivations}(imouse);
end                                             

save('ERC_EVKnown.mat', 'mouseNames', 'EV', 'REV');
end
