function foldertosave = ChooseFolderForFigures(DataType)
%
% Returns name for folder to save figures for Arsenii's project
%
% INPUT
%
%     DataType          type of data you are processing
%                       Possible options:
%                       'Behavior', 'Heart', 'LFP',
%                       'Miscellaneous', 'PlaceFieldFinal',
%                       'PlaceFieldsStability', 'ReactReplay',
%                       'Sleep', 'Spikes'
% 
%  OUTPUT
%
%     foldertosave      string with a folder name
%
% Coded by Dima Bryzgalov, MOBS team, Paris, France
% 05/11/2020
% github.com/bryzgalovdm


%% Folder for intermediate figures

origdir = [dropbox 'figures\'];

%% Next folder depends of DaytaType

if strcmp(DataType,'Behavior')
    foldertosave = [origdir 'Behavior'];
elseif strcmp(DataType,'Heart')
    foldertosave = [origdir 'Heart'];
elseif strcmp(DataType,'LFP')
    foldertosave = [origdir 'LFP'];
elseif strcmp(DataType,'Miscellaneous')
    foldertosave = [origdir 'Miscellaneous'];
elseif strcmp(DataType,'PlaceFieldFinal')
    foldertosave = [origdir 'PlaceField_Final'];
elseif strcmp(DataType,'PlaceFieldsStability')
    foldertosave = [origdir 'PlaceFields_Stability'];
elseif strcmp(DataType,'ReactReplay')
    foldertosave = [origdir 'React-Replay'];    
elseif strcmp(DataType,'Sleep')
    foldertosave = [origdir 'Sleep'];    
elseif strcmp(DataType,'Spikes')
    foldertosave = [origdir 'Spikes'];
else
    error('Unrecognized Datatype. Please (type ''help ChooseFolderForFigures'' for details)');

end