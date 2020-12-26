function [figH] = compSpindleStages(expe, mice_num)

%==========================================================================
% Details: compare sleep events (spiples, spindles, deltas if any) between
% pre and post sleep sessions
%
% INPUTS:
%       - expe              Name of experiment in PathForExperiment
%       - mice_num          ID # of all mice for the analyses
%
% OUTPUT:
%       - fig_spi           Global spiples figure comprising waveforms,
%                           amplitude, frequency, duration, glob and local density
%                           categorize by sleep stages
%
% NOTES:
%
%   Written by Samuel Laventure - 2020-12
%      
%==========================================================================

%% Parameters
if strcmp(expe,'StimMFBWake') || strcmp(expe,'Novel')
    Dir = PathForExperimentsERC_SL(expe);
elseif strcmp(expe,'UMazePAG') 
    Dir = PathForExperimentsERC_Dima(expe);
else    
    warning('Exited. Verify experiment name');
    return
end
Dir = RestrictPathForExperiment(Dir, 'nMice', mice_num);

% % set text format
% set(0,'defaulttextinterpreter','latex');
% set(0,'DefaultTextFontname', 'Arial')
% set(0,'DefaultAxesFontName', 'Arial')
% set(0,'defaultTextFontSize',12)
% set(0,'defaultAxesFontSize',12)

% var init
stageName = {'NREM','REM','Wake','N1','N2','N3','Sleep'};
sstag = [1 5 6];
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
[spi spimean spidif] = get_SleepEvent(Dir.path,'Spindles',sEpoch,subst);
           
% count number of spindle by subjet and stage
if length(Dir.path)==1
    for istage=1:length(stageName)-1
        for isess=1:2
            spinbr(isess,istage) = length(spi.dur{isuj,isess,istage});
        end
    end
end

%%
%#####################################################################
%#                        F I G U R E S
%#####################################################################

%% FIGURE SPINDLES MAIN

% prep data for figures
% get rid of empty data (without substaging)
i=1;
for isuj=1:length(Dir.path)  
    if subst(isuj)
        for isess=1:2
            wf(isess,4:6,i,1:size(spimean.waveforms,4)) = spimean.waveforms(isess,4:6,isuj,:);
        end
        i=i+1;
    end
end
% prep plot titles
ptitles = {'Avg Waveforms','Peak Amplitude','Frequency','Duration','Global Density','Local Density'};
% prep number of mouse per analyses
for istage=1:length(sstag)
    numst(sstag(istage)) = sum(~isnan(squeeze(spimean.waveforms(1,sstag(istage),:,1))));
