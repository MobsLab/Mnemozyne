function figH = sam_sleep_prevspost(expe, subj, varargin)
%==========================================================================
% Details: Output details about sleep pre and post sessions
%
% INPUTS:
%       - expe              Name of the experiment in PathForExperiment
%       - subj              Mice number to analyze
%      
%   OPTIONS:
%       - stim              Default: 0; Put to 1 if you have stim during
%                           sleep
%
% OUTPUT:
%       - figure including:
%           - Pre vs Post sleep % per subject
%           - Pre and post hypnogram per subject
%           - Pre vs post sleep percentage and duration for all subject
%           (mean)
%
% NOTES:
%
%   Original written by Samuel Laventure - 02-07-2019
%   Modified on by SL - 29-11-2019, 2020-12
%      
%  see also, FindNREMfeatures, SubstagesScoring, MakeIDSleepData,PlotIDSleepData
%==========================================================================

% Parse parameter list
for i = 1:2:length(varargin)
    if ~ischar(varargin{i})
        error(['Parameter ' num2str(i+2) ' is not a property.']);
    end
    switch(lower(varargin{i}))
        case 'stim'
            stim = varargin{i+1};
            if stim~=0 && stim ~=1
                error('Incorrect value for property ''stim''.');
            end
        otherwise
            error(['Unknown property ''' num2str(varargin{i}) '''.']);
    end
end

%check if exist and assign default value if not
%Is there stim in this session
if ~exist('stim','var')
    stim=0;
end


%% Parameters
% Get directories
if strcmp(expe,'StimMFBWake') || strcmp(expe,'Novel')
    Dir = PathForExperimentsERC_SL(expe);
elseif strcmp(expe,'UMazePAG') 
    Dir = PathForExperimentsERC_Dima(expe);
else    
    warning('Exited. Verify experiment name');
    return
end
Dir = RestrictPathForExperiment(Dir,'nMice', subj);

% get sessions id and timepoints
try
    [id_pre tdatpre] = RestrictSession(Dir,'BaselineSleep');  %add variable for session to call
catch
    [id_pre tdatpre] = RestrictSession(Dir,'PreSleep');
end
[id_post tdatpost] = RestrictSession(Dir,'PostSleep');
    
% set text format
% set(0,'defaulttextinterpreter','latex');
% set(0,'DefaultTextFontname', 'Arial')
% set(0,'DefaultAxesFontName', 'Arial')
% set(0,'defaultTextFontSize',14)
% set(0,'defaultAxesFontSize',12)

%#####################################################################
%#                           M A I N
%#####################################################################
% check if all mice have substages processed and load substaging
for isuj=1:length(Dir.path)
    cd(Dir.path{1,isuj}{1})
    try
        substg{isuj} = load([pwd '/SleepSubstages.mat'],'Epoch');
        disp(['...loading substages for mouse ' num2str(isuj)])
        ss(isuj) = 1;
    catch
        ss(isuj) = 0;
    end
end

for isubj=1:length(Dir.path)
    cd(Dir.path{1,isubj}{1})
    % load variables
    if ss(isubj)   
        ssnb=5;
        ssnames = {'N1','N2','N3','REM','WAKE'};
    else
        ssnb=3;
        ssnames = {'NREM','REM','WAKE'};
        try 
            sscoring = load('SleepScoring_OBGamma.mat','REMEpoch','SWSEpoch','Wake');
            disp('...loading sleep variables from OBGamma')
        catch
            sscoring = load('SleepScoring_Accelero.mat','REMEpoch','SWSEpoch','Wake');
            disp('...loading sleep variables from Accelero')
        end
    end

    if stim
        stims = load('StimSent.mat');
        disp('...loading stimulations');
    end
    % load LFP to be able to create the sleepstage variable
    LFP = load('LFPData/LFP1.mat', 'LFP');
    
    %pre 
    if ss
        [pre_n1, pre_n2, pre_n3, pre_rem, pre_wake] = get_subscoring(substg{isubj}.Epoch,tdatpre{isubj}{1});
        pre_Epochs = {pre_n1,pre_n2,pre_n3,pre_rem,pre_wake};
    else
        [pre_rem, pre_nrem, pre_wake] = get_sleepscoring(isubj,sscoring,tdatpre);
        pre_Epochs = {pre_nrem,pre_rem,pre_wake};
    end
    pre_SleepStages = CreateSleepStages_tsd(pre_Epochs);
    
    %post
    if ss
        [post_n1, post_n2, post_n3, post_rem, post_wake] = get_subscoring(substg{isubj}.Epoch,tdatpost{isubj}{1});
        post_Epochs = {post_n1,post_n2,post_n3,post_rem,post_wake};
    else
        [post_rem, post_nrem, post_wake] = get_sleepscoring(isubj,sscoring,tdatpost);
        post_Epochs = {post_nrem,post_rem,post_wake};
    end
    post_SleepStages = CreateSleepStages_tsd(post_Epochs);
    
    % prep figure data - hypnograms
    pre_start = Start(tdatpre{isubj}{1})/1e4/3600;
    pre_end = End(tdatpre{isubj}{1})/1e4/3600;
    
    post_start = Start(tdatpost{isubj}{1})/1e4/3600;
    post_end = End(tdatpost{isubj}{1})/1e4/3600;
    
    if ss(isubj)
        colori = {[.2 .6 1], [.0 .4 1], [.0 .0 1], [.6 .0 1], [1 .4 .4]}; %substage color
    else
        colori = {[0 0 0], [.85 .85 .85], [.95 .95 .95]}; %substage color
    end

    %prep figure data - barplot
    predur = sum(End(tdatpre{isubj}{1}) - Start(tdatpre{isubj}{1}));
    postdur = sum(End(tdatpost{isubj}{1}) - Start(tdatpost{isubj}{1}));
    
    for istages=1:ssnb
        stagdur(1,istages) = sum(End(pre_Epochs{istages})-Start(pre_Epochs{istages}));
        stagdur(2,istages) = sum(End(post_Epochs{istages})-Start(post_Epochs{istages}));
        stagperc(1,istages) = stagdur(1,istages)/predur*100;
        stagperc(2,istages) = stagdur(2,istages)/postdur*100;
    end
    
    % for all mice
    stagdur_part(isubj,:,:) = stagdur;
    stagperc_part(isubj,:,:) = stagperc;
    
    %%
    %#####################################################################
    %#             F I G U R E S    B Y   S E S S I O N S
    %#####################################################################
    % hypnogram
    supertit = ['Mouse ' num2str(subj(isubj))  ' - Hypnograms'];
    figH.SleepArch_single{isubj} = figure('Color',[1 1 1], 'rend','painters','pos', ...
        [10 10 1650 1200],'Name', supertit, 'NumberTitle','off');
        %pre
        subplot(3,2,1:2)
            plot(Range(pre_SleepStages,'s')/3600,Data(pre_SleepStages),'k')
            hold on
            for ep=1:length(pre_Epochs)
                plot(Range(Restrict(pre_SleepStages,pre_Epochs{ep}),'s')/3600 ,Data(Restrict(pre_SleepStages,pre_Epochs{ep})),'.','Color',colori{ep}), hold on,
            end
            xlim([pre_start pre_end]) 
            xlabel('Time (h)')
            set(gca,'TickLength',[0 0])
            ytick_substage = 1:ssnb; %ordinate in graph
            ylim([0.5 ssnb+0.5])
            ylabel_substage = ssnames;
            set(gca,'Ytick',ytick_substage,'YTickLabel',ylabel_substage)
            title('Pre-sleep','FontSize',14,'FontWeight','bold'); 
        
        %post
        subplot(3,2,3:4)
            plot(Range(post_SleepStages,'s')/3600,Data(post_SleepStages),'k') 
            hold on
            for ep=1:length(post_Epochs)
                plot(Range(Restrict(post_SleepStages,post_Epochs{ep}),'s')/3600 ,Data(Restrict(post_SleepStages,post_Epochs{ep})),'.','Color',colori{ep}), hold on,
            end
            % stim markers
            if stim 
                plot(Start(stims.StimSent)/1e4/3600,3.25,'g*')
            end
            xlim([post_start post_end]) 
            xlabel('Time (h)')      
            set(gca,'TickLength',[0 0])
            ytick_substage = 1:ssnb; %ordinate in graph
            ylim([0.5 ssnb+0.5])
            ylabel_substage = ssnames;
            set(gca,'Ytick',ytick_substage,'YTickLabel',ylabel_substage)
            title('Post-sleep','FontSize',14,'FontWeight','bold'); 

            if stim
                %annotation
                dim = [.8 .22 .3 .3];
                str = sprintf(['Stimulations: * \nNumber of stim: ' num2str(stims.nbStim)]);
                annotation('textbox',dim,'String',str,'Color','black','FitBoxToText','on');
            end

        subplot(3,2,5)
            b1 = bar(stagdur'/(1E4*60),1,'FaceColor','flat');
            b1(1,1).CData = [1 1 1];
            b1(1,2).CData = [0 0 0];
            xtips1 = b1(1).XData-.05;
            ytips1 = b1(1).YData;
            labels1 = string(round(b1(1).YData,1));
            xtips2 = b1(2).XData+.05;
            ytips2 = b1(2).YData;
            labels2 = string(round(b1(2).YData,1));
            text(xtips1,ytips1,labels1,'HorizontalAlignment','right',...
                'VerticalAlignment','bottom','Color',[.6 .6 .6])
            text(xtips2,ytips2,labels2,'HorizontalAlignment','left',...
                'VerticalAlignment','bottom','Color','black')
            title('Stages duration (min)','FontSize',14)
            set(gca,'XTickLabel',ssnames)
            xlabel('Stages')
            ylabel('min')
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
            % creating legend with hidden-fake data
            hold on
            axP = get(gca,'Position');
            c1=bar(nan(2,5),'FaceColor','flat');
            c1(1,1).CData = [1 1 1];
            c1(1,2).CData = [0 0 0];
            legend(c1,{'Pre-sleep','Post-sleep'},'location','WestOutside');
            set(gca, 'Position', axP)
            
        subplot(3,2,6)
            b2 = bar(stagperc',1,'FaceColor','flat');
            b2(1,1).CData = [1 1 1];
            b2(1,2).CData = [0 0 0];
            xtips1 = b2(1).XData-.05;
            ytips1 = b2(1).YData;
            labels1 = string(round(b2(1).YData,1));
            xtips2 = b2(2).XData+.05;
            ytips2 = b2(2).YData;
            labels2 = string(round(b2(2).YData,1));
            text(xtips1,ytips1,labels1,'HorizontalAlignment','right',...
                'VerticalAlignment','bottom','Color',[.6 .6 .6])
            text(xtips2,ytips2,labels2,'HorizontalAlignment','left',...
                'VerticalAlignment','bottom','Color','black')
            title('Stages duration percentage','FontSize',14)
            set(gca,'XTickLabel',ssnames)
            xlabel('Stages')
            ylabel('%')
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
end  
%  
% %%  prep data for all mice
% % percentage
% ii=1;
% nremall(ii,1:isubj) = squeeze(stagperc_part(:,1,1));
% nremall(ii+1,1:isubj) = squeeze(stagperc_part(:,2,1));
% nremall(ii+2,1:isubj) = nan;
% remall(ii,1:isubj) = squeeze(stagperc_part(:,1,2));
% remall(ii+1,1:isubj) = squeeze(stagperc_part(:,2,2));
% remall(ii+2,1:isubj) = nan;
% wakeall(ii,1:isubj) = squeeze(stagperc_part(:,1,3));
% wakeall(ii+1,1:isubj) = squeeze(stagperc_part(:,2,3));
% wakeall(ii+2,1:isubj) = nan;
% 
% % duration
% ii=1;
% nremalldur(ii,1:isubj) = squeeze(stagdur_part(:,1,1))/(1E4*60);
% nremalldur(ii+1,1:isubj) = squeeze(stagdur_part(:,2,1))/(1E4*60);
% nremalldur(ii+2,1:isubj) = nan;
% remalldur(ii,1:isubj) = squeeze(stagdur_part(:,1,2))/(1E4*60);
% remalldur(ii+1,1:isubj) = squeeze(stagdur_part(:,2,2))/(1E4*60);
% remalldur(ii+2,1:isubj) = nan;
% wakealldur(ii,1:isubj) = squeeze(stagdur_part(:,1,3))/(1E4*60);
% wakealldur(ii+1,1:isubj) = squeeze(stagdur_part(:,2,3))/(1E4*60);
% wakealldur(ii+2,1:isubj) = nan;
% 
% save([dir_out 'sleeparch.mat'],'nremall','remall','wakeall','nremalldur','remalldur','wakealldur');
% 
% 
% %% FIGURE COMPARAISON
%     %Percentage pre vs post all mice
%     supertit = 'Sleep stages percentage pre vs post';
%     
%     figure('Color',[1 1 1], 'rend','painters','pos',[1 1 600 400],'Name', supertit, 'NumberTitle','off')
%         [p,h, her] = PlotErrorBarN_SL([nremall' remall' wakeall'],...
%             'barwidth', .85, 'newfig', 0,...
%             'showPoints',0,'colorpoints',0,'barcolors',[.3 .3 .3]);    
%         set(gca,'Xtick',[1:3:ssnb*3],'XtickLabel',{'           NREM','           REM','          WAKE'});
%         h.FaceColor = 'flat';
%         h.CData([2:3:ssnb*3],:) = repmat([1 1 1],3,1);
%         xlabel('Stages')
%         ylabel('%')
%         hold on
%         % creating legend with hidden-fake data (hugly but effective)
%             b2=bar([-2],[ 1],'FaceColor','flat');
%             b1=bar([-3],[ 1],'FaceColor','flat');
%             b1.CData(1,:) = repmat([.3 .3 .3],1);
%             b2.CData(1,:) = repmat([1 1 1],1);
%             legend([b1 b2],{'Pre-sleep','Post-sleep'})
%     %save figure
%     if save_data
%         print([dir_out 'all_sleeparch_perc_prepost'], '-dpng', '-r300');
%     end
%     
%     % Duration pre vs post all mice
%     supertit = 'Sleep stages duration pre vs post';
%     
%     figure('Color',[1 1 1], 'rend','painters','pos',[1 1 600 400],'Name', supertit, 'NumberTitle','off')
%         [p,h, her] = PlotErrorBarN_SL([nremalldur' remalldur' wakealldur'],...
%             'barwidth', 0.85, 'newfig', 0,...
%             'showPoints',0,'colorpoints',0,'barcolors',[.3 .3 .3]);      
%         set(gca,'Xtick',[1:3:ssnb*3],'XtickLabel',{'           NREM','           REM','          WAKE'});
%         h.FaceColor = 'flat';
%         h.CData([2:3:ssnb*3],:) = repmat([1 1 1],3,1);
%         xlabel('Stages')
%         ylabel('Duration (min)')
%         hold on
%         % creating legend with hidden-fake data (hugly but effective)
%             b2=bar([-2],[ 1],'FaceColor','flat');
%             b1=bar([-3],[ 1],'FaceColor','flat');
%             b1.CData(1,:) = repmat([.3 .3 .3],1);
%             b2.CData(1,:) = repmat([1 1 1],1);
%             legend([b1 b2],{'Pre-sleep','Post-sleep'})
%     %save figure
%     if save_data
%         print([dir_out 'all_sleeparch_dur_prepost'], '-dpng', '-r300');
%     end


end

