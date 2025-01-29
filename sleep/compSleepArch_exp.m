function [figH, sstage] = compSleepArch_exp(expe, mice_num, restrictlen)

%==========================================================================
% Details: compare sleep events (ripples, spindles, deltas if any) between
% pre and post sleep sessions
%
% INPUTS:
%       - expe              Name of 2 experiments in PathForExperiment
%                           Format: {'StimMFBWake','UMazePAG'}
%       - mice_num          ID # of all mice for the analyses
%                           Format: [mouse_exp1, mouse_exp1; mouse_exp2, mouse_exp2]
%       - restrictlen       Minimum length (in seconds) of either pre or post sleep
%                           duration (not session duration). If no
%                           restriction = 0
%       
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
for i=1:length(expe)
    Dir{i} = PathForExperimentsERC(expe{i});
    switch expe{i}
        case 'StimMFBWake'
            expname{i}='MFB';
        case 'Novel'
            expname{i}='Novel';
        case 'UMazePAG'
            expname{i}='PAG';
        case 'Known'
            expname{i}='Known';
        case 'BaselineSleep'
            expname{i}='BaselineSleep';
    end
    Dir{i} = RestrictPathForExperiment(Dir{i}, 'nMice', unique(mice_num{i}));
end

% var init
stageName = {'NREM','REM','Wake','N1','N2','N3','Sleep'};
durstd=120;
sig = 'none';
% manually set minimum rem % during pre-sleep. If at 0 then it will not
% apply any restriction
remmin = 1;
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
                    disp([num2str(mice_num{iexp}(isuj)) ' - ' ...
                            expname{iexp} ' - rejected - not enough sleep (lower duration than required)'])
                end
                clear st1 st2 en1 en2 tot1 tot2
            else
                ok(iexp,isuj)=1;
            end            
%             % exceptions
%             if isuj==6 || isuj==12 % PAG905, PAG1117
%                 ok(iexp,isuj)=0;
%             end
        end
    end
end

% Prepare data

subst_new = nan(length(expe),max(num_exp));
for iexp=1:length(expe)
    for i=1:2, num{i}=0; end
    for isuj=1:num_exp(iexp)
