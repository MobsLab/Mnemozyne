function figH = FigTrajOccup(Occup,a,id_Sess,mNum,varargin)
%
%   INPUT
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
    % Trajectories, barplot (stim/no-stim) per mouse
    lbls = {'','t1','','','t2','','',...
        't3','','','t4','','','t5','','','t6','','',...
        't7','','','t8',''};
    for it=1:nbprepost*3
        probelbls{1,it}=lbls{1,it};
    end
    
    % get x and y (for trajectories)
    for k=1:length(id_Sess{1,i})
        xdat_pre{i,k}  = a{i}.behavResources(id_Sess{1,i}(k)).AlignedXtsd;
        xdat_post{i,k} = a{i}.behavResources(id_Sess{2,i}(k)).AlignedXtsd;
        ydat_pre{i,k}  = a{i}.behavResources(id_Sess{1,i}(k)).AlignedYtsd;
        ydat_post{i,k} = a{i}.behavResources(id_Sess{2,i}(k)).AlignedYtsd;
    end
    for k=1:length(id_Sess{3,i})
        xdat_cond{i,k}  = a{i}.behavResources(id_Sess{3,i}(k)).AlignedXtsd;
        ydat_cond{i,k}  = a{i}.behavResources(id_Sess{3,i}(k)).AlignedYtsd;
    end
    
    % figure
    supertit = ['Mouse ' num2str(mNum(i))  ' - Trajectories'];
    figH{i} = figure('Color',[1 1 1], 'rend','painters', ...
        'pos',[1 1 2000 1200],'Name', supertit, 'NumberTitle','off');
        % Trajectories
        subplot(3,3,1) 
            for k=1:nbprepost    
                % -- trajectories    
                p1(k) = plot(Data(xdat_pre{i,k}),...
                    Data(ydat_pre{i,k}),...
                         'linewidth',.5);  
                hold on
                tempX = Data(xdat_pre{i,k});
                tempY = Data(ydat_pre{i,k});
                plot(tempX(a{i}.behavResources(id_Sess{1,i}(k)).PosMat(:,4)==1), ...
                     tempY(a{i}.behavResources(id_Sess{1,i}(k)).PosMat(:,4)==1),...
                     'p','Color','k','MarkerFaceColor','g','MarkerSize',16);
                clear tempX tempY
            end
            axis off
            xlim([-0.05 1.05])    
            ylim([-0.05 1.05])
            title('Pre-tests')
            % constructing the u maze
            f_draw_umaze
            %legend
            axP = get(gca,'Position');
            lg = legend(p1([1:nbprepost]),sprintfc('%d',1:nbprepost),'Location','WestOutside');
            title(lg,'Trial #')
            set(gca, 'Position', axP)

        subplot(3,3,2) 
            for k=1:nbcond  
                % -- trajectories    
                p2(k) = plot(Data(xdat_cond{i,k}),...
                             Data(ydat_cond{i,k}),...
                             'linewidth',.5);  
                hold on
                tempX = Data(xdat_cond{i,k});
                tempY = Data(ydat_cond{i,k});
                plot(tempX(a{i}.behavResources(id_Sess{3,i}(k)).PosMat(:,4)==1), ...
                     tempY(a{i}.behavResources(id_Sess{3,i}(k)).PosMat(:,4)==1),...
                     'p','Color','k','MarkerFaceColor','g','MarkerSize',16);
                clear tempX tempY
            end
            axis off
            xlim([-0.05 1.05])    
            ylim([-0.05 1.05])
            title('Cond')   
            % constructing the u maze
            f_draw_umaze   

        subplot(3,3,3) 
            for k=1:nbprepost 
                % -- trajectories    
                p3(k) = plot(Data(xdat_post{i,k}),...
                             Data(ydat_post{i,k}),...
                             'linewidth',.5);  
                hold on
                tempX = Data(xdat_post{i,k});
                tempY = Data(ydat_post{i,k});
                plot(tempX(a{i}.behavResources(id_Sess{2,i}(k)).PosMat(:,4)==1), ...
                     tempY(a{i}.behavResources(id_Sess{2,i}(k)).PosMat(:,4)==1),...
                     'p','Color','k','MarkerFaceColor','g','MarkerSize',16);
                clear tempX tempY
            end
            axis off
            xlim([-0.05 1.05])    
            ylim([-0.05 1.05])
            title('Post-tests')   
            % constructing the u maze
            f_draw_umaze

    % Barplots
        subplot(3,3,4)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([squeeze(Occup(i,1,1:nbprepost,1))'*100 ...
                squeeze(Occup(i,1,1:nbprepost,2))'*100],...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
            h_occ.FaceColor = 'flat';
            h_occ.CData(2,:) = [1 1 1];
            set(gca,'Xtick',[1:2],'XtickLabel',{' Stim \newline zone ', ' No-stim \newline zone '});
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
            ylabel('% time');
            ylim([0 100])
        if cond
            subplot(3,3,5)
                [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([squeeze(Occup(i,3,1:nbcond,1))'*100 ...
                    squeeze(Occup(i,3,1:nbcond{i},2))'*100],...
                    'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
                h_occ.FaceColor = 'flat';
                h_occ.CData(2,:) = [1 1 1];
                set(gca,'Xtick',[1:2],'XtickLabel',{' Stim \newline zone ', ' No-stim \newline zone '});
                set(gca, 'FontSize', 14);
                set(gca, 'LineWidth', 1);
                set(h_occ, 'LineWidth', 1);
                set(her_occ, 'LineWidth', 1);
                line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
                ylabel('% time');
                ylim([0 100])
        end

        subplot(3,3,6)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_DB([squeeze(Occup(i,2,1:nbprepost,1))'*100 ...
                squeeze(Occup(i,2,1:nbprepost,2))'*100],...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
            h_occ.FaceColor = 'flat';
            h_occ.CData(2,:) = [1 1 1];
            set(gca,'Xtick',[1:2],'XtickLabel',{' Stim \newline zone ', ' No-stim \newline zone '});
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
            ylabel('% time');
            ylim([0 100])

        % prepare data visualization (stim, nostim for each trial in the same vector)   
        itrial=1;
        for ii=1:3:(nbprepost*3)-2
            datpre(ii) = squeeze(Occup(i,1,itrial,1));
            datpre(ii+1) = squeeze(Occup(i,1,itrial,2));
            datpre(ii+2) = nan;
            datpost(ii) = squeeze(Occup(i,2,itrial,1));
            datpost(ii+1) = squeeze(Occup(i,2,itrial,2));
            datpost(ii+2) = nan;
            itrial=itrial+1;
        end
        if cond
            itrial=1;
            for ii=1:3:nbcond*3-2
                datcond(ii) = squeeze(Occup(i,3,itrial,1));
                datcond(ii+1) = squeeze(Occup(i,3,itrial,2));
                datcond(ii+2) = nan;
                itrial=itrial+1;
            end
        end

        if fixtrial
            nbbars = 4*3;
        else
            nbbars = 8*3;
        end
        subplot(3,3,7)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpre*100,...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
            h_occ.FaceColor = 'flat';
            h_occ.CData([2:3:nbprepost*3-1],:) = repmat([1 1 1],nbprepost,1);
            set(gca,'Xtick',[1:nbbars],'XtickLabel',probelbls);
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
            ylabel('% time');
            ylim([0 100])

        if cond
            subplot(3,3,8)
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
        end

        subplot(3,3,9)
            [p_occ,h_occ, her_occ] = PlotErrorBarN_DB(datpost*100,...
                'barcolors', [0 0 0], 'barwidth', 0.6, 'newfig', 0, 'showpoints',0);
            h_occ.FaceColor = 'flat';
            h_occ.CData([2:3:nbprepost*3-1],:) = repmat([1 1 1],nbprepost,1);
            set(gca,'Xtick',[1:nbbars],'XtickLabel',probelbls);
            set(gca, 'FontSize', 14);
            set(gca, 'LineWidth', 1);
            set(h_occ, 'LineWidth', 1);
            set(her_occ, 'LineWidth', 1);
            line(xlim,[21.5 21.5],'Color','k','LineStyle','--','LineWidth',1);
            ylabel('% time');
            ylim([0 100])   
            hold on


        % Supertitle
        mtit(supertit, 'fontsize',14, 'xoff', 0, 'yoff', 0.05);


        clear datpre datpost 
        if cond
            clear datcond
        end
end