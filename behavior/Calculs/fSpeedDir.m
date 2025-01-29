function speeddir = fSpeedDir(a,id_Sess,varargin)
%
%   INPUT
%       beh                         cell array conainting behavResources for 
%                                   each animal in the anlaysis
%       id_Sess                     cell array with indexes of sessions for
%                                   each mouse
%                                   format -> {mouse1,sess1; 
%                                              mouse2,sess2;
%                                              etc...}
%
%   OPTIONAL (VARARGIN)
%       cond                        conditionning session (1/0)
%                                   default -> 1 
%
%   OUTPUT
%       speed.data                  cell array conataining:                                   
%       -                           xdir              x coordinates in U-Maze {direction, segments}
%       -                           ydir              y coordinates in U-Maze {direction, segments}    
%       -                           vdir              speed for each timepoints
%       -                           speed             speed by direction (toward vs away)
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 20/05/2021
% github.com/samlaventure

% Default values
cond=1;

% Optional Parameters
for i=1:2:length(varargin)    
    switch(lower(varargin{i})) 
        case 'cond'
            cond = varargin{i+1};
            if ~(cond==1) && ~(cond==0)
                error('Incorrect value for property ''cond'' (must be 0 or 1');
            end
    end
end

for i=1:length(a)
    % try to load SpeedDir variable
    load([Dir.path{i}{1} '/behavResources.mat'], 'SpeedDir');
    % if it doesn't exist, will create it
    % BE CAREFUL: THE ORDER IS -> PRE, COND, POST
    if ~exist('SpeedDir','var') || recompute
        %Pre-tests
        for k=1:length(id_Sess{1,i})
            beh = a{i}.behavResources;
            idx = id_Sess{1,i}(k);
            [xdir{1,k} ydir{1,k} vdir{1,k} speed(1,k,1:3)] = SpeedUmaze(beh, idx); 
        end
        %Cond
        if cond
            for k=1:length(id_Sess{3,i})
                beh = a{i}.behavResources;
                idx = id_Sess{3,i}(k);
                [xdir{2,k} ydir{2,k} vdir{2,k} speed(2,k,1:3)] = SpeedUmaze(beh, idx);
            end
        end
        %Post-tests
        for k=1:length(id_Sess{2,i})
            beh = a{i}.behavResources;
            idx = id_Sess{2,i}(k);
            [xdir{3,k} ydir{3,k} vdir{3,k} speed(3,k,1:3)] = SpeedUmaze(beh, idx);
        end
        % grouped by session
        for idir=1:2
            for isess=1:3
                if isess==2
                    it = nbcond{i};
                else
                    it = nbprepost(i);
                end
                all_mean(isess,idir) = nanmean(speed(isess,1:it,idir)); 
            end
        end
        % prep by mouse
        sd{i}.xdir = xdir;
        sd{i}.ydir = ydir;
        sd{i}.vdir = vdir;
        sd{i}.speed = speed;
        allmean_gr(i,1:3,1:2) = all_mean;
        % saving to file (make future run faster)
        SpeedDir.xdir = xdir;
        SpeedDir.ydir = ydir;
        SpeedDir.vdir = vdir;
        SpeedDir.speed = speed;
        SpeedDir.all_mean = all_mean;   
        SpeedDir.info = {'xdir - x coordinates {session,trial}', ...
            'ydir - y coordinates {session,trial}', ...
            'vdir - speed for each timepoint {session,trial}', ...
            'speed - speed for each direction {session,trial,direction}'};
        save([Dir.path{i}{1} '/behavResources.mat'], 'SpeedDir','-append');
        clear SpeedDir
    else
        load([Dir.path{i}{1} '/behavResources.mat'], 'SpeedDir');
        sd{i} = SpeedDir;
        allmean_gr(i,1:3,1:2) = sd{i}.all_mean;
    end
end
speeddir.data = sd;
speeddir.sessavg = allmean_gr;