%         stgperc = cumulSleepScoring(path{isuj},10);
        for isess=1:2
            if ~isempty(sEpoch{iexp,isuj}{isess,3}) && ok(iexp,isuj)
                % session, sleep durations
                sess_epoch = or(sEpoch{iexp,isuj}{isess,3},sEpoch{iexp,isuj}{isess,7});
                dur = sum(End(sess_epoch)-Start(sess_epoch))/60e4;
                if dur>durstd-100 && dur<durstd+100 
                    % set begining and end 
                    lenepoch = Data(length(sEpoch{iexp,isuj}{isess,7}))/1e4;
                    lenstage = 0;
                    for i=1:length(lenepoch)
                        if lenstage+lenepoch(i)<restrictlen
                            lenstage=lenstage+lenepoch(i);
                        else
                            stlast = Start(subset(sEpoch{iexp,isuj}{isess,7},i));
                            endrest = stlast + restrictlen*1e4 - lenstage*1e4;
                            break
                        end
                    end
                    st = Start(sSession{iexp,isuj}{isess});
                    islen = intervalSet(st,endrest);
                    % restrict to min duration
                    for irest=1:4
                        if irest==4
                            irest=7;
                        end
                        if restrictlen                            
                            epoch{irest} = and(sEpoch{iexp,isuj}{isess,irest},islen);
                        else
                            epoch{irest} = sEpoch{iexp,isuj}{isess,irest};
                        end
                    end
                    
                    % check minimal rem duration
                    if remmin
                        remperc = (sum(End(epoch{2})-Start(epoch{2}))/60e4) / ...
                            (sum(End(epoch{7})-Start(epoch{7}))/60e4) * 100;
                        if remperc<4 && isess==1
                            disp([num2str(mice_num{iexp}(isuj)) ' - ' ...
                                expname{iexp} ' - rejected - REM too low'])
                            break
                        end
                        clear remperc
                    end
                    
                    % create epochs
                    num{isess}=num{isess}+1;
                    if subst(iexp,isuj)
                        for irest=4:6
                            if restrictlen
                                epoch{irest} = and(sEpoch{iexp,isuj}{isess,irest},islen);
                            else
                                epoch{irest} = sEpoch{iexp,isuj}{isess,irest};
                            end
                        end
                        % set new substage logical
                        subst_new(iexp,num{isess}) = 1;
                    else
                        subst_new(iexp,num{isess}) = 0;
                    end
                    if restrictlen
                        sesslen(iexp,isess,num{isess}) = restrictlen/60;
                    else
                        sesslen(iexp,isess,num{isess}) = dur;
                    end
                    sessdur(iexp,isess,num{isess}) = dur;
                    sesssleep(iexp,isess,num{isess}) = sum(End(sEpoch{iexp,isuj}{isess,7})-Start(sEpoch{iexp,isuj}{isess,7}))/60e4;
                    % latency to sleep
                    stsleep = Start(sEpoch{iexp,isuj}{isess,7});
                    stsess=Start(sess_epoch);
                    sleeplat(iexp,isess,num{isess}) = (stsleep(1)-stsess(1))/60E4;
                    
                    
                    
                    % duration
                    nrem_dur(iexp,isess,num{isess}) = sum(End(epoch{1})- ...
                        Start(epoch{1}))/60e4;
                    rem_dur(iexp,isess,num{isess}) = sum(End(epoch{2})- ...
                        Start(epoch{2}))/60e4;
                    wake_dur(iexp,isess,num{isess}) = sum(End(epoch{3})- ...
                        Start(epoch{3}))/60e4;
                    sleep_dur(iexp,isess,num{isess}) = sum(End(epoch{7})- ...
                        Start(epoch{7}))/60e4;
                    if subst(iexp,isuj)
                        n1_dur(iexp,isess,num{isess}) = sum(End(epoch{4})- ...
                            Start(epoch{4}))/60e4;
                        n2_dur(iexp,isess,num{isess}) = sum(End(epoch{5})- ...
                            Start(epoch{5}))/60e4;
                        n3_dur(iexp,isess,num{isess}) = sum(End(epoch{6})- ...
                            Start(epoch{6}))/60e4;
                        subsfilled(iexp,isess,num{isess}) = 1;
                    end
                    % percentage with wake
                    if restrictlen
                        nrem_per(iexp,isess,num{isess}) =  (nrem_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})+wake_dur(iexp,isess,num{isess})))*100;
                        rem_per(iexp,isess,num{isess}) =  (rem_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})+wake_dur(iexp,isess,num{isess})))*100;
                        wake_per(iexp,isess,num{isess}) =  (wake_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})+wake_dur(iexp,isess,num{isess})))*100;
                        if subst(iexp,isuj)
                            n1_per(iexp,isess,num{isess}) = (n1_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})+wake_dur(iexp,isess,num{isess})))*100;
                            n2_per(iexp,isess,num{isess}) = (n2_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})+wake_dur(iexp,isess,num{isess})))*100;
                            n3_per(iexp,isess,num{isess}) = (n3_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})+wake_dur(iexp,isess,num{isess})))*100;
                        end
                    else
                        nrem_per(iexp,isess,num{isess}) =  (nrem_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})))*100;
                        rem_per(iexp,isess,num{isess}) =  (rem_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})))*100;
                        wake_per(iexp,isess,num{isess}) =  (wake_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})))*100;
                        if subst(iexp,isuj)
                            n1_per(iexp,isess,num{isess}) = (n1_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})))*100;
                            n2_per(iexp,isess,num{isess}) = (n2_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})))*100;
                            n3_per(iexp,isess,num{isess}) = (n3_dur(iexp,isess,num{isess})/(sesslen(iexp,isess,num{isess})))*100;
                        end
                    end
                    % percentage without wake
                    nrem_per_now(iexp,isess,num{isess}) =  nrem_dur(iexp,isess,num{isess})/ ... 
                        sleep_dur(iexp,isess,num{isess})*100;
                    rem_per_now(iexp,isess,num{isess}) =  rem_dur(iexp,isess,num{isess})/ ...
                        sleep_dur(iexp,isess,num{isess})*100;
                    if subst(iexp,isuj)
                        n1_per_now(iexp,isess,num{isess}) = n1_dur(iexp,isess,num{isess})/ ...
                            sleep_dur(iexp,isess,num{isess})*100;
                        n2_per_now(iexp,isess,num{isess}) = n2_dur(iexp,isess,num{isess})/ ...
                            sleep_dur(iexp,isess,num{isess})*100;
                        n3_per_now(iexp,isess,num{isess}) = n3_dur(iexp,isess,num{isess})/ ...
                            sleep_dur(iexp,isess,num{isess})*100;
                    end
                    %save mouse ID used in data
                    if isess==1, miceID{num{isess},iexp} = mice_num{iexp}(isuj); end
                    %clear var 
                    clear epoch st
                end
            end
        end
    end
    exp_num(iexp)=num{1};
    if restrictlen
        for isuj=1:exp_num(iexp)
            nremdiff_per_now(iexp,isuj) = (nrem_dur(iexp,2,isuj) - nrem_dur(iexp,1,isuj))/nrem_dur(iexp,1,isuj)*100;
            remdiff_per_now(iexp,isuj) = (rem_dur(iexp,2,isuj) - rem_dur(iexp,1,isuj))/rem_dur(iexp,1,isuj)*100;
            if subst_new(iexp,isuj)
                n1diff_per_now(iexp,isuj) = (n1_dur(iexp,2,isuj) - n1_dur(iexp,1,isuj))/n1_dur(iexp,1,isuj)*100;
                n2diff_per_now(iexp,isuj) = (n2_dur(iexp,2,isuj) - n2_dur(iexp,1,isuj))/n2_dur(iexp,1,isuj)*100;
                n3diff_per_now(iexp,isuj) = (n3_dur(iexp,2,isuj) - n3_dur(iexp,1,isuj))/n3_dur(iexp,1,isuj)*100;
            else
                n1diff_per_now(iexp,isuj) = nan;
                n2diff_per_now(iexp,isuj) = nan;
                n3diff_per_now(iexp,isuj) = nan;
            end
        end    
    else
        for isuj=1:exp_num(iexp)
            nremdiff_per_now(iexp,isuj) = (nrem_per_now(iexp,2,isuj) - nrem_per_now(iexp,1,isuj))/nrem_per_now(iexp,1,isuj)*100;
            remdiff_per_now(iexp,isuj) = (rem_per_now(iexp,2,isuj) - rem_per_now(iexp,1,isuj))/rem_per_now(iexp,1,isuj)*100;
            if subst_new(iexp,isuj)
                n1diff_per_now(iexp,isuj) = (n1_per_now(iexp,2,isuj) - n1_per_now(iexp,1,isuj))/n1_per_now(iexp,1,isuj)*100;
                n2diff_per_now(iexp,isuj) = (n2_per_now(iexp,2,isuj) - n2_per_now(iexp,1,isuj))/n2_per_now(iexp,1,isuj)*100;
                n3diff_per_now(iexp,isuj) = (n3_per_now(iexp,2,isuj) - n3_per_now(iexp,1,isuj))/n3_per_now(iexp,1,isuj)*100;
            else
                n1diff_per_now(iexp,isuj) = nan;
                n2diff_per_now(iexp,isuj) = nan;
                n3diff_per_now(iexp,isuj) = nan;
            end
        end
    end
    
