p%% Main

% parameter to set manually
expe = 'known';  % 'pag' or 'mfb' or 'novel' or 'known'
SessionTypes = {'PreSleep', 'TestPre' 'Cond', 'TestPost', 'PostSleep'};

% specific parameters
switch expe
    case 'pag'
        nMice = [797 798 828 861 882 905 906 911 912 977 994 1117 1161 1162 1168 1182 1186 1199 1230 1239];
        % loop for mouse: get behav data
        for imouse = 1:length(nMice)
            eval(['Mouse' num2str(nMice(imouse)) ' = GetRipplesDataPAG(nMice(imouse), SessionTypes);']);
        end
        clear nMice SessionTypes imouse
        % save behav data
        save('ERC_RipplesAversive.mat');
    case 'mfb'
        nMice = [1117 1161 1162 1168 1182 1199 1223 1228 1239 1257 1281 1317 1334 1336];
        % loop for mouse: get behav data
        for imouse = 1:length(nMice)
            eval(['Mouse' num2str(nMice(imouse)) ' = GetRipplesDataMFB(nMice(imouse), SessionTypes);']);
        end
        clear expe SessionTypes nMice imouse
        % save behav data
        save('ERC_RipplesAppetitive.mat');  
    case 'novel'
        nMice = [1116 1117 1161 1162 1182  1185 1223 1228 1230 1239 1281 1317 1336];
        % loop for mouse: get behav data
        for imouse = 1:length(nMice)
            eval(['Mouse' num2str(nMice(imouse)) ' = GetRipplesDataNovel(nMice(imouse), SessionTypes);']);
        end
        clear expe SessionTypes nMice imouse
        % save behav data
        save('ERC_RipplesNovel.mat'); 
    case 'known'
        nMice = [1230 1281 1317 1334 1336];
        % loop for mouse: get behav data
        for imouse = 1:length(nMice)
            eval(['Mouse' num2str(nMice(imouse)) ' = GetRipplesDataKnown(nMice(imouse), SessionTypes);']);
        end
        clear expe SessionTypes nMice imouse
        % save behav data
        save('ERC_RipplesKnown.mat'); 
end


%% Auxiliary functions
% PAG
function MouseData = GetRipplesDataPAG(MouseNum, SessionTypes)
% PAG
Dir = PathForExperimentsERC('UMazePAG');
Dir = RestrictPathForExperiment(Dir, 'nMice', MouseNum);

% load behavior
for isession = 1:length(Dir.path{1})
    tempB = load([Dir.path{1}{isession} 'behavResources.mat'],'behavResources',...
        'SessionEpoch');
    tempR = load([Dir.path{1}{isession} 'SWR.mat'],'ripples', 'tRipples');
    
    for itype=1:length(SessionTypes)
        foundNames = FindSessionID_ERC_in_struct(tempB.SessionEpoch, SessionTypes{itype});
        
        for itrial = 1:length(foundNames)
            if isfield(tempB.SessionEpoch, foundNames{itrial})
                % Extract Data
                ripplesTimeTSD = Restrict(tempR.tRipples, tempB.SessionEpoch.(foundNames{itrial}));
                ripplesTime = Range(ripplesTimeTSD, 's');
                
                % Record down data
                if length(Dir.path{1}) > 1
                    MouseData{isession}.(foundNames{itrial}) = ripplesTime;
                else
                    MouseData.(foundNames{itrial}) = ripplesTime;
                    
                end
            end
        end
    end
end
end



function MouseData = GetRipplesDataMFB(MouseNum, SessionTypes)
% PAG
Dir = PathForExperimentsERC('StimMFBWake');
Dir = RestrictPathForExperiment(Dir, 'nMice', MouseNum);

% load behavior
for isession = 1:length(Dir.path{1})
    tempB = load([Dir.path{1}{isession} 'behavResources.mat'],'behavResources',...
        'SessionEpoch');
    tempR = load([Dir.path{1}{isession} 'SWR.mat'],'ripples', 'tRipples');
    
    for itype=1:length(SessionTypes)
        foundNames = FindSessionID_ERC_in_struct(tempB.SessionEpoch, SessionTypes{itype});
        
        for itrial = 1:length(foundNames)
            if isfield(tempB.SessionEpoch, foundNames{itrial})
                % Extract Data
                ripplesTimeTSD = Restrict(tempR.tRipples, tempB.SessionEpoch.(foundNames{itrial}));
                ripplesTime = Range(ripplesTimeTSD, 's');
                
                % Record down data
                if length(Dir.path{1}) > 1
                    MouseData{isession}.(foundNames{itrial}) = ripplesTime;
                else
                    MouseData.(foundNames{itrial}) = ripplesTime;
                    
                end
            end
        end
    end
end
end

function MouseData = GetRipplesDataNovel(MouseNum, SessionTypes)
% PAG
Dir = PathForExperimentsERC('Novel');
Dir = RestrictPathForExperiment(Dir, 'nMice', MouseNum);

% load behavior
for isession = 1:length(Dir.path{1})
    tempB = load([Dir.path{1}{isession} 'behavResources.mat'],'behavResources',...
        'SessionEpoch');
    tempR = load([Dir.path{1}{isession} 'SWR.mat'],'ripples', 'tRipples');
    
    for itype=1:length(SessionTypes)
        foundNames = FindSessionID_ERC_in_struct(tempB.SessionEpoch, SessionTypes{itype});
        
        for itrial = 1:length(foundNames)
            if isfield(tempB.SessionEpoch, foundNames{itrial})
                % Extract Data
                ripplesTimeTSD = Restrict(tempR.tRipples, tempB.SessionEpoch.(foundNames{itrial}));
                ripplesTime = Range(ripplesTimeTSD, 's');
                
                % Record down data
                if length(Dir.path{1}) > 1
                    MouseData{isession}.(foundNames{itrial}) = ripplesTime;
                else
                    MouseData.(foundNames{itrial}) = ripplesTime;
                    
                end
            end
        end
    end
end
end

function MouseData = GetRipplesDataKnown(MouseNum, SessionTypes)
% PAG
Dir = PathForExperimentsERC('Known');
Dir = RestrictPathForExperiment(Dir, 'nMice', MouseNum);

% load behavior
for isession = 1:length(Dir.path{1})
    tempB = load([Dir.path{1}{isession} 'behavResources.mat'],'behavResources',...
        'SessionEpoch');
    tempR = load([Dir.path{1}{isession} 'SWR.mat'],'ripples', 'tRipples');
    
    for itype=1:length(SessionTypes)
        foundNames = FindSessionID_ERC_in_struct(tempB.SessionEpoch, SessionTypes{itype});
        
        for itrial = 1:length(foundNames)
            if isfield(tempB.SessionEpoch, foundNames{itrial})
                % Extract Data
                ripplesTimeTSD = Restrict(tempR.tRipples, tempB.SessionEpoch.(foundNames{itrial}));
                ripplesTime = Range(ripplesTimeTSD, 's');
                
                % Record down data
                if length(Dir.path{1}) > 1
                    MouseData{isession}.(foundNames{itrial}) = ripplesTime;
                else
                    MouseData.(foundNames{itrial}) = ripplesTime;
                    
                end
            end
        end
    end
end
end
