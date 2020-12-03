function [figH] = compRipStages(expe, mice_num)

%==========================================================================
% Details: compare sleep events (ripples, spindles, deltas if any) between
% pre and post sleep sessions
%
% INPUTS:
%       - expe              Name of experiment in PathForExperiment
%       - mice_num          ID # of all mice for the analyses
%
% OUTPUT:
%       - fig_rip           Global ripples figure comprising waveforms,
%                           amplitude, frequency, duration, glob and local density
%                           categorize by sleep stages
%
% NOTES:
%
%   Written by Samuel Laventure - 2020-11/12
%      
%==========================================================================

%% Parameters
sav=1;


if strcmp(expe,'StimMFBWake')
    Dir = PathForExperimentsERC_SL(expe);
elseif strcmp(expe,'UMazePAG') 
    Dir = PathForExperimentsERC_Dima(expe);
else    
    warning('Exited. Verify experiment name');
    return
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

% get sleep epoch by stage
for isuj = 1:length(Dir.path)
    load([Dir.path{isuj}{1} 'behavResources.mat'], 'SessionEpoch','Vtsd');
    [sEpoch{isuj} subst(isuj)] = get_SleepEpoch(Dir.path{isuj}{1},Vtsd);
end
% get sleep event details
[rip ripmean] = get_SleepEvent(Dir.path,'Ripples',sEpoch,subst);
                                                                                                                                                                                                                                
%%
%#####################################################################
%#                        F I G U R E S
%#####################################################################

%% FIGURE RIPPLES

% prep data for figures
% get rid of empty data (without substaging)
i=1;
for isuj=1:length(Dir.path)  
    if subst(isuj)
        for isess=1:2
            wf(isess,4:6,i,1:size(ripmean.waveforms,4)) = ripmean.waveforms(isess,4:6,isuj,:);
        end
        i=i+1;
    end
end
% prep plot titles
ptitles = {'Avg Waveforms','Amplitude','Frequency','Duration','Global Density','Local Density'};
% prep number of mouse per analyses
for istage=1:6
    numst(istage) = sum(~isnan(squeeze(ripmean.waveforms(1,istage,:,1))));