end
% zeros to nan
[m id] = max(exp_num);
for iexp=1:length(expe)
    for isess=1:2
        if ~(id==iexp)
            sessdur(iexp,isess,exp_num(iexp)+1:end) = nan;
            sesssleep(iexp,isess,exp_num(iexp)+1:end) = nan;
            sleeplat(iexp,isess,exp_num(iexp)+1:end) = nan;

            nrem_dur(iexp,isess,exp_num(iexp)+1:end) = nan;
            rem_dur(iexp,isess,exp_num(iexp)+1:end) = nan;
            wake_dur(iexp,isess,exp_num(iexp)+1:end) = nan;
            nrem_per(iexp,isess,exp_num(iexp)+1:end) = nan;
            rem_per(iexp,isess,exp_num(iexp)+1:end) = nan;
            wake_per(iexp,isess,exp_num(iexp)+1:end) = nan;
            nrem_per_now(iexp,isess,exp_num(iexp)+1:end) = nan;
            rem_per_now(iexp,isess,exp_num(iexp)+1:end) = nan;
        end
        for isuj=1:size(n1_dur,3)
            if ~(subsfilled(iexp,isess,isuj) == 1)
                n1_dur(iexp,isess,isuj) = nan;
                n2_dur(iexp,isess,isuj) = nan;
                n3_dur(iexp,isess,isuj) = nan;
                n1_per(iexp,isess,isuj) = nan;
                n2_per(iexp,isess,isuj) = nan;
                n3_per(iexp,isess,isuj) = nan;
                n1_per_now(iexp,isess,isuj) = nan;
                n2_per_now(iexp,isess,isuj) = nan;
                n3_per_now(iexp,isess,isuj) = nan; 
            end
        end
    end
    nremdiff_per_now(iexp,exp_num(iexp)+1:end) = nan; 
    remdiff_per_now(iexp,exp_num(iexp)+1:end) = nan; 
    n1diff_per_now(iexp,exp_num(iexp)+1:end) = nan; 
    n2diff_per_now(iexp,exp_num(iexp)+1:end) = nan; 
    n3diff_per_now(iexp,exp_num(iexp)+1:end) = nan; 
end

