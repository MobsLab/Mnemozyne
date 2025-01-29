%% Main

% parameter to set manually
expe = 'pag';  % 'pag' or 'mfb' or 'novel' or 'known'
SessionTypes = {'Hab', 'TestPre', 'Cond', 'TestPost'};
% maze limits
maze = [0 0; 0 1; 1 1; 1 0; 0.63 0; 0.63 0.75; 0.35 0.75; 0.35 0; 0 0];
shockZone = [0 0; 0 0.43; 0.35 0.43; 0.35 0; 0 0]; 

% specific parameters
switch expe
    case 'pag'
        % TODO: check this
        nMice = [797 798 828 861 882 905 906 911 912 977 994 1117 1161 1162 1168 1182 1186 1199 1230 1239];
        % loop for mouse: get behav data
        for imouse = 1:length(nMice)
            eval(['Mouse' num2str(nMice(imouse)) ' = GetBehavioralDataPAG(nMice(imouse), SessionTypes);']);
        end
        clear nMice SessionTypes imouse
        % save behav data
        save('ERC_behavAversive.mat');
    case 'mfb'
        nMice = [1117 1161 1162 1168 1182 1199 1223 1228 1239 1257 1281 1317 1334 1336];
        % loop for mouse: get behav data
        for imouse = 1:length(nMice)
            eval(['Mouse' num2str(nMice(imouse)) ' = GetBehavioralDataMFB(nMice(imouse), SessionTypes);']);
        end
        clear expe SessionTypes nMice imouse
        % save behav data
        save('ERC_behavAppetitive.mat');
    case 'novel'
        nMice = [1116 1117 1161 1162 1182  1185 1223 1228 1230 1239 1281 1317 1336];
        % loop for mouse: get behav data
        for imouse = 1:length(nMice)
            eval(['Mouse' num2str(nMice(imouse)) ' = GetBehavioralDataNovel(nMice(imouse), SessionTypes);']);
        end
        clear expe SessionTypes nMice imouse
        % save behav data
        save('ERC_behavNovel.mat');
    case 'known'
        nMice = [1230 1281 1317 1334 1336];
        % loop for mouse: get behav data
        for imouse = 1:length(nMice)
            eval(['Mouse' num2str(nMice(imouse)) ' = GetBehavioralDataKnown(nMice(imouse), SessionTypes);']);
        end
        clear expe SessionTypes nMice imouse
        % save behav data
        save('ERC_behavKnown.mat');
end


%% Auxiliary functions
% PAG
function MouseData = GetBehavioralDataPAG(MouseNum, SessionTypes)
% PAG
Dir = PathForExperimentsERC('UMazePAG');
Dir = RestrictPathForExperiment(Dir, 'nMice', MouseNum);

% load behavior
for isession = 1:length(Dir.path{1})
    temp = load([Dir.path{1}{isession} 'behavResources.mat'],'behavResources',...
        'SessionEpoch');
    
    for itype=1:length(SessionTypes)
        id_sess = FindSessionID_ERC(temp.behavResources, SessionTypes{itype});
        
        for itrial = 1:length(id_sess)
            if isfield(temp.SessionEpoch,[SessionTypes{itype} num2str(itrial)])
                % Extract Data
                pm = temp.behavResources(id_sess(itrial)).PosMat;
                
                time = pm(:,1)-pm(1,1);
                S = pm(:,4);
                
                x = Data(temp.behavResources(id_sess(itrial)).AlignedXtsd);
                y = Data(temp.behavResources(id_sess(itrial)).AlignedYtsd);
                
                record = [time x y S];
                % Record down data
                if length(Dir.path{1}) > 1
                    MouseData{isession}.([SessionTypes{itype} num2str(itrial)]) = record;
                else
                    MouseData.([SessionTypes{itype} num2str(itrial)]) = record;
                    
                end
            end
        end
    end
end
end



function MouseData = GetBehavioralDataMFB(MouseNum, SessionTypes)
% MFB
Dir = PathForExperimentsERC('StimMFBWake');
Dir = RestrictPathForExperiment(Dir, 'nMice', MouseNum);

