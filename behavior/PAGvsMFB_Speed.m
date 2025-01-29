function [figH] = PAGvsMFB_Speed(expe,mice_num)

%==========================================================================
% Details: compare PAG and MFB expermient in speed either toward or away
% from the stim zone for all 3 sessions (pre, cond, post)
%
% INPUTS:
%       - expe              Name of 2 experiments in PathForExperiment
%                           Format: {'StimMFBWake','UMazePAG'}
%       - mice_num          ID # of all mice for the analyses
%                           Format: cell 1 = [### ### ### ####]; cell 2 =
%                           [### ### ### ### ###]
%
% OUTPUT:
%       - figH              Global speed figure comprising 
%
% NOTES:
%
%   Written by Samuel Laventure - 2021-03
%      
%==========================================================================

%% Parameters
%nbr of trials
nt = 4;

speed = nan(2,max([length(mice_num{1}) length(mice_num{2})]),3,2);

%--------------- GET DIRECTORIES-------------------
for iexp=1:2
    Dir = PathForExperimentsERC(expe{iexp});
    Dir = RestrictPathForExperiment(Dir,'nMice', mice_num{iexp});
    %----------------Get data ------------------------
    for isuj=1:length(Dir.path)
        for inexp=1:length(Dir.path{isuj})
            load([Dir.path{isuj}{inexp} '/behavResources.mat'], 'SpeedDir');
            for isess=1:3
                for idir=1:2
                    speed(iexp,isuj,isess,idir) = squeeze(nanmean(SpeedDir.speed(isess,1:nt,idir)));
                end
            end
            % clear var
            clear SpeedDir
        end
    end
end
disp('Data ready')

%%  FIGURE
ymax = max(max(max(max(speed))));
fillnan = nan(1,max([length(mice_num{1}) length(mice_num{2})]));

dats = [speed(1,:,1,1)' speed(1,:,1,2)' fillnan' speed(2,:,1,1)' speed(2,:,1,2)' fillnan' ...
        fillnan' speed(1,:,2,1)' speed(1,:,2,2)' fillnan' speed(2,:,2,1)' speed(2,:,2,2)' fillnan' ...
        fillnan' speed(1,:,3,1)' speed(1,:,3,2)' fillnan' speed(2,:,3,1)' speed(2,:,3,2)'];


supertit = ['Speed by direction'];
figH = figure('Color',[1 1 1], 'rend','painters', ...
    'pos',[1 1 1000 600],'Name', supertit, 'NumberTitle','off');

    [p,h,her] = PlotErrorBarN_SL(dats,...
        'barcolors', [0 0 0], 'barwidth', .98, 'newfig', 0, 'colorPoints',0, ...
        'showpoints',0,'showsigstar','none');

        h.FaceColor = 'flat';
        
        clrsmfbto = [0 .5 .8];
        clrsmfbaw = [.6 .8 1];
        clrspagto = [.6 .2 0];
        clrspagaw = [.75 .5 .6];
        
        h.CData(1,:) = clrsmfbto; h.CData(2,:) = clrsmfbaw;
        h.CData(4,:) = clrspagto; h.CData(5,:) = clrspagaw;
        h.CData(8,:) = clrsmfbto; h.CData(9,:) = clrsmfbaw;
        h.CData(11,:) = clrspagto; h.CData(12,:) = clrspagaw;
        h.CData(15,:) = clrsmfbto; h.CData(16,:) = clrsmfbaw;
        h.CData(18,:) = clrspagto; h.CData(19,:) = clrspagaw;
%         
%         h.CData(1,:) = [0 0 0]; h.CData(2,:) = [1 1 1];
%         h.CData(4,:) = [0 0 0]; h.CData(5,:) = [1 1 1];
%         h.CData(8,:) = [0 0 0]; h.CData(9,:) = [1 1 1];
%         h.CData(11,:) = [0 0 0]; h.CData(12,:) = [1 1 1];
%         h.CData(15,:) = [0 0 0]; h.CData(16,:) = [1 1 1];
%         h.CData(18,:) = [0 0 0]; h.CData(19,:) = [1 1 1];
        set(gca,'xtick',[])
        set(h, 'LineWidth', 1);
        set(her, 'LineWidth', 1);
        ylabel({'Speed','cm/s'},'FontSize',14);
        ylim([0 10])%ymax])
        title([{'Speed in function of'},{'the stimulation zone'}],'FontSize',16)
        % creating legend with hidden-fake data (hugly but effective)
                b1=bar([-2],[ 1],'FaceColor','flat');
                b2=bar([-3],[ 1],'FaceColor','flat');
                b3=bar([-3],[ 1],'FaceColor','flat');
                b4=bar([-3],[ 1],'FaceColor','flat');
                b1.CData(1,:) = repmat(clrsmfbto,1);
                b2.CData(1,:) = repmat(clrsmfbaw,1);
                b3.CData(1,:) = repmat(clrspagto,1);
                b4.CData(1,:) = repmat(clrspagaw,1);
                l1=legend([b1 b2 b3 b4],{'','','Toward','Away'},'Location','EastOutside','NumColumns',2); 
                title(l1,'MFB          PAG           .')
        % text x axis
        % texts position
        ax_gr = axes('position', [.135 .075 .6 .05]); 
        text(0, 0.3,'MFB          PAG              MFB          PAG               MFB          PAG', ...
            'FontSize',14);
        set(ax_gr,'Visible','off')  
        ax_sess = axes('position', [.13 .035 .6 .05]); 
        text(0, 0.3,'        PRE                          COND                         POST ', ...
            'FontSize',14,'FontWeight','bold');
        set(ax_sess,'Visible','off')  
                
                
        makepretty_erc 
end