sstage.expname = expname;
sstage.micenum = mice_num;
sstage.sessdur = sessdur;
sstage.sesssleep = sesssleep;
sstage.sleeplat = sleeplat;
% duration
sstage.dur.nrem = nrem_dur;
sstage.dur.rem = rem_dur;
sstage.dur.wake = wake_dur;
sstage.dur.sleep = sleep_dur;
sstage.dur.n1 = n1_dur;
sstage.dur.n2 = n2_dur;
sstage.dur.n3 = n3_dur;
% percentage with wake
sstage.per.nrem = nrem_per;
sstage.per.rem = rem_per;
sstage.per.wake = wake_per;
sstage.per.n1 = n1_per;
sstage.per.n2 = n2_per;
sstage.per.n3 = n3_per;
% percentage NO wake
sstage.per_nowake.nrem = nrem_per_now;
sstage.per_nowake.rem = rem_per_now;
sstage.per_nowake.n1 = n1_per_now;
sstage.per_nowake.n2 = n2_per_now;
sstage.per_nowake.n3 = n3_per_now;
% difference in percentage NO wake 
sstage.diff_per_nowake.nrem = nremdiff_per_now;
sstage.diff_per_nowake.rem = remdiff_per_now;
sstage.diff_per_nowake.n1 = n1diff_per_now;
sstage.diff_per_nowake.n2 = n2diff_per_now;
sstage.diff_per_nowake.n3 = n3diff_per_now;
% mice id
sstage.miceID = miceID;
% get N
for iexp=1:length(expe)
    numsuj(iexp,1) = sum(~isnan(sstage.dur.nrem(iexp,1,:)));  % all
    numsuj(iexp,2) = sum(~isnan(sstage.dur.n1(iexp,1,:)));    % with substages
end

%%
%#####################################################################
%#                        F I G U R E S
%#####################################################################

clr = {[0 .8 0],[.9 0 0],[1 1 1],[0 0 0]};  %arbitrary order. can change or automate later
% exptxt = {''};
% for iexp=1:length(expe)
%     exptxt{iexp+1} = expname{iexp};
% end
% exptxt{iexp+2}='';


disp('Plotting figures')
% set var
tit_sess = {'Pre-Sleep (min)','Post-Sleep (min)'};
tit_sess_perc = {'Pre-Sleep (%)','Post-Sleep (%)'};

supertit = ['Sleep Architecture - Durations (min)'];
figH.dur = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 800 800],'Name', supertit, 'NumberTitle','off');
    % axes position
    ax_nrem{1} = axes('position', [.15 .7 .32 .25]);
    ax_rem{1} =  axes('position', [.15 .4 .32 .25]);
    ax_wake{1} = axes('position', [.15 .1 .32 .25]);
    ax_nrem{2} = axes('position', [.65 .7 .32 .25]);
    ax_rem{2} =  axes('position', [.65 .4 .32 .25]);
    ax_wake{2} = axes('position', [.65 .1 .32 .25]);
    % texts position
    ax_tnrem = axes('position', [.075 .78 .2 .05]); 
    text(-.18, 0.3,'NREM','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_tnrem,'Visible','off')  
    ax_trem = axes('position', [.075 .48 .2 .05]); 
    text(-.18, 0.3,'REM','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_trem,'Visible','off')  
    ax_twake = axes('position', [.075 .18 .2 .05]); 
    text(-.18, 0.3,'Wake','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_twake,'Visible','off')  
    
    ymax_nrem = max(max([nrem_dur(1,1,:) nrem_dur(2,1,:) ...
        nrem_dur(1,2,:) nrem_dur(1,2,:)]))*1.15;
    ymax_rem  = max(max([rem_dur(1,1,:) rem_dur(2,1,:) ...
        rem_dur(1,2,:) rem_dur(2,2,:)]))*1.15;
    ymax_wake = max(max([wake_dur(1,1,:) wake_dur(2,1,:) ...
        wake_dur(1,2,:) wake_dur(2,2,:)]))*1.15;
    for isess=1:2   
        nremcat=[]; remcat=[]; wakecat=[];
        for iexp=1:length(expe)
            nremcat = [nremcat squeeze(squeeze(nrem_dur(iexp,isess,:)))];
            remcat = [remcat squeeze(squeeze(rem_dur(iexp,isess,:)))];
            wakecat = [wakecat squeeze(squeeze(wake_dur(iexp,isess,:)))];
        end
            
        axes(ax_nrem{isess})
           [p,h,her] = PlotErrorBarN_SL(nremcat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_nrem])
            set(gca,'xticklabel',{[]})
            title(tit_sess{isess})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)

        axes(ax_rem{isess})
           [p,h,her] = PlotErrorBarN_SL(remcat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico}; 
            end
            ylim([0 ymax_rem])
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)

        axes(ax_wake{isess})
           [p,h,her] = PlotErrorBarN_SL(wakecat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_wake])
            set(gca,'xticklabel',{[]})    
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);         
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16) 
    end
    % add legend with N
    basepos=.2;
    interpos=(1-.2*2)/length(expe); 
    pos=basepos;
    for iexp=1:length(expe)
        annotation('textbox','Position',[pos .012 .04 .04 ], ...
            'String',[' ' expname{iexp} ' - N=' num2str(numsuj(iexp))], ...
            'FitBoxToText','on', ...
            'BackgroundColor',clr{iexp},'FaceAlpha',.5);
        pos=pos+interpos;
    end     
    if restrictlen
        annotation('textbox','Position',[.35 .035 .04 .04 ], ...
            'String',['Restricted to first ' num2str(restrictlen) ' sec.'], ...
            'FitBoxToText','on','EdgeColor',[0 0 0]);
    end