end
% prep var - amplitude waveforms
maxy = max(max(max(max(squeeze(squeeze(squeeze(ripmean.waveforms(:,:,:,:))))))))*1.2;
miny = min(min(min(min(squeeze(squeeze(squeeze(ripmean.waveforms(:,:,:,:))))))))*1.2;
supertit = 'Ripples during pre/post sleep - global figure';
figH.global = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1600 2200],'Name', supertit, 'NumberTitle','off');
    % Set plot titles
    ypos = 1.03; % position with 6 x 7 figure with 1600x2200 pixels (rate of diff between plot is .14)
    for iplot=1:6
        a1 = annotation('textbox',[.05 ypos-.14*iplot 0 0],...
            'String',ptitles{iplot},'FitBoxToText','on','EdgeColor','none'); 
        a1.FontSize = 9;
    end
    % Set Number of mouse per stage at bottom of figure
    xpos = 0.18;
    for ist=1:6
        a2 = annotation('textbox',[xpos+.11*ist .08 0 0],'String',['N=' num2str(numst(ist))],...
            'FitBoxToText','on','EdgeColor','none'); 
        a2.FontSize = 9;
    end
    for istage=1:length(stageName)-1
        if ~(sum(sum(isnan(ripmean.waveforms(:,istage,:,:)))) == ...
                size(ripmean.waveforms(:,istage,:,:),4)*2*size(ripmean.waveforms(:,istage,:,:),3))
            subplot(6,7,istage+1)
                % plot pre-sleep event
                if ~isempty(find(ripmean.waveforms(1,istage,:,:,:)>0)) % special case: no event for the session
                    if length(Dir.path)==1 % special case: if only one mouse
                        avgevent = repmat(squeeze(squeeze(ripmean.waveforms(1,istage,:,:))),1,2); % fix if only 1 mouse
                        hpre = shadedErrorBarSL([],avgevent',{@mean, @std},'lineProps','-k','transparent',1);
                    else
                        if ~sum(sum(isnan(ripmean.waveforms(1,istage,:,:)))) % special case: uses mice with substaging only
                            avgevent = squeeze(squeeze(ripmean.waveforms(1,istage,:,:)));
                        else
                            avgevent = squeeze(squeeze(wf(1,istage,:,:)));
                        end
                        hpre = shadedErrorBarSL([],avgevent,{@mean, @std},'lineProps','-k','transparent',1);
                            
                    end
                    clear avgevent
                else
                    yl = yline(0,'--','No PRE event');
                    yl.LabelHorizontalAlignment = 'center';
                    yl.LabelVerticalAlignment = 'bottom';
                    yl.Color = 'k';
                end
                hold on
                % plot post-sleep event
                if ~isempty(ripmean.waveforms(2,istage,:,:,:)) % special case: no event for the session
                    if length(Dir.path)==1 % special case: if only one mouse
                        avgevent = repmat(squeeze(squeeze(ripmean.waveforms(2,istage,:,:))),1,2); % fix if only 1 mouse
                        hpost = shadedErrorBarSL([],avgevent',{@mean, @std},'lineProps','-b','transparent',1);
                    else  
                        if ~sum(sum(isnan(ripmean.waveforms(2,istage,:,:)))) % special case: uses mice with substaging only
                            avgevent = squeeze(squeeze(ripmean.waveforms(2,istage,:,:)));
                        else
                            avgevent = squeeze(squeeze(wf(2,istage,:,:)));
                        end    
                        hpost = shadedErrorBarSL([],avgevent,{@mean, @std},'lineProps','-b','transparent',1);
                    end
                    clear avgevent
                else
                    yl = yline(10,'--','No POST event');
                    yl.LabelHorizontalAlignment = 'center';
                    yl.LabelVerticalAlignment = 'top';
                    yl.Color = 'b';
                end
                % format plot
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
    end
    for i=1:length(Dir.path)
        nanfix(i,1) = nan;
    end
    ampdat = [squeeze(ripmean.amp(1,1,:)) squeeze(ripmean.amp(2,1,:)) nanfix squeeze(ripmean.amp(1,2,:)) squeeze(ripmean.amp(2,2,:)) nanfix ...
         squeeze(ripmean.amp(1,3,:)) squeeze(ripmean.amp(2,3,:)) nanfix squeeze(ripmean.amp(1,4,:)) squeeze(ripmean.amp(2,4,:)) nanfix ...
         squeeze(ripmean.amp(1,5,:)) squeeze(ripmean.amp(2,5,:)) nanfix squeeze(ripmean.amp(1,6,:)) squeeze(ripmean.amp(2,6,:))];
    
     subplot(6,7,9:14)
       [p,h,her] = PlotErrorBarN_SL(ampdat,...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
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
        % creating legend with hidden-fake data (hugly but effective)
        axP = get(gca,'Position');
        b2=bar([-2],[ 1],'FaceColor','flat');
        b1=bar([-3],[ 1],'FaceColor','flat');
        b1.CData(1,:) = repmat([0 0 0],1);
        b2.CData(1,:) = repmat([1 1 1],1);
        legend([b1 b2],{'pre','post'},'Location','WestOutside')
        set(gca, 'Position', axP)
        
    freqdat = [squeeze(ripmean.freq(1,1,:)) squeeze(ripmean.freq(2,1,:)) nanfix squeeze(ripmean.freq(1,2,:)) squeeze(ripmean.freq(2,2,:)) nanfix ...
         squeeze(ripmean.freq(1,3,:)) squeeze(ripmean.freq(2,3,:)) nanfix squeeze(ripmean.freq(1,4,:)) squeeze(ripmean.freq(2,4,:)) nanfix ...
         squeeze(ripmean.freq(1,5,:)) squeeze(ripmean.freq(2,5,:)) nanfix squeeze(ripmean.freq(1,6,:)) squeeze(ripmean.freq(2,6,:))];
     
    subplot(6,7,16:21)
       [p,h,her] = PlotErrorBarN_SL(freqdat,...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
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
        
    durdat = [squeeze(ripmean.dur(1,1,:)) squeeze(ripmean.dur(2,1,:)) nanfix squeeze(ripmean.dur(1,2,:)) squeeze(ripmean.dur(2,2,:)) nanfix ...
             squeeze(ripmean.dur(1,3,:)) squeeze(ripmean.dur(2,3,:)) nanfix squeeze(ripmean.dur(1,4,:)) squeeze(ripmean.dur(2,4,:)) nanfix ...
             squeeze(ripmean.dur(1,5,:)) squeeze(ripmean.dur(2,5,:)) nanfix squeeze(ripmean.dur(1,6,:)) squeeze(ripmean.dur(2,6,:))];
    
    subplot(6,7,23:28)
       [p,h,her] = PlotErrorBarN_SL(durdat,...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
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

     globaldendat = [squeeze(ripmean.globalden(1,1,:)) squeeze(ripmean.globalden(2,1,:)) nanfix squeeze(ripmean.globalden(1,2,:)) squeeze(ripmean.globalden(2,2,:)) nanfix ...
         squeeze(ripmean.globalden(1,3,:)) squeeze(ripmean.globalden(2,3,:)) nanfix squeeze(ripmean.globalden(1,4,:)) squeeze(ripmean.globalden(2,4,:)) nanfix ...
         squeeze(ripmean.globalden(1,5,:)) squeeze(ripmean.globalden(2,5,:)) nanfix squeeze(ripmean.globalden(1,6,:)) squeeze(ripmean.globalden(2,6,:))];
    
     subplot(6,7,30:35)
       [p,h,her] = PlotErrorBarN_SL(globaldendat,...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
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
 
    localdendat = [squeeze(ripmean.localden(1,1,:)) squeeze(ripmean.localden(2,1,:)) nanfix squeeze(ripmean.localden(1,2,:)) squeeze(ripmean.localden(2,2,:)) nanfix ...
         squeeze(ripmean.localden(1,3,:)) squeeze(ripmean.localden(2,3,:)) nanfix squeeze(ripmean.localden(1,4,:)) squeeze(ripmean.localden(2,4,:)) nanfix ...
         squeeze(ripmean.localden(1,5,:)) squeeze(ripmean.localden(2,5,:)) nanfix squeeze(ripmean.localden(1,6,:)) squeeze(ripmean.localden(2,6,:))];
    
     subplot(6,7,37:42)
       [p,h,her] = PlotErrorBarN_SL(localdendat,...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
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
if sav
    % Directory to save and name of the figure to save
    dir_out = [dropbox '/DataSL/StimMFBWake/ripples/Sleep/' date '/'];
    %create folders
    if ~exist(dir_out,'dir')
        mkdir(dir_out);
    end    

    % save figure
    print([dir_out 'GlobalAnalyses_ripples_' num2str(mice_num)], '-dpng', '-r300');
end
        
