function [figH ripples_data] = compRipGroups(expe,mice_num,restrictlen)

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
for iexp=1:length(expe)
    Dir{iexp} = PathForExperimentsERC(expe{iexp});
    switch expe{iexp}
        case 'StimMFBWake'
            expname{iexp}='MFB';
        case 'Novel'
            expname{iexp}='Novel';
        case 'UMazePAG'
            expname{iexp}='PAG';
        case 'Known'
            expname{iexp}='Known';
        case 'BaselineSleep'
            expname{iexp}='BaselineSleep';
    end
    Dir{iexp} = RestrictPathForExperiment(Dir{iexp}, 'nMice', unique(mice_num{iexp}));
end

% var init
stageName = {'NREM','Wake','N1','N2','N3'};
clr = {[0 .8 0],[.9 0 0],[1 1 1],[0 0 0]};  %arbitrary order. can change or automate later
charName = {'Amplitude','Frequency','Duration','Global Density','Local Density'};
ylab = {'uV','Hz','ms','rip/sec','rip/min'};

%%
%#####################################################################
%#                           M  A  I  N
%#####################################################################

% get sleep epoch by stage
disp('Getting data...')
for iexp=1:length(expe)
    disp(['   Experiment: ' expname{iexp}])
    nsuj=0;
    for isuj = 1:length(Dir{iexp}.path)
        for iisuj=1:length(Dir{iexp}.path{isuj})
            nsuj=nsuj+1;
%             load([Dir{iexp}.path{isuj}{iisuj} 'behavResources.mat'], 'SessionEpoch');
            [sEpoch{iexp,nsuj} subst(iexp,nsuj) sSession{iexp,nsuj}] = ...
                get_SleepEpoch(Dir{iexp}.path{isuj}{iisuj});
        end
    end
    num_exp(iexp) = nsuj;
end
disp('Done.')
disp('-------------------')
disp('Calculations')


for iexp=1:length(expe)
    for isuj=1:num_exp(iexp)
        % Restrict session to desired length
        epoch{isuj} = restrict_sesslen(sEpoch{iexp,isuj},sSession{iexp,isuj},subst(iexp,isuj),restrictlen);
    end
    % get sleep event details
    [rip{iexp} ripmean{iexp} ripdif{iexp}] = get_SleepEvent(Dir{iexp}.path,'ripples',epoch,subst(iexp,:));
    
    ripples_data.rip{iexp} = rip{iexp};
    ripples_data.ripmean{iexp} = ripmean{iexp};
    ripples_data.ripdif{iexp} = ripdif{iexp};
    
    clear epoch
end 

%%
%#####################################################################
%#                    P R E P     D A T A
%#####################################################################
stg_order = [3 1 4 5 6]; % order of stage - wake, nrem, n1, n2, n3
fn = fieldnames(ripmean{1}); % get field name of ripmean structure
ichar=0;
for i=1:numel(fn)-1 %length(charName)    
    if (isnumeric(ripmean{1}.(fn{i}))) && ~(i==4) %skip waveforms field 
        ichar=ichar+1;
        for istg=1:length(stageName)
            dat{ichar,istg}(1:max(num_exp),1:(length(expe)*2)+1) = nan;
            datdif{ichar,istg}(1:max(num_exp),1:length(expe)) = nan;
            for iexp=1:length(expe)
                for isess=1:2
                    if isess == 1
                        dat{ichar,istg}(1:size(ripmean{iexp}.(fn{i}),3),iexp) = ...
                            squeeze(ripmean{iexp}.(fn{i})(isess,stg_order(istg),:));
                    else
                        dat{ichar,istg}(1:size(ripmean{iexp}.(fn{i}),3),iexp+length(expe)+1) = ...
                            squeeze(ripmean{iexp}.(fn{i})(isess,stg_order(istg),:));
                    end
                end
                datdif{ichar,istg}(1:size(ripdif{iexp}.(fn{i}),2),iexp) = ...
                    squeeze(ripdif{iexp}.(fn{i})(stg_order(istg),:))';
            end
        end
    end
end

%% Parameters
shwpts = 1;
shwpts_diff = 0;
sig = 'sig';

ymax = [3300,200,42,1,55];

% prep plot titles
pstages = {'Wake','NREM','N1','N2','N3'};

% prep number of mouse per analyses
for iexp=1:length(expe)
    for istage=1:6
        numst(iexp,istage) = sum(~isnan(squeeze(ripmean{iexp}.waveforms(1,istage,:,1))));
    end
end

% Prep data for figure
nanfix(1:max(num_exp),1) = nan;
for iexp=1:length(expe)
    tgroup{iexp*3-2} = expe{iexp};
    tgroup{iexp*3-1} = '';
    tgroup{iexp*3} = '';