supertit = ['Sleep Architecture - Percentage'];
figH.perc = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 800 800],'Name', supertit, 'NumberTitle','off');
    % axes position
    ax_nrem{1} = axes('position', [.15 .7 .32 .25]);
    ax_rem{1} =  axes('position', [.15 .4 .32 .25]);
    ax_wake{1} = axes('position', [.15 .1 .32 .25]);
    ax_nrem{2} = axes('position', [.65 .7 .32 .25]);
    ax_rem{2} =  axes('position', [.65 .4 .32 .25]);
    ax_wake{2} = axes('position', [.65 .1 .32 .25]);
    % texts position
    ax_tnrem = axes('position', [.075 .78 .2 .05]); 
    text(-.18, 0.3,'NREM','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_tnrem,'Visible','off')  
    ax_trem = axes('position', [.075 .48 .2 .05]); 
    text(-.18, 0.3,'REM','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_trem,'Visible','off')  
    ax_twake = axes('position', [.075 .18 .2 .05]); 
    text(-.18, 0.3,'Wake','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_twake,'Visible','off')  
    
    ymax_nrem = max(max([nrem_per(1,1,:) nrem_per(2,1,:) ...
        nrem_per(1,2,:) nrem_per(1,2,:)]))*1.15;
    ymax_rem  = max(max([rem_per(1,1,:) rem_per(2,1,:) ...
        rem_per(1,2,:) rem_per(2,2,:)]))*1.15;
    ymax_wake = max(max([wake_per(1,1,:) wake_per(2,1,:) ...
        wake_per(1,2,:) wake_per(2,2,:)]))*1.15;
    for isess=1:2     
        nremcat=[]; remcat=[]; wakecat=[];
        for iexp=1:length(expe)
            nremcat = [nremcat squeeze(squeeze(nrem_per(iexp,isess,:)))];
            remcat = [remcat squeeze(squeeze(rem_per(iexp,isess,:)))];
            wakecat = [wakecat squeeze(squeeze(wake_per(iexp,isess,:)))];
        end
        axes(ax_nrem{isess})
           [p,h,her] = PlotErrorBarN_SL(nremcat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_nrem])
            set(gca,'xticklabel',{[]})
            title(tit_sess_perc{isess})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
            
        axes(ax_rem{isess})
           [p,h,her] = PlotErrorBarN_SL(remcat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_rem])
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
            
        axes(ax_wake{isess})
           [p,h,her] = PlotErrorBarN_SL(wakecat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_wake])
            set(gca,'xticklabel',{[]})    
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);         
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    % add legend with N
    basepos=.2;
    interpos=(1-.2*2)/length(expe); 
    pos=basepos;
    for iexp=1:length(expe)
        annotation('textbox','Position',[pos .017 .04 .04 ], ...
            'String',[' ' expname{iexp} ' - N=' num2str(numsuj(iexp))], ...
            'FitBoxToText','on', ...
            'BackgroundColor',clr{iexp},'FaceAlpha',.5)
        pos=pos+interpos;
    end    

supertit = ['NREM vs REM - Percentage'];
figH.perc_now = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 800 800],'Name', supertit, 'NumberTitle','off');
    % axes position
    ax_nrem{1} = axes('position', [.15 .7 .32 .25]);
    ax_rem{1} =  axes('position', [.15 .4 .32 .25]);
    ax_nrem{2} = axes('position', [.65 .7 .32 .25]);
    ax_rem{2} =  axes('position', [.65 .4 .32 .25]);
    % texts position
    ax_tnrem = axes('position', [.075 .78 .2 .05]); 
    text(-.18, 0.3,'NREM','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_tnrem,'Visible','off')  
    ax_trem = axes('position', [.075 .48 .2 .05]); 
    text(-.18, 0.3,'REM','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_trem,'Visible','off')  
    
    ymax_nrem = max(max([nrem_per_now(1,1,:) nrem_per_now(2,1,:) ...
        nrem_per_now(1,2,:) nrem_per_now(1,2,:)]))*1.15;
    ymax_rem  = max(max([rem_per_now(1,1,:) rem_per_now(2,1,:) ...
        rem_per_now(1,2,:) rem_per_now(2,2,:)]))*1.15;
    for isess=1:2   
        nremcat=[]; remcat=[];
        for iexp=1:length(expe)
            nremcat = [nremcat squeeze(squeeze(nrem_per_now(iexp,isess,:)))];
            remcat = [remcat squeeze(squeeze(rem_per_now(iexp,isess,:)))];
        end  
        axes(ax_nrem{isess})
           [p,h,her] = PlotErrorBarN_SL(nremcat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_nrem])
            set(gca,'xticklabel',{[]})
            title(tit_sess_perc{isess})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
            
        axes(ax_rem{isess})
           [p,h,her] = PlotErrorBarN_SL(remcat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_rem])
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    % add legend with N
    basepos=.2;
    interpos=(1-.2*2)/length(expe); 
    pos=basepos;
    for iexp=1:length(expe)
        annotation('textbox','Position',[pos .017 .04 .04 ], ...
            'String',[' ' expname{iexp} ' - N=' num2str(numsuj(iexp))], ...
            'FitBoxToText','on', ...
            'BackgroundColor',clr{iexp},'FaceAlpha',.5)
        pos=pos+interpos;
    end    
   
