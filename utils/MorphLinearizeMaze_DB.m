function MorphLinearizeMaze_DB(nMice, varargin)
%
% This function morphs Umaze to the unified 0-1 coordinates and
% linearizes trajectories from 0 (shock zone) to 1 (safe zone)
%
% INPUT
%
%     nMice                     which mice do you wnat to transfer
% 
%     OPTIONAL:
% 
%     ReDoFlag   (boolean)      do you want skip if already done, or redo
%                               (default - false)
%
%  OUTPUT
%
%     It saves new variables in beahvResources.mat
%
% Coded by Dima Bryzgalov, MOBS team, Paris, France
% 16/06/2020
% github.com/bryzgalovdm

%% Hyperparameters
SessionNames = {'Hab', 'TestPreFakeStim', 'TestPre', 'Cond', 'CondPCDriven', 'TestPost', 'ExploAfter'};
% SessionNames = {'TestPost', 'ExploAfter'};
% SessionNames = {'ExploAfter'};
% SessionNames = {'PreSleep', 'Hab', 'TestPre', 'Cond', 'TestPost', 'Extinct'}

%% Default values of optional arguments
redo = false;

%% Optional parameters handling
for i=1:2:length(varargin)
    
    switch(lower(varargin{i}))
        
        case 'redo'
            redo = varargin{i+1};
            if length(redo)>1
                error('Incorrect value for property ''ReDo'' (type ''help MorphLinearizeMaze_DB'' for details).');
            end
            
    end
end


%% Build directories to transform

Dir = PathForExperimentsERC_Dima(SessionNames{1});
Dir = RestrictPathForExperiment(Dir, 'nMice', nMice);
for isess = 2:length(SessionNames)
    
    Dir_temp = PathForExperimentsERC_Dima(SessionNames{isess});
    Dir_temp = RestrictPathForExperiment(Dir_temp, 'nMice', nMice);
    
    Dir = MergePathForExperiment(Dir, Dir_temp);
end

%% Main loop
% Morph first
for i = 1:length(Dir.path)
    for k = 1:length(Dir.path{i})
        MorphMaze(Dir.path{i}{k}, redo);
    end
end
% Then linearize
for i = 1:length(Dir.path)
    for k = 1:length(Dir.path{i})
        LinearizeMaze(Dir.path{i}{k}, redo);
    end
end

end




%% Auxiliary functions

% Morph maze
function MorphMaze(directory, redo)
load([directory '/behavResources.mat']);


if ~exist('AlignedXtsd','var')
    [AlignedXtsd,AlignedYtsd,ZoneEpochAligned,XYOutput] = MorphMazeToSingleShape_EmbReact_DB...
        (Xtsd,Ytsd, Zone{1}, ref, Ratio_IMAonREAL);
    
    save([directory 'behavResources.mat'], 'AlignedXtsd', 'AlignedYtsd', 'ZoneEpochAligned',...
        'XYOutput',  '-append');
else
    if redo
        [AlignedXtsd,AlignedYtsd,ZoneEpochAligned,XYOutput] = MorphMazeToSingleShape_EmbReact_DB...
            (Xtsd,Ytsd, Zone{1}, ref, Ratio_IMAonREAL);
        
        save([directory 'behavResources.mat'], 'AlignedXtsd', 'AlignedYtsd', 'ZoneEpochAligned',...
            'XYOutput',  '-append');
    end
end
close all

end

% Linearize maze
function LinearizeMaze(directory, redo)

load([directory '/behavResources.mat']);

if ~exist('LinearDist','var')
    
    figure('units', 'normalized', 'outerposition', [0 1 0.5 0.8]);
    
    
    imagesc(mask+Zone{1})
    curvexy=ginput(4);
    clf
    
    xxx = Data(Ytsd)';
    yyy = Data(Xtsd)';
    mapxy=[Data(Ytsd)'; Data(Xtsd)']';
    [xy,distance,t] = distance2curve(curvexy,mapxy*Ratio_IMAonREAL,'linear');
    
    t(isnan(xxx))=NaN;
    
    subplot(211)
    imagesc(mask+Zone{1})
    hold on
    plot(Data(Ytsd)'*Ratio_IMAonREAL,Data(Xtsd)'*Ratio_IMAonREAL)
    subplot(212)
    plot(t), ylim([0 1])
    
    saveas(gcf,[directory 'lineartraj.fig']);
    saveFigure(gcf,'lineartraj', directory);
    close(gcf);
    
    LinearDist=tsd(Range(Xtsd),t);
    
    save([directory 'behavResources.mat'], 'LinearDist','-append');
else
    if redo
        figure('units', 'normalized', 'outerposition', [0 1 0.5 0.8]);
        
        
        imagesc(mask+Zone{1})
        curvexy=ginput(4);
        clf
        
        xxx = Data(Ytsd)';
        yyy = Data(Xtsd)';
        mapxy=[Data(Ytsd)'; Data(Xtsd)']';
        [xy,distance,t] = distance2curve(curvexy,mapxy*Ratio_IMAonREAL,'linear');
        
        t(isnan(xxx))=NaN;
        
        subplot(211)
        imagesc(mask+Zone{1})
        hold on
        plot(Data(Ytsd)'*Ratio_IMAonREAL,Data(Xtsd)'*Ratio_IMAonREAL)
        subplot(212)
        plot(t), ylim([0 1])
        
        saveas(gcf,[directory 'lineartraj.fig']);
        saveFigure(gcf,'lineartraj', directory);
        close(gcf);
        
        LinearDist=tsd(Range(Xtsd),t);
        
        save([directory 'behavResources.mat'], 'LinearDist','-append');
    end
end

end