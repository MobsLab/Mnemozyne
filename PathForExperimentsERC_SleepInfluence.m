function Dir = PathForExperimentsERC_SleepInfluence(experimentName)


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

%% My mice from PAGTest (big zone, big ISIs)
LatencyTest_PAGTest.m


%% Marcelo's mice
863 - 20/05/2019
913 - 21/05/2019
934 - 31/05/2019
935 - 03/06/2019
938 - 06/06/2019


%%
% if strcmp(experimentName,'UMazePAG')
% end
%% Get mice names
for i=1:length(Dir.path)
    Dir.manipe{i}=experimentName;
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
    Dir.manipe{i}=experimentName;
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