%%  Figures SUBSTAGING    
% DURATION
supertit = ['NREM Substaging - Durations (min)'];
figH.perc_now = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 800 800],'Name', supertit, 'NumberTitle','off');
    % axes position
    ax_n1{1} = axes('position', [.15 .7 .32 .25]);
    ax_n2{1} =  axes('position', [.15 .4 .32 .25]);
    ax_n3{1} = axes('position', [.15 .1 .32 .25]);
    ax_n1{2} = axes('position', [.65 .7 .32 .25]);
    ax_n2{2} =  axes('position', [.65 .4 .32 .25]);
    ax_n3{2} = axes('position', [.65 .1 .32 .25]);
    % texts position
    ax_tnrem = axes('position', [.075 .78 .2 .05]); 
    text(-.18, 0.3,'N1','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_tnrem,'Visible','off')  
    ax_trem = axes('position', [.075 .48 .2 .05]); 
    text(-.18, 0.3,'N2','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_trem,'Visible','off')  
    ax_twake = axes('position', [.075 .18 .2 .05]); 
    text(-.18, 0.3,'N3','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_twake,'Visible','off')  
    
    ymax_n1 = max(max([n1_dur(1,1,:) n1_dur(2,1,:) ...
        n1_dur(1,2,:) n1_dur(1,2,:)]))*1.15;
    ymax_n2  = max(max([n2_dur(1,1,:) n2_dur(2,1,:) ...
        n2_dur(1,2,:) n2_dur(2,2,:)]))*1.15;
    ymax_n3 = max(max([n3_dur(1,1,:) n3_dur(2,1,:) ...
        n3_dur(1,2,:) n3_dur(2,2,:)]))*1.15;
    
    for isess=1:2   
        n1cat=[]; n2cat=[]; n3cat=[];
        for iexp=1:length(expe)
            n1cat = [n1cat squeeze(squeeze(n1_dur(iexp,isess,:)))];
            n2cat = [n2cat squeeze(squeeze(n2_dur(iexp,isess,:)))];
            n3cat = [n3cat squeeze(squeeze(n3_dur(iexp,isess,:)))];
        end  
        axes(ax_n1{isess})
           [p,h,her] = PlotErrorBarN_SL(n1cat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_n1])
            set(gca,'xticklabel',{[]})
            title(tit_sess{isess})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
            
        axes(ax_n2{isess})
           [p,h,her] = PlotErrorBarN_SL(n2cat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_n2])
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
            
        axes(ax_n3{isess})
           [p,h,her] = PlotErrorBarN_SL(n3cat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_n3])
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    % add legend with N
    basepos=.2;
    interpos=(1-.2*2)/length(expe); 
    pos=basepos;
    for iexp=1:length(expe)
        annotation('textbox','Position',[pos .017 .04 .04 ], ...
            'String',[' ' expname{iexp} ' - N=' num2str(numsuj(iexp,2))], ...
            'FitBoxToText','on', ...
            'BackgroundColor',clr{iexp},'FaceAlpha',.5)
        pos=pos+interpos;
    end   

