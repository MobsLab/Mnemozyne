%% Main

% parameter to set manually
expe = 'mfb';  % 'pag' or 'mfb'
SessionTypes = {'TestPre', 'Cond', 'TestPost'};
% maze limits
maze = [0 0; 0 1; 1 1; 1 0; 0.63 0; 0.63 0.75; 0.35 0.75; 0.35 0; 0 0];
shockZone = [0 0; 0 0.43; 0.35 0.43; 0.35 0; 0 0]; 

% specific parameters
switch expe
    case 'pag'
        nMice = [797 798 828 861 882 905 912 977];
        % loop for mouse: get behav data
        for imouse = 1:length(nMice)
            eval(['Mouse' num2str(nMice(imouse)) ' = GetBehavioralDataPAG(nMice(imouse), SessionTypes);']);
        end
        clear nMice SessionTypes imouse
        % save behav data
        save('ERC_behavAversive.mat');
    case 'mfb'
        nMice = [882 941 117 161];
        % loop for mouse: get behav data
        for imouse = 1:length(nMice)
            eval(['Mouse' num2str(nMice(imouse)) ' = GetBehavioralDataMFB(nMice(imouse), SessionTypes);']);
        end
        clear expe SessionTypes nMice imouse
        % save behav data
        save('ERC_behavAppetitive.mat');     
end


%% Auxiliary functions
% PAG
function MouseData = GetBehavioralDataPAG(MouseNum, SessionTypes)
% Load the data
for itype = 1:length(SessionTypes)
    
    Dir = PathForExperimentsERC_Dima(SessionTypes{itype});
    Dir = RestrictPathForExperiment(Dir, 'nMice', MouseNum);
    
    for itest = 1:length(Dir.path{1})
        temp = load([Dir.path{1}{itest} 'behavResources.mat'],...
            'CleanAlignedXtsd', 'CleanAlignedYtsd', 'CleanPosMat');
        
        % Construct X-Y matrix
        time = temp.CleanPosMat(:,1);
        if exist('CleanAlignedXtsd','var')
            X = Data(temp.CleanAlignedXtsd);
            Y = Data(temp.CleanAlignedYtsd);
        else
            X = Data(temp.AlignedXtsd);
            Y = Data(temp.AlignedYtsd);

        end
        S = temp.CleanPosMat(:,4);
        record = [time X Y S];
        
        % Record down data
        MouseData.([SessionTypes{itype} num2str(itest)]) = record;
        
    end
end
end

function MouseData = GetBehavioralDataMFB(MouseNum, SessionTypes)
% MFB
Dir = PathForExperimentsERC_SL('StimMFBWake');
Dir = RestrictPathForExperiment(Dir, 'nMice', MouseNum);

% load behavior
temp = load([Dir.path{1}{1} 'behavResources.mat'],'behavResources',...
            'SessionEpoch');
        
for itype=1:length(SessionTypes)
    for itrial=1:8
        if isfield(temp.SessionEpoch,[SessionTypes{itype} num2str(itrial)])
            % Get position of session
            id_sess = find_sessionid(temp, [SessionTypes{itype} num2str(itrial)]);
            % Extract Data
            [id_sess tdat posmat] = RestrictSession(Dir,[SessionTypes{itype} num2str(itrial)], ...
                'measure','PosMat');
            pm = reshape(posmat{1},length(posmat{1})/4,4);
            time = pm(:,1);
            S = pm(:,4);
            
            [id_sess tdat X] = RestrictSession(Dir,[SessionTypes{itype} num2str(itrial)], ...
                'measure','AlignedXtsd');
            [id_sess tdat Y] = RestrictSession(Dir,[SessionTypes{itype} num2str(itrial)], ...
                'measure','AlignedYtsd');  
                
            record = [time X{1} Y{1} S];
            % Record down data
            MouseData.([SessionTypes{itype} num2str(itrial)]) = record;
        end
    end
end

end