end
%%
%#####################################################################
%#                        F I G U R E S
%#####################################################################
for ichar=1:length(charName)
    % Raw data figure
    supertit = ['Ripples ' charName{ichar}];
    figH{ichar} = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1800 1500], ...
        'Name', supertit, 'NumberTitle','off');
        
        % axes position
        ax_wake = axes('position', [.15 .77 .42 .12]);
        ax_nrem = axes('position', [.15 .59 .42 .12]);
        ax_n1   = axes('position', [.15 .41 .42 .12]);
        ax_n2   = axes('position', [.15 .23 .42 .12]);
        ax_n3   = axes('position', [.15 .08 .42 .12]);
        AX = {ax_wake,ax_nrem,ax_n1,ax_n2,ax_n3};
        
        ax_difwake = axes('position', [.65 .77 .25 .12]);
        ax_difnrem = axes('position', [.65 .59 .25 .12]);
        ax_difn1   = axes('position', [.65 .41 .25 .12]);
        ax_difn2   = axes('position', [.65 .23 .25 .12]);
        ax_difn3   = axes('position', [.65 .08 .25 .12]);
        AX_diff = {ax_difwake,ax_difnrem,ax_difn1,ax_difn2,ax_difn3};

        % add legend with N
        pos1=.24;
        pos2=.17;
        interpos=(1-.2*3.7)/length(expe); 
        for iexp=1:length(expe)           
            annotation('textbox','Position',[pos1 .535 .04 .04 ], ...
                'String',['All - ' expname{iexp} ' - N=' num2str(numst(iexp,1))], ...
                'FitBoxToText','on', 'BackgroundColor',clr{iexp},'FaceAlpha',.5)
            annotation('textbox','Position',[pos2 .001 .04 .04 ], ...
                'String',['Substaged - ' expname{iexp} ' - N=' num2str(numst(iexp,4))], ...
                'FitBoxToText','on', 'BackgroundColor',clr{iexp},'FaceAlpha',.5)
            pos1=pos1+interpos; pos2=pos2+interpos+.05;
        end   
        
        % set plot stages labels
        ypos = 1.03; 
        for iplot=1:5
            a1 = annotation('textbox',[.05 ypos-.18*iplot 0 0],...
                'String',pstages{iplot},'FitBoxToText','on','EdgeColor','none'); 
            a1.FontSize = 12;
        end

        % Titles & subtitles
        ax_maintitle = axes('position', [.48 .95 .2 .05]); 
        text(-.18, 0.3,['Ripple ' charName{ichar}], ...
            'FontSize',18,'FontWeight','bold');
        set(ax_maintitle,'Visible','off') 
        ax_sub1 = axes('position', [.75 .89 .2 .05]); 
        text(-.18, 0.3,'Difference Pre/Post (%)', ...
            'FontSize',16,'FontWeight','bold');
        set(ax_sub1,'Visible','off') 
        ax_sess1 = axes('position', [.26 .89 .2 .05]); 
        text(-.18, 0.3,'Pre-Sleep', ...
            'FontSize',16,'FontWeight','bold');
        set(ax_sess1,'Visible','off')
        ax_sess2 = axes('position', [.47 .89 .2 .05]); 
        text(-.18, 0.3,'Post-Sleep', ...
            'FontSize',16,'FontWeight','bold');
        set(ax_sess2,'Visible','off') 
        
        for istg=1:length(stageName)
            axes(AX{istg})
                [~,h,her] = PlotErrorBarN_SL(dat{ichar,istg},...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],...
                        'showsigstar','none','showpoints',shwpts,'paired',0);
                    h.FaceColor = 'flat';
                    h.FaceAlpha = .5;
                    for isess=1:2
                        for iexpe=1:length(expe)
                            h.CData(((isess*(length(expe)+1))-4+iexpe),:) = clr{iexpe};
                        end
                    end
                    set(gca,'xticklabel',{[]})    
                    set(h, 'LineWidth', 1);
                    set(her, 'LineWidth', 1);
                    if istg==3
                        ylabel(ylab{ichar});
                    end
                    ylim([0 ymax(ichar)]);
                    makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)    

            axes(AX_diff{istg})
               [~,h2,~] = PlotErrorBarN_SL(datdif{ichar,istg},...
                        'barwidth', 0.6, 'newfig', 0,'barcolors',[1 1 1],...
                        'showsigstar','sig','showpoints',shwpts_diff,'paired',0);
                    h2.FaceColor = 'flat';
                    h2.FaceAlpha = .5;
                    for iexp=1:length(expe)
                        h2.CData(iexp,:) = clr{iexp};
                    end
                    set(gca,'xticklabel',{[]})  
                    set(h, 'LineWidth', 1);
                    set(her, 'LineWidth', 1);  
                    if istg==3
                        ylabel({'% change','in ' ylab{ichar}}); 
                    end
                    makepretty_erc('fsizel',10,'lwidth',1.5,'fsizet',16)
        end
end