% PERCENTAGE
supertit = ['NREM vs REM - Percentage'];
figH.percsub_now = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 800 800],'Name', supertit, 'NumberTitle','off');
    % axes position
    ax_n1{1} = axes('position', [.15 .7 .32 .25]);
    ax_n2{1} =  axes('position', [.15 .4 .32 .25]);
    ax_n3{1} = axes('position', [.15 .1 .32 .25]);
    ax_n1{2} = axes('position', [.65 .7 .32 .25]);
    ax_n2{2} =  axes('position', [.65 .4 .32 .25]);
    ax_n3{2} = axes('position', [.65 .1 .32 .25]);
    % texts position
    ax_tnrem = axes('position', [.075 .78 .2 .05]); 
    text(-.18, 0.3,'N1','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_tnrem,'Visible','off')  
    ax_trem = axes('position', [.075 .48 .2 .05]); 
    text(-.18, 0.3,'N2','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_trem,'Visible','off')  
    ax_twake = axes('position', [.075 .18 .2 .05]); 
    text(-.18, 0.3,'N3','rotation',90, ...
       'FontSize',14,'FontWeight','bold');
    set(ax_twake,'Visible','off')  
    
    ymax_n1 = max(max([n1_per_now(1,1,:) n1_per_now(2,1,:) ...
        n1_per_now(1,2,:) n1_per_now(1,2,:)]))*1.15;
    ymax_n2  = max(max([n2_per_now(1,1,:) n2_per_now(2,1,:) ...
        n2_per_now(1,2,:) n2_per_now(2,2,:)]))*1.15;
    ymax_n3 = max(max([n3_per_now(1,1,:) n3_per_now(2,1,:) ...
        n3_per_now(1,2,:) n3_per_now(2,2,:)]))*1.15;
    
    for isess=1:2   
        n1cat=[]; n2cat=[]; n3cat=[];
        for iexp=1:length(expe)
            n1cat = [n1cat squeeze(squeeze(n1_per_now(iexp,isess,:)))];
            n2cat = [n2cat squeeze(squeeze(n2_per_now(iexp,isess,:)))];
            n3cat = [n3cat squeeze(squeeze(n3_per_now(iexp,isess,:)))];
        end  
        axes(ax_n1{isess})
           [p,h,her] = PlotErrorBarN_SL(n1cat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_n1])
            set(gca,'xticklabel',{[]})
            title(tit_sess_perc{isess})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
            
        axes(ax_n2{isess})
           [p,h,her] = PlotErrorBarN_SL(n2cat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_n2])
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
            
        axes(ax_n3{isess})
           [p,h,her] = PlotErrorBarN_SL(n3cat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_n3])
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    % add legend with N
    basepos=.2;
    interpos=(1-.2*2)/length(expe); 
    pos=basepos;
    for iexp=1:length(expe)
        annotation('textbox','Position',[pos .017 .04 .04 ], ...
            'String',[' ' expname{iexp} ' - N=' num2str(numsuj(iexp,2))], ...
            'FitBoxToText','on', ...
            'BackgroundColor',clr{iexp},'FaceAlpha',.5)
        pos=pos+interpos;
    end   
    
    
    
%% FIGURE DURATION OF SESSION, SLEEP, LATENCY
tit_sess = {'Pre-Sleep(min)','Post-Sleep (min)'};

supertit = ['Sleep Architecture - Durations (min)'];
figH.measures = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 800 800],'Name', supertit, 'NumberTitle','off');
    % axes position
    ax_nrem{1} = axes('position', [.15 .7 .32 .25]);
    ax_rem{1} =  axes('position', [.15 .4 .32 .25]);
    ax_wake{1} = axes('position', [.15 .1 .32 .25]);
    ax_nrem{2} = axes('position', [.65 .7 .32 .25]);
    ax_rem{2} =  axes('position', [.65 .4 .32 .25]);
    ax_wake{2} = axes('position', [.65 .1 .32 .25]);
    % texts position
    ax_tnrem = axes('position', [.075 .78 .2 .05]); 
    text(-.18, 0.3,{'Session','duration'},'rotation',90, ...
       'FontSize',16,'FontWeight','bold');
    set(ax_tnrem,'Visible','off')  
    ax_trem = axes('position', [.075 .48 .2 .05]); 
    text(-.18, 0.3,{'Sleep','duration'},'rotation',90, ...
       'FontSize',16,'FontWeight','bold');
    set(ax_trem,'Visible','off')  
    ax_twake = axes('position', [.075 .18 .2 .05]); 
    text(-.18, 0.3,{'Sleep','latency'},'rotation',90, ...
       'FontSize',16,'FontWeight','bold');
    set(ax_twake,'Visible','off')  
    
    ymax_sess = max(max([sessdur(1,1,:) sessdur(2,1,:) ...
        sessdur(1,2,:) sessdur(1,2,:)]))*1.1;
    ymax_sleep  = max(max([sesssleep(1,1,:) sesssleep(2,1,:) ...
        sesssleep(1,2,:) sesssleep(2,2,:)]))*1.1;
    ymax_lat = max(max([sleeplat(1,1,:) sleeplat(2,1,:) ...
        sleeplat(1,2,:) sleeplat(2,2,:)]))*1.1;
    for isess=1:2 
        sesscat=[]; sleepcat=[]; latcat=[];
        for iexp=1:length(expe)
            sesscat = [sesscat squeeze(squeeze(sessdur(iexp,isess,:)))];
            sleepcat = [sleepcat squeeze(squeeze(sesssleep(iexp,isess,:)))];
            latcat = [latcat squeeze(squeeze(sleeplat(iexp,isess,:)))];
        end      
        axes(ax_nrem{isess})
           [p,h,her] = PlotErrorBarN_SL(sesscat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_sess])
            set(gca,'xticklabel',{[]})
            title(tit_sess{isess})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
            
        axes(ax_rem{isess})
           [p,h,her] = PlotErrorBarN_SL(sleepcat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_sleep])
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
            
        axes(ax_wake{isess})
           [p,h,her] = PlotErrorBarN_SL(latcat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',1, ...
                    'optiontest','ttest','paired',0,'ShowSigstar',sig);
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            ylim([0 ymax_lat])
            set(gca,'xticklabel',{[]})    
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);         
            makepretty_erc('fsizel',12,'lwidth',1.5,'fsizet',16)
    end
    % add legend with N
    basepos=.2;
    interpos=(1-.2*2)/length(expe); 
    pos=basepos;
    for iexp=1:length(expe)
        annotation('textbox','Position',[pos .017 .04 .04 ], ...
            'String',[' ' expname{iexp} ' - N=' num2str(numsuj(iexp))], ...
            'FitBoxToText','on', ...
            'BackgroundColor',clr{iexp},'FaceAlpha',.5)
        pos=pos+interpos;
    end    
    
