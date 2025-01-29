function [figH spindles_data] = compSpiGroups(expe,mice_num,restrictlen)

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
stageName = {'NREM','N2','N3'};
clr = {[0 .8 0],[.9 0 0],[1 1 1],[0 0 0]};  %arbitrary order. can change or automate later
charName = {'Amplitude','Frequency','Duration','Global Density','Local Density'};
ylab = {'uV','Hz','ms','spi/min','spi/min'};

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
            load([Dir{iexp}.path{isuj}{iisuj} 'behavResources.mat'], 'SessionEpoch','Vtsd'); 
            [sEpoch{iexp,nsuj} subst(iexp,nsuj) sSession{iexp,nsuj}] = ...
                get_SleepEpoch(Dir{iexp}.path{isuj}{iisuj},Vtsd);
            path{nsuj}=Dir{iexp}.path{isuj}{iisuj};
        end
    end
    num_exp(iexp) = nsuj;
end
disp('Done.')
disp('-------------------')
disp('Calculations')

%check session length (optional param)
for iexp=1:length(expe)
    for isuj=1:num_exp(iexp)
        if ~isempty(sEpoch{iexp,isuj}{1,3})
            if restrictlen
                st1=Start(sEpoch{iexp,isuj}{1,7});
                en1=End(sEpoch{iexp,isuj}{1,7});
                tot1=sum(en1-st1)/1e4;
                st2=Start(sEpoch{iexp,isuj}{2,7});
                en2=End(sEpoch{iexp,isuj}{2,7});
                tot2=sum(en2-st2)/1e4;
                if (tot1>restrictlen) && (tot2>restrictlen)
                    ok(iexp,isuj)=1;
                else 
                    ok(iexp,isuj)=0;
                end
                clear st1 st2 en1 en2 tot1 tot2
            else
                ok(iexp,isuj)=1;
            end      
        end
    end
end

for iexp=1:length(expe)
    for ii=1:2
        num{ii}=0; 
    end
    for isuj=1:num_exp(iexp)
        if ok(iexp,isuj)
            for isess=1:2
                % set begining and end 
                lenepoch = Data(length(sEpoch{iexp,isuj}{isess,7}))/1e4;
                lenstage = 0;
                for iep=1:length(lenepoch)
                    if lenstage+lenepoch(iep)<restrictlen
                        lenstage=lenstage+lenepoch(iep);
                    else
                        stlast = Start(subset(sEpoch{iexp,isuj}{isess,7},iep));
                        endrest = stlast + restrictlen*1e4 - lenstage*1e4;
                        break
                    end
                end
                st = Start(sSession{iexp,isuj}{isess});
                islen = intervalSet(st,endrest);
                % restrict to min duration (main sleep stages)
                for irest=1:7
                    if irest==4
                        irest=7;
                    end
                    if restrictlen                            
                        epoch{isuj}{isess,irest} = and(sEpoch{iexp,isuj}{isess,irest},islen);
                    else
                        epoch{isuj}{isess,irest} = sEpoch{iexp,isuj}{isess,irest};
                    end
                    if irest==7
                        break
                    end
                end
                % restrict to min duration (substges)
                num{isess}=num{isess}+1;
                if subst(iexp,isuj)
                    for irest=4:6
                        if restrictlen
                            epoch{isuj}{isess,irest} = and(sEpoch{iexp,isuj}{isess,irest},islen);
                        else
                            epoch{isuj}{isess,irest} = sEpoch{iexp,isuj}{isess,irest};
                        end
                    end
                end
            end
        end
    end
    % get sleep event details
    [spi{iexp} spimean{iexp} spidif{iexp}] = get_SleepEvent(Dir{iexp}.path,'Spindles',epoch,subst(iexp,:));
    
    spindles_data.spi{iexp} = spi{iexp};
    spindles_data.spimean{iexp} = spimean{iexp};
    spindles_data.spidif{iexp} = spidif{iexp};
end 