% load behavior
for isession = 1:length(Dir.path{1})
    temp = load([Dir.path{1}{isession} 'behavResources.mat'],'behavResources',...
        'SessionEpoch');
    
    for itype=1:length(SessionTypes)
        id_sess = FindSessionID_ERC(temp.behavResources, SessionTypes{itype});
        
        for itrial = 1:length(id_sess)
            if isfield(temp.SessionEpoch,[SessionTypes{itype} num2str(itrial)])
                % Extract Data
                pm = temp.behavResources(id_sess(itrial)).PosMat;
                
                time = pm(:,1)-pm(1,1);
                S = pm(:,4);
                
                x = Data(temp.behavResources(id_sess(itrial)).AlignedXtsd);
                y = Data(temp.behavResources(id_sess(itrial)).AlignedYtsd);
                
                record = [time x y S];
                % Record down data
                if length(Dir.path{1}) > 1
                    MouseData{isession}.([SessionTypes{itype} num2str(itrial)]) = record;
                else
                    MouseData.([SessionTypes{itype} num2str(itrial)]) = record;
                    
                end
            end
        end
    end
end

end


% Novel
function MouseData = GetBehavioralDataNovel(MouseNum, SessionTypes)
% PAG
Dir = PathForExperimentsERC('Novel');
Dir = RestrictPathForExperiment(Dir, 'nMice', MouseNum);

% load behavior
for isession = 1:length(Dir.path{1})
    temp = load([Dir.path{1}{isession} 'behavResources.mat'],'behavResources',...
        'SessionEpoch');
    
    for itype=1:length(SessionTypes)
        id_sess = FindSessionID_ERC(temp.behavResources, SessionTypes{itype});
        
        for itrial = 1:length(id_sess)
            if isfield(temp.SessionEpoch,[SessionTypes{itype} num2str(itrial)])
                % Extract Data
                pm = temp.behavResources(id_sess(itrial)).PosMat;
                
                time = pm(:,1)-pm(1,1);
                S = pm(:,4);
                
                x = Data(temp.behavResources(id_sess(itrial)).AlignedXtsd);
                y = Data(temp.behavResources(id_sess(itrial)).AlignedYtsd);
                
                record = [time x y S];
                % Record down data
                if length(Dir.path{1}) > 1
                    MouseData{isession}.([SessionTypes{itype} num2str(itrial)]) = record;
                else
                    MouseData.([SessionTypes{itype} num2str(itrial)]) = record;
                    
                end
            end
        end
    end
end
end


% Known
function MouseData = GetBehavioralDataKnown(MouseNum, SessionTypes)
% PAG
Dir = PathForExperimentsERC('Known');
Dir = RestrictPathForExperiment(Dir, 'nMice', MouseNum);

% load behavior
for isession = 1:length(Dir.path{1})
    temp = load([Dir.path{1}{isession} 'behavResources.mat'],'behavResources',...
        'SessionEpoch');
    
    for itype=1:length(SessionTypes)
        id_sess = FindSessionID_ERC(temp.behavResources, SessionTypes{itype});
        
        for itrial = 1:length(id_sess)
            if isfield(temp.SessionEpoch,[SessionTypes{itype} num2str(itrial)])
                % Extract Data
                pm = temp.behavResources(id_sess(itrial)).PosMat;
                
                time = pm(:,1)-pm(1,1);
                S = pm(:,4);
                
                x = Data(temp.behavResources(id_sess(itrial)).AlignedXtsd);
                y = Data(temp.behavResources(id_sess(itrial)).AlignedYtsd);
                
                record = [time x y S];
                % Record down data
                if length(Dir.path{1}) > 1
                    MouseData{isession}.([SessionTypes{itype} num2str(itrial)]) = record;
                else
                    MouseData.([SessionTypes{itype} num2str(itrial)]) = record;
                    
                end
            end
        end
    end
end
end
