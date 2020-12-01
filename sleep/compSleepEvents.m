function [fig_rip] = compSleepEvents(expe, mice_num)

%==========================================================================
% Details: compare sleep events (ripples, spindles, deltas if any) between
% pre and post sleep sessions
%
% INPUTS:
%       - expe              Name of experiment in PathForExperiment
%       - mice_num          ID # of all mice for the analyses
%
% OUTPUT:
%       - figure including:
%           - 
%
% NOTES:
%       - There might be a problem with the figure DYNAMICS
%
%   Written by Samuel Laventure - 2019
%      
%==========================================================================

%% Parameters
sav=1;
dur_parts=10; %duration of sleep parts in minutes
dur_small=1; %duration of small bins of sleep parts in minutes 


% Directory to save and name of the figure to save
dir_out = [pwd '/' expe '/ripples/' date '/'];
%create folders
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

if strcmp(expe,'StimMFBWake')
    Dir = PathForExperimentsERC_SL(expe);
elseif strcmp(expe,'UMazePAG') 
    Dir = PathForExperimentsERC_Dima(expe);
else    
    warning('Exited. Verify experiment name');
end
Dir = RestrictPathForExperiment(Dir, 'nMice', mice_num);

% set text format
set(0,'defaulttextinterpreter','latex');
set(0,'DefaultTextFontname', 'Arial')
set(0,'DefaultAxesFontName', 'Arial')
set(0,'defaultTextFontSize',12)
set(0,'defaultAxesFontSize',12)

% var init
stageName = {'NREM','REM','Wake','N1','N2','N3','Sleep'};

%%
%#####################################################################
%#                           M  A  I  N
%#####################################################################

for isuj = 1:length(Dir.path)
    %% GET SESSION and STAGE EPOCHS
    % load sleep scoring
    try
        load([Dir.path{isuj}{1} 'SleepSubstages.mat'],'Epoch');
        sEpoch{3,1} = Epoch{7};                   % nrem
        sEpoch{3,2} = Epoch{4};                   % rem
        sEpoch{3,3} = Epoch{5};                   % wake
        sEpoch{3,4} = Epoch{1};                   % n1
        sEpoch{3,5} = Epoch{2};                   % n2
        sEpoch{3,6} = Epoch{3};                   % n3
        sEpoch{3,7} = or(Epoch{5},Epoch{7});      % sleep
        subst = 1;
        clear Epoch
        try
            load([Dir.path{isuj}{1} 'SleepScoring_OBGamma.mat'],'sleep_array');
        catch
            load([Dir.path{isuj}{1} 'SleepScoring_Accelero.mat'],'sleep_array');
        end 
    catch
        try
            load([Dir.path{isuj}{1} 'SleepScoring_OBGamma.mat'], 'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch');
        catch
            load([Dir.path{isuj}{1} 'SleepScoring_Accelero.mat'], 'Wake', 'Sleep', 'SWSEpoch', 'REMEpoch');
        end 
        sEpoch{3,1} = SWSEpoch;                   % nrem
        sEpoch{3,2} = REMEpoch;                   % rem
        sEpoch{3,3} = Wake;                       % wake
        sEpoch{3,7} = Sleep;                      % sleep
        subst = 0;
        clear Wake Sleep SWSEpoch REMEpoch
    end
    
    % load behavResources (session epochs)
    load([Dir.path{isuj}{1} 'behavResources.mat'], 'SessionEpoch','Vtsd');
    % restrict to pre/post sessions
    for istage=1:length(stageName)
        if ~(subst) && istage>3 
            istage = 7;
        end
        % speed restriction
        % Locomotion threshold
        immobileEpoch = thresholdIntervals(tsd(Range(Vtsd)...
            ,movmedian(Data(Vtsd),5)),5,'Direction','Below');
        try
            sEpoch{1,istage} = and(and(sEpoch{3,istage},SessionEpoch.BaselineSleep),immobileEpoch);    
        catch
            sEpoch{1,istage} = and(and(sEpoch{3,istage},SessionEpoch.PreSleep),immobileEpoch);    
        end
        sEpoch{2,istage} = and(and(sEpoch{3,istage},SessionEpoch.PostSleep),immobileEpoch);    
    end
    clear SessionEpoch 

    %% LOADING EVENTS
    % Ripples
    load([Dir.path{isuj}{1} 'Ripples.mat'], 'Ripples','RipplesEpoch','T');
    for istage=1:length(stageName)
        for isess=1:2
            if ~(subst) && istage>3
                istage=7;
            end
            rip.epoch{isuj,isess,istage} = and(RipplesEpoch,sEpoch{isess,istage});
            % identify event indexes
            idx = find(ismember(Start(RipplesEpoch),Start(rip.epoch{isuj,isess,istage})));
            ripstart = Start(and(rip.epoch{isuj,isess,istage},sEpoch{isess,istage}));
                        
            rip.amp{isuj,isess,istage} = Ripples(idx,6);
            rip.freq{isuj,isess,istage} = Ripples(idx,5); 
            rip.dur{isuj,isess,istage} = Ripples(idx,4); 
            rip.waveforms{isuj,isess,istage} = T(idx,1:size(T,2));
            
            % calculate densities
            numss = length(idx);       
            sesslen = sum(Stop(sEpoch{isess,istage},'s')-Start(sEpoch{isess,istage},'s'));
            % global density
            rip.globalden{isuj,isess,istage} = numss/sesslen;
            % local density
            for irip=1:length(ripstart)
                numev(irip) = length(find(ripstart<ripstart(irip)+30*1E4 & ripstart>ripstart(irip)-30*1E4));
            end
            rip.localden{isuj,isess,istage} = mean(numev);
            
            ripmean.amp(isess,istage,isuj) = mean(rip.amp{isuj,isess,istage});
            ripmean.freq(isess,istage,isuj) = mean(rip.freq{isuj,isess,istage});
            ripmean.dur(isess,istage,isuj) = mean(rip.dur{isuj,isess,istage});
            if ~isempty(rip.waveforms{isuj,isess,istage})
                ripmean.waveforms(isess,istage,isuj,1:size(rip.waveforms{isuj,isess,istage},2)) ...
                    = mean(rip.waveforms{isuj,isess,istage});
            end
            ripmean.globalden(isess,istage,isuj) = mean(rip.globalden{isuj,isess,istage});
            ripmean.localden(isess,istage,isuj) = mean(rip.localden{isuj,isess,istage});
        end
    end
    clear Ripples RipplesEpoch T     