%%
%#####################################################################
%#                    P R E P     D A T A
%#####################################################################
stg_order = [1 5 6]; % order of stage - nrem, n2, n3
fn = fieldnames(spimean{1}); % get field name of ripmean structure
ichar=0;
for i=1:numel(fn)-1 %length(charName)    
    if (isnumeric(spimean{1}.(fn{i}))) && ~(i==4) %skip waveforms field 
        ichar=ichar+1;
        for istg=1:length(stageName)
            % mice without detected event are 0 - change it to nan (no zero
            % possible)
            dat{ichar,istg}(1:max(num_exp),1:(length(expe)*2)+1) = nan;
            datdif{ichar,istg}(1:max(num_exp),1:length(expe)) = nan;
            for iexp=1:length(expe)
                for isess=1:2
                    if isess == 1
                        dat{ichar,istg}(1:size(spimean{iexp}.(fn{i}),3),iexp) = ...
                            squeeze(spimean{iexp}.(fn{i})(isess,stg_order(istg),:));
                        dat{ichar,istg}(dat{ichar,istg}==0) = nan;
                    else
                        dat{ichar,istg}(1:size(spimean{iexp}.(fn{i}),3),iexp+length(expe)+1) = ...
                            squeeze(spimean{iexp}.(fn{i})(isess,stg_order(istg),:));
                        dat{ichar,istg}(dat{ichar,istg}==0) = nan;
                    end
                end
                datdif{ichar,istg}(1:size(spidif{iexp}.(fn{i}),2),iexp) = ...
                    squeeze(spidif{iexp}.(fn{i})(stg_order(istg),:))';
                datdif{ichar,istg}(datdif{ichar,istg}==0) = nan;
            end
        end
    end
end

%% Parameters
shwpts = 1;
shwpts_diff = 0;
sig = 'sig';

ymax = [800000,20,1000,5,8];

% prep plot titles
pstages = {'NREM','N2','N3'};

% prep number of mouse per analyses
for iexp=1:length(expe)
    for istage=1:6
        numst(iexp,istage) = sum(~isnan(squeeze(spimean{iexp}.waveforms(1,istage,:,1))));
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
    supertit = ['Spindles ' charName{ichar}];
    figH{ichar} = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1800 1100], ...
        'Name', supertit, 'NumberTitle','off');
        
        % axes position
        ax_nrem = axes('position', [.15 .66 .42 .21]);
        ax_n2   = axes('position', [.15 .37 .42 .21]);
        ax_n3   = axes('position', [.15 .08 .42 .21]);
        AX = {ax_nrem,ax_n2,ax_n3};
        
        ax_difnrem = axes('position', [.65 .66 .25 .21]);
        ax_difn2   = axes('position', [.65 .37 .25 .21]);
        ax_difn3   = axes('position', [.65 .08 .25 .21]);
        AX_diff = {ax_difnrem,ax_difn2,ax_difn3};

        % add legend with N
        pos1=.24;
        pos2=.17;
        interpos=(1-.2*3.7)/length(expe); 
        for iexp=1:length(expe)           
            annotation('textbox','Position',[pos1 .59 .04 .04 ], ...
                'String',['All - ' expname{iexp} ' - N=' num2str(numst(iexp,1))], ...
                'FitBoxToText','on', 'BackgroundColor',clr{iexp},'FaceAlpha',.5)
            annotation('textbox','Position',[pos2 .001 .04 .04 ], ...
                'String',['Substaged - ' expname{iexp} ' - N=' num2str(numst(iexp,4))], ...
                'FitBoxToText','on', 'BackgroundColor',clr{iexp},'FaceAlpha',.5)
            pos1=pos1+interpos; pos2=pos2+interpos+.05;
        end   
        
        % set plot stages labels
        ypos = 1.03; 
        for iplot=1:3
            a1 = annotation('textbox',[.05 ypos-.28*iplot 0 0],...
                'String',pstages{iplot},'FitBoxToText','on','EdgeColor','none'); 
            a1.FontSize = 16;
        end

        % Titles & subtitles
        ax_maintitle = axes('position', [.48 .95 .2 .05]); 
        text(-.18, 0.3,['Spindle ' charName{ichar}], ...
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