end
% prep var - amplitude waveforms
maxy = max(max(max(max(squeeze(squeeze(squeeze(spimean.waveforms(:,:,:,:))))))))*1.2;
miny = min(min(min(min(squeeze(squeeze(squeeze(spimean.waveforms(:,:,:,:))))))))*1.2;
supertit = 'Spindles during pre/post sleep - global';
figH.global = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1600 1500],'Name', supertit, 'NumberTitle','off');
    % Set plot titles
    ypos = 1.03; % position with 6 x 7 figure with 1600x2200 pixels (rate of diff between plot is .14)
    for iplot=1:6
        a1 = annotation('textbox',[.05 ypos-.14*iplot 0 0],...
            'String',ptitles{iplot},'FitBoxToText','on','EdgeColor','none'); 
        a1.FontSize = 12;
        if iplot==1
            % creating legend with hidden-fake data for waveforms plots
                s1 = subplot(6,6,1);
                    axP = get(gca,'Position');
                    p1=plot(nan(2,1),'-k','LineWidth',2);
                    hold on
                    p2=plot(nan(3,1),'-b','LineWidth',2);
                    hold off
                    legend([p1 p2],{'pre','post'},'location','East');
                    set(gca, 'Position', axP)
                    set(s1,'Visible','off')
        end
    end
    % Set Number of mouse per stage at bottom of figure
    xpos = 0.21;
    for ist=1:length(sstag)
        if length(Dir.path)==1
            str = {stageName{sstag(ist)},'', ...
                ['N=' num2str(numst(sstag(ist)))], ...
                ['pre#: ' num2str(spinbr(1,sstag(ist)))], ...
                ['post#: ' num2str(spinbr(2,sstag(ist)))]};
        else
            str = ['N=' num2str(numst(sstag(ist)))];
        end
        a2 = annotation('textbox',[xpos+.19*ist .08 0.08 .025],'String',str,...
            'FitBoxToText','off','EdgeColor','none'); 
        a2.FontSize = 11;        
    end
    
    % plot waves and bars
    for istage=1:length(sstag)
        if ~(sum(sum(isnan(spimean.waveforms(:,sstag(istage),:,:)))) == ...
                size(spimean.waveforms(:,sstag(istage),:,:),4)*2*size(spimean.waveforms(:,sstag(istage),:,:),3))
            subplot(6,4,istage+1)
                % plot pre-sleep event
                if ~isempty(find(spimean.waveforms(1,sstag(istage),:,:,:)>0)) % special case: no event for the session
                    if length(Dir.path)==1 % special case: if only one mouse
                        avgevent = repmat(squeeze(squeeze(spimean.waveforms(1,sstag(istage),:,:))),1,2); % fix if only 1 mouse
                        hpre = shadedErrorBarSL([],avgevent',{@mean, @std},'lineProps','-k','transparent',1);
                    else
                        if ~sum(sum(isnan(spimean.waveforms(1,sstag(istage),:,:)))) % special case: uses mice with substaging only
                            avgevent = squeeze(squeeze(spimean.waveforms(1,sstag(istage),:,:)));
                        else
                            avgevent = squeeze(squeeze(wf(1,sstag(istage),:,:)));
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
                if ~isempty(spimean.waveforms(2,sstag(istage),:,:,:)) % special case: no event for the session
                    if length(Dir.path)==1 % special case: if only one mouse
                        avgevent = repmat(squeeze(squeeze(spimean.waveforms(2,sstag(istage),:,:))),1,2); % fix if only 1 mouse
                        hpost = shadedErrorBarSL([],avgevent',{@mean, @std},'lineProps','-b','transparent',1);
                    else  
                        if ~sum(sum(isnan(spimean.waveforms(2,sstag(istage),:,:)))) % special case: uses mice with substaging only
                            avgevent = squeeze(squeeze(spimean.waveforms(2,sstag(istage),:,:)));
                        else
                            avgevent = squeeze(squeeze(wf(2,sstag(istage),:,:)));
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
                title([stageName{sstag(istage)}])
                xlabel('time (ms)')
                ylim([miny maxy])
                xlim([250 2250])
                xticks([251 2249])
                xticklabels({'0','2000'})
                makepretty_erc('fsizel',10,'lwidth',1.5,'fsizet',16)
                if sstag(istage)==1
                    ylabel('uV')
                end
        end
    end
    for i=1:length(Dir.path)
        nanfix(i,1) = nan;
    end
    
    ampdat = [squeeze(spimean.amp(1,1,:)) squeeze(spimean.amp(2,1,:)) nanfix  ...
         squeeze(spimean.amp(1,5,:)) squeeze(spimean.amp(2,5,:)) nanfix ...
         squeeze(spimean.amp(1,6,:)) squeeze(spimean.amp(2,6,:))];
    
     subplot(6,4,6:8)
       [p,h,her] = PlotErrorBarN_SL(ampdat,...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 1 1]; h.CData(2,:) = [0 0 0];
        h.CData(4,:) = [1 1 1]; h.CData(5,:) = [0 0 0];
        h.CData(7,:) = [1 1 1]; h.CData(8,:) = [0 0 0];
        set(gca,'xticklabel',{[]})    
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel('uV');
        makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
        
        % creating legend with hidden-fake data (hugly but effective)
        axP = get(gca,'Position');
        b2=bar([-2],[ 1],'FaceColor','flat');
        b1=bar([-3],[ 1],'FaceColor','flat');
        b1.CData(1,:) = repmat([1 1 1],1);
        b2.CData(1,:) = repmat([0 0 0],1);
        legend([b1 b2],{'pre','post'},'Location','WestOutside')
        set(gca, 'Position', axP)
        
    freqdat = [squeeze(spimean.freq(1,1,:)) squeeze(spimean.freq(2,1,:)) nanfix ...
         squeeze(spimean.freq(1,5,:)) squeeze(spimean.freq(2,5,:)) nanfix ...
         squeeze(spimean.freq(1,6,:)) squeeze(spimean.freq(2,6,:))];
     
    subplot(6,4,10:12)
       [p,h,her] = PlotErrorBarN_SL(freqdat,...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 1 1]; h.CData(2,:) = [0 0 0];
        h.CData(4,:) = [1 1 1]; h.CData(5,:) = [0 0 0];
        h.CData(7,:) = [1 1 1]; h.CData(8,:) = [0 0 0];
        set(gca,'xticklabel',{[]})
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel('Hz');
        makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
        
    durdat = [squeeze(spimean.dur(1,1,:)) squeeze(spimean.dur(2,1,:)) nanfix ...
            squeeze(spimean.dur(1,5,:)) squeeze(spimean.dur(2,5,:)) nanfix ...
            squeeze(spimean.dur(1,6,:)) squeeze(spimean.dur(2,6,:))];
    
    subplot(6,4,14:16)
       [p,h,her] = PlotErrorBarN_SL(durdat,...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 1 1]; h.CData(2,:) = [0 0 0];
        h.CData(4,:) = [1 1 1]; h.CData(5,:) = [0 0 0];
        h.CData(7,:) = [1 1 1]; h.CData(8,:) = [0 0 0];
        set(gca,'xticklabel',{[]})
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel('sec');
        makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
        
     globaldendat = [squeeze(spimean.globalden(1,1,:)) squeeze(spimean.globalden(2,1,:)) nanfix ...
         squeeze(spimean.globalden(1,5,:)) squeeze(spimean.globalden(2,5,:)) nanfix ...
         squeeze(spimean.globalden(1,6,:)) squeeze(spimean.globalden(2,6,:))];
    
     subplot(6,4,18:20)
       [p,h,her] = PlotErrorBarN_SL(globaldendat,...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 1 1]; h.CData(2,:) = [0 0 0];
        h.CData(4,:) = [1 1 1]; h.CData(5,:) = [0 0 0];
        h.CData(7,:) = [1 1 1]; h.CData(8,:) = [0 0 0];
        set(gca,'xticklabel',{[]})
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel('event/sec');
        makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
        
    localdendat = [squeeze(spimean.localden(1,1,:)) squeeze(spimean.localden(2,1,:)) nanfix ...
        squeeze(spimean.localden(1,5,:)) squeeze(spimean.localden(2,5,:)) nanfix ...
        squeeze(spimean.localden(1,6,:)) squeeze(spimean.localden(2,6,:))];
    
     subplot(6,4,22:24)
       [p,h,her] = PlotErrorBarN_SL(localdendat,...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [1 1 1]; h.CData(2,:) = [0 0 0];
        h.CData(4,:) = [1 1 1]; h.CData(5,:) = [0 0 0];
        h.CData(7,:) = [1 1 1]; h.CData(8,:) = [0 0 0];
        set(gca,'xticklabel',{[]})
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel('event/min');
        makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)


%% FIGURE SPINDLE DIFFERENCES

% prep plot titles
ptitles = {'Peak Amplitude','Frequency','Duration','Global Density','Local Density'};

supertit = 'Spindles during pre/post sleep - differences';
figH.diff = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1200 800],'Name', supertit, 'NumberTitle','off');
    % Set plot titles
    ypos = 1.05; 
    for iplot=1:5
        a1 = annotation('textbox',[.05 ypos-.17*iplot 0 0],...
            'String',ptitles{iplot},'FitBoxToText','on','EdgeColor','none'); 
        a1.FontSize = 12;
    end
       
    % amplitude
    subplot(5,4,2:4)
       [p,h,her] = PlotErrorBarN_SL(spidif.amp(sstag,:)',...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [0 0 0]; 
        h.CData(2,:) = [.5 .5 .5]; 
        h.CData(3,:) = [.2 .2 .2];
        set(gca,'xticklabel',{[]})    
        ylabel({'% change','in uV'});
        ymin = min(min(spidif.amp(1:6,:)));
        ymax = max(max(spidif.amp(1:6,:)));
        if sign(ymin)>0, ymin=0; else ymin=ymin*1.15; end
        if sign(ymax)>0, ymax=ymax*1.15; else ymax=0; end    
        ylim([ymin ymax])
        makepretty_erc('fsizel',10,'lwidth',1.5,'fsizet',16)
        
        % creating legend with hidden-fake data (hugly but effective)
        axP = get(gca,'Position');
        b1=bar([-3],[ 1],'FaceColor','flat');
        b2=bar([-2],[ 1],'FaceColor','flat');
        b3=bar([-3],[ 1],'FaceColor','flat');
        b1.CData(1,:) = repmat([0 0 0],1);
        b2.CData(1,:) = repmat([.5 .5 .5],1);
        b3.CData(1,:) = repmat([.2 .2 .2],1);
        legend([b1 b2 b3],stageName(sstag),'Location','EastOutside')
        set(gca, 'Position', axP)
    
    % Freq
    subplot(5,4,6:8)
       [p,h,her] = PlotErrorBarN_SL(spidif.freq(sstag,:)',...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [0 0 0]; 
        h.CData(2,:) = [.5 .5 .5]; 
        h.CData(3,:) = [.2 .2 .2];
        set(gca,'xticklabel',{[]})    
        ylabel({'% change','in Hz'});
        ymin = min(min(spidif.freq(1:6,:)));
        ymax = max(max(spidif.freq(1:6,:)));
        if sign(ymin)>0, ymin=0; else ymin=ymin*1.15; end
        if sign(ymax)>0, ymax=ymax*1.15; else ymax=0; end    
        ylim([ymin ymax])
        makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
        
    % Dur
    subplot(5,4,10:12)
       [p,h,her] = PlotErrorBarN_SL(spidif.dur(sstag,:)',...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [0 0 0]; 
        h.CData(2,:) = [.5 .5 .5]; 
        h.CData(3,:) = [.2 .2 .2];
        set(gca,'xticklabel',{[]})    
        ylabel({'% change','in sec'});
        ymin = min(min(spidif.dur(1:6,:)));
        ymax = max(max(spidif.dur(1:6,:)));
        if sign(ymin)>0, ymin=0; else ymin=ymin*1.15; end
        if sign(ymax)>0, ymax=ymax*1.15; else ymax=0; end    
        ylim([ymin ymax])
        makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
        
    % Global Density
    subplot(5,4,14:16)
       [p,h,her] = PlotErrorBarN_SL(spidif.globalden(sstag,:)',...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [0 0 0]; 
        h.CData(2,:) = [.5 .5 .5]; 
        h.CData(3,:) = [.2 .2 .2];
        set(gca,'xticklabel',{[]})    
        ylabel({'% change','in spi/sec'});
        ymin = min(min(spidif.globalden(1:6,:)));
        ymax = max(max(spidif.globalden(1:6,:)));
        if sign(ymin)>0, ymin=0; else ymin=ymin*1.15; end
        if sign(ymax)>0, ymax=ymax*1.15; else ymax=0; end    
        ylim([ymin ymax])
        makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
        
    % Local Density
    subplot(5,4,18:20)
       [p,h,her] = PlotErrorBarN_SL(spidif.localden(sstag,:)',...
                'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3]);
        h.FaceColor = 'flat';
        h.CData(1,:) = [0 0 0]; 
        h.CData(2,:) = [.5 .5 .5]; 
        h.CData(3,:) = [.2 .2 .2];
        set(gca,'xticklabel',{[]})    
        ylabel({'% change','in spi/min'});
        set(gca,'xtick',[1:3],'xticklabel',stageName(sstag)) 
        ymin = min(min(spidif.localden(1:6,:)));
        ymax = max(max(spidif.localden(1:6,:)));
        if sign(ymin)>0, ymin=0; else ymin=ymin*1.15; end
        if sign(ymax)>0, ymax=ymax*1.15; else ymax=0; end    
        ylim([ymin ymax])
        makepretty_erc('fsizel',10,'lwidth',1.5,'fsizet',16)
end