end

%%
%#####################################################################
%#                        F I G U R E S
%#####################################################################

% Ripples
supertit = 'Ripples global figure';
fig_rip = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1600 2200],'Name', supertit, 'NumberTitle','off')
    for istage=1:length(stageName)-1
        % set right number for stage
             
        subplot(6,6,istage)
            maxy = round(max(max(max(squeeze(squeeze(ripmean.waveforms(:,istage,:,:)))))),-3);
            miny = round(min(min(min(squeeze(squeeze(ripmean.waveforms(:,istage,:,:)))))),-3);
            if ~isempty(find(ripmean.waveforms(1,istage,:,:,:)>0))
                if length(Dir.path)==1
                    avgevent = repmat(squeeze(squeeze(ripmean.waveforms(1,istage,:,:))),1,2); % fix if only 1 mouse
                else  
                    avgevent = squeeze(squeeze(ripmean.waveforms(1,istage,:,:)));
                end
                hpre = shadedErrorBar([],avgevent,{@mean, @std},'-k',1);
                
            else
                yl = yline(0,'--','No PRE event');
                yl.LabelHorizontalAlignment = 'center';
                yl.LabelVerticalAlignment = 'bottom';
                yl.Color = 'k';
            end
            hold on
            if ~isempty(ripmean.waveforms(2,istage,:,:,:))
                if length(Dir.path)==1
                    avgevent = repmat(squeeze(squeeze(ripmean.waveforms(2,istage,:,:))),1,2); % fix if only 1 mouse
                else  
                    avgevent = squeeze(squeeze(ripmean.waveforms(2,istage,:,:)));
                end
                hpost = shadedErrorBar([],avgevent,{@mean, @std},'-b',1);
                clear avgevent
            else
                yl = yline(10,'--','No POST event');
                yl.LabelHorizontalAlignment = 'center';
                yl.LabelVerticalAlignment = 'top';
                yl.Color = 'b';
            end
            title(stageName{istage})
            xlabel('time (ms)')
            ylim([miny maxy])
            if istage==1
                ylabel('uV')
                %legend (make legend outside of plot and subplot!)
                axP = get(gca,'Position');
                [~,hobj,~,~] = legend([hpre.mainLine hpost.mainLine],{'pre','post'},'Location','westoutside');
                hl = findobj(hobj,'type','line');
                set(hl,'LineWidth',3); % make line ticker
                set(gca, 'Position', axP)
            end
    end
    for i=1:length(Dir.path)
        nanfix(i,1) = nan;
    end
    ampdat = [squeeze(ripmean.amp(1,1,:)) squeeze(ripmean.amp(2,1,:)) nanfix squeeze(ripmean.amp(1,2,:)) squeeze(ripmean.amp(2,2,:)) nanfix ...
         squeeze(ripmean.amp(1,3,:)) squeeze(ripmean.amp(2,3,:)) nanfix squeeze(ripmean.amp(1,4,:)) squeeze(ripmean.amp(2,4,:)) nanfix ...
         squeeze(ripmean.amp(1,5,:)) squeeze(ripmean.amp(2,5,:)) nanfix squeeze(ripmean.amp(1,6,:)) squeeze(ripmean.amp(2,6,:))];
    
     subplot(6,6,7:12)
       [p,h,her] = PlotErrorBarN_SL(ampdat,...
                'barwidth', 0.6, 'newfig', 0,...
                'colorpoints',1,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 1 1]; h.CData(2,:) = [0 0 0];
        h.CData(4,:) = [1 1 1]; h.CData(5,:) = [0 0 0];
        h.CData(7,:) = [1 1 1]; h.CData(8,:) = [0 0 0];
        h.CData(10,:) = [1 1 1]; h.CData(11,:) = [0 0 0];
        h.CData(13,:) = [1 1 1]; h.CData(14,:) = [0 0 0];
        h.CData(16,:) = [1 1 1]; h.CData(17,:) = [0 0 0];
        set(gca,'xticklabel',{[]})    
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel('Power');
        title('AMPLITUDE', 'FontSize', 14);
        
    freqdat = [squeeze(ripmean.freq(1,1,:)) squeeze(ripmean.freq(2,1,:)) nanfix squeeze(ripmean.freq(1,2,:)) squeeze(ripmean.freq(2,2,:)) nanfix ...
         squeeze(ripmean.freq(1,3,:)) squeeze(ripmean.freq(2,3,:)) nanfix squeeze(ripmean.freq(1,4,:)) squeeze(ripmean.freq(2,4,:)) nanfix ...
         squeeze(ripmean.freq(1,5,:)) squeeze(ripmean.freq(2,5,:)) nanfix squeeze(ripmean.freq(1,6,:)) squeeze(ripmean.freq(2,6,:))];
     
    subplot(6,6,13:18)
       [p,h,her] = PlotErrorBarN_SL(freqdat,...
                'barwidth', 0.6, 'newfig', 0,...
                'colorpoints',1,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 1 1]; h.CData(2,:) = [0 0 0];
        h.CData(4,:) = [1 1 1]; h.CData(5,:) = [0 0 0];
        h.CData(7,:) = [1 1 1]; h.CData(8,:) = [0 0 0];
        h.CData(10,:) = [1 1 1]; h.CData(11,:) = [0 0 0];
        h.CData(13,:) = [1 1 1]; h.CData(14,:) = [0 0 0];
        h.CData(16,:) = [1 1 1]; h.CData(17,:) = [0 0 0];
        set(gca,'xticklabel',{[]})
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel('Hz');
        title('FREQUENCY', 'FontSize', 14);    
        
    durdat = [squeeze(ripmean.dur(1,1,:)) squeeze(ripmean.dur(2,1,:)) nanfix squeeze(ripmean.dur(1,2,:)) squeeze(ripmean.dur(2,2,:)) nanfix ...
             squeeze(ripmean.dur(1,3,:)) squeeze(ripmean.dur(2,3,:)) nanfix squeeze(ripmean.dur(1,4,:)) squeeze(ripmean.dur(2,4,:)) nanfix ...
             squeeze(ripmean.dur(1,5,:)) squeeze(ripmean.dur(2,5,:)) nanfix squeeze(ripmean.dur(1,6,:)) squeeze(ripmean.dur(2,6,:))];
    
    subplot(6,6,19:24)
       [p,h,her] = PlotErrorBarN_SL(durdat,...
                'barwidth', 0.6, 'newfig', 0,...
                'colorpoints',1,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 1 1]; h.CData(2,:) = [0 0 0];
        h.CData(4,:) = [1 1 1]; h.CData(5,:) = [0 0 0];
        h.CData(7,:) = [1 1 1]; h.CData(8,:) = [0 0 0];
        h.CData(10,:) = [1 1 1]; h.CData(11,:) = [0 0 0];
        h.CData(13,:) = [1 1 1]; h.CData(14,:) = [0 0 0];
        h.CData(16,:) = [1 1 1]; h.CData(17,:) = [0 0 0];
        set(gca,'xticklabel',{[]})
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel('ms');
        title('DURATION', 'FontSize', 14);  
        % creating legend with hidden-fake data (hugly but effective)
        axP = get(gca,'Position');
        b2=bar([-2],[ 1],'FaceColor','flat');
        b1=bar([-3],[ 1],'FaceColor','flat');
        b1.CData(1,:) = repmat([0 0 0],1);
        b2.CData(1,:) = repmat([1 1 1],1);
        legend([b1 b2],{'pre','post'},'Location','WestOutside')
        set(gca, 'Position', axP)

     globaldendat = [squeeze(ripmean.globalden(1,1,:)) squeeze(ripmean.globalden(2,1,:)) nanfix squeeze(ripmean.globalden(1,2,:)) squeeze(ripmean.globalden(2,2,:)) nanfix ...
         squeeze(ripmean.globalden(1,3,:)) squeeze(ripmean.globalden(2,3,:)) nanfix squeeze(ripmean.globalden(1,4,:)) squeeze(ripmean.globalden(2,4,:)) nanfix ...
         squeeze(ripmean.globalden(1,5,:)) squeeze(ripmean.globalden(2,5,:)) nanfix squeeze(ripmean.globalden(1,6,:)) squeeze(ripmean.globalden(2,6,:))];
    
     subplot(6,6,25:30)
       [p,h,her] = PlotErrorBarN_SL(globaldendat,...
                'barwidth', 0.6, 'newfig', 0,...
                'colorpoints',1,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 1 1]; h.CData(2,:) = [0 0 0];
        h.CData(4,:) = [1 1 1]; h.CData(5,:) = [0 0 0];
        h.CData(7,:) = [1 1 1]; h.CData(8,:) = [0 0 0];
        h.CData(10,:) = [1 1 1]; h.CData(11,:) = [0 0 0];
        h.CData(13,:) = [1 1 1]; h.CData(14,:) = [0 0 0];
        h.CData(16,:) = [1 1 1]; h.CData(17,:) = [0 0 0];
        set(gca,'xticklabel',{[]})
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel('event/sec');
        title('GLOBAL DENSITY', 'FontSize', 14);
 
    localdendat = [squeeze(ripmean.localden(1,1,:)) squeeze(ripmean.localden(2,1,:)) nanfix squeeze(ripmean.localden(1,2,:)) squeeze(ripmean.localden(2,2,:)) nanfix ...
         squeeze(ripmean.localden(1,3,:)) squeeze(ripmean.localden(2,3,:)) nanfix squeeze(ripmean.localden(1,4,:)) squeeze(ripmean.localden(2,4,:)) nanfix ...
         squeeze(ripmean.localden(1,5,:)) squeeze(ripmean.localden(2,5,:)) nanfix squeeze(ripmean.localden(1,6,:)) squeeze(ripmean.localden(2,6,:))];
    
     subplot(6,6,31:36)
       [p,h,her] = PlotErrorBarN_SL(localdendat,...
                'barwidth', 0.6, 'newfig', 0,...
                'colorpoints',1,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 1 1]; h.CData(2,:) = [0 0 0];
        h.CData(4,:) = [1 1 1]; h.CData(5,:) = [0 0 0];
        h.CData(7,:) = [1 1 1]; h.CData(8,:) = [0 0 0];
        h.CData(10,:) = [1 1 1]; h.CData(11,:) = [0 0 0];
        h.CData(13,:) = [1 1 1]; h.CData(14,:) = [0 0 0];
        h.CData(16,:) = [1 1 1]; h.CData(17,:) = [0 0 0];
        set(gca,'Xtick',[2:3:18],'XtickLabel',{'NREM','REM','Wake','N1','N2','N3'});
    %         set(gca, 'FontSize', 12);
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel('event/min');
        title('LOCAL DENSITY', 'FontSize', 14);
    % save figure
    print([dir_out 'GlobalAnalyses_ripples'], '-dpng', '-r300');
        
