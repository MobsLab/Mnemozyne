function foundNames = FindSessionID_ERC_in_struct(SessionEpoch, SessionName)
%
% Finds ids of a particular session types in ERC experiments SessionEpoch
% structure
%
% INPUT
%
%     SessionEpoch        structure that contains intervalSet for every
%                         epoch
%     SessionName         Name to search
% 
%  OUTPUT
%
%     ids                 ids found
%
% Coded by Dima Bryzgalov, MOBS team, Paris, France
% 24/02/2023 HELP UKRAINIAN REFUGEES
% github.com/bryzgalovdms


allfields = fieldnames(SessionEpoch);
foundNamesAll = cell(length(allfields));

for k=1:length(allfields)
    if ~isempty(strfind(allfields{k}, SessionName))
        foundNamesAll{k} = allfields{k};
    end
end
foundNames = foundNamesAll(~cellfun('isempty',foundNamesAll));

% Issue the warning in case you did not find
if isempty(foundNames)
    warning(['No instances of ' SessionName ' were found in SessionEpoch']);
end

end