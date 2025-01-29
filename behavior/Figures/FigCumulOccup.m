function figH = FigCumulOccup(trajzone,Occup,a,id_Sess,mNum,varargin)
%
%   INPUT
%       trajzone                    cumulative occupation of the mice in
%                                   umaze zones. Cell array {imouse,isess,itrial}. 
%       Occup                       occupation by zone
%       a                           cell array conainting behavResources for 
%                                   each animal in the anlaysis
%       id_Sess                     cell array with indexes of sessions for
%                                   each mouse
%                                   format -> {mouse1,sess1; 
%                                              mouse2,sess2;
%                                              etc...}
%       mNum                        mice id #
%                                   format -> [mouse1,mouse2,mouse#] in
%                                   integer 
%
%   OPTIONAL (VARARGIN)
%       cond                        conditionning session (1/0)
%                                   default -> 1 
%
%   OUTPUT
%       figH                        figure handle                                   
%
% Coded by Samuel Laventure, MOBS team, Paris, France
% 21/05/2021
% github.com/samlaventure

% Default values
cond=1;
warning('off','all')

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
    nbprepost = length(id_Sess{1,i});
    nbcond = length(id_Sess{3,1});
    % Labels 
    lbls = {'','t1','','','t2','','',...
        't3','','','t4','','','t5','','','t6','','',...
        't7','','','t8',''};
    for it=1:nbprepost*3
    probelbls{1,it}=lbls{1,it};
    end
    for it=1:nbcond{i}*3
    condlbls{1,it}=lbls{1,it};
    end

    % figure    
    supertit = ['Mouse ' num2str(mNum(i))  ' - trial dynamics'];
    figH{i} = figure('Color',[1 1 1], 'rend','painters', ...
        'pos',[10 10 2000 1400],'Name', supertit, 'NumberTitle','off');
        % prepare data visualization (stim, nostim for each trial in the same vector)   
        itrial=1;
        for ii=1:3:(nbprepost*3)-2
            datpre(ii) = squeeze(Occup.data(i,1,itrial,1));
            datpre(ii+1) = squeeze(Occup.data(i,1,itrial,2));
            datpre(ii+2) = nan;
            datpost(ii) = squeeze(Occup.data(i,2,itrial,1));
            datpost(ii+1) = squeeze(Occup.data(i,2,itrial,2));
            datpost(ii+2) = nan;
            itrial=itrial+1;
        end
        itrial=1;
        for ii=1:3:(nbcond{i}*3)-2
            datcond(ii) = squeeze(Occup.data(i,3,itrial,1));
            datcond(ii+1) = squeeze(Occup.data(i,3,itrial,2));
            datcond(ii+2) = nan;
            itrial=itrial+1;
        end

        % occupancy bar plot
            subplot(5,12,1:4)
                [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpre*100,...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
                h_occ.FaceColor = 'flat';
                h_occ.CData([2:3:nbprepost*3-1],:) = repmat([1 1 1],nbprepost,1);
                set(gca,'Xtick',[1:24],'XtickLabel',probelbls);
                set(gca, 'FontSize', 14);
                set(gca, 'LineWidth', 1);
                set(h_occ, 'LineWidth', 1);
                set(her_occ, 'LineWidth', 1);
                line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
                ylabel('% time');
                ylim([0 100])
                title('Pre-tests')

            subplot(5,12,5:8)          
                [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datcond*100,...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
                h_occ.FaceColor = 'flat';
                h_occ.CData([2:3:nbcond{i}*3-1],:) = repmat([1 1 1],nbcond{i},1);
                set(gca,'Xtick',[1:24],'XtickLabel',condlbls);
                set(gca, 'FontSize', 14);
                set(gca, 'LineWidth', 1);
                set(h_occ, 'LineWidth', 1);
                set(her_occ, 'LineWidth', 1);
                line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
                ylabel('% time');
                ylim([0 100])
                title('Cond')

            subplot(5,12,9:12)     
                [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpost*100,...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
                h_occ.FaceColor = 'flat';
                h_occ.CData([2:3:nbprepost*3-1],:) = repmat([1 1 1],nbprepost,1);
                set(gca,'Xtick',[1:24],'XtickLabel',probelbls);
                set(gca, 'FontSize', 14);
                set(gca, 'LineWidth', 1);
                set(h_occ, 'LineWidth', 1);
                set(her_occ, 'LineWidth', 1);
                line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
                ylabel('% time');
                ylim([0 100])   
                title('Post-tests')

        % ------------------------
        %     Cumul occupancy
        % ------------------------
        % Pre
            % get number of zones
            nzones = size(a{imouse}.behavResources(id_Sess{1,i}(1)).ZoneIndices,2)-2;
            it=1;
            for itrial=1:8/nbprepost:4
                subplot(5,12,itrial+12:itrial+12+(8/nbprepost)-1)   
                    area(trajzone{i,1,it}*100)
                    ylim([0 100])
                    xlim([1 size(trajzone{i,1,it},1)])
                    title(['Pre #' num2str(it)])
            % create legend
                    if it==1
                        xlabel('time')
                        ylabel('% of occupancy')
                        axP = get(gca,'Position');
                        if nzones == 7 
                            legend({'Stim','Stim-Near','Stim-Far',...
                                'Center','NoStim-Far','NoStim-Near','NoStim'},'Location','WestOutside')
                        elseif nzones == 5
                            legend({'Stim','Stim-Far',...
                                'Center','NoStim-Far','NoStim'},'Location','WestOutside')  
                        end
                        set(gca, 'Position', axP)
                    end
                subplot(5,12,itrial+24:itrial+24+(8/nbprepost)-1) 
                    area(trajzone{i,1,it+nbprepost/2}*100)
                    ylim([0 100])
                    xlim([1 size(trajzone{i,1,it+nbprepost/2},1)])
                    title(['Pre #' num2str(it+nbprepost/2)])
                    if it==1
                        xlabel('time')
                        ylabel('% of occupancy')
                    end 
                it=it+1;   
            end
        % Cond
            it=1;
            for itrial=1:8/nbcond{i}:4   %allow for cond with 4 and 8 trials
                subplot(5,12,itrial+16:itrial+16+(8/nbcond{i})-1)
                    area(trajzone{i,3,it}*100)
                    ylim([0 100])
                    xlim([1 size(trajzone{i,3,it},1)])
                    title(['Cond #' num2str(it)])

                subplot(5,12,itrial+28:itrial+28+(8/nbcond{i})-1)   
                    area(trajzone{i,3,it+nbcond{i}/2}*100)
                    ylim([0 100])
                    xlim([1 size(trajzone{i,3,it+nbcond{i}/2},1)])
                    title(['Cond #' num2str(it+nbcond{i}/2)])
                it=it+1;   
            end
        % post 
            it=1; 
            for itrial=1:8/nbprepost:4
                subplot(5,12,itrial+20:itrial+20+(8/nbprepost)-1)   
                    area(trajzone{i,2,it}*100)
                    ylim([0 100])
                    xlim([1 size(trajzone{i,2,it},1)])
                    title(['Post #' num2str(it)])

                subplot(5,12,itrial+32:itrial+32+(8/nbprepost)-1) 
                    area(trajzone{i,2,it+nbprepost/2}*100)
                    ylim([0 100])
                    xlim([1 size(trajzone{i,2,it+nbprepost/2},1)])
                    title(['Post #' num2str(it+nbprepost/2)])
                it=it+1;   
            end
        % ------------------------
        % Distance to reward zone
        % -------------------------
        % Pre
            it=1;
            for itrial=1:8/nbprepost:4
                subplot(5,12,itrial+36:itrial+36+(8/nbprepost)-1)    
                    p = plot(Data(a{i}.behavResources(id_Sess{1,i}(it)).LinearDist), 'Color','k');
                    hold on
                    f_draw_zones(Data(a{i}.behavResources(id_Sess{1,i}(it)).LinearDist),nzones)
                    uistack(p,'top')
                    xlim([1 length(Data(a{i}.behavResources(id_Sess{1,i}(it)).LinearDist))])
                    title(['Pre #' num2str(it)])
                    if itrial==1
                        if nzones == 7
                            set(gca,'Ytick',[0 .1 .28 .4 .5 .6 .72 .9 1],'YtickLabel',{'','Stim','Stim-Near',...
                                'Stim-Far','Center','NoStim-Far','NoStim-Near','NoStim',''});
                        elseif nzones == 5
                            set(gca,'Ytick',[0 .1 .3 .5 .7 .9 1],'YtickLabel',{'','Stim',...
                                'Stim-Far','Center','NoStim-Far','NoStim',''});
                        end

                        xlabel('Time')
                    else
                        set(gca,'YTickLabel',[]);
                    end

                subplot(5,12,itrial+48:itrial+48+(8/nbprepost)-1)
                    p=plot(Data(a{i}.behavResources(id_Sess{1,i}(it+nbprepost/2)).LinearDist),'Color','k');
                    hold on
                    f_draw_zones(Data(a{i}.behavResources(id_Sess{1,i}(it+nbprepost/2)).LinearDist),nzones)
                    uistack(p,'top')
                    xlim([1 length(Data(a{i}.behavResources(id_Sess{1,i}(it+nbprepost/2)).LinearDist))])
                    title(['Pre #' num2str(it+nbprepost/2)])
                    if it==1
                        if nzones == 7
                            set(gca,'Ytick',[0 .1 .28 .4 .5 .6 .72 .9 1],'YtickLabel',{'','Stim','Stim-Near',...
                                'Stim-Far','Center','NoStim-Far','NoStim-Near','NoStim',''});
                        elseif nzones == 5
                            set(gca,'Ytick',[0 .1 .3 .5 .7 .9 1],'YtickLabel',{'','Stim',...
                                'Stim-Far','Center','NoStim-Far','NoStim',''});
                        end  
                        xlabel('Time')
                    else
                        set(gca,'YTickLabel',[]);
                    end
                it=it+1;   
            end
            it=1;
        % Cond
            for itrial=1:8/nbcond{i}:4 
                subplot(5,12,itrial+40:itrial+40+(8/nbcond{i})-1) 
                    p=plot(Data(a{i}.behavResources(id_Sess{3,i}(it)).LinearDist),'Color','k');
                    hold on
                    f_draw_zones(Data(a{i}.behavResources(id_Sess{3,i}(it)).LinearDist),nzones)
                    uistack(p,'top')
                    xlim([1 length(Data(a{i}.behavResources(id_Sess{3,i}(it)).LinearDist))])
                    title(['Cond #' num2str(it)])
                    set(gca,'YTickLabel',[]);

                subplot(5,12,itrial+52:itrial+52+(8/nbcond{i})-1)  
                    p=plot(Data(a{i}.behavResources(id_Sess{3,i}(it+nbcond{i}/2)).LinearDist),'Color','k');
                    hold on
                    f_draw_zones(Data(a{i}.behavResources(id_Sess{3,i}(it+nbcond{i}/2)).LinearDist),nzones)
                    uistack(p,'top')
                    xlim([1 length(Data(a{i}.behavResources(id_Sess{3,i}(it+nbcond{i}/2)).LinearDist))])
                    title(['Cond #' num2str(it+nbcond{i}/2)])
                    set(gca,'YTickLabel',[]);
                it=it+1;   
            end
        % Post
            it=1;
            for itrial=1:8/nbprepost:4
                subplot(5,12,itrial+44:itrial+44+(8/nbprepost)-1)  
                    p=plot(Data(a{i}.behavResources(id_Sess{2,i}(it)).LinearDist),'Color','k');
                    hold on
                    f_draw_zones(Data(a{i}.behavResources(id_Sess{2,i}(it)).LinearDist),nzones)
                    uistack(p,'top')
                    xlim([1 length(Data(a{i}.behavResources(id_Sess{2,i}(it)).LinearDist))])
                    title(['Post #' num2str(it)])
                    set(gca,'YTickLabel',[]);

                subplot(5,12,itrial+56:itrial+56+(8/nbprepost)-1) 
                    p =plot(Data(a{i}.behavResources(id_Sess{2,i}(it+nbprepost/2)).LinearDist),'Color','k');
                    hold on
                    f_draw_zones(Data(a{i}.behavResources(id_Sess{2,i}(it+nbprepost/2)).LinearDist),nzones)
                    uistack(p,'top')
                    xlim([1 length(Data(a{i}.behavResources(id_Sess{2,i}(it+nbprepost/2)).LinearDist))])
                    title(['Post #' num2str(it+nbprepost/2)])
                    set(gca,'YTickLabel',[]);
                it=it+1;   

            end
              % Supertitle
            mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.05);
end