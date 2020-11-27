%% Main
nMice = [797 798 828 861 882 905 912 977];
SessionTypes = {'TestPre', 'Cond', 'TestPost'};

for imouse = 1:length(nMice)
    eval(['Mouse' num2str(nMice(imouse)) ' = GetBehavioralData(nMice(imouse), SessionTypes);']);
end

maze = [0 0; 0 1; 1 1; 1 0; 0.63 0; 0.63 0.75; 0.35 0.75; 0.35 0; 0 0];
shockZone = [0 0; 0 0.43; 0.35 0.43; 0.35 0; 0 0]; 

clear nMice SessionTypes imouse
save('ERC_behavAversive.mat');


%% Auxiliary functions
function MouseData = GetBehavioralData(MouseNum, SessionTypes)

% Load the data
for itype = 1:length(SessionTypes)
    
    Dir = PathForExperimentsERC_Dima(SessionTypes{itype});
    Dir = RestrictPathForExperiment(Dir, 'nMice', MouseNum);
    
    for itest = 1:length(Dir.path{1})
        temp = load([Dir.path{1}{itest} 'behavResources.mat'],...
            'CleanAlignedXtsd', 'CleanAlignedYtsd', 'CleanPosMat');
        
        % Construct X-Y matrix
        time = temp.CleanPosMat(:,1);
        X = Data(temp.CleanAlignedXtsd);
        Y = Data(temp.CleanAlignedYtsd);
        S = temp.CleanPosMat(:,4);
        record = [time X Y S];
        
        % Record down data
        MouseData.([SessionTypes{itype} num2str(itest)]) = record;
        
    end
end

end