supertit = ['Sleep (w/out wake) - Changes in Percentage Post-Pre'];
figH.diff = figure('Color',[1 1 1], 'rend','painters','pos',[1 1 1200 800],'Name', supertit, 'NumberTitle','off');
    % axes position
    ax_nremdiff = axes('position', [.1 .6 .32 .35]);
    ax_remdiff = axes('position', [.65 .6 .32 .35]);
    ax_n1diff = axes('position', [.1 .1 .25 .35]);
    ax_n2diff = axes('position', [.4 .1 .25 .35]);
    ax_n3diff = axes('position', [.7 .1 .25 .35]); 

    nremcat=[]; remcat=[]; n1cat=[]; n2cat=[]; n3cat=[];
    for iexp=1:length(expe)
        nremcat = [nremcat squeeze(squeeze(nremdiff_per_now(iexp,:)'))];
        remcat = [remcat squeeze(squeeze(remdiff_per_now(iexp,:)'))];
        n1cat = [n1cat squeeze(squeeze(n1diff_per_now(iexp,:)'))];
        n2cat = [n2cat squeeze(squeeze(n2diff_per_now(iexp,:)'))];
        n3cat = [n3cat squeeze(squeeze(n3diff_per_now(iexp,:)'))];
    end
    
    axes(ax_nremdiff)
        [p,h,her] = PlotErrorBarN_SL(nremcat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',0,'ShowSigstar',sig); 
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            title('NREM')
%             ylim([0 ymax_sleep])
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            ylabel('change in %')
            makepretty_erc
            
    axes(ax_remdiff)
        [p,h,her] = PlotErrorBarN_SL(remcat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',0,'ShowSigstar',sig); 
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            title('REM')
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc
                
    axes(ax_n1diff)
        [p,h,her] = PlotErrorBarN_SL(n1cat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',0,'ShowSigstar',sig); 
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            title('N1')
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            ylabel('change in %')
            makepretty_erc
                
    axes(ax_n2diff)
        [p,h,her] = PlotErrorBarN_SL(n2cat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',0,'ShowSigstar',sig); 
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            title('N2')
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc
            
    axes(ax_n3diff)
        [p,h,her] = PlotErrorBarN_SL(n3cat,...
                    'barwidth', 0.6, 'newfig', 0,'barcolors',[.3 .3 .3],'showPoints',0,'ShowSigstar',sig); 
            h.FaceColor = 'flat';
            h.FaceAlpha = .5;
            for ico=1:length(h.CData)
                h.CData(ico,:) = clr{ico};
            end
            title('N3')
            set(gca,'xticklabel',{[]})
            set(h, 'LineWidth', 1);
            set(her, 'LineWidth', 1);
            makepretty_erc  
            
     % add legend with N
    basepos=.2;
    interpos=(1-.2*2)/length(expe); 
    pos=basepos;
    for iexp=1:length(expe)
        annotation('textbox','Position',[pos .517 .04 .04 ], ...
            'String',[' ' expname{iexp} ' - N=' num2str(numsuj(iexp,1))], ...
            'FitBoxToText','on', ...
            'BackgroundColor',clr{iexp},'FaceAlpha',.5)
        annotation('textbox','Position',[pos .017 .04 .04 ], ...
            'String',[' ' expname{iexp} ' - N=' num2str(numsuj(iexp,2))], ...
            'FitBoxToText','on', ...
            'BackgroundColor',clr{iexp},'FaceAlpha',.5)
        pos=pos+interpos;
    end    
    
disp('SLEEP ARCH DONE')

